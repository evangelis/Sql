/**********************************************************************************************************************
CREATE [DEFINER=usr] TRIGGER [IF NOT EXISTS] trigName;
    {BEFORE|AFTER} {INSERT|UPDATE|DELETE} ON tblName FOR EACH ROW
    [{PRECEDES|FOLLOWS} otherTrigName]
  BEGIN
     statements;
  END;
DROP TRIGGER [IF EXISTS] [dbName.]trigName;
SHOW TRIGGERS [{FROM|IN}dbName] [{LILKE 'patt'|WHERE cond}];
SHOW CREATE TRIGGER trigName;

 Triggers:Is a stored program that insert is invoked automatically in response to  INSERT,DELETE,UPDATE operations
  They are an altrernative to run scheduled tasks
  They provide another way to check integrity of  the data & handle errors from the database layer
 1.The trigger body can access the values of the columns being affected by the DML statement
   To distinguish between the values of he columns  before and after the DML has fired , you can use the
   OLD,NEW modifiers
    Trigger Event  Modifiers allowed
    INSERT           NEW
    UPDATE           OLD,NEW
    DELETE           OLD




***********************************************************************************************************************/
USE classicmodels1;
--employees_audit  keeps the changes of the employees table
CREATE TABLE IF NOT EXISTS employees_audit (
    INT AUTO_INCREMENT PRIMARY KEY,employeeNumber INT NOT NULL,
    lastName VARCHAR(50) NOT NULL, changedate DATETIME DEFAULT NULL,
    action VARCHAR(50) DEFAULT NULL
);





--------------------------------------------------------------------------------
USE studentdb;
--1.Before Insert

CREATE TABLE IF NOT EXISTS WorkCenters (
    id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL
);
DROP TABLE IF EXISTS WorkCenterStats;

CREATE TABLE WorkCenterStats(
    totalCapacity INT NOT NULL
);

DELIMITER $$
--Trigger updates the total capacity of the WorkCenterStats table before a new work center
--is inserted into the WorkCenter table
CREATE TRIGGER IF NOT EXISTS before_workcenters_insert
    BEFORE INSERT ON WorkCenters FOR EACH ROW
 BEGIN
   DECLARE rowCnt INT DEFAULT 0;
   SELECT COUNT(*) INTO rowCnt FROM WorkCenterStats;
   IF rowCnt > 0 
        THEN UPDATE WorkCenterStats SET totalCapacity = totalCapacity + NEW.capacity;
   ELSE 
        INSERT INTO WorkCenterStats(totalCapacity) VALUES (new.capacity) ;
    END IF;
 END $
DELIMITER ;

INSERT INTO WorkCenters(name, capacity) VALUES('Mold Machine',100);
INSERT INTO WorkCenters(name, capacity) VALUES('Packing',200);
SELECT * FROM WorkCenterStats;

--2.After Insert Trigger:Inserts a reminder into the reminders table
     --if the birth date of birth is NULL
CREATE TABLE IF NOT EXISTS members (
    id INT AUTO_INCREMENT,name VARCHAR(100) NOT NULL,
    email VARCHAR(255),  birthDate DATE,
    PRIMARY KEY (id)
);
CREATE TABLE reminders (
    id INT AUTO_INCREMENT,
    memberId INT,message VARCHAR(255) NOT NULL,
    PRIMARY KEY (id , memberId)
);
DELIMITER $$
CREATE DEFINER='root'@'localhost' TRIGGER IF NOT EXISTS after_members_insert
    AFTER INSERT ON members FOR EACH ROW
 BEGIN
  IF NEW.birthDate IS NULL THEN INSERT INTO reminders (memberId,message) VALUES
    (NEW.id,CONCAT('Hi ',NEW.name,' please update your date of birth'));
  END IF;
 END$$
DELIMITER;
INSERT INTO members(name, email, birthDate) VALUES
    ('John Doe', 'john.doe@example.com', NULL), ('Jane Doe', 'jane.doe@example.com','2000-01-01');
SELECT * FROM reminders;

--3i.A BEFORE UPDATE trigger that is associated with the billings table

CREATE TABLE billings (
    billingNo INT AUTO_INCREMENT,customerNo INT,
    billingDate DATE,amount DEC(10 , 2 ),
    PRIMARY KEY (billingNo)
);

