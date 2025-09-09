# Task 2: Top States & Ranking

## 📌 Goal
The goal of this task is to identify the **top contributing states per year** based on the number of births.  
This demonstrates the use of **aggregations, window functions, ranking, and percentage calculations** in SQL.

---

## 📂 Dataset
- **Source**: `bigquery-public-data.samples.natality`  
- **Description**: Contains US natality records including birth weight, state, year, plurality, and other birth-related attributes.

---

## 💻 Queries Overview

### 1. Count births per state per year
- `COUNT(*)` with `GROUP BY year, state` to calculate total births per state.

### 2. Calculate total births per year
- `SUM(no_of_b) OVER (PARTITION BY year)` computes yearly totals for percentage calculation.

### 3. Calculate percentage contribution
- `no_of_b / b_in_yr * 100` to find each state’s share of total births in a year.  
- `ROUND(..., 2)` for clean output.

### 4. Rank states per year
- `RANK() OVER (PARTITION BY year ORDER BY percent DESC)` assigns ranks.  
- Filter `b_rank <= 3` to get **top 3 states** per year.

---

## 🛠 Skills Demonstrated
- **Aggregations**: `COUNT()`, `SUM()`  
- **Window Functions**: `SUM() OVER` for yearly totals, `RANK() OVER` for ranking  
- **Percentage calculations and rounding**  
- **CTEs (Common Table Expressions)** for stepwise query structure  
- **Filtering top results** using `WHERE b_rank <= 3`

---

## 📄 Files in this Folder
- `queries.sql` → SQL scripts for this project  
- `results.csv` → Exported results showing top 3 states per year  
- `README.md` → This file

---

## 🔗 Insights
- Easily identifies states contributing the most births each year.  
- Shows trends in birth distribution across states over time.  
- Demonstrates practical usage of window functions and ranking for reporting and analytics.
