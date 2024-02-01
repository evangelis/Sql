     Structured Streaming 

 Structured Streaming is a scalable and fault-tolerant sreaming engine built on top of the Spark SQL engine 
 Expressing streaming computations is done the same way as expressiong batch computations on static data;the Spark SQL engine takes care of running them incrementally and continuously 
 We can use the DataFrame/Dataset API in Java/Scala/Python/R to express streaming aggregations,stream joins ,event-time windows etc.
Hence,the computations are executed on the same optimized Spark SQL engine which ensures end-to-end exactly once fault tolerance semantics through checkpointing and write-ahead logs 
 Structured Streaming queries are processed by a micro-batch processing engine which processes data streams as a series of small batches ,therefore achieving end-to-end latencies as low as 100 ms and exaclty-once fault-tolerant guarantees
 Continuous Processing is a new super-low latency processing mode ,which cvan achieve end-to-end latencies of 1 millisecond 


 A.Programming Model 
 1.The key idea is treating a live stream as a table that is continuously bering appended.So,every data item that is arriving on the stream is like a row that is appended to the Input Table.
 Every triggerr interval (eq 5 seconds) new rows will be appended to the Input Table 
 2.A query to the Input Table (IT)will generate a Result Table.As new rows are appended to the Input Table, the corresponding Result Table is going to be updated 
 Whenever the Result Table (RT)is updated ,we want to write the changed rows to an external storage sink
 3.The Output is defined as what gets written to the external sink and is described in terms of saveMode :

 	Complete Mode:The entire updated RT is written to the external sink
 	Append Mode:Only the new rows appended in the RT since latest trigger are written to the external storage
 	Update Mode:Only the rows that were updated since the last trigger will be output to the external sink
 4.Event-Time is the time embeded in the data itself,representing the time when the data wasd generating.Operating on the event-time,means that we are intrerested about the time when data was generated in the source rather than when Spark receives them.
 In our model,event-time is a column in every row of the data received.
 this allows window-based aggregations (eg number of events per minute) to be a special type of grouping and aggregation on the event-time column (each time window is a group andeach row can belong to multiple groups)
 5.Handling late data comes naturally in this model:Watermarking allows the user to specify the threshold of late data.Spark is updating the RT having full control over updating old aggregates when there is late data and cleaning up old data to limit the size of intermediate state data 
 Watermarking is rewsponsible for automatically tracking the event-time on the data stream and attempting to cleanup old state
 Watermark on a quuery is set by specifying the event-time column and the threshold of how long late data is expected to arrive 
 6.Fault Tolerance Semantics
 The semantics of streaming systems are captured in terms of how many times each record is processed by the system.

 	At most once :Each rec will either be processed once or 0 times.
 	At least once:Each rec will be processed 1 or more times
 	Exactly once :Each rec will be processed exactly 1 time 
 In any stream processing system there are 3 steps in processing the data:
 	
 	 Receiving the data from sources :Different input sources provide different guarantees
 	 Transforming the data that were received:All received data will be processed exactly once
 	 Pushing out the transformed data to externa systems (to file systems,databases,dashboards etc):Output operations
 	provide at-least-once semantics as they depend on the semantics of the downstream system (transactional or not)
 	and the type of transformations (idempotent or not)


 Under the hood,Spark SQL translates the transformations and actions on dataframes into a series of transformnations and actions on RDDs.In other words, Spark SQL adds a higher level of abstraction while keeping the advantages of using RDDs

 	An RDD  is an immutable, deterministically recomputable ,distributed dataset .Each RDD remembers the lineage of operations performed on a fault-tolerrant dataset
 	If any partition is lost (worker node failure),the partition will be recomputed from the original fault-tolerant dataset using the lineage of operations.
    Assuming all of the RDD transformations being deterministic ,the data of the final transformed RDD will always be the same  irrespective of failures in the spark cluster

 7.State Stores:
  A state store is a versioned key-value store that provides both read and write operations
 There are 2 state store providewr implementations :[HDFS,RocksDB]
 	(i)HDFS state store provider :
 	   It is the default impl/tion in which all the data is stored in memory map in the 1st stage and then backed by files in HDFS -compatible file systems
 	   All updates to the store happed transactionally and each set of updates increments thes store' versionb 
 	(ii)rather than keeping the state in memory 

 8.Triggers :

 9.Metrics:

 B.Input Sources & Output Systems 
 Streaming DataFrames can be created through the DataStreamReader interface returned by :[SparkSession.readStream()]
 

    Source        		Options 
    File source    path,maxFilesPerTrigger,
    			   fileNameOnly,latestFirst
    Socker source  host,port
    Rate source    rowsPerSecond,numPartitions
    			   rampUpTime
    rate-micro-    numPartitions,rowsPerBatch,
      batch	       startTimestamp,
      			   advancedMillisPerBatch
    Kafka source   subscribe,assign,subscribePattern,
    			   kafka.bootstrap.servers
    			   startingTimestamp,startingOffsets
    			   endingTimestamp("1000"),
    			   endingOffsets({"topicA":{"0":23,"1":-1}})
  Notes
 1.Schema Inference:Structured Streaming from file-based sources requires to specify the schema,ensuring a consistent schema to be used
  Partition discovery occurs when sdubdirectories that are named [/key=value/]
 2.Output operations are defined through the DataStreamWriter interface returned by [Dataset.writeStream()] where we specify the following: 
 	Details of the output sink (format,location etc),output mode (append,complete,update),trigger interval and checkpoint location (dir in an HDFS-compatible fault tolerant system)

 	Output Sink         Options        Output Mode      Fault-Tolerant
 	File sink        path,retention     Append            Exactly-once
 	Console sink     numRows,truncate,  All               No
 	Memory sink            --           Append,Complete   No (restarts in complete mode)
 	ForeachBatch sink      --           All               Depends on impl/tion
 	Foreach sink           --           All               At-least-once
 	Kafka sink         kafka.bootstrap. All
 						servers,
 					   topic,includeHeaders               At-least-once 


 C.Operations on Streaming DataFrames
  Starting a streaming query involves the fololowing steps : 
  Create a Streaming DataFrame (DataStreamReader interface),define the operations (transfornmations and actions) for the Spark SQL engine to compute and define the outpout operatrions (DataStreamWriter interface)

  	df.writeStream().format("parquet").option("checkpointLocation","/path/to/dir")
  		.option("path","path/to/dest/dir")
  		.start();
  	aggDF.writeStream().queryName("aggregates")
  		.outputMode("complete").format("memory").start();

 1.Basic Operations :[selection,aggregation,projection]

 	import org.apache.spark.sql.*;
 	import org.apache.spark.sql.expressions.javalang.typed;
 	import org.,apache.spark.sql.catalyst.encoders.ExpressionEncoder;
 	import org.apache.spark.api.java.function.*;
 	import org.apache.spark.sql.streaming.StreamingQuery;
 	import java.util.*;

