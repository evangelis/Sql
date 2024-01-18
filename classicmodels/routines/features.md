1.Transactions [START TRANSACTION, COMMIT, ROLLBACK]
 A sequence of >=1 sql statements that are executed as a single unit of work.
 A transaction ensures data integrity by enabling a set of operations to either succeed or be fully rolled back in a case of an error

 	SET autocommit={0|OFF};
    START TRANSACTION #statement to start a transaction
    COMMIT # Apply changes introduced during the transaction
    ROLLBACK # Rolls back changes made during the transaction, and reverts the 
    		 # state of the db before the trasaction started


2.Conditional Statements

3.Loops [LOOP ,REPEAT UNTIL, WHILE]
 LOOP statement allows us to exwecute 1 or more statements multiple times
Typically we terminate the LOOP when a condition is true using the [IF.. LEAVE] construct
The LOOP can have optional labels at the beginning and the end 
 WHILE loop executes 1 or more statements as long as a condition is true    
 REPEAT .. UNTIL: a loop thast repeatedly executes a block of statements until a contition is true
Note that REPEAT ..UNTIL checks the condition after the execxution of the block ,implying that the blockl of statements always executes at least once,whereas the WHILE loop is a pretest loop ,meaning that the condition is checked before the execution of the block of statements

	[begin_label:] LOOP 	     
		statements;									
	END LOOP [end_label]	

IF condition THEN ITERATE [label] is used to skip the current iteration and start a new one
IF CONDITION THEN LEAVE [label] is used to terminate the loop 

	[begin_label:] LOOP              [begin_label:]LOOP
		statements;											 statements;
		IF condition THEN 							 IF condition THEN 
			ITERATE [begin_label];					 LEAVE [begin_label];
		END IF;													 END IF;	
	END LOOP;	                       END LOOP; 

	[begin_label:]WHILE              [label:]WHILE search condition DO
		search_condition 									statements;
	  statements;												IF CONDITION THEN LEAVE [label]; END IF;
	END WHILE [end_label];					 END WHILE [label];	

	[begin_label:] REPEAT 			     [label:]REPEAT 
		statements;												statements;
	UNTILcondition;											IF CONDITION THEN LEAVE [label]; END IF;
	END REPEAT [end_label];							UNTIL search_condition 
																		END REPEAT [label];
4.Error Handling [Handlers,Conditions,warnings,Errors,SIGNAL,RESIGNAL]

	SHOW WARNINGS [LIMIT [offset,] row_count];
	SHOW COUNT(*) WARNINGS;
	SELECT @@warning_count;

 Condition :refers to errors,warnings or exceptional cases that require special handling.
In particular a condition can take on of the following values:
  [SQLWARNING,SQLEXCEPTION,NOT FOUND,mysql_error_code,SQLSTATE [VALUE] sqlstate_val]
 SQLSTATE [VALUE] sqlstate_value:A 5 char String that indicates an SQLSTATE;It consists of 2 parts:
 	Class Code :First 2 characters ,indicates the category of the error
 	Subclass Code:Next 3 characters ,provides specific info about the error within the category
 SQLEXCEPTION :Shorthand for the class of SQLSTATE values that don't begin with '00','01','03'
 SQLWARNING:Shorthand for the class of SQLSTATE values beginning with '01'
 NOT FOUND:Shorthand for the class of SQLSTATE values beginning with '02'
 mysql_error_code:An integer indicating a MySQL error code ,eq 1051
 A condition arises during the execution of a stored routine and should be handled properly
To handle a condition we declare a handler
	
	DECLARE {CONTINUE|EXIT} HANDLER FOR condition_value1 [..]
		statements ; --execute when the routine encounters one of the conditions
To declare a named error condition use the DECLARE ... CONDITION

	DECLARE condName CONDITION FOR condition_value 
		condition_value:{SQLSTATE [VALUE]sqlstate_val |mysql_error_code}  
Examples:
	
	DECLARE unknown_table CONDITION FOR 1051;
	DECLARE CONTINUE HANDLER FOR unkown_table 
		BEGIN --
		END;
SIGNAL statement allows us to raise an exception within a stored program 

	SIGNAL condition_value 
		[SET signal_info_item1,...]




