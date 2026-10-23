-- 12. Chegirmalarning foydaga ta'siri
-- Savol: chegirma savdoni oshiradimi yoki faqat marjani yeydimi?
SELECT
    ROUND(discount * 100)::int || '%'          AS discount_level,
    COUNT(*)                                   AS lines,
    ROUND(AVG(quantity), 2)                    AS avg_qty,
    ROUND(SUM(revenue) / 1e6, 1)               AS revenue_mln,
    ROUND(SUM(profit) / 1e6, 1)                AS profit_mln,
    ROUND(100 * SUM(profit) / SUM(revenue), 1) AS margin_pct,
    COUNT(*) FILTER (WHERE profit < 0)         AS loss_lines
FROM v_sales
GROUP BY discount
ORDER BY discount;
