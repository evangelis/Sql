/***********************************************************************************************************************
CREATE [DEFINER =usr] PROCEDURE IF NOT EXISTS procName({IN|OUT|INOUT}param1 type1,[,...])
   [ {COMMENT 'str'| READS SQL|MODIFIES SQL DATA|NO SQL|CONTAINS SQL}|LANGUAGE SQL|
    SQL SECURITY {DEFINER|INVOKER}]
   proc_body;

CREATE [DEFINER=usr] FUNCTION [IF NOT EXISTS] funcName(param1 type1,[...]) RETURNS type2
    [characteristic]
    funcBody;
 ALTER PROCEDURE procName [characteristic]
 ALTER FUNCTION funcName [characeristic]
    characteristic:{
        COMMNET 'str'|LANGUAGE SQL|
            {READS SQL | NO SQL|MODIFIES SQL DATA|CONTAINS SQL}|
        SQL SECURITY {DEFINER|INVOKER}
   }
DROP {PROCEDURE|FUNCTION} routineName;
SHOW CREATE {PROCEDURE|FUNCTION} routineName;
SHOW {PROCEDURE|FUNCTION} STATUS [{LIKE 'pattenr'|WHERE expr}] \G
SHOW {FUNCTION|PROCEDURE} CODE routineName ;--presentation of the internal implementation of the named stored routine
SELECT routine_name FROM information_schema.routines
    WHERE routine_type ={FUNCTION|PROCEDURE} AND routine_schema= 'dbName';
 Notes
    1. Procedure parameters: [IN|OUT|INOUT] param1 type1[(length)];
      IN is the default mode,the calling program (call proName(param1,..)) must pass an arg to the stored procedure
      Even if you change the value of the IN param inside the procedure,its original value remains unchanged,
      implying that the caller works on a copy of the variable
      OUT:the value of OUT parameters can be modified inside the procedure
      INOUT:The calling program must pass the argument and the stored procedure may modify the value of the parameter
       passing it back to the caller program


A.Prerequisites
 1.Conditional Statements[IF,CASE]
    IF CONDITION THEN stmts;[ELSEIF elseIfStmts...;ELSE elseStmts;] END IF;
   Statement IF ..THEN ..ELSEIF ...ELSE :Evaluate >=1 conditions & execute the corresponding code
   if the condition is true
      IF ..THEN #Evaluates 1 condition and executes a block of code if the condition is true
      IF ..THEN..ELSE #Evaluates 1 condition >>  >>.Otherwise ,it executes another code block
      IF ..THEN ..ELSEIF..ELSE#Evaluates multiple conditions & executes a block of code if a
    CASE case_val:                      | CASE
         WHEN when_val1 THEN stmts;     |      WHEN search_cond1 THEN stmts;
         WHEN when_val2 THEN stmts;     |      WHEN search_cond2 THEN stmts;
         [...]                          |      [...]
         [ELSE else_stmts;]             |      [ESLE else_stmts;]
    END CASE;                           | END CASE;
 2.Loops :[LOOP,WHILE,REPEAT,LEAVE & CONTINUE]
    (i)LOOP :-LOOP statement allows us to execute >=1 statements repeated
    [begin_label:]LOOP         [label:]LOOP
       stmts;                     IF condition THEN LEAVE [label];
    END LOOP [end_label];       END LOOP [label];
    (ii) WHILE ..DO loop:A loop that executes a block of code as long as a condition is true
        It checks the search condition at the start of each iteration [pre-test loop ]
    [begin_label:]WHILE search_cond DO
            stmts;
    END WHILE [end_label];
    (iii)Repeat ..UNTIL Loop:A loop that repeatedly executes a block of statements until a condition is true
    [begin_label:]REPEAT
        stmts;
        UNTIL condition
    END REPEAT [end_label];

 3.Cursors:A db object that is used for iterating the results of a SELECT statement
    DECLARE curName CURSOR FOR selectStmt [WHERE condition];
    OPEN curName; # Opens a previously declared cursor
    FETCH [[NEXT] FROM] curName INTO varName1 [,var2,...]#Fetches the next row for the select stmt
                                                        -- associated with the cursor
    CLOSE curName; #Closes a previously opened cursor

  4.
  5.Stored Objects Access Control :DEFINER attribute & SQL SECURITY characteristic
    CREATE DEFINER=usr {FUNCTION|PROCEDURE} [IF NOT EXISTS] routineName ([{IN|OUT|INOUT}]param_list) ...
        SQL SECURITY [DEFINER|INVOKER]
   The DEFINER attribute defaults to CURRENT_USER;You can specify any user if you have the SUPER privilege
   The SQL SECURITY characteristic

***********************************************************************************************************************/
USE classicmodels1;
/*******************
     customers:[customerNumber,customerName,contactlastName,contactFirstName,phone,addressLine1
                addressLine2,city,state,postalCode,country,salesRepEmployeenumber,creditLimit]
***********************************************************************************************************************/
SELECT routime_name FROM inforfation_schema.routines
    WHERE routine_schema='classicmodels1' AND routine_type='PROCEDURE';
