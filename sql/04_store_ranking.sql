-- 4. Filiallar reytingi (2025): viloyat ichida va umumiy
-- Savol: har bir viloyatda qaysi filial yetakchi, qaysi biri orqada?
WITH store_stats AS (
    SELECT
        region,
        store_name,
        SUM(revenue)             AS revenue,
        SUM(profit)              AS profit,
        COUNT(DISTINCT order_id) AS orders
    FROM v_sales
    WHERE order_date >= DATE '2025-01-01'
    GROUP BY region, store_name
)
SELECT
    region,
    store_name,
    ROUND(revenue / 1e6, 1)                                 AS revenue_mln,
    ROUND(100 * profit / revenue, 1)                        AS margin_pct,
    ROUND(revenue / orders)                                 AS avg_check,
    RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS rank_in_region,
    RANK() OVER (ORDER BY revenue DESC)                     AS rank_overall
FROM store_stats
ORDER BY rank_overall;
