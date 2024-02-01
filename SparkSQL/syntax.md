1.DDL Statements :
 {DROP|CREATE}, {Database|Function|Table|View},ALTER {Database|Table|View},TRUNCATE Table,REPAIR TABLE,TRUNCATE TABLE,USE Database

 --Database
 CREATE {DATABASE|SCHEMA} [IF NOT EXISTS] dbName 
 	[COMMENT 'str'] [LOCATION dir] [WITH DBPROPERTIES[(pname=pvalue,..)]];
DROP {SCHEMA|DATABASE} IF EXISTS dbName {RESTRICT|CASCADE} ;
ALTER {DATABASE|SCHEMA} dbName 
	SET {DBPROPERTIES|PROPERTIES} (pname1=pval1,..); --eq LOCATION
USE dbName;

--View 
CREATE [OR REPLACE] VIEW [[GLOBAL] TEMP] [IF NOT EXISTS] viewName
	[(colName1 [COMMENT 'str')..] [COMMENT 'viewCmt' ] [TBLPROPERTIES (pname1 =pval1,..)]
	AS select_statement;
DROP VIEW [IF EXISTS] vName;
ALTER VIEW -- RENAME TO | SET TBLPROPERTIES|UNSET TBLPROPERTIES| AS SELECT ..
ALTER VIEW vName RENAME TO vName1;
ALTER VIEW vName UNSET TBLPROPERTIES [IF EXISTS] (pname1,..);
ALTER VIEW vName SET TBLPROPERTIES (pname1=pval1,...);
ALTER VIEW vName AS SELECT query1; 

--Function
CREATE [OR REPLACE] [TEMPORARY] FUNCTION [IF NOT EXISTS] fname 
	AS 
DROP [TEMPORARY] FUNCTION [IF EXISTS] fname;

--Table 
--CREATE TABLE : {LIKE ..|USING HIVE_FORMAT|USING DATA_SOURCE}
CREATE TABLE [IF NOT EXISTS] tblName [(col1 dtype1 [COMMENT cmt1]..)] USING d_source [OPTIONS (k1=val1,..)] 
	[PARTITIONED BY (col3,col4,..)]
	[CLUSTERED BY ()] [SORTED BY ()]
 [LOCATION path] [COMMENT 'str'] [TBLPROPERTIES (k1=val1,..)] 
  [AS SELECT select_stmt];

TRUNCATE TABLE tbl [PARTITION (p_col1 =p_val1,..)];
DROP TABLE [IF EXISTS] tbl [PURGE];

2.DML Statements :INSERT TABLE,LOAD,INSERT OVERWRITE DIRECTORY
	
	INSERT INTO [TABLE] tblname REPLACE WHERE bool_expr;
	INSERT [INTO |OVERWRITE] [TABLE] tblName [part_spec] [(col_list)]
		{VALUES (v|NULL..)|query}

3.Data Retrieval statements [SELECT,EXPLAIN]


	--SELECT 
	[WITH with_query[..]] 
	select_stmt [{UNION |INTERSECT | EXCEPT} [ALL|DISTINCT] select_stmt2...]
	[ORDER BY {expr[ASC|DESC] [NULLS {FIRST|LAST}]..}]
	[SORT BY {expr [ASC|DESC] [NULLS {FIRST|LAST}]..}]
	[CLUSTERED BY {expr ..}]
	[DISTRIBUTE BY {expr}] 
	[WINDOW {named_window [,WINDOW n_window2..]}]
	[LIMIT {ALL | expr}]

	SELECT [hints,..] FROM {from)_item}
	[PIVOT clause] 
	[UNPIVOT clause] --transforms rows into columns
	[LATERAL VIEW clause] [WHERE bool_expr] 
	[GROUP BY expr,..] [HAVING bool_expr];

 	--cte defines a temporary result set that can be referenced multiple times
 	WITH cte [...] expression_name[(col1,..)] [AS] query; 
Clauses
CLUSTER BY {expr..} :Reaprtitions the data based on the expr and then sorts the data within each partition
DISTRIBUTE BY {expr} : Repartitions the data based on the expr
SORT BY {expr [ASC|DESC] [NULLS {FIRST |LAST}]}:
#Inline table: A temp table created using the VALUES clause
VALUES (expr..) [[AS] tblname(col1,..)]

CASE [expr] WHEN bool_expr THEN res1 [WHEN bool_expr2 THEN res2] [...]
[ELSE else_res]
END;
##LATERAL VIEW works 
LATERAL VIEW [OUTER] generator_func(expr..) [tbl_alias] AS col_alias [...,]

4.Auxiliary Statements :Describe,show,analyze,set,cache,uncache,reset,list

--DESCRIBE {|DATABASE|TABLE|QUERY|FUNCTION}
	
	{DESC|DESCRIBE} FUNCTION [EXTENDED]fname;
	{DESC|DESCRIBE} DATABASE [EXTENDED] dbName;
	{DESC|DESCRIBE} [TABLE] [PARTITION BY p_colname1=p_val1...] [colName]
	{DESC|DESCRIBE} [QUERY] input_stmt ;--select stmt,cte,table stmt,inline table stmt ,from stmt
--SHOW :{COLUMNS,FUCNTIONS,DATABASES,PARTITIONS,TABLES,TABLE,VIEWS,CREATE TABLE}

	SHOW CREATE TABLE tblName [AS serde];--generates HIVE DDL for a Hive SerDe table
	SHOW {DATABASES|SCHEMAS} [LIKE regpattern];
	SHOW TABLES {FROM|IN} dbName [LIKE regPattern];
	SHOW TABLE [EXTENDED][{FROM|IN} dbName] [LIKE regPatt]
		[PARTITION (p_col=p_val,..)];
	SHOW VIEWS [{FROM|IN} dbName] [LIKE reggPattern];
	SHOW PARTITIONS tblName  [PARTITION (p_col1=p_val1..)];
		