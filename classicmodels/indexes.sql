/***********************************************************************************************************************
 *Indexes
 A.DDL & DML language
 *  CREATE [UNIQUE|FULLTEXT|SPATIAL] INDEX indxName [USING {BTREE|HASH}]
 * 		ON tblName ()
 *     
 * DROP INDEX idxName ON tblName [alg_option|lock_option]
        alg_option: ALGORITHM={COPY|DEFAULT|INPLACE}
 *     lock_option: LOCK [=] {DEFAULT|SHARED|EXCLUSIVE|NONE}
   SHOW [EXTENDED] {INDEX|INDEXES|KEYS} {FROM|IN} tblName
            [{FROM|IN} dbName] [WHERE expr]
 * ALTER TABLE ADD {INDEX|KEY} [idx_name] [idx_type] [key_part...]
   ALTER TABLE ADD {FULLTEXT|SPATIAL} [INDEX|KEY] [idxName]
 * ALTER TABLE ALTER INDEX indxName {VISIBLE|INVISIBLE}
   ALTER TABLE ADD CONSTRAINT consName UNIQUE {INDEX|KEY}(col1,..)
   ALTER TABLE RENAME {INDEX|KEY} old_idx TO new_idxName
   ALTER TABLE DROP {INDEX|KEY} idxName
   ANALYZE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 --key distribution analysis
   USE INDEX idx_list
   FORCE INDEX idxNam1,...
 Index is a data structure (BTree,Hash) that improves the speed of data
 retrieval on a table at the cost of additional storage to maintain
 When creating a table with a PRIMARY KEY or UNIQUE KEY MySQL creates a
 special index called PRIMARY and is stored together with the data in the
 same table
   1.Index Cardinality [SHOW INDEXES {FROM|IN} tblName;]
    It refers to the uniqueness of values stored  in a specific column
    within an index
    MySQl generates index cardinality based on statistics stored as integers.
    Query optimizer uses cardinality to generate an optimal query plan for a
    given query.It also uses index cardinality to decide whether to use the
    index or not in JOIN operations
   2.USE INDEX & FORCE INDEX hint to the query optimizer:
     SHOW INDEX FROM tbl; ANALYZE TABLE TBL;
     SELECT select_list FROM tblName USE INDEX(idx_list) [WHERE condition];
     EXPLAIN SELECT select_list FROM tblName [WHERE condition];
     SELECT * from tblName FORCE INDEX (idx_list) [WHERE condition];
     EXPLAIN SELECT select_list FROM tblName USE INDEX (idx_list) [WHERE condition];
     EXPLAIN SELECT select_list FROM tblName FORCE INDEX (idx_list) [WHERE condition];
   3.List invisible indexes :
        A PK or an implicit PK ie UNIQUE index cannot be invisible
        Invisible indexes allow us to mark the index as unavailable for the query
        optimizer
     SHOW INDEXES {FROM |IN} tbl [{FROM|IN}dbName]  WHERE VISIBLE='NO';
     ALTER TABLE tbl ALTER INDEX idxName {VISIBLE|INVISIBLE};
   4.Composite Index: Is an index on multiple columns (up to 16 columns)
     It is important the order of columns in the index specification to speed up
     queries.So, consider a composite index consisting of :INDEX(c1,c2,c3).This index
     adds the following searching capabilities:(c1),(c1,c2)(c1,c2,c3)
     The query optimizer cannot use the index to perform lookups if the columns do not
     form the leftmost prefix of the index
        eq: SELECT * FROM table_name WHERE c1...    
   5.Unique Index:Enforce uniqueness of values to 1 or more columns
     Each table can have at most 1 PRIMARY KEY
   6.Prefix Index:INDEX (colName(int))
      CREATE INDEX idxName  ON tblName (colName(length));
      SELECT COUNT(*) FROM tblName;
      SELECT COUNT(DISTINCT LEFT(colName,int)) unique_rows FROM tbl;
       When creating a secondary index for a column ,MySQL stores the values of the columns
      in a separate data structure (BTree or Hash) ,consuming disk space and slowing down
      INSERT operations
       If the columns are of type string {char,varchar,text,binary,varbinary,blob} we
      can create an index for the leading part of the column values of the string column
       To decide about the length of the index,first count the number of rows
      The goal is to maximize the uniqueness of values,so evaluate different prefix
      lengths until you achieve some reasonable uniqueness of rows
    7.Clustered Index:A clustered index  is the table itself,while a typical index is a separate
      data structure (BTree,Hash) that stores the key values for fast lookups.
      A Clustered index enforces the ordering of the rows physically
       Each table has 1 clustered index,which stores the rows into sorted order
       When defining a PRIMARY KEY,(InnoDB ) MySQL uses this PK as the clustered index
      In the absence of a PK a UNIQUE INDEX insert is used as a clustered index
       All other indexes are non-clustered or secondary indexes

    8.Descending Index:
      It stores key values in descending order

 B.Regex Patterns [REGEXP,RLIKE,REGEXP_LIKE,REGEXP_INSTR(),REGEXP_REPLACE,REGEXP_SUBSTR]
    expr REGEXP regPattern =expr RLIKE regPattern #Returns 1 if expr matches pattern or 0 otherwise
    expr NOT REGEXP regPattern= expr NOT RLIKE regPattern = NOT (expr REGEXP patt)= NOT (expr RLIKE patt)
    REGEXP_SUBSTR(str,regPatt,[pos,occur,match_type]):Extract a substring
    REGEXP_INSTR(instr,patt,[pos,occur,return_option,match_type]): The starting position of a matching substring
    REGEXP_REPLACE(str,patt,replacementStr,[pos,occur,match_type])]:Replaces the matches
    REGEXP_LIKE(str,patt,match_type):{1,0}
    match_types:
       c,i:for case sensitive and case insensitive matching
       m:Multiline mode
       n:Matches line terminators
       u:

       []: Character class ,matches a char in a class of characters
       Positional Anchors:
        ^,$,:Matches the start of the line and the end of the line ,respectively
        \A,\Z:Matches the start of input and the end of input respectively
        \<,\>:Matches the start of a word and the end of a word, respectively
        \b:Matches the boundary of a word ie either the start or the end ow the word
        \b:Matches the non start of a word or the nbon-end of a word
    Repetition Operators:
        *:Matches zero or more occurrences of the preceding character
        +:Matches 1 or more occurrences of the preceding character or class
        ?:Matches zero or 1 occurrence of the preceding character or class
        {m}:Matches m occurrences of the preceding character class
        {m,}:Matches at least (m+ times) m occurrences of the preceding char or class
        {m,n}:Matches from m to n occurrences of the preceding char or class
   Metacharacters:
       .:Matches any one character except newline [^\n]
        \d, \D: Matches any digit [0-9] and any non-digit character [^0-9] respectively
        \s ,\S:Matches any one space char[\n,\t,\r,\f] and any one non-space char [^\n,\t.\r,\f] respectively
        \w, \W:Matches any word character [a-zA-Z0-9_] and any non-word character [^a-zA-Z0-9_] respectively
    Parenthesized Back References:
        ():Parenthesis creates a back reference
        $1,$2,$ or \1,\2,\,3 ... are used to retrieve the back references

    Wildcard character % : Matches any string of >=0
    Wildcard character _ : Matches any one character
     expr [NOT] LIKE pattern [ESCAPE char] -- Use with

 C.Full-text search [FULLTEXT index ,MATCH(),AGAINST()]
  An index that allows us to perform efficient text searches;it uses an algorithm that considers
  word relevance,word proximity and the context of the search terms to provide accurate results
  Syntax:
  _______________________________________________________________________
  | CREATE TABLE tbl (--...                  ALTER TABLE tbl ADD        |
  |      FULLTEXT(col1,col2,..)                 FULLTEXT(col1,col2,..); |
  |)                                                                    |
  |CREATE FULLTEXT INDEX idxName ON tblName(col1,...)                   |
  |ALTER TABLE tblName DROP INDEX idxName;                              |
  |_____________________________________________________________________|

   MATCH (col1,col2..) AGAINST(expr [search_modifier])
    search_modifier: {
        IN NATURAL LANGUAGE MODE | IN BOOLEAN MODE| IN QUERY MODE | WITH QUERY EXPANSION
        IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION
   }
    (i)In Natural Language Mode :the match (col1,..) performs a natural language search for a string
       Results are sorted by relevance
       It doesnt support boolean operators,stopwords should be included with double quotes
    (ii)WITH QUERY EXPANSION:Widens the search results of the full text searches based on automatic    
    (iii)In Natural Language Mode With Query Expansion :Similar to the above but also extends search
        to include synonyms of the words
        It doesn't support boolean operators
        Useful when we want to capture a wider range of relevant content
    (iv)In Boolean Mode:It doesn't perform a natural language processing
        Results are sorted by relevance and
        It supports boolean operators [AND,OR,NOT] and allows fine-tuning with modifiers {+,-,*}
        Significance is assigned to words using {+,-}
        Suitable for complex search with boolean logic
     Boolean Operators:
       +:Include the world, -:exclude the word
       >:Include and increase the ranking value
       <:Include and decrease the ranking value
       ~:Negate the word's ranking value
       ():Group words into subgroups
       *:Wildcard at the end  of a word
       "":Defines a phrase

********************************************************************************************************************/

 --#CREATE an index for jobTitle column on employees table
 USE classicmodels1;
 CREATE INDEX idx_jobTitle ON employees (jobTitle);
 EXPLAIN SELECT employeeNumber,lastName,firstName 
 	FROM employees WHERE jobTitle = 'Sales Rep';

