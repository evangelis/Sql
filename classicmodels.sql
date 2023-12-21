/*!40014 SET SQL_MODE=''*/;
 /*! SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS,FOREIGN_KEY_CHECKS=0*/;
/*!*/;  
CREATE DATABASE IF NOT EXISTS classicmodels;
USE classicmodels;

CREATE TABLE IF NOT EXISTS productlines (
	productLine      VARCHAR(50),
	textDescription  
	htmlDescription MEDIUMTEXT,
	image           BLOB ,
	PRIMARY KEY (productLine)
);

CREATE TABLE IF NOT EXISTS products(
	productCode,
	productName
	productLine
	productScale
	productVendor
	productDescription
	quantityInStock
	buyPrice
	MSRP
	PRIMARY KEY (productCode),
	FOREIGN KEY ()
);

CREATE TABLE IF NOT EXISTS offices(
	officeCode
	city
	phone
	addressLine1
	addressLine2
	state 
	country
	postalCode
	territory
	PRIMARY KEY (officeCode)
);

CREATE TABLE IF NOT EXISTS employees(
	employeeNumer
	lastName
	firstName
	extension
	email
	officeCode
	reportsTo
	jobTitle
	PRIMARY KEY (employeeNumer),
	FOREIGN KEY ()

);

CREATE TABLE IF NOT EXISTS customers(
	customerNumber
	customerName
	contactLastName
	contactFirstName
	phone
	addressLine1
	addressLine2
	city
	state
	salesRepEmployeeNumber
	creditLimit
	PRIMARY KEY (customerNumber),
	FOREIGN KEY ()
);

CREATE TABLE IF NOT EXISTS payments(
	customerNumber
	checkNumber
	paymentDate
	amount 
	PRIMARY KEY (C),
	FOREIGN KEY ()
);

CREATE TABLE IF NOT EXISTS orders(
	orderNumber
	orderDate
	requiredDate
	shippedDate
	status
	comments
	customerNumber
	PRIMARY KEY (orderNumber),
	FOREIGN KEY ()
);

CREATE TABLE IF NOT EXISTS orderDetails(
	orderNumber
	productCode
	quantityOrdered
	priceEach
	orderLineNumber
	PRIMARY KEY (orderNumber,productCode),
	FOREIGN KEY ()
);