DELIMITER $$
CREATE TRIGGER IF NOT EXISTS before_billing_update
    BEFORE UPDATE ON billings FOR EACH ROW
  BEGIN
    IF new.amount >old.amount*10 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New amount cannot be 10 times greater than the current amount.';
    END IF;
  END$$
DELIMITER;

--3ii.Before Update :check the quantity column ,signalling an error
DROP TABLE IF EXISTS sales;

CREATE TABLE IF NOT EXISTS sales (
    id INT AUTO_INCREMENT, product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,fiscalYear SMALLINT NOT NULL,
    fiscalMonth TINYINT NOT NULL,
    CHECK (fiscalMonth >=1 AND fiscalMonth<=12),
    CHECK (fiscalYear BETWEEN 2001 AND 2050),
    CHECK (quantity >=0),
    UNIQUE (product,fiscalYear,fiscalMonth),
    PRIMARY KEY(id)
);

INSERT INTO sales(product, quantity, fiscalYear, fiscalMonth) VALUES
    ('2003 Harley-Davidson Eagle Drag Bike',120, 2020,1),
    ('1969 Corvair Monza', 150,2020,1),
    ('1970 Plymouth Hemi Cuda', 200,2020,1);
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS before_sales_update BEFORE UPDATE ON sales FOR EACH ROW
 BEGIN
   DECLARE errorMessage VARCHAR(255);
   SET errorMessage = CONCAT('The new quantity ',NEW.quantity ,
        'cannot be 3 times greater than the current quantity ',OLD.quantity);
   IF NEW.quantity >old.quantity * 3 THEN SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT=errorMessage;
   END IF;
 END $$
DELIMITER ;

--let's update the sales table accordingly ,setting  a high quantity
UPDATE sales SET quantity = 150 WHERE id =1;
SHOW ERRORS;