--Consider customers table :USE INDEX hint
SHOW INDEXES FROM customers;
ANALYZE TABLE customers;
CREATE INDEX idx_cust_ln ON CUSTOMERS (contactLastName);
CREATE INDEX idx_cust_fn ON customers (contactFirstName) ;
CREATE INDEX idx_cust_fn_ln ON customers (contactFirstName,contactLastName);
CREATE INDEX idx_cust_ln_fn ON customers (contactLastName,contactFirstName);
EXPLAIN SELECT * FROM customers WHERE contactFirstName LIKE 'A%' OR contactLastName LIKE 'A%';
EXPLAIN SELECT * FROM customers USE INDEX (idx_cust_fn_ln,idx_cust_ln)
    WHERE contactFirstName LIKE 'A%' OR contactLastName LIKE 'A%';

SHOW INDEXES FROM customers WHERE VISIBLE = 'NO';
--FORCE INDEX hint for the query optimizer (low cardinality ,few unique values)
SHOW INDEXES FROM products;
CREATE INDEX idx_buyprice ON products(buyPrice);
EXPLAIN SELECT productName,buyPrice FROM products
    WHERE buyPrice BETWEEN 10 AND 80 idx_cust_fn_ln ORDER BY buyPrice;
EXPLAIN SELECT productName,buyPrice FROM products FORCE INDEX (idx_buyPrice)
    WHERE buyPrice BETWEEN 10 AND 80 ORDER BY buyPrice;

