USE sales;
-- Create the customers table
CREATE TABLE customers (
   id INT AUTO_INCREMENT PRIMARY KEY,
   customer_name VARCHAR(255) NOT NULL,
   email VARCHAR(255) NOT NULL
);

-- Insert five customers into the customers table
INSERT INTO customers (customer_name, email) VALUES
('John Doe', 'john.doe@example.com'),
('Jane Smith', 'jane.smith@example.com'),
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Williams', 'bob.williams@example.com'),
('Eva Davis', 'eva.davis@example.com');
