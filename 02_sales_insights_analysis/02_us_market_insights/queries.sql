-- STEP 1: Join orders, order items, and users to build a complete dataset
WITH step1_joined_data AS (
    SELECT
    oi.order_id,
    o.user_id,
    ROUND(oi.sale_price, 2) AS sale_price,
    u.gender,
    u.state,
    u.country,
    u.age
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON o.user_id = u.id
  WHERE
    o.status = 'Complete' AND -- only include completed orders
    country = 'United States' -- focus on USA customers
),

-- STEP 2: Count distinct orders per user (used for segmentation)
step2_distinct_user_order AS (
  SELECT
    state,
    user_id,
    COUNT(DISTINCT order_id) AS order_count_per_user
  FROM step1_joined_data
  GROUP BY user_id,state
),

-- STEP 3: Aggregate metrics by state
step3_by_state AS (
  SELECT
    s1.state,
    COUNT(DISTINCT s1.user_id) AS user_count,   -- unique customers
    COUNT(DISTINCT s1.order_id) AS order_count, -- total orders
    COUNT(DISTINCT CASE WHEN order_count_per_user = 1 THEN s2.user_id END) AS one_time_buyers,
    COUNT(DISTINCT CASE WHEN order_count_per_user > 1 THEN s2.user_id END) AS repeat_buyers,
    ROUND(SUM(s1.sale_price),2) AS revenue,

    -- Gender breakdown
    COUNTIF(s1.gender = 'F') AS female_count,
    COUNTIF(s1.gender = 'M') AS male_count,
    COUNTIF(s1.gender IS NULL) AS unknown_gender,

    -- Age group segmentation
    COUNT(DISTINCT CASE WHEN s1.age < 18 THEN s1.user_id END) AS age_under_18,
    COUNT(DISTINCT CASE WHEN s1.age BETWEEN 18 AND 24 THEN s1.user_id END) AS age_18_to_24,
    COUNT(DISTINCT CASE WHEN s1.age BETWEEN 25 AND 34 THEN s1.user_id END) AS age_25_to_34,
    COUNT(DISTINCT CASE WHEN s1.age BETWEEN 35 AND 44 THEN s1.user_id END) AS age_35_to_44,
    COUNT(DISTINCT CASE WHEN s1.age BETWEEN 45 AND 54 THEN s1.user_id END) AS age_45_to_54,
    COUNT(DISTINCT CASE WHEN s1.age BETWEEN 55 AND 64 THEN s1.user_id END) AS age_55_to_64,
    COUNT(DISTINCT CASE WHEN s1.age > 64 THEN s1.user_id END) AS age_above_65,
    COUNT(DISTINCT CASE WHEN s1.age IS NULL THEN s1.user_id END) AS age_unknown
  FROM step1_joined_data AS s1
  LEFT JOIN step2_distinct_user_order AS s2
  ON 
    s1.user_id = s2.user_id AND
    s1.state = s2.state
  GROUP BY state
)

-- FINAL OUTPUT: State-level performance and demographics
SELECT
  state,
  user_count,
  order_count,
  one_time_buyers,
  repeat_buyers,
  revenue,
  ROUND(order_count / user_count,2) AS order_per_user,
  ROUND(revenue / user_count,2) AS revenue_per_user,
  ROUND(revenue / order_count,2) AS revenue_per_order,
  female_count,
  male_count,
  unknown_gender,
  age_under_18,
  age_18_to_24,
  age_25_to_34,
  age_35_to_44,
  age_45_to_54,
  age_55_to_64,
  age_above_65,
  age_unknown
FROM step3_by_state
ORDER BY revenue DESC;
