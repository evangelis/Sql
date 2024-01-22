CREATE DATABASE IF NOT EXISTS sales;
USE sales;
CREATE TABLE IF NOT EXISTS products(
   id INT AUTO_INCREMENT PRIMARY KEY,
   product_name VARCHAR(255) NOT NULL,
   price DECIMAL(10,2) NOT NULL
);

INSERT INTO products (product_name, price) VALUES
('Smartphone XYZ', 599.99),
('Laptop ABC', 1299.99),
('Wireless Earbuds', 79.99),
('4K Ultra HD Smart TV', 899.99),
('Gaming Console XYZ', 399.99);
