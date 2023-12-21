/***********************************************************************************************************************
 *Indexes
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
   ANALYZE TABLE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 --key distribution analysis
   USE INDEX idxName
 Index is a data structure (BTree,Hash) that improves the speed of data
 retrieval on a table at the cost of additional storage to maintain
 When creating a table with a PRIMARY KEY or UNIQUE KEY MySQL creates a
 special index called PRIMARY and is stored together with the data in the
 same table
   1.Index Cardinality [SHOW INDEXES {FROM|IN} tblName;]
    It refers to the uniqueness of values stored insert in a specific column
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
     It is important the order of columns insert in the index specification to speed up
     queries.So, consider a composite index consisting of :INDEX(c1,c2,c3).This index
     adds the following searching capabilities:(c1),(c1,c2)(c1,c2,c3)
     The query optimizer cannot use the index to perform lookups if the columns do not
     form the leftmost prefix of the index
        eq: SELECT * FROM table_name WHERE c1
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
      data structure (BTree,Hash) that stores the key values for fast lookups
      Clustered index enforces the ordering of the rows physically
       Each table has 1 clustered index,which stores the rows insert into sorted order
       When defining a PRIMARY KEY,(InnoDB ) MySQL uses this PK as the clustered index
      In the absence of a PK a UNIQUE INDEX insert is used as a clustered index
       All other indexes are non-clustered or secondary indexes

    8.Descending Index:
      It stores key values in descending order

 **********************************************************************************************************************/

 --#CREATE an index for jobTitle column on employees table
 USE classicmodels1;
 CREATE INDEX jobTitle ON employees (jobTitle);
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
SHOW INDEXES FROM customers WHERE VISIBLO = 'NO';
--FORCE INDEX hint for the query optimizer (low cardinality ,few unique values)
SHOW INDEXES FROM products;
CREATE INDEX idx_buyprice ON products(buyPrice);
EXPLAIN SELECT productName,buyPrice FROM products
    WHERE buyPrice BETWEEN 10 AND 80 ORDER BY buyPrice;
EXPLAIN SELECT productName,buyPrice FROM products FORCE INDEX (idx_buyPrice)
    WHERE buyPrice BETWEEN 10 AND 80 ORDER BY buyPrice;

--Composite index
CREATE INDEX name ON employees (lastName,firstName);
SELECT firstName ,lastName,email FROM employees
    WHERE lastName ='Patterson'; --leftmost prefix of the index is used  insert into lookups ()
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
CREATE INDEX idx_prodName ON products(producntName(20));
EXPLAIN SELECT productName,buyPrice,msrp FROM products WHERE
    productName LIKE '1970%'; --query optimizer scans all rows



CREATE SCHEMA IF NOT EXISTS studentdb;
USE studentdb;
CREATE TABLE IF NOT EXISTS table_name (
    c1 data_type PRIMARY KEY,c2 data_type,
    c3 data_type,c4 data_type,
    INDEX index_name (c2,c3,c4)
);
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
CREATE  PROCEDURE IF NOT EXISTS insertTdata(IN rowCnt INT,IN low INT, IN high INT)
  BEGIN
    DECLARE counter INT DEFAULT 0;
    REPEAT
      SET counter := counter +1;
      --insert data
      INSERT INTO t(a,b) VALULES
        (ROUND(RAND()*(high-low)+high),ROUND(RAND()*(high-low)+high));
    UNTIL counter >= rowCnt
    END REPEAT;
END $$
DELIMITER ;

CALL insertTdata(1000,1,1000);
EXPLAIN SELECT * FROM t
    ORDER BY a,b; -- uses index a_asc_b_asc
EXPLAIN SELECT * FROM t  ORDER BY a DESC,b; -- uses index a_desc_b_asc
