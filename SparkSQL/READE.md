 I.Introduction
  Structured Data : Is the data that has a standardized format for efficient access
 Excell files,SQL dbs, point-of-sale data resdervation systems ,web formn results ,reservation systems ,product directories are all examples of structured data 
 Unstructured Data: Information with no set data model.
Text files,video files,images,reports ,email are examples of unstructured data
Enterprises are creating data at an exponential rate ,and the vast majority of data (80-90%) is unstructured
Benefits include ease of usage,scalability (add storage and processing power )and analytics (analyzing patterns from data using ML algorithms)
Challenges include the limited usage and  inflexibility (changing the schema of the data is difficult)

 Unstructered data is stored in NoSQL databases and Data Lakes.It lacks searchability as it does not adhere to predefined rules.Analyzing unstructered data requires expertise and advanced analuytical tools

 Semi-Structured Data : It lacks a specific relationalor tabular data model not being structured data, but includes metadata that can be analyzed ,such as tags and other markers 
JSON,XML,email zipped files,web files are considered semi-strucvtured data  

1.Semi-Structured data is considered mopre straingthforward to derive info from than unstructured data.
2.Structured data is usually stored in [Data Warehouses] while unstrtuctured data is stored in [Data Lakes]
 Data Warehouse : is where sturctured data is stored,acting as a central repo for enterprise data. 
It supports large scale data analysis by hundreds of users providing useful insights and business intelligence.
A data warehouse pulls data from multiple structured sources, relational databases and transactional systems.

 Data Lake: A central repo,used to store raw unstructured data .As companies create vast amount of uunstructured data daily, a data lake can store usntruictured data at scale. 
 It can store data from mobile apps, IoT devices,social media and relational data from business apps  


 II.Spark SQL 
 A.General 
 Spark SQL is a Spark module for structured data processing. 
The interfaces provided by Spark SQL provide spark with more information about the structure of the data & the computation being performed .Internally,Spark SQL uses this info to perform extra optimizations 
To interact with Spark SQL you can use either SQL or the Dataset API ;the same execution engine wioll be used irrespective of which API or language will be used to express the computation
Thus,we can switch back and forth between different APIs to express based on which one provides the most natural way to express the computation

 Dataset is a distributed collection of data,that combines thge benefits of RDDs (strong typing) with the benefits of Spark SQL's optimized engine
It is available in Java & Scala but not in Python;it is constructed from JVM objects 
Datasets are similar to RDDs but instead of using Java serialization or Kryo they use a org.apache.spark.sql.Encoder to serialize the objects for transmitting and processing over the network.
 
 DataFrame is Dataset organized into named columns ,equivalent to table in RDBMs or a DataFrame in Python and R, but with some extra optimizations nder the hood. 
It can constructed from a wide array odf sources:External databases, structured data files, existing RDDs, Hive tables.
In Java it is expressed as Dataset<Row>, in Scala as Dataset[Row]

B.Data Types                                                         
                  Spark SQL & DF Java                 Python            SQL
                                                                               
    Numeric Types: ByteType    	 byte,Byte            int,long          BYTE,TINYINT 
                   ShortType     short,Short          int,long          SHORT,SMALLINT
                   IntegerType   int,Integer          int,long          INT,INTEGER
                   LongType      long, Long           long              LONG,BIGINT
                   FloatType     float,Float          float             FLOAT,REAL
                   DoubleType    double,Double        float             DOUBLE
                   DecimalType   java.math.BigDecimal decimal.Decimal   DECIMAL,DEC,NUMERIC  
    String Types:  StringType    String                                 STRING,VARCHAR,CHAR,
                                                                        TIIINY
                                                                        TEXT,MEDIUMTEXT,LONGTEXT
                                                                        ENUM,SET
    Binary Types:  BinaryType    byte[]                bytearray        BINARY,VARBINARY,
                                                                        TINYBLOB,MEDIUMBLOB,LONGBLOB
    Boolean Type : BooleanType   boolean,Boolean       bool 

    Complex Types: ArrayType     java.util.List        list,tuple    
                   mapType       java.util.Map         dict
                   StructType    org.apache.spark.sql. list,tuple
                                            Row                      
                   StructField 
    Date & Time:   DateTimeType                        datetime.date       DATE   
                   TimestampType  java.time.Period    datetime.datetime
              TimestampNTZType    java.time.Period    datetime.datetime  
    Intervals:DayTimeIntervalType java.time.Duration          
                   YearMonthIntervalType               java.time.Period
 Notes:
  1.There are 2 ways to comply with the SQL standard 
   (i) [spark.sql.ansi.enabled->true] :Spark SQL will use an  ANSI compliant dialect instead of  being Hive compliant
   (ii) [spark./sql.storeAssignmentPolicy=ANSI]