SHOW FUNCTION STATUS WHERE db='classicmodels1';
SHOW PROCEDURE STATUS WHERE db='classicmodels1';

--Drop a nonexistent procedure
DROP PROCEDURE IF EXISTS abc;
SHOW WARNINGS;

--totalOder procedure
DELIMITER $$
CREATE DEFINER ='root'@'localhost' PROCEDURE getTotalOrder()
    COMMENT 'Compute number of rows in orders table'
 BEGIN
   DECLARE totalOrder INT DEFAULT 0;
   SELECT COUNT(*) INTO totalOrder FROM orders;
   SELECT totalOrder;
 END$$

 --Office by country procedure
CREATE PROCEDURE IF NOT EXISTS getOfficeByCountry(IN countryName VARCHAR(255))
   COMMENT 'Get all offices that are located in a country specified by the input parameter'
 BEGIN
   SELECT * FROM offices WHERE country = countryName;
 END;

--Procedure:order count (orderNumber) by status =orderStatus[orders table]
CREATE PROCEDURE IF NOT EXISTS orderCountByStatus(
                    IN orderStatus VARCHAR(25),OUT total INT)
    COMMENT 'Returns the number of orders based on their order status'
 BEGIN
   SELECT COUNT(orderNumber) INTO total
   FROM orders WHERE status=orderStatus;
 END $$
DELIMITER ;
CALL orderCountByStatus('Shipped',@total);
SELECT @total;
--getPayments procedure
DELIMITER $$
CREATE DEFINER ='root'@'localhost' PROCEDURE IF NOT EXISTS getPayments()
    COMMENT 'Returns customer & payment info'
    LANGUAGE SQL
 BEGIN
  SELECT customerName,checkNumber,paymentDate, amount
  FROM payments INNER JOIN customers USING (customerNumber);
 END $$
 DELIMITER ;
--getCustomers procedure
SHOW FULL COLUMNS FROM customers;

CREATE PROCEDURE IF NOT EXISTS getCustomers()
 BEGIN
   SELECT customerName,city,state,postalCode,country
   FROM customers ORDER BY customerName;
 END $$

--getCustomerLevel :CALL GetCustomerLevel(447,@level); SELECT @level;
CREATE PROCEDURE IF NOT EXISTS getCustomerLevel(IN pCustNumber INT,OUT pCustLevel VARCHAR(20))
 BEGIN
   DECLARE credit DECIMAL(10,2) DEFAULT 0;
   SELECT creditLimit INTO credit
   FROM customers WHERE customerNumber=pCustNumber;
   IF credit >50000 THEN SET pCustLevel = 'PLATINUM';
   ELSEIF credit <=50000 AND credit > 10000 THEN SET pCustLevel = 'GOLD';
   ELSE SET pCustLevel='SILVER';
 END $$

--getCustomerShipping(): select the customers (customerNumber) and then use CASE to determine shipping time (string)
CREATE DEFINER='root'@'localhost' PROCEDURE IF NOT EXISTS getCustomerShipping(
            IN pCustNumber INT , OUT pShipping VARCHAR(50))
 LANGUAGE SQL SQL SECURITY DEFINER
 BEGIN
  DECLARE customerCountry VARCHAR(100);
 SELECT country INTO customreCountry
 FROM customers WHERE customerNumber=pCustNumber ;
  CASE customerCountry
    WHEN 'USA' THEN pShipping = '2-day Shipping';
    WHEN 'CANADA' THEN pShipping= '3-day Shipping';
    ELSE pShippiing= '5-day Shipping';
  END CASE;
 END$$


--GetDeliveryStatus: [orders]
CREATE DEFINER='root'@'localhost' PROCEDURE IF NOT EXISTS  getDeliveryStatus(
            IN pOrderNumber INT, OUT pDeliveryStatus VARCHAR(100))
   COMMENT 'Get the delivery status of an order based on the number of waiting days'
 BEGIN
  DECLARE waitingDay INT DEFAULT 0;
  SELECT INTO waitingDay FROM orders WHERE orderNumner=pOrderNumber;
   CASE
    WHEN waitingDay= 0 THEN SET pDeliveryStatus= 'ON Time';
    WHEN waitingDay >=1 AND waitingDay < 5 THEN SET pDeliveryStatus ='Late' ;
    WHEN waitingDay >=5 THEN SET pDeliveryStatus ='Very late';
    ELSE SET pDeliveryStatus='No information';
   END CASE;
 END $$

