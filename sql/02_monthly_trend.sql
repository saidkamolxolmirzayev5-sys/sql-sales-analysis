-- 2. Oylik tushum dinamikasi va o'sish sur'ati (MoM, YoY)
-- Savol: qaysi oylarda savdo cho'qqiga chiqadi, qaysilarida tushadi?
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(revenue)                          AS revenue
    FROM v_sales
    GROUP BY 1
)
SELECT
    month,
    ROUND(revenue / 1e6, 1)                                                AS revenue_mln,
    ROUND(100 * (revenue / LAG(revenue) OVER (ORDER BY month) - 1), 1)     AS mom_pct,
    ROUND(100 * (revenue / LAG(revenue, 12) OVER (ORDER BY month) - 1), 1) AS yoy_pct,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) / 1e6, 1)
                                                                           AS moving_avg_3m_mln
FROM monthly
ORDER BY month;
