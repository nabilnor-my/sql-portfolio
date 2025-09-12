WITH monthly_revenue AS (
  SELECT
    FORMAT_DATE('%Y-%m', created_at) AS year_month,
    ROUND(SUM(sale_price),2) AS total_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  GROUP BY year_month
),
monthly_revenue_with_lag AS (
  SELECT
    year_month,
    total_revenue,
    LAG(total_revenue,1) OVER (ORDER BY year_month ASC) AS revenue_lag_1m
  FROM monthly_revenue
)
SELECT
  year_month,
  total_revenue,
  revenue_lag_1m,
  ROUND(total_revenue - revenue_lag_1m,2) AS rev_growth,
  COALESCE(ROUND((total_revenue - revenue_lag_1m)/revenue_lag_1m*100,2),0) AS growth_mom_pc
FROM monthly_revenue_with_lag
ORDER BY year_month ASC