5.Cursors & Prepared Statements
 A Cursor is a db object used for iterating the results of a SELECT statement

 	DECLARE cursorName CURSOR FOR select_stmt [WHERE condition ..];
 	OPEN cursorName;#Initializes the result set for the cursor
 	FETCH cursorName INTO var1 [,var2...] #Fetches  next row as pointed by the cursor & process the data
 	CLOSE cursorName;

 Prepared statements allows us to write SQL queries with placeholders for parameters
 and bind the values to those parameters at runtime
 MySQL Server receives the prepared statement with placeholders for the parameters and then parses the query, optimizes it and precompiles it. Then it creates the prepared statement

 	PREPARE stmtName FROM preparable_stmt;#The preparable_stmt is send to the MySQL Server with placeholders (?,...) 
 			#specified in the prepared statement
 	[SET @var1=val1;...]
 	EXECUTE stmt [USING @var1,..];
 	{DEALLOCATE|DROP} PREPARE stmt;


################################################################################################################################################

	USE studentdb;
    ##(i)Prepared statements
    SELECT * FROM information_schema.tables WHERE table_type= 'BASE TABLE' AND 
    	table_schema= 'studentdb' AND table_name LIKE 'user%'\G
    SHOW EXTENDED COLUMNS FROM users; #{id,username,email}

#Prepare an insertion statement for the users table ,set values & execute the statement.Finally de-allocate the prepared statement
	
	PREPARE insert_users FROM 'INSERT INTO (username,email) VALUES (?,?);'    
	SET @username= 'jane_doe';SET @email = 'jane@example.com';
	EXECUTE insert_users USING @username, @email;
	SELECT * FROM users;
	DEALLOCATE PREPARE insert_users;
#Retrieve data from a table
	
	DELIMITER $$
	CREATE DEFINER=CURRENT_USER PROCEDURE IF NOT EXISTS getData(IN tblName VARCHAR(255)) READS SQL DATA SQL SECURITY DEFINER BEGIN 
		DECLARE unknown_table CONDITION FOR 1051;
		DECLARE EXIT HANDLER FOR unknown_table 
		BEGIN SHOW ERRORS; END;
		SET @sql_query = CONCAT('SELECT * FROM ',tblName);
		PREPARE getStmt FROM @sql_query;
		EXECUTE getStmt ;
		DEALLOCATE PREPARE getStmt;
	END $$
	DELMITER ;
	CALL getData('useres');

	CREATE TABLE IF NOT EXISTS accounts (
       account_id INT AUTO_INCREMENT  PRIMARY KEY ,
       account_holder VARCHAR(255) NOT NULL,
       balance DECIMAL(10, 2) NOT NULL);

	CREATE TABLE IF NOT EXISTS transactions (
       transaction_id INT AUTO_INCREMENT PRIMARY KEY,
       account_id INT NOT NULL,
       amount DECIMAL(10, 2) NOT NULL,
       transaction_type ENUM('DEPOSIT', 'WITHDRAWAL') NOT NULL,
       FOREIGN KEY (account_id) REFERENCES accounts(account_id));

	INSERT INTO accounts (account_holder, balance) VALUES 
	('John Doe', 1000.00), ('Jane Doe', 500.00);


#(ii)Procedure to insert rows into the users table using Handlers
	
	DELIMITER $$
	CREATE DEFINER=CURRENT_USER PROCEDURE IF NOT EXISTS users_insert(IN p_usrname VARCHAR(50),IN p_email VARCHAR(50)) READS SQL DATA SQL SECURITY DEFINER BEGIN
	--Handler for unique constraint violation
	DECLARE EXIT HANDLER FOR SQLSTATE '23000' 
	BEGIN 
		SELECT 'Error :Duplicate username,please select a different username.' AS messsage
	END;
	--Attempt to insert the user into the table & if it succeeds display a msg
	INSERT INTO users (username,email) VALUES (p_username,p_email);
	SELECT 'User inserted successfully ' AS Message;
    END $$
    DELIMITER ;
    CALL users_insert('vangelis_a','vangelis@example.com');

#(iii)Procedure transfers money between the 2 accounts

	DELIMITER $$
    CREATE DEFINER=CURRENT_USER PROCEDURE IF NOT EXISTS transfer(IN sender_id INT ,IN receiver_id INT, IN amount DECIMAL(10,2)) 
    READS SQL DATA SQL SECURITY INVOKER COMMENT 'Transfers money between 2 accounts'
    BEGIN 
    	DECLARE rollback_msg VARCHAR(255) DEFAULT 'Transaction rolled back due to insafficient funds'; 
    	DECLARE commit_msg   VARCHAR(255) DEFAULT 'Transaction committeed successfully';
    	START TRANSACTION;
    	--Attempt to debit money from account 1 & credit money to account 2
    	UPDATE accounts SET balance= balance -amnount WHERE account_id = sender_id;
    	UPDATE accounts SET balance =balance - amount WHERE account_id =receiver_id;
    	IF (SELECT balance FROM accounts WHERE account_id =sender_id ) <0 THEN ROLLBACK;
    	SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = rollback_msg;
    	ELSE 
    		INSERT INTO transactions (account_id,amount,transaction_type) VALUES 
    			(sender_id,-amount,'WITHDRAWAL');
    		INSERT INTO transactions (account_id,amount,transaction_type) VALUES 
    			(account_id,amount,'DEPOSIT');
    	END IF;
    	COMMIT;
    	SELECT commit_msg AS 'Result';
    	END $$
    	DELIMITER ;
    	CALL transfer(1,2,1000);


