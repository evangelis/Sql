 			A guide to Spark SQL :Dataset API

1.Entry Point
 Every Spark app consists of a driver program that runs the user's main() function and executes various computations in parallel on a cluster of nodes.
 The entry point of all functionality is the SparkSession class;using a SparkSession object we can create DataFrames from Hive tables,existing RDDs ,and spark data sources

2.Untyped Dataset Operations : Operations on DataFrames are refered to as untyped operations .DataFrames are Dataset<Row> or DataSet[Row] in Java and Scala respectively as opposed to strongly typed operations performed on Datasets 

    import org.apache.spark.sql.*;//Row,Dataset,SparkSession,Encoder,Encoders
    import org.apache.spark.api.java.JavaRDD;
    import org.apache.spark.api.java.function.*;//MapFunction,Function
    import org.apache.spark.sql.types.*;//StrcutField,StructType,DataTypes
    import java.util.*;//ArrayList,List
    import java.io.Serikalizable;

 	SparkSession spark = SparkSession.builder()
 		.appName("Java Saprk SQL example")
 		//.config("spark.some.config","value")
 		.getOrCreate();
 	DataSet<Row> df = spark.read().json("people.json");
 	df.show(); //columns [age(int),name (string)]
 	//Untyped operations
 	df.printSchema(); 
 	df.select("name").show();df.select(col("name")).show();
 	df.filter();
 	df.groupBy("age").gt(21).count();

3.Run SQL queries programmatically : The sql() function on  AparkSession object enables apps to run SQL queries programmatically.
 Temporary views are session-scoped and disappear when the session that created them terminates. 
 Globbal temporary views are temporary viewsa that are shared among sessions 

 	df.createOrReplaceTempView("people");
 	sqlDF = spark.sql("SELECT * FROM people");
 	sqlDF.show();
 	df.createGlobaltempView("peple");
 	spark.sql("SELECT * FROM global_temp>.people").show();
 	spark.newSession().sql("SELECT * FROM globasl_temp.people");

4.Datasets: 

  	public class Person implements Serializable {
  	private String name;
  	private long age;
  	public String getName() {return name;}
	public void setName(String name) {this.name = name;}
 	public long getAge() {return age;}
	public void setAge(long age) {this.age = age;}
	}
	//Create an instance of a Bean class
	Person person = new Person();
	person.setName("Andy");person.setAge(32);
	//Encoders are created for Java beans 
	Encoder<Person> persEncoder = Encoders.bean(Person.class);
	Dataset<Person> ds  = spark.createDataset(Collections.singletonList(person),persEncoder);
	ds.show();
	//Convert a DataFrame to a Dataset 
	Dataset<Person> pds = spark.read().json("people.json").as(persEncoder);
	Encoder<Long> longEnc = Encoders.LONG();
	Dataset<Long> lds = spark.createDataset(Arrays.asList(1L,2L,3L),longEnc);
	Dataset<Long> transformedlds = lds.map((MapFunction<Long,Long> val->val+1L),longEnc);
	transformedlds.collect(); //[2,3,4]

