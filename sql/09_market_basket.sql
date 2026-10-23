-- 9. Savat tahlili: qaysi mahsulotlar birga sotib olinadi?
-- support    — juftlik uchragan cheklar ulushi
-- confidence — A olinganda B ham olinish ehtimoli
-- lift > 1   — bog'liqlik tasodifdan kuchliroq
WITH baskets AS (
    SELECT DISTINCT order_id, product_id, product_name FROM v_sales
),
total AS (
    SELECT COUNT(DISTINCT order_id) AS n FROM baskets
),
product_freq AS (
    SELECT product_id, COUNT(*) AS cnt FROM baskets GROUP BY product_id
),
pairs AS (
    SELECT
        a.product_id   AS id_a,
        b.product_id   AS id_b,
        a.product_name AS product_a,
        b.product_name AS product_b,
        COUNT(*)       AS together
    FROM baskets a
    JOIN baskets b ON a.order_id = b.order_id AND a.product_id < b.product_id
    GROUP BY 1, 2, 3, 4
)
SELECT
    p.product_a,
    p.product_b,
    p.together,
    ROUND(100.0 * p.together / t.n, 2)              AS support_pct,
    ROUND(100.0 * p.together / fa.cnt, 1)           AS confidence_pct,
    ROUND(1.0 * p.together * t.n / (fa.cnt * fb.cnt), 2) AS lift
FROM pairs p
CROSS JOIN total t
JOIN product_freq fa ON fa.product_id = p.id_a
JOIN product_freq fb ON fb.product_id = p.id_b
WHERE p.together >= 200
ORDER BY lift DESC
LIMIT 10;