--Composite index
SHOW KEYS FROM employees \G 
CREATE INDEX name ON employees (lastName);
DROP INDEX name ON employees;
CREATE INDEX idx_name ON employees (lastName,firstName);
SELECT firstName ,lastName,email FROM employees
    WHERE lastName ='Patterson'; --leftmost prefix of the index is used into lookups ()
EXPLAIN SELECT firstName ,lastName,email FROM employees
    WHERE lastName ='Patterson';
 --employees whose last name is Patterson and the first name is Steve
SELECT firstName ,lastName,email FROM employees
    WHERE lastName ='Patterson' AND firstName='Steve';

--Prefix index :Products table
--finds the products whose names start with the string 1970
EXPLAIN SELECT productName,buyPrice,msrp FROM products WHERE
    productName LIKE '1970%'; --query optimizer scans all rows
SELECT COUNT(*) FROM products;--110
SELECT COUNT(DISTINCT LEFT(productName,10)) unique_rows FROM products;
SELECT COUNT(DISTINCT LEFT(productName,20)) unique_rows FROM products;
CREATE INDEX idx_prodName ON products(productName(20));
EXPLAIN SELECT productName,buyPrice,msrp FROM products WHERE
    productName LIKE '1970%'; --query optimizer scans all rows

-------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS studentdb;
USE studentdb;
/**********************************************
CREATE TABLE IF NOT EXISTS table_name (
    c1 data_type PRIMARY KEY,c2 data_type,
    c3 data_type,c4 data_type,
    INDEX index_name (c2,c3,c4)
);
***********************************************/
CREATE INDEX idx_name ON table_name (c2,c3,c4);

CREATE  TABLE IF NOT EXISTS contacts(
    id INT  AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    UNIQUE KEY unique_email (email)
);
CREATE UNIQUE INDEX idx_name_phone ON contacts (first_name,last_name,phone);
SHOW INDEXES FROM contacts;

