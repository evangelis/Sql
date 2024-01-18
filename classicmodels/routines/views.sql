/************************************************************************************************************************
CREATE [OR REPLACE]
    [ALGORITHM={UNDEFINED|TEMPTABLE|MERGE}][DEFINER=usr]
    [SQL SECURITY {DEFINER|INVOKER}]
    VIEW [dbName.]viewName [(column_list)] AS SELECT select_list
    [WITH [CASCADED|LOCAL] CHECK OPTION];

DROP VIEW [IF EXISTS] [RESTRICT|CASCADE]; --Restrict, Cascade are ignored
ALTER [ALGORITHM={UNDEFINED|MERGE|TEMPTABLE}] [DEFINER=usr]
    [SQL SECURITY {DEFINER|INVOKER}]
    VIEW [dbName.]viewName AS SELECT select_list
   [WITH [CASCADED|LOCAL] CHECK OPTION];
DROP VIEW [IF EXISTS] viewName1 [,..viewName2,..] [RESTRICT|CASCADE]
SHOW CREATE VIEW viewName;
SELECT table_name view_name,is_updatable FROM information_schema.views
        WHERE table_schema ='dbName';
SHOW FULL TABLES [{FROM|IN} dbName] [{WHERE table_type='VIEW'|LIKE 'patt'};

Views :Are named queries stored  in the same namespace as tables;they are virtual tables
 They simplify complex queries ,having them stored and issuing a select statement every time
we need this query
 Views add extra layer of security :By Using views with privileges we limit which users have 
access to what data
 When creating a view specify the OR REPLACE clause ,if the view already exists.Explicitly 
specifying the list of columns next to the view name 
 1.Updatable views: issuing INSERT,UPDATE,DELETE to insert/update/delete rows in/from the base table
   However,the view must not contain the following:
    Aggregations:[GROUP BY, HAVING], agg functions (max(),sum(),etc),
    Joins :[LEFT JOIN],
    DISTINCT,Subqueries in SELECT or WHERE clause
 2.Rename views:

    SHOW CREATE VIEW viewName
    RENAME TABLE viewName TO new_view_name;
    ALTER TABLE viewName RENAME TO new_view_name;
    SHOW FULL TABLES WHERE table_type='VIEW';
 3.With Check option :Prevents a view from updating,inserting or deleting (DML statements)
   rows.MySQL checks to ensure that the changes being introduced through the view are
   compatible with the view definition

 4.Cascaded & Local check option :The scope of the 'with check option' is {LOCAL|CASCADED}
   WITH CASCADED VIEW: MySQL checks the rules of this view and all dependent views


***********************************************************************************************************************/

USE classicmodels1;
SELECT table_name FROM information_schema.tables WHERE table_type = 'VIEW';
SHOW FULL TABLES FROM classicmodels1 WHERE TABLE_TYPE ='VIEW'  \G
SELECT table_name,is_updatable FROM information_schema.views WHERE 
    table_schema = 'classicmodels1'
--1.total sales per order :orderDetails table [orderNumber,productCode,quantityOrdered,priceEach,orderLineNumber]
CREATE OR REPLACE ALGORITHM = UNDEFINED DEFINER = 'vangelis'@'localhost' SQL SECURITY DEFINER VIEW salePerOrder 
    AS SELECT
    orderNumber, SUM(quantityOrdered*priceEach) total
 FROM orderDetails GROUP BY orderNumber ORDER BY total DESC;
SHOW FULL TABLES WHERE TABLE_TYPE ='VIEW';
SELECT * FROM salePerOrder LIMIT 3;

#(1.i) bigSaleOrder is based on the salePerOrder 
CREATE OR REPLACE ALGORITHM =UNDEFINED DEFINER =CURRENT_USER SQL SECURITY DEFINER VIEW bigSaleOrder AS SELECT 
    orderNumber ,ROUND(total,2) as total FROM salePerOrder 
    WHERE total > 60000 ;

--2.customer payments
CREATE OR REPLACE ALGORITHM = UNDEFINED DEFINER = CURRENT_USER SQL SECURITY DEFINER
    VIEW customerPayments AS SELECT
   customerName,checkNumber, paymentDate, amount
 FROM customers
  INNER JOIN payments  USING (customerNumber);
  ORDER BY amount DESC;
SELECT *FROM customerPayments LIMIT 4;

