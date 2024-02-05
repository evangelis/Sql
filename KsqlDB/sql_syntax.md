 I. Statements

 # A.Streams & Tables :[CREATE,DROP,INSERT ,DESCRIBE,PRINT]
 # Stream

    CREATE [OR REPLACE] [SOURCE] STREAM [IF NOT EXISTS] 
 		streamName([colName1 dtype [KEY|HEADER(key)|HEADERS] ...])
     WITH (propert_name1=p_value1,...);	
    DROP STREAM [IF EXISTS] str1 [DELETE TOPIC];
    ALTER STREAM streamName ADD [COLUMN] colName dtype [...];
    INSERT INTO strName [(colName1,..)] VALUES (v1,..);
    INSERT INTO strName [WITH (propert_name1=pval1,..)] 
    	AS SELECT select_expr FROM from_stream 
    	[[LEFT|FULL|INNER] JOIN {join_tbl|join_stream} 
    		[WITHIN {<sz> time_unit|(bef_sz time_unit,afte	time_unit)}] 
    		[GRACE PERIOD <sz> time_unit] ON join_criteria]
    	[WHERE condition] [PARTITION BY new_key_expr ...]
    	EMIT CHANGES;


   # Materialized stream :Create as select
    CREATE [OR REPLACE] STREAM strName [WITH (pname=pval1,..)] AS SELECT select_expr FROM stream1 
    	[[LEFT|FULL|INNER] JOIN {tbl1|strName3} [WITHIN {bef_sz time_unit, aft_sz time_unit| <size> time_unit}]
    	[GRACE PERIOD <grace_size> time_unit] ON join_criteria]
    	[WHERE condition] [PARTITION BY colName] 
    	EMIT CHANGES;
 # Table 
  	CREATE [OR REPLACE] [SOURCE] TABLE [IF NOT EXISTS] tblName[(colName1 dtype [PRIMARY KEY],...)]
  		WITH(pname1=pval1,..);-- create a table & register in an underlying topic
    DROP TABLE [IF EXISTS] tblName [DELETE TOPIC];
    ALTER TABLE tblName ADD [COLUMN] colName dtype [...];
   # Materialized Table 
  	CREATE [OR REPLACE] TABLE tblName [WITH (pname=pval1,..)] AS SELECT select_expr FROM from_item
  		[[LEFT|FULL|INNER] JOIN {join_tbl|join_str} ON join_criteria]
  		[WINDOW w_expr]
  		[WHERE condition] [GROUP BY group_expr] [HAVING h_expr]
  		[EMIT output_refinement];
  	PRINT topiCName [FROM BEGINNING] [INTERVAL|SAMPLE intv] [LIMIT num];

 # B. Custom Types: [CREATE,DROP,SHOW] 		
 	{LIST|SHOW} TYPES;
 	DROP TYPE [IF EXISTS] typeName AS dtype;
 	CREATE typeName AS dtype;
 	DEFINE varName; 
 	UNDEFINE varName;

 # C. Metadata :[SHOW ,DESCRIBE,SPOOL]
 	{LIST|SHOW} {TABLES|STREAMS} [EXTENDED];
 	{SHOW|LIST} FUNCTIONS;
 	SHOW PROPERTIES;
 	{LIST|SHOW} QUERIES [EXTENDED];
 	{SHOW|LIST} [ALL] TOPICS [EXTENDED];
 	DESCRIBLE FUNCTION funcName;
 	SPOOL {fName|OFF}; --Stores issued commands & their results into a file

 # D. Queries :[SELECT (push & pull),EXPLAIN,TERMINATE,PAUSE,RESUME]
 	{PAUSE|RESUME|TERMINATE} {query_id|ALL}; --Pause/resume/terminate persistent queries
 	EXPLAIN {query_id|sql_expression};
  #	Select Pull query
  	SELECT select_expr FROM from_item 
  		[WHERE condition] [AND window_bounds] [LIMIT cnt];
  # Select Push query
    SELECT select_expr FROM from_item 
    	[[LEFT |FULL|INNER] JOIN join_item 
    	    [WITHIN	{(bef_sz time_unit,aft_sz time_unit)| sz time_unit}] ON join_criteria]
    	[WINDOW w_expr]
    	[WHERE condition] [GROUP BY group_expr] [HAVING h_expr]
    	EMIT [output_refinement] [LIMIT cnt];

 # E. Connectors [CREATE,DEECRIBE,DROP,SHOW]
 	CREATE {SOURCE|SINK} CONNECTOR [IF NOT EXISTS] connectorName
 		WITH(pname1=pval1,..);
 	DROP CONNECTOR [IF EXISTS] connectorName;
 	{SHOW|LIST} CONNECTORS;
 	DESCRIBE CONNECTOR connectorName;

 # F. Execution [RUN SCRIPT,ALTER SYSTEM]
  	RUN SCRIPT /path/to/filename;
  	ALTER SYSTEM 'config-name' ='config-value'; --eq auto.offset.reset ={earliest|latest}

 # G. Assertions [ASSERT SCHEMA,ASSERT TOPIC] 


 II. Operators & Functions
 # Operators
 	Comparison Operators: EQ,NEQ,LT,LTE,GT,GTE, 
                        [NOT] BETWEEN expr ..AND expr2
                        [NOT LIKE expr [ESCAPE char]
                        IS [NOT] NULL
                        IS [NOT] DISTINCT FROM expr
    Arithmetic Operators: +,-./,*,%
    Logical Operators : AND,OR,NOT
    Source Dereference: '.' ,specifies columns by dereferencing the source collection
    Subscript operator: '[subscript_expr]' is used to reference the value at an 
                        array index or map key
    Struct Dereference: '->',access the fields in a struct 
       eq: SELECT users.address->street, u.address->street from users u emit changes;
 #Functions
  A. Aggregate Functions
   # Applies to both streams and tables	
  	AVG(colName),COUNT(*),COUNT(colName),SUM(colName)
  	COLLECT_LIST(colName) -- returns an ARRAY
  	CORRELATION(expr1,expr2),HISTOGRAM(colName) --MAP<Key,BIGINT>
  	STDDEV_SAMPLE(colName)=STDDEV_SAMP(colName)
  # Applies only to streams
   	COLLECT_SET(colName),COUNT_DISTINCT(colName),MAX(colName),MIN(colName),
   	TOPK(col1,..),TOPKDISTINCT(col1,..)
   	EARLIEST_BY_OFFSET(col1,[ignoreNulls])
   	LATEST_BY_OFFSET(col1,[ignoreNulls])

  B.Table Functions
  # Functions that return >=0 rows
    EXPLODE(arrayName) --Outputs 1 value for each of the array elements 
    CUBE_EXPLODE(ARRAY[col1,..colN]) --Outputs all possible combinations of the 
                                      array columns
  C.Scalar Functions :Return a single value
 # Numeric Functions

 # String Functions  :Encoding Types :{utf8,ascii,base64,hex}
    CONCAT(Strcol1,Strcol2,..),CONCAT(BYTES1,BYTES2,...),CONCAT_WS(sep,expr1,expr2,...),
    encode(strCol1,input_encoding,output_encoding),lcase(col1),ucase(col1),len({strCol|bytesCol}),initCal(col)
    rpad(inCol,len,padding),lpad(inCol,len,padding)
    split(col1delimiter),
    substring({str|bytes},pos [,len]),instr(str,substr,[pos,..len])
 # Bytes Functions 
 # Date & Time Functions
    FORMAT_DATE(dt,'yyyy-MM-dd'),format_time(tm,'HH:mm:ss.SSS') --converts a date/time value into a string
    FORMAT_TIMESTAMP(tmsl,'yyyy-MM-dd HH:mm:ss.SSS' [,TIMEZONE)
    PARSE_DATE(strCol1,'yyyy-MM-dd'),PARSE_TIME(strCol,'HH:mm:ss.SSS'),
    PARSE_TIMESTAMP(strCol1,'yyyy-MM-dd HH:MM:ss.SSS') ---converts a string to a TIMESTAMP value
    DATEADD(unit,intv,strCol), DATESUB(unit,intv,col),TIMEADD(unit,intv,str_expr),TIMESUB(unit,intv,expr)
    TIMESTAMPADD(unit,intv,col1),TIMESTAMPSUB(unit,intv,expr)
    UNIX_DATE([dt]),UNIX_TIMESTAMP([tmsp]) -- Returns a BIGINT
    FROM_UNIXTIME(millisecs_unixtmsp)--converts to TIMESTAMP
    FROM_DAYS(int)
    CONVERT_TZ(col1,'from_tz','to_tz')

 # Nulls
    COALESCE(expr1,expr2,...),IFNULL(expr,true_res) 
    NULLIF(expr1,expr2) -- returns null if expr1 =expr2 ;otherwise expr1
 # Collections 
    ARRAY[expr1,...], ARRAY_CONCAT(a1,a2),ARRAY_CONTAINS(a1,elem), ARRAY_DISTINCT(a1)
    ARRAY_EXCEPT(a1,a2),ARRAY_MAX(a1),ARRAY_MIN(a1),ARRAY_LENGTH(a1),ARRAY_INTERSECTION(a1,a2),
    ARRAY_UNION(a1,a2),ARRAY_JOIN(col1,delimiter), ARRAY_REMOVE(a1,elem),ARRAY_SORT(a1,[{'ASC|DESC'}])
    MAP(key VARCHAR :=v1,...), MAP_KEYS(m1),MAP_VALUES(m1), MAP_UNION(M1,M2),AS_MAP(keys,values)
  # Invocation Functions
    FILTER(arr1,x=>...), FILTER(m1,(k,v)=>...), TRANSFORM(a1,x=>..),TRANSFORM(m1,(k,v)=>..,(k,v)=>..)
    REDUCE(a1,state,(s,x)=>...), REDUCE(m1,state, (s,k,v)=>...)

  # URL Functions

  

 


