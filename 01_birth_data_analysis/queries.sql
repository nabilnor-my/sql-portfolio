WITH wg_by_yr AS (
  SELECT
    year, 
    state, 
    AVG(weight_pounds) AS avg_wg 
  FROM bigquery-public-data.samples.natality
  WHERE state IS NOT NULL
  GROUP BY year, state
)
SELECT
  year,
  state,
  avg_wg,
  avg_wg - prv_wg AS wg_diff 
FROM (
  SELECT
    *,
    LAG(avg_wg) OVER (
      PARTITION BY state 
      ORDER BY year ASC
    ) AS prv_wg
  FROM wg_by_yr
)
ORDER BY state, year ASC;
