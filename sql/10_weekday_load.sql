-- 10. Hafta kunlari bo'yicha yuklama va kechki soatlar ulushi
-- Savol: xodimlar smenasini qachon kuchaytirish kerak?
SELECT
    EXTRACT(ISODOW FROM order_ts)::int                  AS weekday_n,
    CASE EXTRACT(ISODOW FROM order_ts)::int
        WHEN 1 THEN 'Dushanba'  WHEN 2 THEN 'Seshanba' WHEN 3 THEN 'Chorshanba'
        WHEN 4 THEN 'Payshanba' WHEN 5 THEN 'Juma'     WHEN 6 THEN 'Shanba'
        ELSE 'Yakshanba' END                            AS weekday,
    COUNT(*)                                            AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)  AS orders_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE EXTRACT(HOUR FROM order_ts) BETWEEN 17 AND 20)
          / COUNT(*), 1)                                AS evening_17_21_pct
FROM orders
GROUP BY 1, 2
ORDER BY 1;
