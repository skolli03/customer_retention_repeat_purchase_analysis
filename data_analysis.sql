-- Reorder Rate by Department
SELECT 
	d.department,
    AVG(op.reordered) AS reordered_rate,
    COUNT(op.reordered) AS total_orders
FROM order_products op
JOIN products p
	ON op.product_id = p.product_id
JOIN departments d
	ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY reordered_rate;


-- Top Reordered Products
SELECT 
	p.product_id,
    p.product_name,
    d.department,
    AVG(op.reordered) AS reordered_rate,
    COUNT(op.reordered) AS total_orders
FROM products p
JOIN order_products op
	ON op.product_id = p.product_id
JOIN departments d
	ON p.department_id = d.department_id
GROUP BY p.product_id, p.product_name
HAVING total_orders > 500
ORDER BY reordered_rate DESC
LIMIT 20;


-- Customer Segments
WITH segments AS (
SELECT 
	user_id,
	MAX(order_number) AS order_count,
	CASE
		WHEN MAX(order_number) >= 3 AND MAX(order_number) <= 7 THEN 'New'
		WHEN MAX(order_number) >= 8 AND MAX(order_number) <= 20 THEN 'Regular'
		WHEN MAX(order_number) >= 21 THEN 'Loyal'
		END AS customer_loyalty
FROM orders
GROUP BY user_id),

days AS (
	SELECT 
		s.customer_loyalty,
        AVG(o.days_since_prior_order) AS avg_days_since_prior_order
	FROM orders o
    JOIN segments s
		ON o.user_id = s.user_id
	GROUP BY s.customer_loyalty
),

segment_stats AS (
	SELECT 
		s.customer_loyalty,
		COUNT(DISTINCT s.user_id) AS customer_count,
		COUNT(*) / COUNT(DISTINCT op.order_id) AS avg_order_size,
		AVG(op.reordered) AS reorder_rate
	FROM segments s
	JOIN orders o
		ON o.user_id = s.user_id
	JOIN order_products op
		ON op.order_id = o.order_id
	GROUP BY customer_loyalty
	ORDER BY reorder_rate DESC
)

SELECT
	ss.customer_loyalty,
    ss.customer_count,
    ss.avg_order_size,
    ss.reorder_rate,
    d.avg_days_since_prior_order
FROM segment_stats ss
JOIN days d
	ON ss.customer_loyalty = d.customer_loyalty;
    
    
-- Ordering Rhythm
SELECT
	CASE
		WHEN order_dow = 0 THEN 'Sunday'
        WHEN order_dow = 1 THEN 'Monday'
        WHEN order_dow = 2 THEN 'Tuesday'
        WHEN order_dow = 3 THEN 'Wednesday'
        WHEN order_dow = 4 THEN 'Thursday'
        WHEN order_dow = 5 THEN 'Friday'
        WHEN order_dow = 6 THEN 'Saturday'
        END AS day_of_week,
	order_hour_of_day AS hour_of_day,
	COUNT(*) AS total_orders
FROM orders
GROUP BY day_of_week, hour_of_day, order_dow
ORDER BY order_dow, hour_of_day;


-- Order Behavior
SELECT
    CASE
        WHEN add_to_cart_order <= 3 THEN '1-3'
        WHEN add_to_cart_order <= 10 THEN '4-10'
        ELSE '11+'
    END AS cart_position,
    COUNT(*) AS total_items,
    AVG(reordered) AS reorder_rate
FROM order_products
GROUP BY cart_position
ORDER BY MIN(add_to_cart_order);

ANALYZE TABLE order_products, products, departments;
SET GLOBAL innodb_buffer_pool_size = 2147483648;