Create DataFrame representing the stream of input lines from connection to localhost:9999.Then split the lines into words & generate running word counts

 	SparkSession spark = SparkSession.builder().appName("")
 		.getOrCreate();
 	Dataset<Row> linesDf = saprk.readStream().format("socket")
 		.option("host","localhost").option("port",port)
 		.load();
 	Dataset<String> wordsDS=linesDf.as(Encoders.STRING())
 		.flatMap((FlatMapFunction<String,String>)x->Arrays.asList(x.split(" ")).iterator(),Encoders.STRING());
 	Dataset<Row> wordCountsDF =wordsDS.groupBy("value").count();
 	StreamingQuery sq = wordCountsDF.writeStream().format("console")
 		.start();
 	sq.awaitTermination();

  Now,consider an IoT device and a corresponding streaming dataframe with schema :[device:string,type:string,singal:double,time:datetype]

  	public class DeviceData{
  		private String device,deviceType;
  		private Double signal;
  		private java.sql.Date time;
  		/Gettes,setters for each field
  	}
  	Dataset<Row> df = ... //
  	Dataset<DeviceData> ds = df.as(ExpressionEncoder.javaBean(DeviceData.class));
  	//select devices which have signal >10 
  	df.filter(FilterFunction<DeviceData> val->val.getSignal()>10)
  		.map((MapFunction<DeviceData,String>)v->v.getDevice(),Encoders.STRING());
  	//
  	//

 2.Window operations on Event Time

 3.Join Operations  

