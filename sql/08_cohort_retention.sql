-- 8. Kohort tahlil: birinchi xarid oyiga ko'ra mijozlarning qaytib kelishi
-- Savol: yangi mijozlarning necha foizi 1, 3, 6 va 12 oydan keyin ham xarid qiladi?
WITH first_purchase AS (
    SELECT customer_id, DATE_TRUNC('month', MIN(order_date))::date AS cohort_month
    FROM v_sales
    GROUP BY customer_id
),
activity AS (
    SELECT DISTINCT
        v.customer_id,
        f.cohort_month,
        ((EXTRACT(YEAR FROM v.order_date) - EXTRACT(YEAR FROM f.cohort_month)) * 12
          + EXTRACT(MONTH FROM v.order_date) - EXTRACT(MONTH FROM f.cohort_month))::int AS month_n
    FROM v_sales v
    JOIN first_purchase f USING (customer_id)
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS size FROM first_purchase GROUP BY 1
)
SELECT
    a.cohort_month,
    c.size                                                          AS new_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE month_n = 1)  / c.size, 1) AS m1_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE month_n = 3)  / c.size, 1) AS m3_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE month_n = 6)  / c.size, 1) AS m6_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE month_n = 12) / c.size, 1) AS m12_pct
FROM activity a
JOIN cohort_size c USING (cohort_month)
-- 2024-yanvar kohortiga oldingi yillardan qolgan mijozlar ham tushadi, shuning uchun fevraldan
WHERE a.cohort_month BETWEEN DATE '2024-02-01' AND DATE '2024-12-01'
GROUP BY a.cohort_month, c.size
ORDER BY a.cohort_month;
