# Task 1: Average Birth Weight Trends by State

## 📌 Goal
The goal of this task is to find the **average birth weight per year by state** and analyze **year-to-year trends** using SQL. This demonstrates the use of **aggregations, CTEs, and window functions** in BigQuery.

---

## 📂 Dataset
- **Source**: `bigquery-public-data.samples.natality`
- **Description**: Contains US natality records, including birth weight, state, year, plurality, and other birth-related attributes.

---

## 💻 Queries Overview

### 1. Average Birth Weight per Year by State
- Aggregates average birth weight (`AVG(weight_pounds)`) for each year and state.
- Uses **GROUP BY** to summarize data.

### 2. Year-to-Year Trends
- Calculates the **previous year’s average weight** using `LAG()` window function.
- Computes **difference** between current and previous year (`avg_wg - prv_wg`).
- Helps identify states with significant yearly changes in average birth weight.

### 3. Optional Filtering
- Queries can include filters like `state IS NOT NULL` or specific year ranges (`WHERE year BETWEEN 2000 AND 2005`) for cleaner results.

---

## 🛠 Skills Demonstrated
- **Aggregations**: `AVG()`, `COUNT()`, `SUM()`
- **Filtering**: `WHERE`
- **Window Functions**: `LAG()` for trend analysis
- **CTEs (Common Table Expressions)**: Organizing complex queries for readability
- **Subqueries**: Calculating differences without repeating window functions

---

## 📄 Files in this Folder
- `queries.sql` → SQL scripts for all queries in this task  
- `results.csv` → Exported query outputs from BigQuery  
- `README.md` → This file  

---

## 🔗 Insights
- States with the largest fluctuations in birth weight can be identified using `wg_diff`.
- This task demonstrates **data aggregation and trend analysis**, useful for real-world data analytics projects.
