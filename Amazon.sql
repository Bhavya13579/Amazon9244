CREATE DATABASE amazon_project;
USE amazon_project;
CREATE TABLE regions (
    region_id INT,
    region_name VARCHAR(50)
);
CREATE TABLE customers (
    customer_id INT,
    region_id INT,
    is_prime TINYINT,
    signup_date DATE
);
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    cost DECIMAL(10,2)
);
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(20)
);
CREATE TABLE order_items (
    order_item_id INT,
    order_id INT,
    product_id INT,
    quantity INT
);
INSERT INTO regions (region_id, region_name) VALUES
(1, 'North'),
(2, 'South'),
(3, 'West');

SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE '/Users/bhavyaverma/downloads/python codes/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, region_id, is_prime, signup_date);

LOAD DATA LOCAL INFILE
'/Users/bhavyaverma/downloads/python codes/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category, price, cost);

LOAD DATA LOCAL INFILE
'/Users/bhavyaverma/downloads/python codes/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_date, order_status);

LOAD DATA LOCAL INFILE
'/Users/bhavyaverma/downloads/python codes/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_item_id, order_id, product_id, quantity);

-- Sanity check joins  
SELECT 
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- Orders by status (business health snapshot)
SELECT 
    order_status,
    COUNT(*) AS orders
FROM orders
GROUP BY order_status;

-- Prime vs Non-Prime customers
SELECT
    c.is_prime,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.is_prime;

-- Revenue proxy
SELECT
    SUM(oi.quantity * p.price) AS gross_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

-- Revenue by category
SELECT
    p.category,
    SUM(oi.quantity * p.price) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Top 10 products by sales
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- Customer lifetime orders (behavioral analysis)
SELECT
    customer_id,
    COUNT(order_id) AS orders_count
FROM orders
GROUP BY customer_id
ORDER BY orders_count DESC
LIMIT 10;

-- highest-value customers
SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    RANK() OVER (ORDER BY COUNT(order_id) DESC) AS customer_rank
FROM orders
GROUP BY customer_id
ORDER BY customer_rank
LIMIT 20;

-- Dense ranking of products by revenue (no gaps)
SELECT
    p.product_name,
    SUM(oi.quantity * p.price) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS revenue_rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue_rank
LIMIT 10;

-- Running total of revenue (trend analysis)
SELECT
    order_date,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT
        o.order_date,
        SUM(oi.quantity * p.price) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.order_date
) t
ORDER BY order_date;

-- Customer cohort analysis
SELECT
    YEAR(c.signup_date) AS cohort_year,
    COUNT(DISTINCT o.customer_id) AS active_customers
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY cohort_year
ORDER BY cohort_year;

-- Category share of total revenue
SELECT
    category,
    SUM(category_revenue) AS revenue,
    ROUND(
        100 * SUM(category_revenue) /
        SUM(SUM(category_revenue)) OVER (),
        2
    ) AS revenue_share_pct
FROM (
    SELECT
        p.category,
        SUM(oi.quantity * p.price) AS category_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
) t
GROUP BY category
ORDER BY revenue DESC;

-- Top 3 categories by revenue per year
WITH yearly_revenue AS (
    SELECT
        YEAR(o.order_date) AS year,
        p.category,
        SUM(oi.quantity * p.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'DELIVERED'
    GROUP BY year, p.category
)
SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY year
               ORDER BY revenue DESC
           ) AS rank_in_year
    FROM yearly_revenue
) t
WHERE rank_in_year <= 3;

-- Row counts
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
 
-- join integrity
SELECT COUNT(*) 
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- adding primary key
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE order_items ADD PRIMARY KEY (order_item_id);
ALTER TABLE regions ADD PRIMARY KEY (region_id);

-- indexes 
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