#4i.After update : items_update_trigger 
CREATE TABLE IF NOT EXISTS items (
    id INT PRIMARY KEY,name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS item_changes(
    change_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT,
    change_type VARCHAR(10),
    chanage_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items (id)
);

DELIMITER $$
CREATE DEFINER =CURRENT_USER TRIGGER IF NOT EXISTS items_update_trigger 
    AFTER UPDATE ON items FOR EACH ROW BEGIN 

    INSERT INTO item_changes (item_id,change_type) VALUES 
        (NEW.id ,'UPDATE') 
 END $$       
DELIMITER ;

INSERT INTO items(id, name, price) VALUES (1, 'Item', 50.00);
UPDATE itemsSET price = 60.00  WHERE id = 1;
SELECT * FROM item_changes;

#4.ii after update on sales
DROP TABLE IF EXISTS SalesChanges;
CREATE TABLE IF NOT EXISTS SalesChanges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    salesId INT,
    beforeQuantity INT,
    afterQuantity INT,
    changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Sales(product, quantity, fiscalYear, fiscalMonth) VALUES
    ('2001 Ferrari Enzo',140, 2021,1),
    ('1998 Chrysler Plymouth Prowler', 110,2021,1),
    ('1913 Ford Model T Speedster', 120,2021,1);
DELIMITER $$
CREATE DEFINER = 'root'@'localhost' TRIGGER after_sales_update AFTER UPDATE ON sales FOR EACH ROW
 BEGIN
   IF old.quantity <>new.quantity THEN
      INSERT INTO SalesChanges(salesId,beforeQUantity,afterQuantity) VALUES
      (OLD.id,OLD.quantity,NEW.quantity)
   END IF;
 END$$
DELIMITER;
UPDATE Sales SET quantity = 350 WHERE id = 1;
UPDATE Sales SET quantity = CAST(quantity*1.1 AS UNSIGNED);
SELECT * FROM SalesChanges;

--5.Before Delete: Create a table to store deleted salaries & a trigger than inserts
    -- a row in SalaryArchives before a delete in Salaries table takes place
DROP TABLE IF EXISTS Salaries;

CREATE TABLE IF NOT EXISTS Salaries (
    employeeNumber INT PRIMARY KEY,validFrom DATE NOT NULL,
    amount DEC(12 , 2 ) NOT NULL DEFAULT 0
);
INSERT INTO salaries(employeeNumber,validFrom,amount) VALUES
    (1002,'2000-01-01',50000),(1056,'2000-01-01',60000),(1076,'2000-01-01',70000);

CREATE TABLE IF NOT EXISTS SalaryArchives (
    id INT PRIMARY KEY AUTO_INCREMENT,employeeNumber INT
    validFrom DATE NOT NULL,
    amount DEC(10,2) NOT NULL DEFAULT 0,
    deletedAt TIMESTAMP DEFAULT NOW()
);

DELIMITER $$
CREATE DEFINER= 'root'@'localhost' TRIGGER IF NOT EXISTS before_salaries_delete
    BEFORE DELETE ON Salaries FOR EACH ROW
 BEGIN
  INSERT INTO SalariesArchives(employeeNumber,validFrom,amount) VALUES
    (OLD.employeeNumber,OLD.validFrom,OLD.amount);
 END$$
 DELIMITER;

DELETE FROM Salaries WHERE employeeNumber=1002;
SELECT * FROM SalaryArchives;

--6.After Delete Trigger:SalaryBudgets stores the total of salaries from the Salaries2 table
    --Trigger updates the 
DROP TABLE IF EXISTS Salaries2;

CREATE TABLE IF NOT EXISTS Salaries2 (
    employeeNumber INT PRIMARY KEY,
    salary DECIMAL(10,2) NOT NULL DEFAULT 0
);
INSERT INTO Salaries2 (employeeNumber,salary) VALUES
    (1002,5000),(1056,7000),(1076,8000);

CREATE TABLE IF NOT EXISTS SalaryBudgets (
    total DECIMAL(15,2) NOT NULL
);
INSERT INTO IGNORE SalaryBudgets(total) SELECT SUM(salary) FROM Salaries2;
#after delete trigger in SalaryBudgets when a row in Salaries2 is deleted

CREATE DEFINER = CURRENT_USER TRIGGER IF NOT EXISTS salaries2_aft_del 
    AFTER DELETE ON Salaries2 FOR EACH ROW 
   UPDATE SalaryBudgets SET total = total - old.salary;
DELIMITER ;

DELETE FROM Salaries WHERE employeeNumber = 1002;
SELECT * FROM SalaryBudgets;
-------------------------------
USE classicmodels1;

--7.Multiple Triggers
/**** Create price_logs table
   Create trigger before_products_update for a BEFORE UPDATE event on the products table.
   Log the person who changed the price by creating the UserChangeLogs table &
   A before_products_update_log_user trigger for BEFORE UPDATE events on products table
   Change the price of a product
***/
CREATE TABLE IF NOT EXISTS PriceLogs (
    id INT AUTO_INCREMENT NOT NULL,
    productCode VARCHAR(15) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(id),
    FOREIGN KEY fk_priceLogs_products (productCode) REFERENCES products (productCode)
            ON DELETE CASCADE ON UPDATE CASCADE
);
DELIMITER $$
CREATE DEFINER ='root'@'localhost' TRIGGER IF NOT EXISTS before_products_update
    BEFORE UPDATE ON products FOR EACH ROW
 BEGIN
    IF OLD.msrp <>NEW.msrp THEN INSERT INTO priceLogs(productCode,price) VALUES
         (OLD.productCode,OLD.msrp);
    END IF;
 END $$
DELIMITER ;
SELECT *FROM PriceLogs ;
UPDATE products SET msrp=200 WHERE productCode= 'S12_1099';
SELECT * FROM PriceLogs;

CREATE TABLE UserChangeLogs (
    id INT AUTO_INCREMENT,
    productCode VARCHAR(15) DEFAULT NULL,
    updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    updatedBy VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY fk_UserChangeLogs_products (productCode) REFERENCES products(productCode)
        ON DELETE CASCADE ON UPDATE CASCADE
);
DELIMITER $$
CREATE DEFINER ='vangelis'@'localhost' TRIGGER IF NOT EXISTS before_products_update_log_user
    BEFORE UPDATE ON products FOR EACH ROW FOLLOWS before_products_update
 BEGIN
    IF old.msrp <>new.msrp THEN INSERT INTO UserChangeLogs(productCode,updatedBy) VALUES
       (old.productCode,USER());
    END IF;
  END $$
DELIMITER;
SHOW TRIGGERS FROM classicmodels1 WHERE table='employees';
------------------------------------------
SHOW TRIGGERS FROM classicmodels1;
SHOW TRIGGERS IN classicmodels1 WHERE table ='customers' OR table ='products';
SHOW TRIGGERS FROM studentdb;
SHOW TRIGGERS FROM studentdb WHERE table = 'Sales';