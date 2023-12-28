/************************************************************************************************************************
CREATE [OR REPLACE]
    [ALGORITHM={}][DEFINER=usr]
    [SQL SECURITY {DEFINER|INVOKER}]
    VIEW viewName [(column_list)] AS SELECT select_list
    [WITH [CASCADED|LOCAL] CHECK OPTION];

DROP VIEW [IF EXISTS] [RESTRICT|CASCADE]; --Restrict, Cascade are ignored
ALTER [ALGORITHM=] [DEFINER=usr]
    [SQL SECURITY {DEFINER|INVOKER}]
    VIEW viewName AS SELECT select_list
   [WITH [CASCADED|LOCAL] CHECK OPTION];
DROP VIEW [IF EXISTS] viewName1 [,..viewName2,..] [RESTRICT|CASCADE]
SHOW CREATE VIEW viewName;
SELECT tblName,is_updatable FROM information_schema.views
        WHERE table_schema ='dbName';
SHOW FULL TABLES WHERE table_type='VIEW';

Views :Are named queries stored  in the same namespace as tables;they are virtual tables
 They simplify complex queries ,having them stored and issuing a select statement every time
 we need this query
 Views add extra layer of security :Using views with privileges we limit which users have access
 to what data
 1.Updatable views: issuing INSERT,UPDATE,DELETE to insert/update/delete rows in/from the base table
   However,the view must not contain the following:
    Aggregations:[GROUP BY, HAVING], agg functions (max(),sum(),etc),
    Joins :[LEFT JOIN],
    DISTINCT,Subqueries insert in SELECT or WHERE clause
 2.Rename views:

    SHOW CREATE VIEW viewName
    RENAME vieName TO new_view_name;
    ALTER TABLE
    SHOW FULL TABLES WHERE table_type='VIEW';
 3.With Check option :Prevents a view from updating,inserting or deleting (DML statements)
   rows,MySQL checks to ensure that the changes being introduced through the view are
   compatible with the view definition

 4.Cascaded & Local check option :The scope of the 'with check option' is {LOCAL|CASCADED}
   WITH CASCADED VIEW: MySQL checks the rules of this view and all dependent views


***********************************************************************************************************************/

USE classicmodels1;

--1.total sales per order :orderDetails table [orderNumber,productCode,quantityOrdered,priceEach,orderLineNumber]
CREATE VIEW salePerOrder AS SELECT
    orderNumber, SUM(quantityOrdered*priceEach) total
 FROM orderDetails GROUP BY orderNumber ORDER BY total DESC;
SHOW FULL TABLES WHERE TABLE_TYPE ='view';
SELECT * FROM salePerOrder LIMIT 3;

--2.customer payments
CREATE VIEW customerPayments AS SELECT
   customerName,checkNumber, paymentDate, amount
 FROM customers
  INNER JOIN customerPayments  USING (customerNumber);
SELECT *FROM customerPayments LIMIT 4;

--3.Updatable view: officeInfo: change the phone number of office with code=4
CREATE DEFINER='root'@'localhost' SQL SECURITY INVOKER
    VIEW IF NOT EXISTS officeInfo AS SELECT officeCode,phone,city
  FROM offices;
SELECT * FROM officeInfo;
UPDATE officeInfo SET phone = '+33 14 723 5555' WHERE officeCOde=4;
SELECT * FROM officeInfo WHERE officeCode =4;

--4.productLineSales [productLines,products,orderDetails]
CREATE VIEW IF NOT EXISTS productLineSales AS SELECT
    productLine,SUM(quantityOrdered)  totalQrtyOrdered
   FROM productLines
    INNER JOIN products USING (productLine)
    INNER JOIN orderDetails USING (productCode)
   GROUP BY productLine;

--5.check option:vps [employees]
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

USE studentdb;
CREATE VIEW daysofWeek (day) AS SELECT
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
INSERT INTO items(name,price)
VALUES('Laptop',700.56),('Desktop',699.99

--create a view based on the items table
CREATE VIEW LuxuryItems AS SELECT * FROM items WHERE price >700;
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




