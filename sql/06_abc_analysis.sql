-- 6. ABC tahlil: mahsulotlarni tushumga qo'shgan hissasi bo'yicha guruhlash
-- A — tushumning birinchi 80%, B — keyingi 15%, C — qolgan 5%
-- Savol: assortimentning qaysi qismi asosiy pulni keltiradi?
WITH product_rev AS (
    SELECT product_name, SUM(revenue) AS revenue
    FROM v_sales
    GROUP BY product_name
),
cumulative AS (
    SELECT
        *,
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING)
            / SUM(revenue) OVER () AS cum_share
    FROM product_rev
)
SELECT
    CASE WHEN cum_share <= 0.80 THEN 'A'
         WHEN cum_share <= 0.95 THEN 'B'
         ELSE 'C' END                                        AS abc_class,
    COUNT(*)                                                 AS products,
    ROUND(SUM(revenue) / 1e6, 1)                             AS revenue_mln,
    ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
    STRING_AGG(product_name, ', ' ORDER BY revenue DESC)     AS products_list
FROM cumulative
GROUP BY 1
ORDER BY 1;