--Alter a procedure
CREATE PROCEDURE IF NOT EXISTS getEmployees() BEGIN
    SELECT * FROM employees; END $$
SHOW CREATE PROCEDURE getEmployees \G

ALTER PROCEDURE getEmployees COMMENT 'Get employees';
--use of cursors:create_email_list procedure [employees table]
CREATE DEFINER='root'@'localhost' PROCEDURE IF NOT EXISTS create_email_list(INOUT email_list TEXT)
    COMMENT 'Iterate over all rows of the employees table & concatenate the emails into a string [Uses LOOP & CURSOR]'
 BEGIN
   DECLARE done BOOLEAN DEFAULT FALSE;
   DECLARE email_address VARCHAR();
   --cursor for employee email
   DECLARE cur CURSOR FOR SELECT email FROM employees;
   DECLARE NOT FOUND SET done = TRUE;
   OPEN cur;
   SET email_list ='';
   procees_mail:LOOP
        FETCH cur INTO email_a;
            IF done = TRUE LEAVE process_email;
            END IF;
        --Concatenate emails into the email_list
        SET email_list =CONCAT();
   END LOOP;
   CLOSE cur;
 END$$

--Functions
CREATE FUNCTION IF NOT EXISTS customerLevel(credit DECIMAL(10,2)) RETURNS VARCHAR(20)
    DETERMINISTIC
    COMMENT 'Returns customer level based {Platinum,Gold,Silver} on the credit '
 BEGIN
   DECLARE customerLevel VARCHAR(20);
   IF credit >50000 THEN SET customerLevel ='PLATINUM';
   ELSEIF credit <=50000 AND credit >=10000 THEN SET customerLevel='GOLD';
   ELSEIF credid <10000 THEN SET customerLevel='SILVER';
   END IF;
  RETURN (customerLevel);
 DELIMITER ;
 


-----------------------------------------------------------------------------------------

DELIMITER ;
USE studentdb;
DROP TABLE IF EXISTS calendars;
CREATE TABLE calendars(
    date DATE PRIMARY KEY,month INT NOT NULL,quarter INT NOT NULL,
    year INT NOT NULL
);

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS fillDates(IN startDate DATE, IN endDate DATE)
    COMMENT 'INSERT rows into the calendars table using a labelled LOOP'
 BEGIN
    DECLARE currentDate DATE DEFAULT startDate;
    insert_date:LOOP
        SET currentDate = DATE_ADD(currentDate,INTERVAL 1 DAY);
    IF currentDate > endDate THEN LEAVE insert_date;
    END IF;
    --Insert date into the table
    INSERT INTO calendar(date,month,quarter,year) VALUES
      (currentDate,MONTH(currentDate),QUARTER(currentDate),YEAR(currentDate));
    END LOOP;
 END //
DELIMITER ;
CALL fillDates('2024-01-01','2024-12-31');

DELIMITER //
CREATE DEFINER= 'root'@'localhost' PROCEDURE IF NOT EXISTS localDates(IN startDate DATE, IN day INT)
    COMMENT 'Inserts dates into the calendars table using a wile loop'
 BEGIN
   DECLARE counter INT DEFAULT 0 ;
   DECLARE currentDate DEFAULT startDate;
   WHILE counter <=day DO
        CALL fillDates(currentDate);
        SET counter := counter+1;
        SET currentDate=DATE_ADD(currentDate,INTERVAL 1 DAY);
   END WHILE;
 END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE IF NOT EXISTS repeatDemo()
    COMMENT 'Concatenates numbers 1 to 9 into a string using REPEAT loop';
 BEGIN
  DECLARE counter INT DEFAULT 0;
  DECLARE result VARCHAR(10) DEFAULT '';
  REPEAT
    SET result = CONCAT();
    SET counter = counter+1;
  UNTIL counter >=10;
  END REPEAT;
 SELECT result; --display the result
 END //
DELIMITER ;

--cursor demo
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS cursorDemo()
 BEGIN
   DECLARE done INT DEFAULT FALSE;
   DECLARE a CHAR(16);
   DECLARE b,c INT;
   DECLARE cur1 CURSOR FOR SELECT id,data FROM ;
   DECLARE cur2 CURSOR FOR SELECT
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1; OPEN cur2;

DELIMITER ;

DELIMITER //
CREATE PROCEDURE createPersonTable() BEGIN
    DROP TABLE IF EXISTS persons;
    CREATE TABLE IF NOT EXISTS persons(
        id INT AUTO_INCREMENT PRIMARY KEY,
        first_name VARCHAR(255) NOT NULL,
        last_name VARCHAR(255) NOT NULL
    );
    INSERT INTO persons(first_name,last_name) VALUES
        ('John','Doe'),('Jane','Doe');
    --Retrieve data
    SELECT * FROM persons ;
 END //

