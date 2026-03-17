# 🏭 Supply Chain Performance Analysis
### Beauty & Personal Care Industry | End-to-End Data Analytics Project

[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://python.org)
[![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat&logo=mysql&logoColor=white)](#)
[![Power BI](https://img.shields.io/badge/PowerBI-F2C811?style=flat&logo=powerbi&logoColor=black)](#)
[![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat&logo=pandas&logoColor=white)](https://pandas.pydata.org)

---

## 📌 Problem Statement 

A Beauty & Personal Care company operates its supply chain across **5 major Indian cities** (Mumbai, Delhi, Kolkata, Bangalore, Chennai) with **5 suppliers** managing **100 SKUs** across Haircare, Skincare, and Cosmetics categories.

**Business Challenge:** The company is facing rising defect rates, inconsistent supplier lead times, and unclear cost drivers — making it difficult to take data-driven procurement and logistics decisions.

**Goal:** Conduct a full supply chain performance audit to identify bottlenecks, rank supplier risk, and recommend actionable improvements.

---

## 🎯 Objectives

1. Analyze **product-level revenue, pricing, and defect performance**
2. Evaluate **supplier reliability** using lead time, defect rate & cost KPIs
3. Compare **shipping carriers and transport modes** for cost-efficiency
4. Identify **inspection failures** and their business impact
5. Build a **rule-based Supplier Risk Scorecard**
6. Deliver **quantified business recommendations**

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|------|-------|
| **Python** (Pandas, NumPy) | Data cleaning, EDA, statistical analysis |
| **Matplotlib & Seaborn** | Data visualizations (8+ charts) |
| **SQL** (MySQL/PostgreSQL) | Advanced queries — CTEs, Window Functions, Aggregations |
| **Power BI** | Executive KPI dashboard with DAX measures |
| **Jupyter Notebook** | End-to-end analysis notebook |

---

##  Project Structure

```
Supply-Chain-Performance-Analysis/
│
├── 📓 supply_chain_analysis.ipynb   ← Full Python EDA & Analysis
├── 🗄️  supply_chain_queries.sql      ← 16 Advanced SQL Queries
├── 📊 README.md                     ← Project documentation
│
├── data/
│   └── supply_chain_data.csv        ← Dataset (100 SKUs, 24 features)
│
└── dashboard/
    ├── product_performance.png
    ├── supplier_performance.png
    ├── shipping_analysis.png
    ├── quality_analysis.png
    ├── defect_heatmap.png
    ├── location_analysis.png
    ├── risk_scorecard.png
    └── correlation_matrix.png
```

---

## 📊 Dataset Overview

| Attribute | Details |
|-----------|---------|
| **Records** | 100 SKUs |
| **Features** | 24 columns |
| **Cities** | Mumbai, Delhi, Kolkata, Bangalore, Chennai |
| **Suppliers** | 5 (Supplier 1–5) |
| **Product Categories** | Haircare, Skincare, Cosmetics |
| **Transport Modes** | Road, Air, Rail, Sea |
| **Carriers** | Carrier A, B, C |
| **Null Values** | None — clean dataset |

---

## 🔍 Analysis Performed

### 1. Product Performance Analysis
- Revenue share by product type
- Units sold and average pricing comparison
- Defect rate benchmarking across categories

### 2. Supplier Performance Deep Dive
- KPI comparison: Lead time, defect rate, manufacturing cost
- Inspection pass/fail/pending rates per supplier
- Supplier ranking using window functions (RANK)

### 3. Shipping & Transportation Analysis
- Carrier efficiency: cost vs. delivery time
- Transport mode comparison: Air vs Road vs Rail vs Sea
- Route distribution and cost-per-day efficiency ratio

### 4. Quality Inspection Analysis
- Overall inspection result distribution
- Defect rate distribution (histogram + boxplot)
- Supplier × Product defect heatmap

### 5. Inventory & Location Analysis
- City-wise revenue and order volume
- Lead time vs defect rate scatter by city
- Low stock alerts with critical/low/adequate classification

### 6. Supplier Risk Scorecard
- Rule-based scoring: Defect Rate + Lead Time + Mfg Cost + Fail Rate
- Risk categories: 🟢 Low | 🟡 Medium | 🔴 High
- Built without ML — pure business logic

### 7. Correlation Analysis
- Full correlation matrix of 15 numerical KPIs
- Notable correlations identified for business insights

---

## 📈 Key Findings

| Area | Finding |
|------|---------|
| **Top Product** | Skincare leads revenue at **₹2,41,628 (41.7% share)** |
| **Quality Gap** | **36% of SKUs failed inspection** — significant concern |
| **Pending Backlog** | 41% SKUs still pending clearance — supply chain risk |
| **Best Supplier** | Supplier 1: highest revenue (₹1,57,529) + lowest defect rate (1.80%) |
| **High Risk Supplier** | Supplier 3: lead time 20.1 days + elevated defect rate |
| **Transport Gap** | Air shipping costs 34% more than Sea transport |
| **Top City** | Mumbai & Kolkata tied at ~₹1,37,000 revenue each |

---

## 💼 Business Impact & Recommendations

| # | Finding | Recommendation | Potential Impact |
|---|---------|---------------|-----------------|
| 1 | 36% inspection failure rate | Implement pre-shipment quality gates at supplier end | Reduce fail rate from 36% → <15% in 2 quarters |
| 2 | Supplier 3: 20.1-day lead time | Issue performance improvement notice; monthly review | Saving ~₹15K/month in holding costs |
| 3 | Air transport 34% costlier than Sea | Shift non-urgent SKUs from Air to Sea/Rail | Estimated ₹4,200/month savings |
| 4 | Supplier 4 mfg cost ₹62.71 vs avg ₹46 | Renegotiate contracts or reallocate SKUs | ₹441+ saved per production cycle |
| 5 | Skincare = 41.7% revenue share | Increase production allocation for skincare | 10% volume boost = ~₹24,000 additional revenue |

---

## 🗄️ SQL Highlights (16 Queries)

```sql
-- Supplier Risk Scorecard using Advanced CTE + PERCENTILE_CONT
WITH supplier_metrics AS (
    SELECT supplier_name,
           ROUND(AVG(defect_rates), 2)         AS avg_defect,
           ROUND(AVG(lead_time), 1)             AS avg_lead_time,
           ROUND(AVG(manufacturing_costs), 2)  AS avg_mfg_cost
    FROM supply_chain_data
    GROUP BY supplier_name
),
risk_scored AS (
    SELECT *,
        CASE WHEN avg_defect > 2.3 THEN 2 ELSE 0 END +
        CASE WHEN avg_lead_time > 17 THEN 2 ELSE 0 END +
        CASE WHEN avg_mfg_cost > 44 THEN 1 ELSE 0 END AS risk_score
    FROM supplier_metrics
)
SELECT *, 
    CASE WHEN risk_score <= 1 THEN '🟢 Low Risk'
         WHEN risk_score <= 3 THEN '🟡 Medium Risk'
         ELSE '🔴 High Risk' END AS risk_category
FROM risk_scored ORDER BY risk_score DESC;
```

**SQL Techniques Used:** CTEs, Window Functions (RANK, NTILE, Running Totals), CASE Statements, Subqueries, PERCENTILE_CONT, Aggregations, HAVING

---

## 🚀 How to Run

```bash
# 1. Clone the repository
git clone https://github.com/rushi2372/Supply-Chain-Performance-Analysis.git

# 2. Navigate to project folder
cd Supply-Chain-Performance-Analysis

# 3. Install required libraries
pip install pandas numpy matplotlib seaborn jupyter

# 4. Launch Jupyter Notebook
jupyter notebook supply_chain_analysis.ipynb
```

---

## 📬 Connect With Me

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/rushi2372)
[![Email](https://img.shields.io/badge/Email-D14836?style=flat&logo=gmail&logoColor=white)](mailto:rushikeshsangamnere4561@gmail.com)
[![Phone](https://img.shields.io/badge/Phone-25D366?style=flat&logo=whatsapp&logoColor=white)](tel:+919096506345)

---

> *"This project demonstrates end-to-end data analyst capabilities — from raw data to executive-ready insights using Python, SQL, and Power BI."*