5.Interoperating with RDDs
 There are 2 methods available for converting existing RDDs into datasets :
 Using reflection to infer the schema of an RDD (offers concise code ),or programmatically constructing the schema and apply it to an existing RDD .The second approach is more verbose but allows us to construct Datasets when the columns anbd their types are not known until runtime

 	//Inferring the schema using reflection :Create a JavaRDD<Person> 
 	JavaRDD<Person> personsRdd = spark.read().textFile("people.txt")
 		javaRDD().map(line->{
 			String[] parts = line.split(",");
 			Person per = new Person();
 			per.setName(parts[0]);
 			per.setAge(parts[1]);
 			return per;
 			});
 	Dataset<Row> peopleDF = spark.createDataFrame(personsRdd,Person.class);
 	peopleDF.createOrReplaceTempView("people1");
 	DataSet<Row> teenNamesDF = spark.sql("SELECT name FROM people1 WHERE age BETWEEN 13 AND 19");
 	Encoder<String> strEnc = Encoders.STRING();
 	Dataset<String> teenNamesByIndex = teenNamesDF.map(
 		(MapFunction<Row,String>)row->"Name :"+row.getString(0),strEnc);
 	teenNamesByIndex.show();
 	Dataset<String> teenNamesByField = teenNamesDF.map(
 		(MapFunction<Row,String>) row->"Name:"+ row.<String>getAs("name"),strEnc);
 	teenNamesByIndex.show();teenNamesByField.show();



 Programmatically specifying the schema: 
   1.Create a JavaRDD<String> from the original RDD
   2.Create the schema using the StructType to match the Rows in the RDD
   3.Apply the schema of the RDD of Rows 
 	
    JavaRDD<String> peopleRdd = spark.sparkContext().textFile("people.txt",1)
    	.toJavaRDD();
    String schemaStr  = "name age";
    List<StrcutField> fieldsLst = new ArrayList<>();
    for(String fname :schemaStr.split(" ")){
    	StructFiled field = DataTypes.createStructField(fname,DataTypes.StriongType,True);
    	fieldslst.add(field);
    }
    StructType schema = DataTypes.createStructType(fieldslst);
    //Apply tyhe schema to the dataframe 
    Dataset<Row> peopleDF = spark.createDataFrame(,schema);
    peopleDF.createOrReplaceTempView("people2");
    Dataset<Row> namesDF = spark.sql("SELECT name FROM people2");
    Dataset<String> namesDS =namesDF.map((MapFunction<Row,String) row:);
    namesDS.show();


6.Functions :Scalar,Aggregate,User Defined
 A.Scalar User-Defined Functions :are user -programmalbe routines that act on one row
 Properties : [asNonNullable(),asNonDeterministic(),withName(name:String)]

    import org.apache.spark.sql.*;
    imprt org.apache.spark.sql.types.DataTypes;
    import org.apache.spark.sql.api.java.UDF1;
    import org.apache.spark.sql.expessions.UserDefinedFunction;

    SparkSession spark = SparkSession.builder().appName("")
    	.getOrCreat();
    //Define & register a zero-argument udf of type double (non-deterministic)
    UserDefinedFunction randomUdf = udf(()->Math.random(),DataTypes.DoubleType);
    randomUdf.asNonDeterministic();
    spark.udf().register("random",randomUdf);
    spark.sql("SELECT random()").show();

    //Define & register a one-argument udf
    spark.udf().register("plusOne",
    	(UDF1<Integer,Integer>));
    spark.sql("SELECT plusOne(5)").show();

    //Define & register a 2-arg udf :strLenUdf
    UserDefinedFunction strLenUdf = udf()
    spark.udf().register("strLen",strLenUdf);
    spark.sql("SELECT strLen('test',1)").show();

 B.User Defined Aggregate Functions (UDAFs)
