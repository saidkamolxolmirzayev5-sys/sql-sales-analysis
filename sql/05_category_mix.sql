-- 5. Kategoriyalar: tushumdagi ulush va foydadagi ulush
-- Savol: qaysi kategoriya ko'p sotiladi-yu, kam foyda keltiradi?
SELECT
    category,
    ROUND(SUM(revenue) / 1e6, 1)                             AS revenue_mln,
    ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
    ROUND(100 * SUM(profit)  / SUM(SUM(profit))  OVER (), 1) AS profit_share_pct,
    ROUND(100 * SUM(profit) / SUM(revenue), 1)               AS margin_pct
FROM v_sales
GROUP BY category
ORDER BY revenue_mln DESC;
