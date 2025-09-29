-- STEP 1: Join orders, order items, and users to build a complete dataset
WITH step1_joined_data AS (
    SELECT
    oi.order_id,
    o.user_id,
    ROUND(oi.sale_price, 2) AS sale_price,  -- clean up decimals
    o.created_at,                           -- order date for lifespan calculation
    u.state,                                -- segmentation variable (dimension)
    u.country,                              -- filter condition
    u.age                                   -- (future segmentation option)
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON o.user_id = u.id
  WHERE
    o.status = 'Complete' AND -- only include completed orders
    country = 'United States' -- focus on USA customers
),

-- STEP 2: Aggregate to user level (per customer metrics)
step2_user_level AS (
  SELECT
    user_id,
    state,
    COUNT(DISTINCT order_id) AS user_order_count, -- total orders by customer
    SUM(sale_price) AS user_revenue,              -- total revenue from customer
    MIN(created_at) AS first_order,               -- start of relationship
    MAX(created_at) AS last_order,                -- most recent order
  FROM step1_joined_data
  GROUP BY user_id, state
),

-- STEP 3: Derive lifespan (tenure of each customer)
step3_clv_components_p1 AS (
  SELECT
    user_id,
    state,
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
    state,
    user_revenue,
    user_order_count,
    user_customer_lifespan,
    user_revenue / user_order_count AS user_aov,    -- avg order value
    user_order_count / GREATEST(user_customer_lifespan,1) AS user_purchase_frequency
    -- orders per month (guard against div/0 with GREATEST)
  FROM step3_clv_components_p1
),

-- STEP 5: Calculate CLV per user
step5_user_clv AS (
  SELECT
    user_id,
    state,
    user_revenue,
    user_order_count,
    user_customer_lifespan,
    user_aov,
    user_purchase_frequency,
    user_aov * user_purchase_frequency * user_customer_lifespan AS user_clv
    -- textbook simplified CLV formula:
    -- CLV = AOV × Frequency × Lifespan
  FROM step4_clv_components_p2
  WHERE state IS NOT NULL
)

-- Final aggregation: roll user-level CLV up to state segments
SELECT
  state,
  COUNT(user_id) AS total_customer,
  -- how many customers in segment
  ROUND(SUM(user_revenue) / SUM(user_order_count),2) AS state_aov,
  -- overall segment AOV (revenue ÷ orders)
  ROUND(AVG(user_revenue),2) AS avg_revenue_per_customer,
  -- how much each customer generates on average
  ROUND(SUM(user_order_count) / COUNT(user_id), 2) AS avg_orders_per_customer,
  -- typical number of orders per customer
  ROUND(SUM(user_revenue),2) AS state_revenue,
  -- total revenue by state
  ROUND(SUM(user_clv),1) AS total_state_clv,
  -- total segment CLV (sum of individuals)
  ROUND(AVG(user_revenue),2) AS avg_state_revenue,
  -- sanity check: mean revenue per customer
  ROUND(AVG(user_clv),1) AS avg_state_clv
  -- mean CLV per customer in this state group
FROM step5_user_clv
GROUP BY state
ORDER BY total_state_clv DESC
