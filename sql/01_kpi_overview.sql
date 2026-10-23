-- 1. Asosiy ko'rsatkichlar (KPI) yillar kesimida
-- Savol: biznes yildan-yilga qanchalik o'sdi?
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::int   AS year,
        SUM(revenue)                         AS revenue,
        SUM(profit)                          AS profit,
        COUNT(DISTINCT order_id)             AS orders,
        COUNT(DISTINCT customer_id)          AS customers
    FROM v_sales
    GROUP BY 1
)
SELECT
    year,
    ROUND(revenue / 1e6, 1)                                           AS revenue_mln,
    ROUND(profit / 1e6, 1)                                            AS profit_mln,
    ROUND(100 * profit / revenue, 1)                                  AS margin_pct,
    orders,
    customers,
    ROUND(revenue / orders)                                           AS avg_check,
    ROUND(100 * (revenue / LAG(revenue) OVER (ORDER BY year) - 1), 1) AS revenue_yoy_pct
FROM yearly
ORDER BY year;
