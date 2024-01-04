I.Data Types & Operators
 # A.Data Types
 Numerical Types : 
    Integers: BIT,TINYINT,SMALLINT,INT=INTEGER,BIGINT
    Floating-points:FLOAT,DOUBLE,DECIMAL(total_,)       
 Strings Types: 
    CHAR(n),VARCHAR(n),ENUM('strVal1','strVal2'[,..]),SET('strVal1',[...]),
    TINYTEXT,SMALLTEXT,MEDIUMTEXT,TEXT,LONGTEXT
 Binary strings: BINARY(sz),VARBINARY(n),TINYBLOB,MEDIUMBLOB,BLOB,LONGBLOB
 Date & Time Types : 
        DATE, TIME,DATETIME [format:YYYY-MM-DD HH:mm:ss],TIMESTAMP ,YEAR [YYYY,or YY]  
 Json Type:JSON stores & manages Json documents
 Special Types :POINT,MULTIPOINT,LINESTRING,MULITLINESTRING,POLYGON,MULTIPOLYGON
                GEOMETRY, GEOMETRYCOLLECTION
 # B. Operators
 Arithmetic Operators: +,-,*,/,%
 Comparison Operators:=,<,>,(!=,<>),<=,>=, <=> (equal null-safe)
 Logical Operators: (AND ,&&),(OR,||),(NOT,!),(XOR,^)
 Set Operators: UNION,INTERSECT,EXCEPT
 Bitwise Operators:

    
