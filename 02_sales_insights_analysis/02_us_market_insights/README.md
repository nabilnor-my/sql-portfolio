# Task 2: U.S. Market Insights

## 📌 Goal
The goal of this task is to analyze **state-level customer behavior** in the United States, focusing on **revenue distribution, buyer retention, and demographics**.  
This demonstrates the use of **multi-table joins, conditional aggregations, and segmentation techniques** in BigQuery.

---

## 📂 Dataset
- **Source**:  
  - `bigquery-public-data.thelook_ecommerce.orders`  
  - `bigquery-public-data.thelook_ecommerce.order_items`  
  - `bigquery-public-data.thelook_ecommerce.users`  
- **Description**: Combined orders, items, and user profile data to study revenue, order patterns, and demographic breakdowns at the U.S. state level.

---

## 💻 Queries Overview

### 1. Data Preparation
- Joined **orders**, **order items**, and **users**.  
- Filtered for **completed orders** and restricted to **United States** customers.  

### 2. State-Level Metrics
- Aggregated by `state` to calculate:
  - **Distinct users** (`COUNT(DISTINCT user_id)`)  
  - **Distinct orders** (`COUNT(DISTINCT order_id)`)  
  - **Revenue** (`SUM(sale_price)`)  

### 3. Buyer Segmentation
- Classified customers as:
  - **One-time buyers** → `order_count_per_user = 1`  
  - **Repeat buyers** → `order_count_per_user > 1`  

### 4. Demographic Breakdown
- Gender distribution via `COUNTIF(gender = 'F'/'M')`.  
- Age segmentation using conditional `COUNT(DISTINCT CASE WHEN ...)`.  

---

## 🛠 Skills Demonstrated
- **Joins**: Merging multiple tables on keys (`order_id`, `user_id`).  
- **Aggregations**: `COUNT()`, `SUM()`, `ROUND()` for performance metrics.  
- **Conditional Logic**: `CASE WHEN` inside aggregations.  
- **Segmentation**: Distinguishing one-time vs. repeat customers.  

---

## 📄 Files in this Folder
- `queries.sql` → SQL scripts for state-level analysis  
- `results.csv` → Exported query outputs from BigQuery  
- `README.md` → This file  

---

## 🔗 Insights
- **Revenue concentration**: California, Texas, and Florida contribute nearly **50% of U.S. sales**.  
- **Retention gap**: Most states are dominated by **one-time buyers**, showing opportunity for **loyalty programs**.  
- **High-value states**: New Jersey, Oregon, and Connecticut show **higher revenue per user**, indicating more affluent or engaged buyers.  
- **Stable order values**: Revenue per order is consistent across states, suggesting predictable average transaction size.  
- **Demographics**: Customers are primarily aged **25–44**, while under-18 and over-65 are underrepresented, signaling potential to grow in those age brackets.  
