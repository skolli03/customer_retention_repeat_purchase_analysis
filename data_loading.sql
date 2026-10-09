CREATE DATABASE instacart;
USE instacart;


-- Orders Table
CREATE TABLE orders (
	order_id INT PRIMARY KEY,
    user_id INT,
    eval_set VARCHAR(10),
    order_number INT,
    order_dow INT,
    order_hour_of_day INT,
    days_since_prior_order INT
);

SET GLOBAL local_infile = 1;

TRUNCATE TABLE orders;
LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/Data Analysis/SQL/Business Case Study/orders_sample.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, user_id, eval_set, order_number, order_dow, order_hour_of_day, @days)
SET days_since_prior_order = NULLIF(@days, '');


-- Order Products Table
CREATE TABLE order_products (
	order_id INT,
    product_id INT,
    add_to_cart_order INT,
    reordered INT
);
ALTER TABLE order_products ADD PRIMARY KEY (order_id, product_id);

LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/Data Analysis/SQL/Business Case Study/order_products_sample.csv'
INTO TABLE order_products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Aisles Table
CREATE TABLE aisles (
	aisle_id INT PRIMARY KEY,
    aisle TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/Data Analysis/SQL/Business Case Study/aisles.csv'
INTO TABLE aisles
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Departments Table
CREATE TABLE departments (
	department_id INT PRIMARY KEY,
    department TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/Data Analysis/SQL/Business Case Study/departments.csv'
INTO TABLE departments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Order Products Train Table
CREATE TABLE order_products_train (
	order_id INT PRIMARY KEY,
    product_id INT,
    add_to_cart_order INT,
    reordered INT
);

LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/Data Analysis/SQL/Business Case Study/order_products__train.csv'
INTO TABLE order_products_train
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Products Table
CREATE TABLE products (
	product_id INT PRIMARY KEY,
    product_name TEXT,
    aisle_id INT,
    department_id INT
);

TRUNCATE TABLE products;

LOAD DATA LOCAL INFILE 'C:/Users/suraj/OneDrive/Desktop/Data Analysis/SQL/Business Case Study/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM products;


-- Foreign Keys
ALTER TABLE order_products ADD FOREIGN KEY (product_id) REFERENCES products (product_id);

ALTER TABLE order_products ADD FOREIGN KEY (order_id) REFERENCES orders (order_id);

ALTER TABLE products ADD FOREIGN KEY (aisle_id) REFERENCES aisles (aisle_id);

ALTER TABLE products ADD FOREIGN KEY (department_id) REFERENCES departments (department_id);