SELECT @@version AS 'MySQL Version',VERSION(),CONCAT('MySQL',' ',VERSION())version;
SHOW GLOBAL VARIABLES LIKE 'max_connections'
#1.Databases,Tables,Columns
SHOW DATABASES;
SHOW SCHEMAS;
SHOW DATABASES LIKE '%schema'; # information_schema, performance_schema
SELECT schema_name FROM information_schema.schemata;
SELECT schema_name FROM information_schema.schemata WHERE 
	schema_name LIKE '%schema'; -- information_schema, performance_schema

USE classicmodels1;
SHOW FULL TABLES
SHOW TABLES LIKE 'p%';
SHOW FULL TABLES FROM mysql;
SHOW FULL TABLES IN mysql LIKE 'time%';


DESC orders; --[field,type,null,key,default,extra]
SHOW COLUMNS FROM orders; --the same
SHOW FULL COLUMNS FROM orders; -- privileges extra column

/* Find tables that include a particular column */
SELECT table_name FROM information_schema.columns 
	WHERE column_name ='orderNumber';
SELECT DISTINCT table_name FROM information_schema.columns WHERE 
	table_schema='classicmodels1' ;

#2.Users & Roles
SELECT user,host FROM mysql.user;

CREATE USER IF NOT EXISTS david@localhost IDENTIFIED BY 'Secret!Pass1$';
SELECT user,host FROM mysql.user WHERE 
	user = 'david' AND host = 'localhost';

CREATE USER IF NOT EXISTS dolphin@localhost IDENTIFIED BY 'Secret!Pass1$';
ALTER USER dolphin@localhost ACCOUNT LOCK;

SELECT user,host ,account_locked FROM mysql.user WHERE user = 'dolphin';
SHOW CLOBAL STATUS LIKE 'locked_connects';

--Manage Roles
--create a db :crmdb & a customers[id,first_name,last_name,phone,email] table
CREATE SCHEMA IF NOT EXISTS crmdb;
USE crmdb;

CREATE TABLE customers(
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL, 
    last_name VARCHAR(255) NOT NULL, 
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(255)
);
INSERT INTO customers(first_name,last_name,phone,email)
VALUES('John','Doe','(408)-987-7654','john.doe@mysqltutorial.org'),
      ('Lily','Bush','(408)-987-7985','lily.bush@mysqltutorial.org');
SELECT * FROM customers;
/****Create a set of roles for various users that will need read,write or full accees
 *   Then grant privilages to the various roles
 *   Finally,assign roles to user accounts
 *  ***/
CREATE ROLE IF NOT EXISTS crm_dev,crm_read,crm_write;
GRANT ALL ON crmdb.* TO crm_dev;
GRANT SELECT ON crmdb.* TO crm_read;
GRANT INSERT,UPDATE,DELETE TO crm_write;
--create users & assign them roles
CREATE USER IF NOT EXISTS crm_dev_usr1@localhost IDENTIFIED BY   'Kalaseelese$1';
CREATE USER IF NOT EXISTS crm_read_usr1@localhost IDENTIFIED BY  'Kalaseelese$1';
CREATE USER IF NOT EXISTS crm_write_usr1@localhost IDENTIFIED BY 'Kalaseelese$1';
CREATE USER IF NOT EXISTS crm_write_usr2@localhost IDENTIFIED BY 'Kalaseelese$1';

GRANT crm_read TO crm_read_usr1@localhost;
GRANT crm_write,crm_read TO crm_write_usr1@localhost,crm_write_usr2@localhost;
GRANT  crm_dev TO crm_dev_usr1@localhost;

SHOW GRANTS FOR crm_dev;
SHOW GRANTS FOR crm_read;
SHOW GRANTS FOR crm_write;
SHOW GRANTS FOR crm_write_usr1@localhost;
SHOW GRANTS FOR crm_write_usr1@localhost USING crm_write;

--Set [default] roles
--Current user 
SELECT CURRENT_ROLE() ; --NONE
SET ROLE 
###(ii)crm_read_usr1:Connect 
SET DEFAULT ROLE ALL TO crm_read_usr1@localhost;
--Re-connect 
SELECT CURRENT_ROLE() # 'crm_read'@'%'
SET ROLE NONE; 
SET ROLE ALL ;

--Revoke privileges from roles & then restore
REVOKE  INSERT,UPDATE,DELETE ON crmdb.* FROM crm_write;
GRANT INSERT,UPDATE,DELETE on crm.* TO crm_write;

--Copy privileges from a user acount to another
CREATE USER IF NOT EXISTS crm_dev_usr2 IDENTIFIED BY 'Kalaseelese$1';
GRANT crm_dev_usr1 TO crm_dev_usr2 ;

#3.Table Maintainance
USE classicmodels1;
CHECK TABLES customers,oredrs,orderDetails,products;
ANALYZE TABLE customers ;
ANALYZE TABLE customers UPDATE HISTOGRAM ON status,postalCode;
REPAIR TABLE products,orderDetails EXTENDED ;
REPAIR TABLE customers USE_FRM; --Table definition file (.frm)

SHOW TABLE STATU LIKE 'customer' \G --data_length, index_length etc
OPTIMIZE TABLE customers;

#4.Backup ,Restore & execution of MySQL scripts
CREATE DATABASE IF NOT EXISTS sales ; --already exists
USE sales;
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);
INSERT INTO employees (name, email) VALUES
    ('John Doe', 'john.doe@example.com'),
    ('Jane Smith', 'jane.smith@example.com'),
    ('Bob Johnson', 'bob.johnson@example.com'),
    ('Alice Jones', 'alice.jones@example.com'),
    ('Charlie Brown', 'charlie.brown@example.com');

#Back up the database :mysqldump -u vangelis -p -h localhost sales \    
#mysql -u vangelis -p  <  ~/Desktop/SQL/classicmodels/administration/backupSales.sql 
DELETE FROM  employees where id = 3;    
#Restore the database : mysql -u vangelis -p < ~/Desktop/SQL/classicmodels/administration/backupSales.sql
USE sales;
SELECT * FROM employees; 

CREATE TABLE IF NOT EXISTS contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);
INSERT INTO contacts (first_name, last_name, email) VALUES
    ('John', 'Doe', 'john.doe@example.com'),
    ('Jane', 'Smith', 'jane.smith@example.com'),
    ('Bob', 'Johnson', 'bob.johnson@example.com');

--Drop the backup for the sales database :sudo rm -rf backupSales.sql
--back up the database again: msyqldump -u vangelis -p sales > backupSales.sql & exit
INSERT INTO contacts(first_name, last_name, email) VALUES('Bob','Climo', 'bob.climo@example.com');
DELETE FROM contacts; --delete all rows from contacts
SHOW MASTER STATUS ; #File: binlog.000652 Position: 1716,current position of the binary log
--Point -in -Time  Recovery 
DROP DATABASE IF EXISTS  sales ;
CREATE DATABASE IF NOT EXISTS sales;
#mysqldump -u vangelis -p < ~/Desktop/vangelis/SQL/classicmodels/administration/backupSales.sql 
#Recover the rows for the contacts table from the binary log file
SHOW MASTER STATUS;--binlog.000652
SHOW GLOBAL VARIABLES LIKE ''
#mysqlbinlog binlog.000652 | mysql -u vangelis -p 


#5.Other administrative tasks

#Execute SQL file  
$mysql -u myuser -p -v -t -vvv < ~/Desktop/SQL/classicmodels/administration/script.sql 
SELECT * FROM products;


