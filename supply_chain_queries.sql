-- ============================================================
-- SUPPLY CHAIN PERFORMANCE ANALYSIS — SQL QUERIES
-- Author  : Rushikesh Ramesh Sangamnere
-- Dataset : Beauty & Personal Care Supply Chain (100 SKUs)
-- Tools   : MySQL / PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: PRODUCT PERFORMANCE ANALYSIS
-- ============================================================

-- 1.1 Revenue, Units Sold & Defect Rate by Product Type
SELECT
    product_type,
    COUNT(*)                                    AS total_skus,
    SUM(number_of_products_sold)               AS total_units_sold,
    ROUND(SUM(revenue_generated), 2)           AS total_revenue,
    ROUND(AVG(price), 2)                       AS avg_price,
    ROUND(AVG(defect_rates), 2)                AS avg_defect_rate,
    ROUND(
        SUM(revenue_generated) * 100.0 /
        SUM(SUM(revenue_generated)) OVER (), 2
    )                                           AS revenue_share_pct
FROM supply_chain_data
GROUP BY product_type
ORDER BY total_revenue DESC;


-- 1.2 Top 10 SKUs by Revenue Generated
SELECT
    sku,
    product_type,
    ROUND(price, 2)                AS price,
    number_of_products_sold        AS units_sold,
    ROUND(revenue_generated, 2)    AS revenue,
    ROUND(defect_rates, 2)         AS defect_rate,
    inspection_results
FROM supply_chain_data
ORDER BY revenue_generated DESC
LIMIT 10;


-- ============================================================
-- SECTION 2: SUPPLIER PERFORMANCE ANALYSIS
-- ============================================================

-- 2.1 Supplier KPI Summary
SELECT
    supplier_name,
    location,
    COUNT(*)                                   AS total_skus,
    ROUND(SUM(revenue_generated), 2)           AS total_revenue,
    ROUND(AVG(lead_time), 1)                   AS avg_lead_time_days,
    ROUND(AVG(defect_rates), 2)                AS avg_defect_rate_pct,
    ROUND(AVG(manufacturing_costs), 2)         AS avg_mfg_cost,
    SUM(production_volumes)                    AS total_production_volume,
    ROUND(AVG(manufacturing_lead_time), 1)     AS avg_mfg_lead_time
FROM supply_chain_data
GROUP BY supplier_name, location
ORDER BY total_revenue DESC;


-- 2.2 Supplier Inspection Failure Rate (CTE)
WITH inspection_summary AS (
    SELECT
        supplier_name,
        COUNT(*)                                                     AS total_skus,
        SUM(CASE WHEN inspection_results = 'Fail'    THEN 1 ELSE 0 END) AS fail_count,
        SUM(CASE WHEN inspection_results = 'Pass'    THEN 1 ELSE 0 END) AS pass_count,
        SUM(CASE WHEN inspection_results = 'Pending' THEN 1 ELSE 0 END) AS pending_count
    FROM supply_chain_data
    GROUP BY supplier_name
)
SELECT
    supplier_name,
    total_skus,
    fail_count,
    pass_count,
    pending_count,
    ROUND(fail_count    * 100.0 / total_skus, 1) AS fail_rate_pct,
    ROUND(pass_count    * 100.0 / total_skus, 1) AS pass_rate_pct,
    ROUND(pending_count * 100.0 / total_skus, 1) AS pending_rate_pct
FROM inspection_summary
ORDER BY fail_rate_pct DESC;


-- 2.3 Supplier Ranking by Lead Time (Window Function)
SELECT
    supplier_name,
    ROUND(AVG(lead_time), 1)           AS avg_lead_time,
    ROUND(AVG(defect_rates), 2)        AS avg_defect_rate,
    RANK() OVER (ORDER BY AVG(lead_time) ASC)       AS lead_time_rank,
    RANK() OVER (ORDER BY AVG(defect_rates) ASC)    AS quality_rank,
    RANK() OVER (ORDER BY SUM(revenue_generated) DESC) AS revenue_rank
FROM supply_chain_data
GROUP BY supplier_name
ORDER BY lead_time_rank;


-- 2.4 Suppliers with Above-Average Defect Rate (Subquery)
SELECT
    supplier_name,
    ROUND(AVG(defect_rates), 2)    AS avg_defect_rate,
    COUNT(*)                       AS total_skus
