# Task 1: Sales Performance Review

## 📌 Goal
The goal of this task is to analyze **monthly revenue trends** and calculate **month-over-month (MoM) growth**.  
This demonstrates the use of **aggregations, window functions, and growth rate calculations** in BigQuery.

---

## 📂 Dataset
- **Source**: `bigquery-public-data.thelook_ecommerce.order_items`
- **Description**: Contains e-commerce order data including item sale prices and timestamps, useful for analyzing sales patterns and performance over time.

---

## 💻 Queries Overview

### 1. Monthly Revenue
- Aggregates total monthly revenue (`SUM(sale_price)`).
- Uses `FORMAT_DATE('%Y-%m', created_at)` to group data by **year-month**.

### 2. Month-over-Month Comparison
- Applies `LAG()` to bring forward the previous month’s revenue.
- Computes **absolute revenue growth** (`rev - prev_rev`).
- Computes **percentage growth** (`(rev - prev_rev)/prev_rev * 100`).

### 3. Handling Edge Cases
- Applies `COALESCE()` in percentage growth calculation to avoid division by zero. 

---

## 🛠 Skills Demonstrated
- **Date Formatting**: `FORMAT_DATE` for year-month extraction
- **Aggregations**: `SUM()` for revenue
- **Window Functions**: `LAG()` for previous month comparison
- **Growth Calculations**: Absolute and percentage growth
- **Error Handling**: Preventing divide-by-zero with `NULLIF`

---

## 📄 Files in this Folder
- `queries.sql` → SQL scripts for all queries in this task  
- `results.csv` → Exported query outputs from BigQuery  
- `README.md` → This file  

---

## 🔗 Insights
- Identifies **revenue growth trends** over time.  
- Highlights **months of strong growth** and **periods of decline**.  
- Provides a foundation for further analysis such as **seasonality effects** and **business cycle performance**.