C.Functions 

 1.Scalar Functions

 //Array Functions
 array(expr,..),sequence(start,stop,step),get(a1,indx),element_at(a1,indx)
 array_except(a1,a2),array_intersect(a1,a2),array_union(a1,a2)
 array_distinct(a1),array_contains(a1,elem),array_position(a1,elem)
 arrays_overlap(a1,a2),arrays_zip(a1,a2),array_join)(a1,delimiter,[null_repl])
 array_min(a1),array_max(a1),array_repeat(elem,cnt),
 array_insert(arr,pos,elem) ,array_remove(a1,elem),array_append(a1,elem),
 arrqay_prepend(a1,elem)
 shuffle(arr),sort_array(a1 ,[ascendingOrder]),flatten(arrayofArrays),array_compact(a1),

  //Map Functions
  map(k1,v1,k2,v2,..)map_from_arrays(keyArr,valArr),str_to_map(),map_concat(m1,m2,..)
  map_entries(m1)->array, map_contains_key(m1,k),map_keys(m1),map_values(m1)
  element_at(m1,k),

 
 //Aggregate Functions
 avg(expr),min(expr),max(expr),sum(expr),
 count(*),count([DISTINCT expr1[...]),count_if(expr)
 stddev(expr)=std(expr_)=stddev_pop(expr),stddev_samp(expr),
 variance(expr)=var_pop(expr),var_samp(expr) 

 //Window Functions
 lag(expr,[offset,..default]),lead(expr,[offset,..default]),nth_value(expr[,offset])
 rank(),dense_rank(),percent_rank(),row_number(),
 ntile(n),cum_dist()

 //Conditional Functions
 coalesce(expr1,expr2,..), if(expr1,expr2,expr3)//if expr1 is true returns expr2 
 ifnull(expr1,expr2)
 CASE WHEN expr1 THEN res1 [WHEN expr2 THEN res2..] [ELSE else_res] END
 
  //Conversion Functions
 tinyint(expr),smallint(expr),int(expr),bigint(expr),float(expr),double(expr),decimal(expr),
 boolean(expr),string(expr),binary(expr),date(expr),timestamp(expr)
 CAST(expr AS dtype)

 //Date & Time Functions
 curdate()=current_date=current_date, current_timestamp=current_timestamp()=now()
 localtimestamp=localtimestamp()
 make_date(year,month,day),make_timestamp(y,m,d,h,min,sec [,tz])
 year(dt),quarter(dt),month(dt),hour(tmsp),minute(tmps),second(tmsp),
 last_day(dt),day(dt),dayofmopnth(dt),dayofweek(dt),dayofyear(dt),
 add_months(start_dt,num),date_add(dt,num)=dateadd(st,num),date_sub(dt,num)=datesub(dt,num),date_format(tmsp,fmt),trunc(dt,fmt)
 date_diff(endDt,startDt)
 from_unixtime(unixtm,[fmt]),to_unix_timestamp(tmsp,[fmt])

 //String Functions
 repeat(str,n),replace(str,str,replStr)
 lcase(str)=lower(str),ucase(str)=upper(str),initcap(str),left(str,len),right(str,len),ltrim(str),rtrim(str),trim({LEADING|TRAILING|BOTH}[trimStr] [FROM] str)
 lpad(str,len [,pad]),rpad(str,len,[pad]),character_length(expr)=char_length(expr),length(expr), octet_length(expr)
 endswith(left,right),startswith(left,right),decode(bin,charset),encode(str,charset)
 space(n),split(str,regexPatt,limit),substring(str,pos [,len]),substring(str FROM pos [FOR len]),substring_index(str,delim,cnt),
 instr(str,substr)->int, position(substr,str [,pos])
 regexp_substr(str,regPatt)->string,regexp_instr(str,regPatt)->int,regexp_extract(str,regPatt [,idx]),regexp_count(str,regPatt),regexp_replace(str,regPatt,replStr[,pos])

 //Predicate Functions
 !expr, expr1 AND expr2 ,not expr1 ,expr1 or expr2,
 expr1 <expr2 ,expr1 <= expr2, expr1 >= expr2, expr1 =expr2, expr1 ==expr2,exrp1<=> expr2 
 expr1 in (expr2,expr3,..),isnull(expr1),isnotnull(expr1),isnan(expr1)
 regexp(str,regPatt)=regexp_like(str,regPatt)=rlike(str,regPatt)->BOOLEAN
 str LIKE patt [ESCAPE char]

 //Generator Functions
 explode(arr_or_map)// seperates elements of array/map into multiple rows or rows and columns respectively
 posexplode(arr_or_map)//seperates elemets and their positions
 posexplode_outer(arr_map)//Uses column names :'pos','col','key','val'
 explode_outer(arr_or_map)
 inline(arr),inline_outer(arr)//explodes an array of strcuts
 stack(n,expr1,..exprk)//seperates expr1 ..exprk intop n rows


 D.useful classes in [org.apache.spark.sql] package

 interface Row extends scala.Serializable

    StructType schema()
    Object     get(int i) 
    <T> T      getAs(int i),getAs(String fieldName),getAnyValueAs(int i)
    <Xxx> Xxx  getXxx(int i) //Xxx ={byte,boolean,double,float,int,long,short,String,Date,BigDecimal,List,}

    class SparkSession implements scala.Serializable, java.io.Closeable, org.apache.spark.internal.Logging
      static SparkSession  active()
      static void    clearActiveSession(),clearDefaultSession()
                     setActiveSession(SparkSession s),setDefaultSession(SparkSession s)
      static SparkSession.Builder builder()               
      DataFrameReader  read()
      DataStreamReader readStream()
      UDFRegistration  udf()
      SQLContext       sqlContext()
      SparkContext     sparkContext

      Dataset<Row>     table(String tblName),sql(String sql [,Map<String,Object>]),
                       sql(String sqlStr, scala.collection.immutable.Map<String,Object>),
                       emptyDataFrame(),createDataFrame(List<Row> rows,StructType schema)
                       createDataFrame(JavaRDD<Row> rdd,StructType schema),createDataFrame(JavaRDD<?> rdd,Class<?> beanClass)
      String  version()
      <T> Dataset<T>   createDataset(List<T>,Encoder<T>),emptyDataSet(Encoder<T>)
                       createDataset(scala.collection.Seq<T> ,Encoder<T>)   
      Dataset<Long>    range([long start,]long end [,long step,..int numPartitions])






    class Dataset<T> extends Object implements scala.Serializable
 A strongly typed collection of domain-specific objects that can be transformed and operated upon in parallel.Each Dataset has an untyped form called DataFrame ,that is ,Dataset<Row>
    
    //methods
    boolean        isLocal(),isStreaming(),isEmpty()
    SparkSession   sparkSession()
    SQLContext     sqlContext()
    StorageLevel   storageLevel()
    DataFrameStat
      nctions      st()
    StructType     schema()
    RDD<T>         rdd()
    JavaRDD<T>     toJavaRDD() 
    Encoder<T>     encoder()
    DataFrameWriter<T> write()
    DataStreamWriter<T> writeStream()
    DataFrameWriterV2<T> writeTo(String p)
    Iterator<T>    toLocalIterator()
    Object         take(int n),tail(int n),head(int n)//returns rows
                   collect() // array with all rows in this Dataset
    T              first(),head(),
    List<T>        collectAsList()
    long           count()
    void           create[OrReplace][Global]TempView(String name),printSchema([int level]), show([int num,{boolean|int}trunc,boolean vertical])
                   explain([String mode])
    Dataset<T>     alias(String alias),alias(scala.Symbol alias),checkpoint([boolean eager]),localCheckpoint([boolean]),cache(),
                   persist(StorageLevel l),limit(in n),unpersist(),
                   distinct(),coalesce(int np),repartition(int np),
                   dropDuplicates({String[] colNames|String col1,..|scala.collection.Seq<String>}),dropDuplicates()
                   filter({String cond|FilterFunction<T> |Column cond|}),filter(scala.Function1<T,Object>),where({Column|String cond})
                   hint(String name,..{Object params|scala.collection.Seq<Object>})
                   sanmple([boolean withRepl,]double fraction,[long seed]),
                   except(Dataset<T> ds2),exceptAll(Dataset<T> ds2),intersectAll(Dataset<T> ds2),intersect(Dataset<T>),
                   unionAll(Dataset<T>),unionAll(Dataset<T>),unionByName(Datase
                   sortBy({Columbn|String ..|scala.collection.Seq<String>})
                   sortWithinPartitions({Column..|String ..|scala.collection.Seq<String>})t<T>[,boolean allowMissingCols])
                   orderBy({Column c1..|String c1..|scala.coll.Seq<String>}),

    <U>Dataset<U>  as(Encoder<U>),flatMap({FlatMapFunction<T,U>|scala.Function1<T,scala.collection.TraversableOnce<U>>},Encoder<U>)
                   map({MapFunction<T,U>|scala.Function1<T,U>},Encoder<U>)

    Dataset<Row>   drop({Column cols|String ..colnames|scala.collection.Seq<String>}),
                   describe({String col..|scala.collection.Seq<String>})
                   select({Column col..|String c1,..|scala.collection>Seq<String>|scala.collection.Seq<Column>})
                   selectExpr({String expr..|scala.collection.Seq<String>})
                   withColumn(String col,Column col),withColumnRenamed(String col1,String newCol1)
                   withColumns(),withColumnsRenamed({Map<String,String>|scala.collection.immutable.Map<String,String>})
                   toDF(),toDF({String ..colnames|scala.collection.Seq<String>})
                   join(Dataset<?> df2[,{Column joinExpr|scala.collection.Seq<String>}],..String joinType)
                   crossJoin(Dataset<?>right),cube({Column ..|String .|scala.collection.Seq<String>})


    void           foreach(ForeachFunction<T>|scala.Function1<T,scala.runtime.BoxedUnit>),
                   foreachPartition(ForeachPartitionFunction<T>)
                   ForeachPartitionFunction(scala.Function1<scala.collection.Iterator<T,scala.runtime.BoxedUnit>>)








    
class org.apache.spark.sql.DataFrameWriter<T> : Saves a Dataset to an external storage system 

    //methods
    DataFrameWriter<T> option(String key,{boolean|long|double|String}val),
                       options(Map<String,String>),options(scala.collection.Map<String,String>)
                       format(String src),insertInto(String tblName),
                       partitionBy(String ..colNames),partitionBy()
                       bucketBy(int num,String colName1,..),bucketBy(int n,String col,scala.collection.Seq<String> colNames)
                       sortBy(String colName,..{scala.collection.Seq<String>|..String }colNames)//sort output in each bucket
                       mode(SaveMode mode),mode(String),
    void               save(),save(String path),saveAsTable(String tbl)
                       csv(String path),json(String path),orc(String p)
                       parquet(String p),text(String p),
                       jdbc(String url,String tbl,Properties pr)

 class org.apache.spark.sql.DataFrameWriterV2<T> :Write a dataset to an external storage using the v2 API
    implements CreateTableWriter<T>

    //Methods
    DataFrameWriterV2<T>   option(String k,String v),options(Map<String,String>)
                           options(scala.collection.Map<String,String>),option(scala.collection.Seq<String>)
    CreateTableWriter<T>   partitionedBy(Column col,Column ..cols)
                           partitionedBy(Column c,scala.collection.Seq<Column>)
                           tableProperty(String pr,String val)   
    void                   createOrReplace(),create(),append(),replace(),
                           overwrite(Column condition),overwritePartitions()

 Save operations can optionally take a SaveMode argument specifying how to handle existing data

    SaveMode.ErrorIfExists
    SaveMode.Append
    SaveMode.Overwrite
    SaveMode.Ignore

  class org.apache.spark.sql.DataFrameReader   Loads a Dataset from external storage systems  (file systems, key-value stores etc)
    implements org.apache.spark.internal.Logging 

    //Methods
    DataFrameReader schema(String schema),schema(StructType schema),
                  option(String key ,{boolean|long|double|String} value),format(String src)
                  options(Map<String,String> opts),options(scala.collection.Map<String,String> opts)
    Dataset<Row>  load(),load(String ...paths),load(String path),load(scala.collection.Seq<String> paths)
                  table(String tbl),text(String ...paths),text(scala.collection.Seq<String> paths)
                  parquet(String p1 ,..String paths),parquet(scala.collection.Seq<String> paths)
                  json(String p1,...String paths),json(scala.collection.Seq<String> paths)
                  jdbc(String url,String tbl,[String predicates,]
                  Properties pr),jdbc(String url,)
                  jdbc(String url,String tbl,String colName,long lowBoubnd,long highBound,int numPartitions,Properties pr)
                  csv()
                  orc(String p1,..),orc(scala.collection.Seq<String> paths)
    Dataset<String> textFile(String p1,...),textFile(scala.collection.Seq<String> paths)

