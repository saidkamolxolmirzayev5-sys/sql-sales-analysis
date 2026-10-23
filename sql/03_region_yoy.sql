-- 3. Viloyatlar bo'yicha 2024 va 2025 yillarni solishtirish
-- Savol: qaysi hudud eng tez o'smoqda?
WITH by_region AS (
    SELECT
        region,
        SUM(revenue) FILTER (WHERE EXTRACT(YEAR FROM order_date) = 2024) AS rev_2024,
        SUM(revenue) FILTER (WHERE EXTRACT(YEAR FROM order_date) = 2025) AS rev_2025
    FROM v_sales
    GROUP BY region
)
SELECT
    region,
    ROUND(rev_2024 / 1e6, 1)                                AS rev_2024_mln,
    ROUND(rev_2025 / 1e6, 1)                                AS rev_2025_mln,
    ROUND(100 * (rev_2025 / NULLIF(rev_2024, 0) - 1), 1)    AS growth_pct,
    ROUND(100 * rev_2025 / SUM(rev_2025) OVER (), 1)        AS share_2025_pct
FROM by_region
ORDER BY rev_2025 DESC;