Are user-programmable routines that act on multiple rows at once and return  a single aggregated value as a result 
Base class for UDAF is [org.apache.spark.sql.expressions.Aggregator] abstract class


	Aggregator[IN,BUF,OUT]
  IN:The input for the aggregation
  BUF:The type of teh intermediate value of the reduction
  OUT:The type of the final output result
  buferEncoder:Encoder[BUF] ,the encoder for the intermediate type 
  outputEncoder:Encoder[OUT],the encoder for the output type
  zero:BUF ,the initial value of the intermediate result for the aggregation
  reduce(b:BUF,a:IN):BUF ,aggregates input value a into current intermediate value
  merge(b1:BUF,b2:BUF):BUF ,merges 2 intermediate values
  finish(b:BUF):OUT ,transforms the output of teh reduction operation
  toColumn():TypedColumn<IN,OUT> ,returns this Aggregator as a  TypedColumn to be used in a Dataset


    import java.io.Serializable;
    import org.apache.spark.sql.*;
	import org.apache.spark.sql.expressions.Aggregator;
	import org.apache.spark.sql.functions;

 (i)Untyped UDAF example

    public class UdafUntyped
		public static class Average implements Serializable {
			private long sum,count;
			public Average(){}
			public Average(long s,long c){
				this.sum=s;this.long= l;
			}
			//Getters & Setters ...
		}
		public static class MyAverage extends Aggregator<Long,Average,Double>{
			@Override public Average zero(){return new Average(0L,0L);}
		
			public Encoder<Average> bufferEncoder(){
				return Encoders.bean(Average.class);
			}
			public Encoder<Double> outputEncoder(){
				return Encoders.DOUBLE();
			}
			@Override public Average merge(Average a1,Average a2){
				long msum = a1.getSum()+a2.getSum();
				long mcnt = a1.getCount()+a2.getCount();
				a1.setSum(msum);a1.setCount(mcnt);
				return a1;
			}
			@Override public Average reduce(Average buf,Long data){
				long newCount = buf.getCount() + 1;
				long newSum = buf.getSum() + data;
				buf.setSum(newSum);buf.setCount(newCount);
				return buf;
			}	
			@override public Double finish(Average reduction){
				return ((double)reduction.getSum())/reduction.getCount();
			}
		}
		public static void main(String[] args){
			SparkSession spark = SparkSession.builder().appName("")
				.getOrCreate();
			spark.udf().register("myAverage",);
			Dataset<Row> df = spark.read().json("employees.json");
			df.show();
			df.createOrReplaceTempView("employees");
			Dataset<Row> resultDF = spark.sql("SELECT myAverage(salary) FROM employees");
			resultDF.show();
			spark.stop();
		}

	}

 (ii)Typed UDAF 

    public class TypedUDAF {
    	public static class Employee implements Serializable{
    		private String name;
    		private long salary; 
    		//Constructors,getters,setters ...
    	}
    	public static class Average implements Serializable {
    		private long sum,count;
    		//Constructors,getters ,setters
    	}
    	public static class MyAverage extends Aggregator<Employee,Average,Double>{
    		@Override public MyAverage zero(){return new MyAverage(0L,0L);}
    	
    		@Override public MyAverage reduce(MyAverage buf,Employee emp){
    			long newCnt  = buf.getCount() + 1;
    			long newSum= buf.getSum() + emp.getSalary();
    			buf.setSum(newSum);buf.setCount(newCnt);
    			return buf;
    		}
    		@Override public MyAverage merge(MyAverage a1,MyAverage a2){
    			long sum = a1.getSum() +a2.getSum();
    			long count = a1.getCount()+ a2.getCount();
    			a1.setSum(sum);a1.setCount(count);
    			return a1;
    		}
    		@Override public double finish(MyAverage reduction){
    			return ((double)reduction.getSum())/getCount();
    		}
    		@Override public Encoder<MyAverage> bufferEncoder(){
    			return Encoders.bean(MyAverage.class);
    		}
    		@Override public Encoder<Double> outputEncoder(){
    			return Encoders.DOUBLE();
    		}
    	}
    	public static void main(String[] args){
			SparkSession spark = SparkSession.builder().appName("")
				.getOrCreate();
			Encoder<Employee> empEncoder = Encoders.bean(Employee.class);
			Dataset<Employee> ds = spark.read().json("employees.json").as(empEncoder);
			MyAverage myavg = new MyAverage();
			TypedColumn<Enmployee,Double> avgSalary = ;
			Dataset<Double> resDF = ds.select(avgSalary);
			resDF.show();
			spark.stop();
		}
    }

 7. Data Sources
 Spark SQL supports operating on a variety of sources through the DataFrame interface.
  A.Generic Load and Save functions
 For file-based data sources it is possible to bucket & sort or partition the output.However, bucketing and sorting is applicable only to persistent tables 