FROM supply_chain_data
GROUP BY supplier_name
HAVING AVG(defect_rates) > (
    SELECT AVG(defect_rates) FROM supply_chain_data
)
ORDER BY avg_defect_rate DESC;


-- ============================================================
-- SECTION 3: SHIPPING & TRANSPORT ANALYSIS
-- ============================================================

-- 3.1 Shipping Carrier Performance
SELECT
    shipping_carriers,
    COUNT(*)                                AS total_orders,
    ROUND(AVG(shipping_costs), 2)           AS avg_shipping_cost,
    ROUND(AVG(shipping_times), 1)           AS avg_shipping_days,
    ROUND(SUM(revenue_generated), 2)        AS total_revenue_handled,
    ROUND(AVG(defect_rates), 2)             AS avg_defect_rate
FROM supply_chain_data
GROUP BY shipping_carriers
ORDER BY total_orders DESC;


-- 3.2 Transportation Mode Efficiency Analysis
SELECT
    transportation_modes,
    COUNT(*)                            AS total_shipments,
    ROUND(AVG(costs), 2)                AS avg_total_cost,
    ROUND(AVG(shipping_costs), 2)       AS avg_shipping_cost,
    ROUND(AVG(shipping_times), 1)       AS avg_delivery_days,
    ROUND(
        AVG(costs) / NULLIF(AVG(shipping_times), 0), 2
    )                                   AS cost_per_day  -- efficiency ratio
FROM supply_chain_data
GROUP BY transportation_modes
ORDER BY avg_total_cost ASC;


-- 3.3 Route Performance with Running Totals (Window Function)
SELECT
    routes,
    transportation_modes,
    COUNT(*)                                                    AS shipment_count,
    ROUND(AVG(costs), 2)                                       AS avg_cost,
    ROUND(AVG(shipping_times), 1)                              AS avg_days,
    ROUND(
        SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC), 0
    )                                                           AS cumulative_shipments
FROM supply_chain_data
GROUP BY routes, transportation_modes
ORDER BY shipment_count DESC;


-- ============================================================
-- SECTION 4: INVENTORY & LOCATION ANALYSIS
-- ============================================================

-- 4.1 City-wise Supply Chain Performance
SELECT
    location,
    COUNT(*)                                AS total_skus,
    ROUND(SUM(revenue_generated), 2)        AS total_revenue,
    ROUND(AVG(stock_levels), 1)             AS avg_stock_level,
    ROUND(AVG(lead_time), 1)                AS avg_lead_time,
    ROUND(AVG(defect_rates), 2)             AS avg_defect_rate,
    ROUND(AVG(shipping_costs), 2)           AS avg_shipping_cost
FROM supply_chain_data
GROUP BY location
ORDER BY total_revenue DESC;


-- 4.2 Low Stock Alert — SKUs Below Threshold
SELECT
    sku,
    product_type,
    supplier_name,
    location,
    stock_levels,
    order_quantities,
    CASE
        WHEN stock_levels < 10  THEN '🔴 Critical — Reorder Now'
        WHEN stock_levels < 25  THEN '🟡 Low — Monitor Closely'
        ELSE                         '🟢 Adequate'
    END AS stock_status
FROM supply_chain_data
ORDER BY stock_levels ASC;


-- 4.3 Revenue vs Stock Correlation by Product
SELECT
    product_type,
    ROUND(AVG(stock_levels), 1)            AS avg_stock,
    ROUND(AVG(number_of_products_sold), 1) AS avg_units_sold,
    ROUND(AVG(revenue_generated), 2)       AS avg_revenue,
    ROUND(
        (AVG(number_of_products_sold) - AVG(stock_levels)) /
        NULLIF(AVG(stock_levels), 0) * 100, 1
    )                                       AS demand_supply_gap_pct
FROM supply_chain_data
GROUP BY product_type
ORDER BY demand_supply_gap_pct DESC;


-- ============================================================
-- SECTION 5: QUALITY & DEFECT ANALYSIS
-- ============================================================

