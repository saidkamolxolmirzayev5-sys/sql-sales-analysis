-- 7. RFM segmentatsiya (Recency, Frequency, Monetary)
-- Savol: mijozlarning qaysi guruhi eng qimmatli va qaysilari ketish arafasida?
WITH rfm AS (
    SELECT
        customer_id,
        DATE '2025-12-31' - MAX(order_date) AS recency_days,
        COUNT(DISTINCT order_id)            AS frequency,
        SUM(revenue)                        AS monetary
    FROM v_sales
    GROUP BY customer_id
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC, customer_id) AS r,
        NTILE(5) OVER (ORDER BY frequency, customer_id)         AS f
    FROM rfm
),
segments AS (
    SELECT
        *,
        CASE
            WHEN r >= 4 AND f >= 4 THEN '1. Chempionlar'
            WHEN r >= 3 AND f >= 3 THEN '2. Sodiq mijozlar'
            WHEN r >= 4 AND f <= 2 THEN '3. Yangi / istiqbolli'
            WHEN r <= 2 AND f >= 3 THEN '4. Xavf ostida'
            WHEN r <= 2 AND f <= 2 THEN '5. Yo''qotilgan'
            ELSE                        '6. E''tibor talab'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*)                                                   AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)         AS customers_pct,
    ROUND(AVG(recency_days))                                   AS avg_recency_days,
    ROUND(AVG(frequency), 1)                                   AS avg_orders,
    ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS revenue_share_pct
FROM segments
GROUP BY segment
ORDER BY segment;