It is possible to use both partitioning and bucketing for a single table.Using saveAsTable(String) saves the dataframes
as persistent tables to Hive metastore
An existing Hive metastore is not necessary, as Spark will create a Derby metastore for us automatically.

        peopleDF.write().bucketBy(42,"name").sortBy("age")
    	    .saveAsTable("peopole_bucketed");
        usersDF.write().partirtionBy("favorite_color").bucketBy(42,"name")
            .saveAsTable("namesPartByColor.parquet");
        usersDF.write().partitionBy("favorite_color").format("parquet")
            .save("namesPartByColor.parquet");

 File-based forces include :[parquet,avro,csv,json,text,orc,protobuf]
 Parquet,Avro,Protobuf Buffers and Thrift support schema evolution 
 Table partitioning is a common optimization technique used in systems like Hive.
 In partitioned tables,data are stored in diff directories with partitioning columns encoded in
 the path of each parrtitioned directory

 All built-in file sources (including Text/CSV/JSON/ORC/Parquet) are able to discover and infer partitioning information
 (i) Apache Avro data source :useful for streaming data sources or sinks ,like Apache Kafka.
  Each Kafka record will be augmented by some metadata ,such as the ingestion timestamp into kafka,the offset etc. 
It provides data serialization and exchange services for Apache Hadoop and Apache Kafka.
It suitable for use in distributed systems,it suppoprts schema evolution and is language independent. 

    Avro Type  Spark SQL Type  Avro Conversion    Options
    boolean     BooleanType                       avroSchema[None
    int         IntegerType                       compression [snappy]
    long        LongType                          mode[FAILFAST,PERSMISSIVE]
    float       FloatType
    double      DoubleType
    string      StringType
    enum        StringType
    fixed       BinaryType
    bytes       BinaryType
    record      StructType
    array       ArrayType
    map         MapType
    union         --
               ByteType    ->int
               ShortType   ->int
               DecimalType ->fixed
               BinaryType  ->bytes
               DateType    ->int
              TimestampType->long
    to_avro(): encode a column as binbary in Avro format
    from_avro(): Decode Avro binary data into a column
 An Avro schema is created using JSON format 

    String jsonSchema = new String(Files.readAllBytes(paths.get(
        "./examples/src/main/resources/user.avsc"));
    Dataset<Row> df = spark.readStream().format("kafka")
        .option("kafka.bootstrap.servers","h1:p1,h2:p2").option("subscribe","topic1")
        .load();
    //Decode the Avro data into a struct->filter by column favorite_column
    //encode column 'name' in Avro format
    Dataset<Row> outputDF = df.select(from_avro("value"),
        .where("user.favorite_color==\
        .select(to_avro(col("user.name")).as("value");
    StreamingQuery query = outputDF.writeStream().format("kafka")
        .option("kafka.bootstrap.servers","h1:p1,h2:p2").option("topic","topic2")
        .start();
(ii)Parquet data source
 It is a columnar data format which automatically preserve the schema of the original data.


    
 The spark-submit script does not include the spark-avro module ,which is external .Adding dependenies to spark-submit is done as follows:

 	./bin/spark-submit --packages org.apache.spark:spark-avro:2_12:3.5.0  \
 		--class <mainClass> --master <masterUrl> --deploy-mode <mode> \
 			[--conf <key>=<value>..] /path/to/app.jar [app_arguments]
 	./bin/saprk-shell --packages org.apache.spark:spark-avro:2_12:3.5.0 ...

implementation 'org.apache.spark:spark-core_2.13:3.5.0'


5.Cluster Mode Overview
 Terminology

 	Application: User defined prog built on Spark and consisting of a driver progra and executors on the cluster
 	Driver program:The process running the main() of the app and creating the SparkContext
 	Cluster manager:External service acquires resources on the cluster
 	Worker node:Any node that can run app code in the cluster
 	Executor:A process launched for an app on a workder node, responsible for running tasks and 
 			keeping data in memory or disk.Each app has its own executors
 	Task : A unit of work to be send to one executor
 	Job:A parallel computation,cosnisting of multiple tasks
 	Stage:Each job gets divided into smaller sets of tasks that depend on each other
 	Deploy mode:Distinguishes where the driver process is located.
 	Cluster manager types : Standalone ,Hadoop YARN ,Kubernetes,Apache Mesos
 	Application jar : A JAR containing the user spark app .We may need to create an Uber JAR conating the spark app and all its dependencies



 Spark apps run as independent sets of processes on a cluster ,coordinated by the SparkContext object in the main,driver program
To run on  a cluster SparkContext can connect to several types of cluster managers ,which allocate resources across apps
Once connected to the cluster manager, spark acquires executors (processes that run computations and store data ) on nodes 
Then, spark sends the application code ,defined by JAR files or Python files (passed to SparkContext) to the executors
Finally, SparkContext sends tasks to executors to run
 Spark is agnostic to the undrlying cluster manager,as long as it can acquire executor processes and these communicate with each other
 Each app gets its own executors ,which stay up for the duration of  the app and run tasks in multiple threads.Thus,apps are isolated from each other  on both the executor side (tasks from diff apps run on diff JVMs)and the scheduling side (each driver schedules its own tasks)
 The driver program schedules tasks on the cluster and must listen for and accept incoming connections from its executors throughout its lifetime.Moreover,it should be run close to worker nodes,preferably on local area network

6.Submit Apps [spark-submit] script

	./bin/spark-submit --class <mainClass> \
	 --master <masterUrl> --deploy-mode <mode> \
	 --conf <key>=<val> \
	 #... other options
	 <application_jar> [app_arguments]

 Master URLs

 	local,local[k]:Run spark locally with 1,or k worker threads
 	local[*]:Run spark locally with as many worker threads as the logical cores of the machine
 	local[K,F]:Runs locally with k worker threads and F maxFailures
 	local[*,F]
 	local -cluster[N,C,M]:Local cluster mode for unit tests
 		 N: num of workers ,C:cores per worker ,M: MB of memory per worker
 	spark://HOST:PORT :Connect to the given spark standalone cluster
 					   Default port is 7077
 	spark://H1:P1,H2:P2 :Connect to the given spark standalone cluster with standby masters with zookeeper
 	yarn :Connect to a YARN cluster.The location is found in :HADDOP_CONF_DIR or YARN_CONF_DIR
 	k8s://HOST:PORT : Connect to a Kubernetes cluster
 	mesosL//HOST:PORT : Connect to a Mesos cluster ,default port :5050


Examples 
	
# Run on a YARN cluster in cluster deploy mode
	export HADOO_CONF_DIR =xxx
	./bin/spark-submit --class org.apache.spark.examples.SparkPi \
		--master yarn --deploy-mode cluster \
		--executor-memory 20G --num-executors 50 \
		/path/to/examples.jar 1000
# Run on a Spark standalone cluster in cluster deploy mode with supervise
	./bin/spark-submit --class org.apache.spark.examples.SparkPi \
		--master spark://207.184.161.138:7077 
		--deploy-mode cluster --supervise \
		--executor-memory 20G --total-executor-cores 100 \
		/path/to/examples.jar 1000
## Run a Python application on a Spark standalone cluster
	./bin/spark-submit --master spark://207.184.161.138:7077 \
		/examples/src/main/python/pi.py 1000



Appendix :RDD Programming
A.Abstractions
1.RDD:Is an abstraction,a collection of elements partitioned across the nodes of the cluster that can be operated on in parallel.
An RDD is created by starting with a file in the Hadopp (-supported)file system or an existing Scala collection in the driver program
2.Shared variables :

B.Operations on RDDs
 Transformations create a new dataset from an existing one and are lazy as they do not compute resulsts right away;they are only computed when an action requires a result to be returned to the driver program
 Actions:Return a value to the driver program after running computations on the dataset
 Transformed RDDs may be recomputed each time we run an action on them.Howver,we may opt to persist the RDD in memory :[cache(),persist(StorageLevel.MEMORY_ONLY)]
 RDD of key-value pairs are represented by the JavaPairRDD class .There are some special operations available only on key-value rdds ,mainly the "distributed shuffle operations",such as grouping,reducing or aggregating the elements by key. 
 Package :org.apache.spark.api.java
  In the package org.apache.spark.api.java.function there are various functional interfaces available 
    
    interface Function0<R> 
    	R call()
    interface Function1<T,R>
    	R call(T t1)
  	interface Function2<T1,T2,R> 
  		R call(T1 v1,T2 v2) ...
  	...
  	interface Function4<T1,T2,T3,T4,R>
  		call(T1 v1,T2 v2,T v3,T4 v4)

    interface MapFunction<T,U>
    	U call(T val)
    interface FlatMapFunction<T,R> 
    	java.util.Iterator<R> call(T v)
    interface FlatMapFunction2<>
    interface ReduceFunction
    interface FilterFunction<T> 
    interface ForeachFunction<T>
    	void call(T t)
    interface ForeachPartitionFunction<T>
    	coid call(java.util.Iterator<T> )
    interface VoidFunction<T>
    interface VoidFunction2<T1,T2,R>
    interface DoubleFunction<T>
    interface DoubleMapFunction
 
 Transformations include the following functions:
   filter(func),map(func),flatMap(func),distinct([np]),mapPartitions(func),mapPartitionsWithIndex(func)
   join(rdd2[,np]),intersection(rdd2),union(rdd2),cogroup(rdd2[,np]),cartesian(rdd2),pipe(cmd [env_params])
   sample(withRepl,fract,[seed]),coalesce(int np),repartition(int np),repartitionAndSortWithinPartitions(partitioner)
   sortByKey([ascending] [np]),groupByKey([np]),reduceByKey(func [,np]),aggregateByKey((zeroVal,seqOp,combOp)[,np])

Actions include the following functions: 
   first(),take(n),collect(),takeSample(withRepl,num [,seed]),takeOrdered(n [,ordering]),count()
   countByKey(),reduce(func),
   saveAsTextFile(apth),saveAsObjectFile(path]),saveAsSequenceFile(path)
    Transformation Function
    filter(func)
    

 1.Transformations 

 	JavaRDD<T>     distinct([int numParts]),filter(Function<T,Boolean> f),
 	               union(JavaRDD<T> rdd2),intersection(JavaRDD<T> rdd2),cartesian(JavaRDD<T> rdd2)
 	               coalesce(int np,boolean shuffle),reaprtition(int np)
 	               cache(),persist(StorageLevel l),unpersist() 
 	               sample(boolean withRepl,double fraction,..long seed),subtract(JavaRDD<T> rdd2,[int np]),setName(String n)
    JavaRDD<T>[]   randomSplit(double[] weights,..long seed)
 	               sortBy(Function<T,S> )
 	<U> JavaRDD<U> map(Function<T<U>f),mapPartitions(FlatMapFunction<Iterator<T>,U>), mapPartitionsWithIndex()
 	JavaRDD<String>  pipe(String cmd),pipe(List<String> cmds,..Map<String,String> env,boolean separateWorkingDir, int bufferSize)


 2.Actions

    void saveAsTextFile(String path,..Class<? extends org.apache.hadoop.io.compress.CompressionCodec> cd)
         saveAsObjectFile(String path),saveAsSequenceFile(String)
    T    first(),max(Comparator<T> cmp),min(Comparator<T> )
    List<T> collect(),take(int num),takeSample(boolean withRepl,inbt num ,..long seed),takeOrdered(int num,Comparator<T> cmp), top(int n ,..Comparator<T>)
    long count(), countApproxDistinct()


