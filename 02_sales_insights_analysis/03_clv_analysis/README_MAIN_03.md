# Task 3: Customer Lifetime Value (CLV) Analysis  

## 📌 Goal  
The goal of this task is to estimate **Customer Lifetime Value (CLV)** for U.S. customers in the TheLook dataset.  
CLV helps measure the **long-term revenue potential** of a customer by combining:  
- **Average Order Value (AOV)**  
- **Purchase Frequency (F)**  
- **Customer Lifespan (L)**  

This demonstrates the use of **multi-step CTE pipelines, metric derivation, and segmentation** in BigQuery.  

---

## 📂 Dataset  
- **Source**:  
  - `bigquery-public-data.thelook_ecommerce.orders`  
  - `bigquery-public-data.thelook_ecommerce.order_items`  
  - `bigquery-public-data.thelook_ecommerce.users`  
- **Description**: Transactions and user data were joined to compute **user-level purchase behavior**. Analysis is restricted to **United States customers** with **completed orders**.  

---

## 💻 Queries Overview  

### 1. Data Preparation  
- Joined **orders**, **order items**, and **users**.  
- Filtered for **completed orders** in the **United States**.  

### 2. User-Level Metrics  
- Per user, calculated:  
  - **Revenue** (`SUM(sale_price)`)  
  - **Orders** (`COUNT(DISTINCT order_id)`)  
  - **First & last purchase dates** → lifespan  

### 3. CLV Components  
- **Customer Lifespan (L):** Time between first and last order (in months).  
- **Average Order Value (AOV):** `revenue / orders`.  
- **Purchase Frequency (F):** `orders / lifespan`.  

### 4. Customer Lifetime Value (CLV)  
- Formula applied:  `CLV = AOV × Purchase Frequency × Lifespan`

### 5. Segmentation  
CLV was analyzed across three customer dimensions:  
1. **Gender** (Male, Female, Unknown)  
2. **State** (U.S. states)  
3. **Age Groups** (<25, 25–34, 35–44, 45+)  

---

## 🛠 Skills Demonstrated  
- **CTEs (Common Table Expressions):** Breaking analysis into sequential steps.  
- **Metric Engineering:** Deriving AOV, frequency, and lifespan from raw data.  
- **Segmentation:** Comparing CLV across demographics and geography.  
- **Aggregation & Grouping:** Using `SUM()`, `AVG()`, and ratios for insights.  

---

## 📄 Files in this Folder  
- `3.1_gender_clv.sql` → CLV by gender  
- `3.2_state_clv.sql` → CLV by state  
- `3.3_agegroup_clv.sql` → CLV by age group  
- `results/` → Exported query outputs  
- `README.md` → This file  

---

## 🔗 Insights  
- **Average CLV per customer** is modest, showing customers typically have short active lifespans.  
- **Gender:** Female and male customers show similar AOVs, but CLV varies due to differences in purchase frequency.  
- **State:** Revenue is concentrated in high-population states, but smaller states sometimes show higher **CLV per customer**, indicating stronger loyalty.  
- **Age:** Middle-aged customers (25–44) show the **highest CLV**, while under-25 and over-55 groups are less valuable.  

