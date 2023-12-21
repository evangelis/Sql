/*!40014 SET SQL_MODE=''*/;
 /*! SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS,FOREIGN_KEY_CHECKS=0*/;

CREATE DATABASE IF NOT EXISTS classicmodels1;
USE classicmodels1;
DROP TABLE IF EXISTS productlines,products,offices,employees,customers,payments,orders,orderDetails;

CREATE TABLE IF NOT EXISTS productlines (
	productLine      VARCHAR(50),
	textDescription  VARCHAR(40) DEFAULT NULL,
	htmlDescription MEDIUMTEXT,
	image           MEDIUMBLOB ,
	PRIMARY KEY (productLine)
);

CREATE TABLE IF NOT EXISTS products(
	productCode          VARCHAR(15),
	productName			 VARCHAR(70)   NOT NULL,
	productLine  		 VARCHAR(50)   NOT NULL,
	productScale		 VARCHAR(10)   NOT NULL,
	productVendor		 VARCHAR(50)   NOT NULL,
	productDescription	 TEXT          NOT NULL,	
	quantityInStock	     SMALLINT(6)   NOT NULL,
	buyPrice	   		 DECIMAL(10,2) NOT NULL,	
	MSRP                 DECIMAL(10,2) NOT NULL, 
	PRIMARY KEY (productCode),
	CONSTRAINT fk_products_pl  FOREIGN KEY (productLine) REFERENCES productlines (productLine)
);

CREATE TABLE IF NOT EXISTS offices(
	officeCode    VARCHAR(10),
	city		  VARCHAR(50) NOT NULL, 
	phone		  VARCHAR(50) NOT NULL,
	addressLine1  VARCHAR(50) NOT NULL,
	addressLine2  VARCHAR(50) DEFAULT NULL,	
	state 		  VARCHAR(50) DEFAULT NULL, 
	country	      VARCHAR(5)  NOT NULL,
	postalCode	  VARCHAR(15) NOT NULL,	
	territory	  VARCHAR(10) NOT NULL,
	PRIMARY KEY (officeCode)
);

CREATE TABLE IF NOT EXISTS employees(
	employeeNumer INT NOT NULL AUTO_INCREMENT,
	lastName      VARCHAR(50)  NOT NULL,
	firstName     VARCHAR(50)  NOT NULL,
	extension     VARCHAR(10)  NOT NULL, 
	email		  VARCHAR(100) NOT NULL,
	officeCode	  VARCHAR(10)  NOT NULL,  
	reportsTo	  INTEGER      DEFAULT NULL,
	jobTitle	  VARCHAR(50)  NOT NULL,
	PRIMARY KEY (employeeNumer),
	CONSTRAINT fk_employees_offices FOREIGN KEY (officeCode) REFERENCES offices (officeCode),
	CONSTRAINT fk_employees_reportsTo FOREIGN KEY (reportsTo) REFERENCES employees (employeeNumber)
);

CREATE TABLE IF NOT EXISTS customers(
	customerNumber	 INTEGER ,
	customerName	 VARCHAR(50)  NOT NULL,
	contactLastName  VARCHAR(50)  NOT NULL, 	
	contactFirstName VARCHAR(50)  NOT NULL,
	phone			 VARCHAR(50)  NOT NULL,
	addressLine1	 VARCHAR(50)  NOT NULL,
	addressLine2	 VARCHAR(50)  DEFAULT NULL,
	city			 VARCHAR(50)  NOT NULL,
	state  			 VARCHAR(50)  DEFAULT NULL, 
	salesRepEmployeeNumber INT    DEFAULT NULL,
	creditLimit      DECIMAL(10,2) DEFAULT NULL,      
	PRIMARY KEY (customerNumber),
	CONSTRAINT fk_customers_employees FOREIGN KEY (salesRepEmployeeNumber) REFERENCES customers(employeeNumer)
);

CREATE TABLE IF NOT EXISTS payments(
	customerNumber INTEGER,
	checkNumber    VARCHAR(50)   NOT NULL,
	paymentDate	   DATE          NOT NULL,	
	amount 		   DECIMAL(10,2) NOT NULL,	
	PRIMARY KEY (customerNumber,checkNumber),
	CONSTRAINT fk_payments_customers FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

CREATE TABLE IF NOT EXISTS orders(
	orderNumber    INTEGER,
	orderDate      DATE        NOT NULL, 
	requiredDate   DATE 	   NOT NULL,
	shippedDate    DATE 	   NOT NULL,
	status         VARCHAR(15) NOT NULL,
	comments       TEXT,
	customerNumber INT 		   NOT NULL,
	PRIMARY KEY (orderNumber),
	CONSTRAINT fk_orders_customers FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

CREATE TABLE IF NOT EXISTS orderDetails(
	orderNumber      INTEGER,
	productCode	     VARCHAR(15)   NOT NULL,
	quantityOrdered	 INTEGER       NOT NULL,
	priceEach		 DECIMAL(10,2) NOT NULL,
	orderLineNumber  SMALLINT(6)   NOT NULL,
	PRIMARY KEY (orderNumber,productCode),
	CONSTRAINT fk_od_orders FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber),
	CONSTRAINT fk_od_products FOREIGN KEY (productCode) REFERENCES products(productCode)
);