#3.customerOrders :Is based on multiple tables [orderDetails,orders,customers]
CREATE OR REPLACE ALGORITHM= UNDEFINED DEFINER = 'root'@'localhost' SQL SECURITY DEFINER
    VIEW customerOrders AS SELECT 
   orderNumber,customerName, SUM(quantityOrdered*priceEach) total FROM orderDetails
  INNER JOIN orders USING(orderNumber) INNER JOIN customers USING (customerNumber)
  GROUP BY orderNumber;

#(3i)customerOrderStats [customers,orders] :Explicit columns
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER =CURRENT_USER SQL SECURITY DEFINER 
    VIEW custmerOrderStats(customerName,orderCount) AS SELECT
   customerName,COUNT(orderNumber) 
 FROM customers  INNER JOIN orders USING (customerNumber) GROUP BY customerName;   

SELECT customerName, orderCount FROM custmerOrderStats ORDER BY orderCount,customerName;

--4.Updatable view: officeInfo: change the phone number of office with code=4
CREATE OR REPLACE ALGORITHM= UNDEFINED DEFINER='root'@'localhost' SQL SECURITY DEFINER
    VIEW officeInfo AS SELECT officeCode,phone,city
  FROM offices;
SELECT * FROM officeInfo;
UPDATE officeInfo SET phone = '+33 14 723 5555' WHERE officeCOde=4;
SELECT * FROM officeInfo WHERE officeCode =4;

--5.productLineSales [productlines,products,orderDetails]
CREATE OR REPLACE ALGORITHM = UNDEFINED DEFINER =CURRENT_USER SQL SECURITY DEFINER 
    VIEW productLineSales AS SELECT
       productLine,SUM(quantityOrdered)  totalQtyOrdered
   FROM productlines
    INNER JOIN products USING (productLine)
    INNER JOIN orderDetails USING (productCode)
   GROUP BY productLine;
RENAME TABLE productLineSales TO productLineQtySales;
SHOW FULL TABLES FROM classicmodels1 WHERE TABLE_TYPE = 'VIEW';


--6.check option:vps [employees]
CREATE OR REPLACE VIEW vps AS SELECT
    employeeNumber,lastname,firstname, jobtitle,extension,
    email,officeCode,reportsTo
    FROM employees WHERE jobTitle= '%VP%'
   WITH CHECK OPTION;
SELECT * FROM vps;

/***** 1 --insert a row into employees through the vps updatable view whose
--jobTitle = 'IT Manager' is ok,but this employee is not visible through the vps view
 2.use the WITH CHECK OPTION at the end of the view definition
  The following produces an Error code CHECK OPTION failed 'classicmodels1.vps'

****/

INSERT INTO vps(employeeNumber,firstname,lastname,jobtitle,extension,email,officeCode,reportsTo)
VALUES(1704,'John','Smith','IT Staff','x9112','johnsmith@classicmodelcars.com',1,1703);


--7. aboveAvgProducts:[products] ,uses subqueries
CREATE OR REPLACE ALGORITHM = UNDEFINED DEFINER =CURRENT_USER SQL SECURITY DEFINER  
    VIEW aboveAvgProducts AS SELECT productCode,productName,buyPrice FROM products
    WHERE buyPrice > (SELECT AVG(buyPrice) FROM products) ORDER BY buyPrice DESC;

    SELECT table_name view_name FROM information_schema.tables WHERE 
        table_type ='VIEW' AND table_schema ='classicmodels1' AND TABLE_NAME LIKE 'customer%';


--8. employee_countries :[employees,offices]
CREATE OR REPLACE ALGORITHM =UNDEFINED DEFINER =CURRENT_USER SQL SECURITY DEFINER 
    VIEW employee_countries AS SELECT 
 employeeNumber,firstName,lastName,country 
 FROM employees INNER JOIN offices USING (officeCode);

SHOW CREATE VIEW employee_countries \G 
/**** Updatable Views: Can use UPDATE & INSERT statements to add or modify rows of the base table
 *      through the updatable view
 *  Cannot include aggregate functions ,group by ,having distinct, union, left join ,outer join,
 *  subquery in where clause
 * The WITH CHECK OPTION prevents from updating or inserting rows to a table that are not visible
 *  through the view
 * The scope of check option can be local or cascaded
 * 
 * 
***/