INSERT INTO contacts(first_name,last_name,phone,email)
VALUES('John','Doe','(408)-999-9765','john.doe@mysqltutorial.org');
/*** INSERT INTO contacts(first_name,last_name,phone,email) --causes Error
VALUES('john','doe','(408)-999-9765','john.d@mysqltutorial.org');
 the combination of first_name, last_name, and phone already exists

*********************************************************************/
CREATE TABLE IF NOT EXISTS t(
    a INT, b INT,
    INDEX a_asc_b_asc (a ASC, b ASC),
    INDEX a_asc_b_desc (a ASC,b DESC),
    INDEX a_desc_b_asc (a DESC,b ASC),
    INDEX a_desc_b_desc (a DESC, b DESC)
);

DELIMITER $$
CREATE  PROCEDURE IF NOT EXISTS insertTData(IN rowCnt INT,IN low INT, IN high INT)
  BEGIN
    DECLARE counter INT DEFAULT 0;
    REPEAT
      SET counter := counter +1;
      --insert data
      INSERT INTO t(a,b) VALUES
        (ROUND(RAND()*(high-low)+high),ROUND(RAND()*(high-low)+high));
    UNTIL counter >= rowCnt
    END REPEAT;
END $$
DELIMITER ;

CALL insertTdata(1000,1,1000);
EXPLAIN SELECT * FROM t
    ORDER BY a,b; -- uses index a_asc_b_asc
EXPLAIN SELECT * FROM t  ORDER BY a DESC,b; -- uses index a_desc_b_asc

 --Operator LIKE
USE classicmodels1;
SELECT employeeNumber, lastName, firstName
 FROM employees WHERE lastname LIKE '%on%'; --contains string 'on'

SELECT employeeNumber, lastName, firstName
 FROM employees WHERE lastname NOT LIKE 'B%'; --Doesn't start with letter 'B'

SELECT productCode, productName FROM products WHERE
    productCode LIKE '%\_20%';--Find product codes containing string '_20'

SELECT productCode,  productName
 FROM   products WHERE
    productCode LIKE '%$_20%' ESCAPE '$';

--FullText index
USE studentdb;
CREATE TABLE IF NOT EXISTS posts(
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  FULLTEXT (title,body)
);

INSERT INTO  posts (title, body) VALUES
('Introduction to MySQL', 'MySQL is a popular relational database management system.'),
('Advanced SQL Techniques', 'Learn advanced SQL techniques for optimizing queries.'),
('Web Development with PHP', 'Building dynamic websites using PHP and MySQL.'),
('Data Security Best Practices', 'Ensuring the security of your database and sensitive information.'),
('MySQL Performance Tuning', 'Optimizing the performance of your MySQL database.'),
('Database Design Principles', 'Designing efficient and normalized database structures.'),
('Full-Text Search in MySQL', 'Exploring the powerful full-text search capabilities of MySQL.'),
('Scaling MySQL for Large Datasets', 'Strategies for scaling MySQL to handle large datasets.'),
('Error Handling in MySQL', 'Best practices for handling errors in MySQL queries.'),
('Backup and Recovery Strategies', 'Implementing reliable backup and recovery strategies for MySQL.');

DROP TABLE IF EXISTS documents;
CREATE TABLE documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    contents TEXT,
    FULLTEXT ( contents )
);
INSERT INTO documents(contents) VALUES
  ('MySQL Database'),('MySQL'),('Database'),('SQL'),('A fork of MySQL');

#In natural language mode :search for the documents whose contents have the words "mysql"
SELECT id,contents MATCH(contents) AGAINST('mysql')
 FROM documents WHERE
    MATCH(contents) AGAINST ('mysql' IN NATURAL LANGUAGE MODE);
--search for the documents whose contents have the words "mysql" and/or "database"
SELECT *,MATCH(contents) AGAINST ('mysql,database'  IN NATURAL LANGUAGE MODE) relevancy
 FROM documents WHERE
  MATCH(contents) AGAINST ('mysql,database');

--With query expansion
SELECT * FROM documents WHERE
    MATCH(contents) AGAINST('MySQL' WITH QUERY EXPANSION);
--Boolean mode & operators
SELECT * FROM documents WHERE
      MATCH(contens) AGAINST('mysql');
SELECT * FROM documents WHERE --documents containing the word MySQL but not the word databases
    MATCH(contents) AGAINST('mysql-database'IN BOOLEAN MODE);
SELECT * FROM documnets WHERE
        MATCH(contents) AGAINST('+database' IN BOOLEAN MODE);
--rows that contain words starting with “sql
SELECT * FROM documents WHERE
  MATCH(contents) AGAINST('sql*' IN BOOLEAN MODE);