II.Select Table,Values DML Statements 
    
    SELECT expr [AS] alias;
    SELECT {colName|expr} [AS] column_alias FROM tblName;  # setting a temporary name to a column 
    --ORDER BY sorts the resulting set 
    SELECT select_list FROM tblName ORDER BY col1 [ASC|DESC] [,col2 [ASC|DESC]...];
    SELECT col1 As X1,col2 [...] FROM  tblName [AS] tblAlias # using a table alias in a select statement
    #Complete syntax of select statement
    SELECT [ALL|DISTINCT|DISTINCTROW] [HIGH_PRIORITY] [STRAIGHT_JOIN] 
       [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT] [SQL_CALC_FOUND_ROWS]
       select_expr [..] 
       [into_option]
       [FROM tblReferences [PARTITION partName1..]] [WHERE condition] 
       [GROUP BY {colName|colPos|expr} [WITH ROLLUP] [HAVING condition]
       [WINDOW wName1 AS (wspec),..]
       [ORDER BY {colName|colPos|expr} [ASC|DESC]  
       [LIMIT {[offset,]row_count| row_count OFFSET offset]
       [into_option]
    VALUES ROW(v1,v2,..) [ROW(v1,..)] [ORDER BY {colName|pos|expr} [ASC|DESC]}] 
        [LIMIT num];
    TABLE tblName [ORDER BY {}..] [LIMIT num];# =SELECT * FROM tblName [order by..limit n]

into_option:{INTO OUTFILE 'fname' [CHARACTER SET chs]|
             INTO DUMPFILE 'fname'|INTO varName1 [,varName2..]}
   
 # A.Filtering data [WHERE,AND,OR,IN,NOT IN,BETWEEN,IS NULL,LIMIT,LIKE,SELECT DISTINCT]
 1.SELECT DISTINCT:Avoid any duplicate rows (unique combination of columns in select list).
 Only 1 NULL value will be kept (all null values are considered equal)
 
    SELECT DISTINCT select_list FROM tblName [WHERE search_cond] [ORDER BY sort_expr]; 

 2.Logical AND operator: 

     SELECT a AND b ;#returns 1 if both a,b operands (literals or expr) are non-zero and not null.
     			  #If 1 operand is NULL it returns NULL ,eq:SELECT 1 AND 1;->returns 1 

 3.Logical OR operator:
 
    SELECT a OR b;#If both a,b are not null it returns true (1) if both are non-zero
       #if 1 operand is null ,it returns 1 if both operands are non-zero

 4.Operator IN

    SELECT value IN (val1,val2,val3...)#1,if vakue equals one of the values in the list
    val=val1 OR val2 OR val3 [...] # equivalent ,combination of OR operators
    # returns null if value in the left operand is null or the value doesnt equal a value in the list and 1 value is null
    value NOT IN(val1,val2,val3,...);#Negation of the above

 5.IS [NOT] NULL operator:
 
    SELECT value IS NULL;#Comparison operator,test whether a value is null or not
    SELECT value IS NOT NULL; #Returns 1 (true) if the value is not null,else 0

 6.BETWEEN..AND.. operator:Logical operator,specifies whether a value is in a range or not

     SELECT value BETWEEN low AND;# 1 if value >= low and value <=high ,otherwise 0

 7.[NOT] LIKE operator: Logical operator,tests whether a string contains a specified 

 	%:wildcard character matches any one or more characters 
 	_:wildcard char matches any single character 
    SELECT expr LIKE pattern [ESCAPE escape_char]

 8.LIMIT clause:constrain the number of rows to return

 	SELECT select_list FROM tblName [WHERE condition] [ORDER BY col1 [ASC|DESC]]
 		LIMIT [offset,] row_count; # offset starts from 0,specifies the 1st row to return
 	SELECT select_list FROM tblName [...] 
 		LIMIT n-1,1; #Returns 1 row starting at row n ,ie nth highest row

# B.Grouping data [GROUP BY,HAVING,HAVING COUNT,ROLLUP]
   Order of evaluation :[FROM->WHERE->GROUP BY->HAVING->DISTINCT->SELECT->ORDER BY->LIMIT]
   ROLLUP:Generate subtotals and grand totals
	
	SELECT col1,..cn [aggregate_func(ci)] FROM tblName [WHERE conditions]
		GROUP BY col1,[col2,..] #Without an aggreagate function it behaves like SELECT DISTINCT ...
    SELECT col1,col2,.. FROM tblName [WHERE condition] 
    	GROUP BY col1 [,col2,..] HAVING group_condition #HAVING evaluates each group 
    SELECT col1,[..] COUNT(col2) FROM tblName [WHERE where_cond] 
   		GROUP BY col1 [,col2,..] HAVING COUNT(col2) ...
   		# Uses HAVING COUNT(colName) to filter the groups baased on the number of rows in each group.You cannot assign an alias to COUNT(column)
    SELECT select_list FROM tblName [WHERE cond] GROUP BY col1 [..] [HAVING h_expr]
    	WITH ROLLUP;

  9.Set Operators [UNION,EXCEPT,INTERSECT]
	UNION operator:Combines,appends the result set vertically, as opposed to JOIN statement which combines the result set horizontally
    INTERSECT operator:Find rows that are common in multiple queries
    EXCEPT operator: Retrieve rows from 1 query that do not appear in another query

 	SELECT select_list UNION [DISTINCT|ALL] [FROM tbl1] SELECT select_list2  [FROM tbl2]
 		[UNION [DISTINCT|ALL] SELECT select_list3...] [ORDER BY {expr|int|colName}] #Combine results of >=2 queries
    SELECT column_list1 [FROM tbl1] INTERSECT [ALL|DISTINCT] SELECT col_list2 [FROM tbl2]
    	[ORDER BY {colPosition|colName|expr}];
    SELECT column_list1 [FROM tbl1] [WHERE clause] EXCEPT [ALL|DISTINCT] select_list2 [FROM tbl2] ;
        [WHERE condition] [ORDER BY {colName|colPosition|expr}]

 10.Joining Tables
 MySQL supports the folowing types of joins: [inner,left,right,cross,self]
 Joins are optional clauses that appear in the select statement
 LEFT JOIN: Returns all rows from the left table and matching rows from the right table,or null
 RIGHT JOIN:Returns all rows from the righ table and matching rows from he left table,or null     
 INNER JOIN:Matches rows from one table with rows from another table
          It compares each row in he left table with everey row in the right table and creates
          a new row whose columns contain all columns of rows from the 2 tables including
          new row in the result set
 CROSS JOIN:Cartesian product of rows from multiple tables
 Self-JOIN:Joins a table to itself,and performs an INNER or LEFT join.
           You must assign each instance of the table a unique alias differentiating them

 
  II.Working with Tables
 1.AUTO_INCREMENT:
   Attribute that automatically generates a unique monotonically increasing numbers each time we insert a row
   It is typically associated with the PRIMARY KEY to generate unique identifiers for that column
   
    CREATE TABLE tblName( colName dtype AUTO_INCREMENT ...)
    SELECT LAST_INSERT_ID();#most recent insert row's id
    ALTER TABLE tblName ADD colName dtype AUTO_INCREMENT;
    ALTER TABLE tblName AUTO_INCREMENT=val1; #Reset the value to any int >= current number
    TRUNCATRE TABLE tblName;#resets AUTO_INCREMENT to 0 ,deleting all rows
 2.Add,Remove columns,indexes ,tables and Rename a table  a Column or an Index
    Attempting to remove a column that is a foreign key results in error;you must drop the foreign key.
    When adding a new column ,if you don't specify the position it will be added as the last column in the table.

    ALTERT TABLE tblName DROP FOREIGN KEY fk_symbol;
    ALTER TABLE tblName DROP COLUMN colName;
    ALTER TABLE tblName ADD [COLUMN] colName dtype [{FIRST|AFTER} existingColName]; 
    ALTER TABLE tblName RENAME colNme TO newColName;
    ALTER TABLE tblName RENAME TO newTbl;
    #indexes
    ALTER TABLE tblName DROP PRIMARY KEY;
    ALTER TABLE tblName DROP FOREIGN KEY fk_symbol;
    ALTER TABLE tblName DROP {CHECK|CONSTRAINT} symbol;
    ALTER TABLE tblName ADD {INDEX|KEY} [idxName] [USING {BTREE|HASH}] [(key_part..)] [idx_opt]
    ALTER TABLE tblName ADD {FULLTEXT|SPATIAL} [INDEX|KEY]  [idxName] [idx_opt]
    ALTER TABLE tblName ADD [CONSTRAINT [symbol]] PRIMARY KEY [USING {BTREE|HASH}]
    ALTERT TABLE tblName ADD [CONSTRAINT [symbol]] FOREIGN KEY [idxName] 
    ALTER TAble tblName ADD [CONSTRAINT [symbol]] UNIQUE [INDEX|KEY] [idxName] [USING {BTREE|HASH}]
        [idx_opt]
    #drop a table
    DROP TABLE [IF EXISTS] tbl1 [...] [RESTRICT|CASCADE];

 3.Change,modify column definitions & index properties
    
    ALTER TABLE tblBName MODIFY [COLUMN] colName col_def [FIRST|AFTER] col2;
    ALTER TABLE tblName CHANGE [COLUMN] colName newColName col_def [FIRST|AFTER] col2;
    ALTER TABLE tblBName ALTER [COLUMN ] colName {
        SET {VISIBLE|INVISIBLE}|SET DEFAULT {literal|expr}|DROP DEFAULT};
    ALTER TABLE tblNanme ALTER INDEX idxName {VISIBLE| INVISIBLE};
    ALTER TABLE tblbName ALTER {CHECK|CONSTRAINT} [NOT] ENFORCED;
 4.TRUNCATE & Delete 
  If there is a foreign key in the table definition that references another table the truncate will fail.
  TRUNCATE resets the value of the AUTO_INCREMENT to its initial state & and deletes all rows from the table
      Truncate is equivalent to a DROP TABLE & CREATE TABLE statements,or a DELETE FROM without a where clause

        TRUNCATE TABLE tblName;
        DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tblName [[AS] tblAlias] 
            [PARTITION part_name1,..] 
            [WHERE condition]  [ORDER BY {int|colName [ASC|DESC]} ] [LIMIT row_cnt]
        #Delete multiple tables
        DELETE [LOW_PRIORITY] [QWUICK] [IGNORE] tblName1[.*] tblName2[.*] 
             FROM tblreferences [WHERE condition]  --tablereferences are the tables involved in a JOIN
        DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl1[.*], tbl2[.*] 
            USING tblReferences  [WHERE condition] 
  
 5.Generated Columns [GENERATED ALWAYS]
   Data in these columns are computed based on predefined expressions
   In the column definition add the GENERATED ALWAYS clause to indicate that it is a generated column.
   Then,indicate the type of the generated column,as VIRTUAL or STORED (defaults to VIRTUAL)
    
    colName dtype [GENERATED ALWAYS] AS (expression) 
                [VIRTUAL|STORED] [UNIQUE [KEY]];
 6.Temporary tables
   A type of table which you can query as many times as you want in a single session. 
   You can explicitly drop the table during a single session,if it is no longer needed.
   It is only available to a single client for a single session,different clients can create
   temporary tables with the same name without causing error.
   It can have the same name with a regular table ,though it is not recommended.
   It is useful to store expensive queries and create another query to access the table
   
    CREATE TEMPORARY TABLE [IF NOT EXISTS] (col_name dtype ...);
    DROP TEMPORARY TABLE [IF EXISTS] tblName;

 7.Storage Engines
  A component responsible for managing ,storing,retrieving and manipulating data within tables
  MyISAM:Is optimized for compression andd speed 
  MEMORY: Tables are stored in memory & uses hash indexes for search.MEMORY tables have a lifetime
         that depends on the uptime of the database server  
  CSV:Stores data in csv format & is convinient to transfer data to non-sql storage engines
  InnoDB: Provides support for ACID compliant operations and transactions
  FEDERATED:
  Archive:Stores large amount of data in a compressed format saving space.Only [INSERT,SELECT] statements
          are allowed
  BLACKHOLE:
   Engine Transactional ACID compliance FK constraints FullText search Locking Crash Recovery Temporary tables
   InnoDB  Yes           Yes             Yes            Yes              Yes    Yes
   MyISAM  No            No              No             Yes                      No            Yes
   CSV     
   MEMORY
   BLACKHOLE
   FEDERATED
   ARCHIVE
   MRG_MYISAM

    SHOW ENGINES [{LIKE patt| WHERE condition}];
    SELECT engine,support FROM information_schema.engines ORDER BY engine;
 8.MySQL Constraints: [PRIMARY KEY,FOREIGN KEY,NOT NULL, CHECK,UNIQUE,DEFAULT]
 (i)PRIMARY KEY:Is a column  or a group of columns in a table that uniquely identifies each row 
    in that table.
    A PK column must consist of unique values;if it is composed of multiple columns then their 
    combination values in these columns must be unique.
    A table can have at most 1 PK.
     
    CREATE TABLE tbl(col1 dtype ,col2 dtype ..    CREATE TABLE tbl( col1 dtype PRIMARY KEY,
            PRIMARY KEY(col1,col2)                       ...
    );                                             );
    ALTER TABLE tbl ADD PRIMARY KEY (col1,col2,..);
    ALTER TABLE tbl DROP PRIMARY KEY;
  

 (ii)FOREIGN KEY:A column or a group of columns in a table that links to columns in some other table
    MySQL uses FK to accomplish referential integrity as the fk places constraints on the data in the 
    related tables
    The FK maintains referential integrity between the parent & child tables by using the 
    [ON DELETE,ON UPDATE] clauses.Reference options:
    CASCADE:Deleting/Updating a row in a parent row causes the values of the child tables to be deleted/updated
    NO ACTION=RESTRICT
    SET DEFAULT:
    SET NULL:If as row in the parent table is updated/deleted then values in the FK columns are set to null
    RESTRICT:If a row in the parent table has matching rows in the child table then MySQL rejects updating/deleting 
        the rowsd in the parent table
    When loading data to parent and child tables it may be useful to disable foreign key checks


(iii)UNIQUE integrity constraint 
  It is a constraint that ensures the uniqueness of values in a column or a combination of columns
  NULL values are treated as distinct for unique constraints
  When creating a unique constraint ,MySQL creates a corresponding index to enforce the rule
  If you define a unique constraint without specifying a name, MySQL automatically creates one

    CREATE TABLE tbl(...           CREATE TABLE tbl (
        col3 dtype UNIQUE,              col1 dtype ,cole dtype ,..
       ...                              UNIQUE(col1,col2)    
    );                              );
    SHOW INDEXES FROM tblName;
    SHOW CREATE TABLE tbl; 
    ALTER TABLE tbl ADD CONSTRAINT consName UNIQUE (col_list);
    ALTER TABLE tbl DROP INDEX idxName;
    DROP INDEX idxName ON tbl;

(iv)CHECK constraint
 It is used to ensure that a column or a group of columns satisfies some boolean expression
 Omitting the name of this constraint causes MySQL to automatically generate one
 
    CREATE TABLE tbl (...
        [CONSTRAINT conName] CHECK (boolean_expr) [ENFORCED|NOT ENFORCED],
        ...
    );
    SHOW CREATE TABLE tblName; --obtain the automatically created name for check constraint
    ALTER TABLE tbl ADD [CONSTRAINT conName] CHECK (boolean_expr);
    ALTER TABLE tbl DROP CHECK conName;
(v)DEFAULT constraint
    
 (vi)NOT NULL constraint
   Ensures that values of a column will not be null  
 
 III.DML :Modifying data [INSERT,DELETE,UPDATE,REPLACE,LOAD {DATA|XML},VALUES,TABLE,subqueries,cte]
    1.INSERT,UPDATE,DELETE,REPLACE statements

    INSERT [LOW_PRIORITY|DELAYED|HIOGH_PRIORITY|IGNORE] [INTO] tblName [PARTITION pname1..][(colName1,..)] 
        {{VALUES|VALUE} (val_list)..} [AS row_alias1[(colAlias1,..)]
        [ON DUPLICATE KEY UPDATE assignment_list]
    INSERT [LOW_PRIORITY|HIGH_PRIORITY|DELAYED|IGNORE] [INTO] tblName [PARTITION pname1..]
        SET assignment_list [AS row_alias[(colAlias..)]
        [ON DUPLICATE KEY UPDATE assignment_list]
    INSERT [LOW_PRIORITY|DELAYED|HIGH_PRIORITY|IGNORE] [INTO] tblName [PARTITION ponmame1..]
        [(col1,..)] {SELECT|TABLE tblName| VALUES row_constructors]}
        [ON DUPLICATE KEY UPDATE assignment_list]
    #update 1 table or multiple tables 
    UPDATE [LOW_PRIORITY] [IGNORE] tblReference 
        SET assignment_list [WHERE condition] [ORDER BY {colName|colPos|expr} [ASC|DESC]]
        [LIMIT row_cnt]
    UPDATE [LOW_PRIORITY] [IGNORE] tblReferences 
        SET assignment_list [WHERE condition]
    #delete
    DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tblName [[AS] alias] [PARTITION pname1..]
        [WHERE condition] [ORDER BY {colName|colPos|expr}..[ASC|DESC]}]
        [LIMIT row_cnt]
    #replace
    REPLACE [LOW_PRIORITY|DELAYED] [INTO] tblName [PARTITION pname1..] [(col1,..)]
        {{VALUES|VALUE}(val_list)..}|VALUES row_constructor}
    REPLACE [LOW_PRIORITY|DELAYED] [INTO] tblName [PARTITION pname1,..]
        SET assignment_list
    REPLACE [LOW_PRIORITY|DELAYED] [INTO] tblName [PARTITION pname1,.] [(col1,..)]
        {SELECT..|TABLE tblName};
 2.Subqueries
   A query (select statement)nested within another query or a query nested within another subquery
   The subquery is called inner query while the query that contains the subquery is called outer query
   Derived Table: When the subquery is in the FROM clause, the result is a temporary table and is 
   is referenced to as derived table or materialized subquery
   When the subquery is in the WHERE clause you can use comparison operators {<,>,<=,>=,<>,!=,<=>}
   EXISTS operator is used to test the existence of rows returned byu subqueries

    SELECT select_list FROM tblName WHERE {
        operand comparison_operator ANY (subquery);
        operand comparison_operator SOME (subquery);
        operand comparison_operator ALL (subquery);
        operand IN (subquery); 
    }st FROM tbl WHERE [NOT] EXISTS (subquery);
    SELECT select_list FROM (
        SELECT column_list FROM tbl1) derivedTbl 
        [WHERE derivedTbl_condition];

 3.Common Table Expressions (cte) 
  A WITH statement that has 1 or more subclauses 
  It is a named temporary result and as with the derived tables it is not stored as an object lasting only
  during the query execution  
  A recursive common table expression is a self referencing named temporary result set,consisting of :
    An initial query, a recursive part which references the cte_name itself and a termination condition
    The recursive part is joined with the initial query (anchor member) by a [UNION {ALL|DISTINCT}] operator
  The recursive member must not contain the following: 
    Aggregate functions,GROUP BY,ORDER BY,LIMIT,DISTINCT clauses

    WITH cte_name  AS (
        query)
    SELECT* FROM cte_name;
    WITH RECURSIVE rcte_name AS (
        initial_query --anchor member
        recursive_query --recursive member
    ) SELECT* FROM rcte_name;
 