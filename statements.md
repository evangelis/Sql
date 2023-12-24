I.MySQL Data Types
 Numerical Types: TINYINT,SMALLINIT,MEDIUMINT,INT (INTEGER),BIGINT,
 				  BOOL (BOOLEAN),BIT(n)
                  FLOAT,DOUBLE (DOUBLE PRECISION or REAL),DECIMAL(n,d) (DEC,FIXED,NUMERIC)
 String Types:    CHAR(n),VARCHAR(n),TINYTEXT,TEXT,MEDIUMTEXT,LONGTEXT (~4bg)
 				  ENUM,SET	                  
 Binary Strings:  BINARY(n),VARBINARY(n),TINYBLOB,BLOB,MEDIUMBLOB,LONGBLOB
 Date/Time Types: DATETIME,TIME,DATE,YEAR,TIMESTAMP
 Special Types:   POINT,LINESTRING,POLYGON,MULTIPOINT,MULTILINESTRING,MULTIPOLYGON,
                  GEOMETRY,GEOMETRYCOLLECTION

 Comments are ignored by the processing engine but are important serving documentation  and explanation purposes
  --: End-of-line comment 
  # :lasts until the end-of-line
  /* */:Multiline comment
 Notes:
 1.Datetime types: 
  YEAR(4|2) Stores the year in format: ['YYYY'] or ['YY']	
  DATETIME stores both date & time in the format: ['YYYY-MM-DD HH:mm:SS']
  DATE Stores dates in the format : ['YYYY-MM-DD']
  TIME Stores time in the format: ['HH:MM:SS']
  TIMESTAMP similar to DATETIME but store the number of seconds since epoch  January 1, 1970 UTC)
 
 To extract the current date/time use the following: [NOW(),CURDATE(),CURTIME()]
 	CURDATE()=CURRENT_DATE()=CURRENT_DATE and CURTIME()=CURRENT_TIME=CURRENT_TIME()
 2.String Types
  ENUM:is a special string type with a value choosen from a list of available values.Members of the enum must be declared and defined explicitly at table creation.Each enum member is associated with an index ,beginning at 1 .
  The index of NULL is NULL and the emtpy string has index 0 ,denoting an error value
  SET is another special string type similar to enum, but we can choose 0 or more from the list of its available members
  A Set can have a maximum of 64 members
 3.String literals:Is enclosed by a pair of single quotes ('string') or double quotes ("string").It is recommended to use single quotes

 4.Variables:[System variables,Use-defined variables,local variables]
  (i)User-Defined Variables:Begin with '@' sign (eq @myVar) ,are connection specific being available only to the specific client session
  Define variables:

    SET @varName :=val  ,or SET @varName = val
    SELECT @varName :=val
    SELECT colName INTO @varName
   
  (ii)System variables:
  Global variables affect the overall of the server,and are referenced via:
  	[GLOBAL varName,@@global.varName]
  Session variables affect individual client connections, and are refernced via
  	[@@session.varName,SESSION varName,@@varName]
  (iii)Local variables are defined locally within stored routines inside a BEGIN ..END block.
    To define a local variable use :[DECLARE]			
 5.MySQL specific codes
  Statements enclosed within /*!...*/ are known as MySQL specific codes and are recognized only by the MySQL engine (other engines will treat them as comments)
  Here are the MySQL specific codes:

    /*!4010 SET NAMES utf &/;
    /*!40101 SET SQL MODE=''*/;
    /*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS,FOREIGN_KEY_CHECKS=0*/;
    /*!40101 SET OLD_SQL_MODE=@@SQL_MODE,SQL_MODE=*/;
 
 7.Create ,Run scripts ,Back up & Recovery

 	#Input & output redirection operators '<', '>' and SOURCE command
    $mysql -u username -p < /path/to/scriptName.sql --use of input redirection operator '<'
    $mysql -u usr -p </path/sqript.sql > output.txt --Input &output redirection operators
    $mysql -u usr -p -t -vvv < /path/to/scriptName.sql
    $mysql -u usr -p -vvv -e "SELECT user,host FROM user;SHOW DATABASES" mysql
    $mysql -u usr -p
    mysql> SOURCE /path/to/sript.sql
    #mysqlimport utility
    #Backup with mysqldump utility
    $mysqlimport dbName tbl1 [,tbl2,..]
    $mysqldump -u usr -p dbName [tbl1,..tbl2,tbl3..] >backupFile.sql
    $mysqldump -u usr -p --databases db1 [,db2,..] > backupFile.sql
    $mysqldump -u root -p --all-databases --ignore-table=mysql.user >backupServer.sql
    #Backup using SELECT ...INTO OUTFILE
    mysql>SELECT * INTO OUTFILE '/path/to/file.txt' FROM tblName [WHERE criteria];
    mysql>SELECT col1[,col2,..] INTO OUTFILE '/path/to/fname.sql' FROM tblName [WHERE criteria];

II.Stored Objects & programs [Triggers,Events,Views,Stored Routines]
 Compound Statement: comprises multiple statements ,treated as a unit.Is is enclosed within a [BEGIN ... END] and each of the statements is terminated with a ';' (semicolon statement delimiter).

    CREATE [DEFINER={CURRENT_USER|'usr'@'host'}]
    	FUNCTION [IF NOT EXISTS]funcName(param1 ,..) RETURNS return_type
    	[{[NOT] DETERMINISTIC|COMMENT 'str'|SQL SECURITY {DEFINER|INVOKER}|
    	LANGUAGE SQL| characteristic}]
    	statements ;
    	RETURN value;
    characteristic:{READS SQL DATA|MODIFIES SQL DATA|CONTAINS SQL|NO SQL}	

    CREATE [DEFINER ={CURRENT|USER|'user'@'host'}]
    	PROCEDURE [IF NOT EXISTS] procName(param1 IN|OUT|INTOUT ,..)
    	[{COMMENT 'str'|LANGUAGE SQL|[NOT] DETERMINISTIC}|SQL SECURITY {DEFINER|INVOKER}|characteristic}]
    	statements;

   	CREATE [OR REPLACE]  ALGORITHM=[{UNDEFINED|MERGE|TEMPTABLE}]
   		[DEFINER=user] [SQL SEQURITY {DEFINER|INVOKER}]
   		viewName [(column_list)] AS SELECT selectStm;



    CREATE TRIGGER trigName {BEFORE|AFTER} {INSERT|UPDATE|DELETE} 
   		ON tblName FOR EACH ROW 
   		statements;

   	SET @GLOBAL.EVENT_SCHEDULER=ON;	
   	SHOW PROCESSLIST \G
   	CREATE [DEFINER= usr] EVENT [IF NOT EXISTS] eventName ON SCHEDULE schdl
   		[ON COMPLETION [NO]PRESERVE] [COMMENT 'str'] [ENABLE|DISABLE|DISABLE ON SLAVE]
   		DO event_body;

 III.