-- 5.1 Quality Overview by Product and Supplier
SELECT
    product_type,
    supplier_name,
    COUNT(*)                                                         AS total_skus,
    ROUND(AVG(defect_rates), 2)                                      AS avg_defect_rate,
    SUM(CASE WHEN inspection_results = 'Fail' THEN 1 ELSE 0 END)    AS failed_inspections,
    ROUND(
        SUM(CASE WHEN inspection_results = 'Fail' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                                                                AS fail_rate_pct
FROM supply_chain_data
GROUP BY product_type, supplier_name
ORDER BY avg_defect_rate DESC;


-- 5.2 Defect Rate Quartile Distribution (Window Function)
SELECT
    sku,
    product_type,
    supplier_name,
    ROUND(defect_rates, 2)   AS defect_rate,
    NTILE(4) OVER (ORDER BY defect_rates ASC) AS defect_quartile,
    CASE NTILE(4) OVER (ORDER BY defect_rates ASC)
        WHEN 1 THEN 'Q1 — Best Quality'
        WHEN 2 THEN 'Q2 — Above Average'
        WHEN 3 THEN 'Q3 — Below Average'
        WHEN 4 THEN 'Q4 — Worst Quality'
    END AS quality_tier
FROM supply_chain_data
ORDER BY defect_rates ASC;


-- 5.3 Manufacturing Cost vs Defect Rate Analysis (CTE)
WITH mfg_analysis AS (
    SELECT
        supplier_name,
        ROUND(AVG(manufacturing_costs), 2)  AS avg_mfg_cost,
        ROUND(AVG(defect_rates), 2)          AS avg_defect_rate,
        ROUND(AVG(manufacturing_lead_time), 1) AS avg_mfg_lead_time
    FROM supply_chain_data
    GROUP BY supplier_name
)
SELECT
    *,
    CASE
        WHEN avg_mfg_cost > 50 AND avg_defect_rate > 2.5
            THEN '🔴 High Cost + High Defect — Urgent Review'
        WHEN avg_mfg_cost > 50 AND avg_defect_rate <= 2.5
            THEN '🟡 High Cost + Acceptable Quality — Cost Optimization Needed'
        WHEN avg_mfg_cost <= 50 AND avg_defect_rate > 2.5
            THEN '🟡 Low Cost + High Defect — Quality Improvement Needed'
        ELSE
            '🟢 Optimal — Low Cost + Good Quality'
    END AS supplier_classification
FROM mfg_analysis
ORDER BY avg_mfg_cost DESC;


-- ============================================================
-- SECTION 6: SUPPLIER RISK SCORECARD (Advanced CTE)
-- ============================================================

WITH supplier_metrics AS (
    SELECT
        supplier_name,
        ROUND(AVG(defect_rates), 2)            AS avg_defect,
        ROUND(AVG(lead_time), 1)               AS avg_lead_time,
        ROUND(AVG(manufacturing_costs), 2)     AS avg_mfg_cost,
        ROUND(
            SUM(CASE WHEN inspection_results='Fail' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 1
        )                                       AS fail_rate_pct
    FROM supply_chain_data
    GROUP BY supplier_name
),
medians AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_defect)      AS med_defect,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_lead_time)   AS med_lead_time,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_mfg_cost)    AS med_mfg_cost
    FROM supplier_metrics
),
risk_scored AS (
    SELECT
        sm.*,
        (
            CASE WHEN sm.avg_defect    > m.med_defect    THEN 2 ELSE 0 END +
            CASE WHEN sm.avg_lead_time > m.med_lead_time THEN 2 ELSE 0 END +
            CASE WHEN sm.avg_mfg_cost  > m.med_mfg_cost  THEN 1 ELSE 0 END +
            CASE WHEN sm.fail_rate_pct > 35              THEN 1 ELSE 0 END
        ) AS risk_score
    FROM supplier_metrics sm, medians m
)
SELECT
    supplier_name,
    avg_defect,
    avg_lead_time,
    avg_mfg_cost,
    fail_rate_pct,
    risk_score,
    CASE
        WHEN risk_score <= 1 THEN '🟢 Low Risk'
        WHEN risk_score <= 3 THEN '🟡 Medium Risk'
        ELSE                      '🔴 High Risk'
    END AS risk_category
FROM risk_scored
ORDER BY risk_score DESC;

-- ============================================================
-- END OF QUERIES
-- Total Queries: 16 | Techniques: CTEs, Window Functions,
-- Aggregations, Subqueries, CASE Statements, NTILE, RANK,
-- PERCENTILE_CONT, Running Totals
-- ============================================================
