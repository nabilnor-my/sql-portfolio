WITH b_by_state AS (
  SELECT
    year,
    state,
    COUNT(*) AS no_of_b
  FROM `bigquery-public-data.samples.natality`
  WHERE state IS NOT NULL
  GROUP BY year, state
),
b_by_year AS (
  SELECT
    year,
    state,
    no_of_b,
    SUM(no_of_b) OVER (PARTITION BY year) AS b_in_yr
  FROM b_by_state
), 
birth_perc AS (
  SELECT
    year,
    state,
    no_of_b,
    b_in_yr,
    ROUND(no_of_b / b_in_yr *100,2) AS percent
  FROM b_by_year
),
state_rank AS (
  SELECT
    year,
    state,
    no_of_b,
    b_in_yr,
    percent,
    RANK() OVER (
      PARTITION BY YEAR
      ORDER BY percent DESC
    ) AS b_rank
  FROM birth_perc
)
SELECT
  year,
  b_rank,
  state,
  no_of_b,
  b_in_yr,
  percent
FROM state_rank
WHERE b_rank <= 3
ORDER BY year ASC, b_rank ASC;
