-- UzRetail: sxema va ma'lumotlarni yuklash (PostgreSQL 14+)
-- Ishga tushirish (loyiha papkasidan):
--   psql -U postgres -d uzretail -f sql/00_schema.sql

DROP TABLE IF EXISTS order_items, orders, customers, products, stores CASCADE;

CREATE TABLE stores (
    store_id     INT PRIMARY KEY,
    store_name   TEXT NOT NULL,
    region       TEXT NOT NULL,
    city         TEXT NOT NULL,
    opened_date  DATE NOT NULL
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  TEXT NOT NULL,
    category      TEXT NOT NULL,
    unit_price    NUMERIC(12, 2) NOT NULL,
    unit_cost     NUMERIC(12, 2) NOT NULL
);

CREATE TABLE customers (
    customer_id      INT PRIMARY KEY,
    gender           TEXT,
    birth_year       INT,
    registered_date  DATE NOT NULL,
    home_store_id    INT REFERENCES stores (store_id)
);

CREATE TABLE orders (
    order_id        INT PRIMARY KEY,
    order_ts        TIMESTAMP NOT NULL,
    customer_id     INT NOT NULL REFERENCES customers (customer_id),
    store_id        INT NOT NULL REFERENCES stores (store_id),
    payment_method  TEXT NOT NULL
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY,
    order_id       INT NOT NULL REFERENCES orders (order_id),
    product_id     INT NOT NULL REFERENCES products (product_id),
    quantity       INT NOT NULL CHECK (quantity > 0),
    unit_price     NUMERIC(12, 2) NOT NULL,
    discount       NUMERIC(4, 2) NOT NULL DEFAULT 0
);

\copy stores      FROM 'data/stores.csv'      WITH (FORMAT csv, HEADER true)
\copy products    FROM 'data/products.csv'    WITH (FORMAT csv, HEADER true)
\copy customers   FROM 'data/customers.csv'   WITH (FORMAT csv, HEADER true)
\copy orders      FROM 'data/orders.csv'      WITH (FORMAT csv, HEADER true)
\copy order_items FROM 'data/order_items.csv' WITH (FORMAT csv, HEADER true)

CREATE INDEX idx_orders_ts       ON orders (order_ts);
CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_items_order     ON order_items (order_id);
CREATE INDEX idx_items_product   ON order_items (product_id);

-- Har bir qator bo'yicha tushum va foyda: barcha tahlillar shu view'dan foydalanadi
CREATE OR REPLACE VIEW v_sales AS
SELECT
    oi.order_item_id,
    o.order_id,
    o.order_ts,
    o.order_ts::date                                         AS order_date,
    o.customer_id,
    o.store_id,
    s.store_name,
    s.region,
    o.payment_method,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.discount,
    oi.quantity * oi.unit_price * (1 - oi.discount)          AS revenue,
    oi.quantity * p.unit_cost                                AS cost,
    oi.quantity * (oi.unit_price * (1 - oi.discount) - p.unit_cost) AS profit
FROM order_items oi
JOIN orders   o ON o.order_id   = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN stores   s ON s.store_id   = o.store_id;
