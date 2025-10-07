-- STEP 1: Create Temp Table - Join orders, order items, and users to build a complete dataset
CREATE TEMP TABLE step1_joined_data AS (
    SELECT
    oi.order_id,
    o.user_id,
    oi.sale_price,
    o.created_at,                           -- order date for lifespan calculation
    u.country,                              -- filter condition
    u.age                                   -- segmentation variable (dimension)
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON o.user_id = u.id
  WHERE
    o.status = 'Complete' AND -- only include completed orders
    country = 'United States' -- focus on USA customers
);

-- STEP 2: Aggregate to user level (per customer metrics)
CREATE TEMP TABLE age_group_clv_summary AS (
WITH step2_user_level AS (
  SELECT
    user_id,
    age,
    COUNT(DISTINCT order_id) AS user_order_count, -- total orders by customer
    SUM(sale_price) AS user_revenue,              -- total revenue from customer
    MIN(created_at) AS first_order,               -- start of relationship
    MAX(created_at) AS last_order,                -- most recent order
  FROM step1_joined_data
  GROUP BY user_id, age
),

-- STEP 3: Derive lifespan (tenure of each customer)
step3_clv_components_p1 AS (
  SELECT
    user_id,
    age,
    user_order_count,
    user_revenue,
    TIMESTAMP_DIFF(last_order, first_order, DAY)/30 AS user_customer_lifespan
    -- lifespan in months (approx); avoids noise from daily granularity
  FROM step2_user_level
),

-- STEP 4: Derive AOV and Purchase Frequency
step4_clv_components_p2 AS (
  SELECT
    user_id,
    age,
    user_revenue,
    user_order_count,
    user_customer_lifespan,
    user_revenue / user_order_count AS user_aov,    -- avg order value
    SAFE_DIVIDE(user_order_count, NULLIF(user_customer_lifespan,0)) AS user_purchase_frequency
    -- orders per month (guard against div/0 with GREATEST)
  FROM step3_clv_components_p1
),

-- STEP 5: Calculate CLV per user
step5_user_clv AS (
  SELECT
    user_id,
    age,
    user_revenue,
    user_order_count,
    user_customer_lifespan,
    user_aov,
    user_purchase_frequency,
    user_aov * user_purchase_frequency * user_customer_lifespan AS user_clv
    -- textbook simplified CLV formula:
    -- CLV = AOV × Frequency × Lifespan
  FROM step4_clv_components_p2
  WHERE age IS NOT NULL
)

-- Final aggregation: roll user-level CLV up to age group segments
SELECT
  CASE 
    WHEN age < 18 THEN "Under 18"
    WHEN age BETWEEN 18 AND 24 THEN "18 to 24"
    WHEN age BETWEEN 25 AND 34 THEN "25 to 34"
    WHEN age BETWEEN 35 AND 44 THEN "35 to 44"
    WHEN age BETWEEN 45 AND 54 THEN "45 to 54"
    WHEN age BETWEEN 55 AND 64 THEN "55 to 64"
    WHEN age > 64 THEN "Above 65"
    ELSE "NIL" 
  END AS age_group,
  COUNT(user_id) AS total_customer,
  -- how many customers in segment
  ROUND(SUM(user_revenue) / SUM(user_order_count),2) AS age_group_aov,
  -- overall segment AOV (revenue ÷ orders)
  ROUND(AVG(user_revenue),2) AS avg_revenue_per_customer,
  -- how much each customer generates on average
  ROUND(SUM(user_order_count) / COUNT(user_id), 2) AS avg_orders_per_customer,
  -- typical number of orders per customer
  ROUND(SUM(user_revenue),2) AS age_group_revenue,
  -- total revenue by age group
  ROUND(SUM(user_clv),1) AS total_age_group_clv,
  -- total segment CLV (sum of individuals)
  ROUND(AVG(user_clv),1) AS avg_age_group_clv
  -- mean CLV per customer in this age group
FROM step5_user_clv
GROUP BY age_group
ORDER BY
  CASE
    WHEN age_group = "Under 18" THEN 1
    WHEN age_group = "18 to 24" THEN 2
    WHEN age_group = "25 to 34" THEN 3
    WHEN age_group = "35 to 44" THEN 4
    WHEN age_group = "45 to 54" THEN 5
    WHEN age_group = "55 to 64" THEN 6
    WHEN age_group = "Above 65" THEN 7
    ELSE 8
  END
);

-- 🔍 Sanity check : ensure segmentation totals match overall revenue
SELECT 
  (SELECT ROUND(SUM(age_group_revenue),2) FROM age_group_clv_summary) AS total_from_segments,
  (SELECT ROUND(SUM(sale_price),2) FROM step1_joined_data) AS total_from_base,
  ROUND(( (SELECT SUM(age_group_revenue) FROM age_group_clv_summary) - 
          (SELECT SUM(sale_price) FROM step1_joined_data) ), 2) AS difference;
