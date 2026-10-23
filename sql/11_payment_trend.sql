-- 11. To'lov usullari: choraklar bo'yicha ulush o'zgarishi
-- Savol: mijozlar naqd puldan elektron to'lovga qanchalik tez o'tyapti?
SELECT
    EXTRACT(YEAR FROM order_ts)::int || '-Q' || EXTRACT(QUARTER FROM order_ts)::int AS quarter,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_method = 'Naqd')      / COUNT(*), 1) AS cash_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_method LIKE 'Karta%') / COUNT(*), 1) AS card_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_method = 'Click')     / COUNT(*), 1) AS click_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_method = 'Payme')     / COUNT(*), 1) AS payme_pct
FROM orders
GROUP BY 1
ORDER BY 1;