#Raising errors

	CREATE TABLE IF NOT EXISTS employees (
     id INT PRIMARY KEY,
     name VARCHAR(100),
     salary DECIMAL(10,2));
    INSERT INTO employees (id, name, salary) VALUES
    (1, 'John Doe', 50000),(2, 'Jane Smith', 75000),(3, 'Bob Johnson', 90000);

	DELIMITER $$
	CREATE DEFINER=CURRENT_USER PROCEDURE IF NOT EXISTS employees_upd_salary (IN p_emp_id INT, IN p_salary DECIMAL(10,2)) BEGIN 
		DECLARE employee_count INT;
		SELECT COUNT(*) FROM employees INTO employee_count FROM employees 
			WHERE id = p_emp_id;
		IF employee_count = 0 THEN SIGNAL SQLSTATE VALUE '45000' 
			SET MESSAGE_TEXT='Employee not found';
		END IF;
		--Valildate salary
		IF p_salary <0 THEN SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT ='Salary cannot be negative';
		END IF;
		--Update the salary
		UPDATE employees SET salary  = p_salary WHERE id = p_emp_id;
	END $$
	DELIMITER ;
	CALL employees_upd_salary(1,-7000);   


#Cursors:

	USE classicmodels1;
	DELIMITER $$
	CREATE DEFINER=CURRENT_USER PROCEDURE IF NOT EXISTS email_list(INOUT lst TEXT)
		READS SQL DATA SQL SECURITY DEFINER COMMENT 'Iterates over the employee rows using cursors'
	BEGIN 
		DECLARE email_address VARCHAR(100) DEFAULT "";
		DECLARE finished BOOLEAN DEFAULT FALSE;
		DECLARE curs CURSOR FOR SELECT email FROM employees;
		DECLARE CONTINUE HANDLER FOR NOT FOUND 
			SET finished= TRUE;
		OPEN curs;
		SET lst = '' ;
		process_email: LOOP 
			FETCH curs INTO email_address ;
			IF finished =TRUE THEN LEAVE process_email;
			END IF;
			SET lst = CONCAT(email_address," :",lst);
		END LOOP;
		CLOSE curs;
	END $$
	DELIMITER ;

	CALL email_list(@email_list); 
	SELECT @email_list \G



###Loops

	USE studentdb;
	CREATE TABLE IF NOT EXISTS calendars(
		date DATE PRIMARY KEY, month INT NOT NULL, quarter INT NOT NULL, year INT NOT NULL);

	DELIMITER $$
 	CREATE DEFINER=CURRENT_USER PROCEDURE IF NOT EXISTS fillDates(IN startDt DATE, IN endDt DATE) 
 		READS SQL DATA COMMENT 'Inserts rows into the calendars table' BEGIN
 		DECLARE currDt = DATE DEFAULT startDt;
 		--increase date by 1 day leaving the loop if current date exceeds end date
  		insert_dt:LOOP 
  			SET currDt =DATE_ADD(startDt,INTERVAL 1 DAY);
  			IF currDt > endDt THEN LEAVE insert_dt;
  			END IF;
  			INSERT INTO calendars(date,month,quarter,year) VALUES 
  				(currDt,MONTH(currDt),QUARTER(currDt),YEAR(currDt));
  		END LOOP;
  	END $$
    DELIMITER ;
    CALL fillDates('2024-01-01','2024-12-31');

 	DELIMITER $$
 	CREATE DEFINER= CURRENT_USER PROCEDURE IF NOT EXISTS loadDates(IN startDt DATE, IN day INT) SQL SECURITY DEFINER COMMENT 'Inserts dates into the calendar' BEGIN 
 		DECLARE counter INT DEFAULT 0;
 		DECLARE currDt DATE DEFAULT startDt; 																					

 		insert_dt: WHILE counter <= day DO
 			CALL fillDates()
 			SET counter = counter +1;
 			SET currDt = DATE_ADD(currDt,INTERVAL 1 DAY);
 		END WHILE;
 		END $$
 		DELIMITER ;
 		CALL loadDates('2025-01-01',365);






###############################################################################################################################################