#################################################################################################################################################


USE studentdb;
SHOW FULL TABLES FROM 'studentdb' WHERE TABLE_TYPE ='VIEW';
SELECT * FROM information_schema.tables WHERE table_type='VIEW' AND table_schema ='studentdb' \G 


CREATE OR REPLACE DEFINER = 'vangelis'@'localhost' VIEW daysofWeek (day) AS SELECT
    'MON' UNION SELECT 'TUS' UNION SELECT  'WED' UNION SELECT 'THU'
    UNION SELECT 'FRI' UNION SELECT 'SAT' UNION SELECT 'SUN';
SELECT *FROM daysofWeek;

-- create a new table named items
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(11 , 2 ) NOT NULL
);

--insert data into the items table
INSERT INTO items(name,price) VALUES('Laptop',700.56),('Desktop',699.99);

--create a view based on the items table
CREATE OR REPLACE ALGORITHM = UNDEFINED DEFINER = CURRENT_USER SQL SECURITY DEFINER 
    VIEW LuxuryItems AS SELECT * FROM items WHERE price >700 ORDER BY price DESC;
--Delete row with id=3
DELETE FROM LuxuryItems WHERE id =3;
SELECT * FROM LuxuryItems;
SELECT * FROM items;

--{local|cascaded} check option
CREATE TABLE IF NOT EXISTS t1(c INT );
CREATE OR REPLACE VIEW v1 AS SELECT c FROM t1
    WHERE c>10;
CREATE OR REPLACE VIEW v2 AS SELECT c FROM v1
    WHERE c>10 WITH CASCADED CHECK OPTION;

CREATE OR REPLACE VIEW v3 AS SELECT
    c FROM v2 WHERE c < 20;

INSERT INTO v1(c) VALUES (5); --it shouldn't insert this value
INSERT INTO v2(c) VALUES (5); --Error Code: 1369. CHECK OPTION failed 'classicmodels1.v2'
INSERT INTO v3(c) VALUES (8); --Error Code:1369.CHECK OPTION failed 'classicmodels1.v3'
INSERT INTO v3(c) VALUES (30); --works ok,(no check option)

ALTER VIEW v2 AS SELECT
    c FROM v1
    WITH LOCAL CHECK OPTION;
INSERT INTO v2(c) VALUES (5); --No rules apply (no check option)
INSERT INTO v3(c) VALUES (8);--It succeeds due to local check option of the v2 view,
                            --check of v1 wont apply



CREATE TABLE IF NOT EXISTS employees(
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL
);

INSERT INTO employees (type, name) VALUES
('Full-time', 'John Doe'),('Contractor', 'Jane Smith'),('Temp', 'Alice Johnson'),
('Full-time', 'Bob Anderson'),('Contractor', 'Charlie Brown'),
('Temp', 'David Lee'),('Full-time', 'Eva Martinez'),('Contractor', 'Frank White'),
('Temp', 'Grace Taylor'),('Full-time', 'Henry Walker'),
('Contractor', 'Ivy Davis'),('Temp', 'Jack Turner'),
('Full-time', 'Kelly Harris'),('Contractor', 'Leo Wilson'),
('Temp', 'Mia Rodriguez'),('Full-time', 'Nick Carter'),
('Contractor', 'Olivia Clark'),('Temp', 'Pauline Hall'),('Full-time', 'Quincy Adams');

SELECT * FROM employees LIMIT 3;
#contractors view :Updatable view
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER = CURRENT_USER SQL SECURITY DEFINER 
    VIEW contractors AS SELECT id,type,name FROM employees WHERE type = 'Contractor'
    ORDER BY name;
--insert a row to the the underlying table (employees) through the view
INSERT INTO contractors(name,type) VALUES ('Andy Black','Contractor'),('Deric Seetoh', 'Full-time');
SELECT * FROM employees WHERE name like 'Deric%' OR name like 'And%';

--Prevent inserting rows to the employees table through the contractors view
ALTER ALGORITHM =UNDEFINED DEFINER =CURRENT_USER SQL SECURITY DEFINER VIEW contractors 
    AS SELECT id,type,name FROM employees WHERE type ='Contractor'  
    ORDER BY name WITH CHECK OPTION;
-- INSERT INTO contractors(name, type) VALUES('Brad Knox', 'Full-time');#Error 1369