/***** Regular Expressions *****/
USER classcimdodels1;
--check if a given string contains any digits
SELECT 'MySQL 8.2' REGEXP '\\d+'; --1
--Checks if the string 'MySQL 8.0' has a version that includes a digit a dot and a digit,
SELECT 'MySQL 8.2' REGEXP '\\d\.\\d';
--Find products whose names contain the number 193 followed by any single digit
SELECT productName FROM products WEHRE
    productName REGEXP '193\\d';
--Index position of a sequence of digits
SELECT REGEXP_INSTR('1936 Mercedes-Benz 500K Special Roadster','\\d+') AS position;
SELECT REGEXP_INSTR(SELECT
  REGEXP_INSTR('1936 Mercedes-Benz 500K Special Roadster', '\\d+',5) position;
 --occurrence parameters
SELECT REGEXP_INSTR(
    '1936 Mercedes-Benz 500K Special Roadster', '\\d+',1,1) first_match,
    REGEXP_INSTR('1936 Mercedes-Benz 500k Special Roadster','\\d+',1,2)
    second_match ;

--case sensitive match
SELECT REGEXP_INSTR('1936 Mercedes-Benz 500K Special Roadster','\\d+');
--find the position of the 4-digit substring
SELECT productName FROM products WHERE REGEXP_INSTR(productName,'\\d{4}') >0;
--product names that start with 4 digits
SELECT productName FROM products
    WHERE REGEXP_LIKE(productName,'\\d{4}');
SELECT productName FROM products WHERE
    productName REGEXP '\\d{4}';
--Get the version of MySQL 8.0
SELECT REGEXP_SUBSTR('MySQL 8.0','\\d+\.\\d+') version ;
SELECT REGEXP_SUBSTR('3 apples weighs 400 grams','\\d+',2) weight;
-- extract the year (4 digits) from the product names
SELECT productName, REGEXP_SUBSTR(productName,'\\d{4}') year FROM products
    WHERE REGEXP_SUBSTR(productName,'\\d{4}')  IS NOT NULL;

--REGEXP_REPLACE(str,patt,replStr,[pos,occur,match_type])
--replace all non-digit characters in a phone number with an empty string
SELECT REGEXP_REPLACE('(212)-456-7890','\\D','')phone_number;
--Replace ,but start searching at position 6
SELECT REGEXP_REPLACE('(212)-456-7890','[^0-9]+',6) phone_number;
 --replace only the 1st occurrence of non digit character with an empty string
SELECT REGEXP_REPLACE('(212)-456-78900','\\D+',1,1) phone_nmumber;

USE studentdb;
CREATE TABLE IF NOT  EXISTS contacts2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(100) NOT NULL
);
INSERT IGNORE INTO contacts2 (name, phone) VALUES
    ('John Doe', '+1(484)-476-0002'),('Jane Smith', '+1(555)-987-6543'),
    ('Bob Johnson', '+1(555)-555-5555'),('Alice Brown', '+1(555)-111-2222'),
    ('Eve White', '+1(555)-999-8888');

--Replace non-digit characters in the phone number with an empty string
SELECT * FROM contacts2;
UPDATE contacts SET
    phone= REGEXP_REPLACE(phone,'\\D+','');
SELECT * FROM contacts2;
ALTER TABLE contacts2 ADD COLUMN email VARCHAR(200) NOT NULL;
--add a check constraint to the email column using regex: "^\S+@\S+\.\s+$" & regexp_like()
ALTER TABLE contacts2 ADD CONSTRAINT email_valid CHECK(
    REGEXP_LIKE(email,'^\\S+@\\S+\\.\\S+$')=1
);
INSERT INTO contacts2 (name,phone,email) VALUES
    ("John Doe","(212)-345-5743", "john.doe@mysqltutorial.org");
INSERT INTO contacts2 (name,phone,email) VALUES  ("Jane Doe","(212)-345-4567","jane.doe@mysqltutorial");-- check

ALTER TABLE contacts2 DROP INDEX email_valid;
--Reimplement email validation using the fololowing regex pattern:
--^\w+([.-]?\w+)*@\w+([.+]?\w+)*(\.\w{2,3})+$
ALTER TABLE contacts2 ADD CONSTRAINT email_validation CHECK(
    REGEXP_LIKE(email,'^\\w+([.+]?\w+)*@\\w+([.+]\\w+)*(\\.\\w{2,3})+$')=1);
