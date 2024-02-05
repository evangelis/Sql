            KsqlDB 
 KsqlDB is a database built for stream processing applications on top of Apache Kafka.

  Introduction
Data Lake:
A centralized repository that ingests and stores large volumes of data in its original form
It can accommodate all types of data from any source ,including structured data (db tables,Excel sheets etc),
semi-structured data (webpages,xml files etc)  to unstructured data (audio files,images,tweets etc).
It captures both relational and non-relational data from a variety of sources
(IoT devices,business apps,streaming ,mobile devices,audio & video files from streaming apps,social media etc)
Huge amounts of data are produced at an organization and stored at data lakes ,without the need to structure them
beforehand.
Data Lake architecture prioritizes storage volume and cost over performance.
It uses ETL tools
Data Warehouse:
It stores data in a structured format,a relational database that stores data from transactional systems.
It includes various sources, but requires designing the schema before storing the data.This preprocessing take the
form of ETL to clean,filter and structure data beforehand.
It offers fast query performance.

ELT & ETL
# ETL :Extract ,Transform and Load is a mechanism by which :
    Data is extracted from a source system, it is then transformed on a seperate server,
    and then is loaded into a destination system.
    It is a time-intensivce process as data is transformed before loading into a destination
    system.
    1.It is ideal for small data sets with complicated transformation requirements.
    2.The data outpout is typically structured as ETL does not offer ETL compatibility.
    3.Data is transformed before entering the destination system,thus raw data cannot
      be re-queried.
# ELT: Extract,Load and Transform is a newer mechanism by which :
    Data is extracted from a source system then loaded into a destination system and 
    transformed inside the destination system.
    1.Raw data is loaded directly into the destination system and transformed in parallel,
      (simulataneous load & transform inside the destination system) thus being faster than ELT.
    2.Raw data is loaded directly into the destination system and ,therefore can be re-queried
      endlessly.
    3.Ideal for large datasets that require speed  & efficiency.The data output can be structured,
      semi-structured or even usntructrured and offers data lake compatibility.

 A.Terminology
 Kafka is a distributed streaming platform for working with events.It is horizontally scalable, fault-tolerant and
extremely fast.KsqlDB is built on top of Kafka and borrows heavily from kafka's abstractions.
 Event: Isd anything that occured and was recorded,like the sale of an item,or the submission of an invoice,or even 
a log line emitted by a web server when receiving a request. An event is the core unit of data for KsqlDB and is 
 1.An event is represented by using a simple key/value model,similar to Kafka's notion of record.
   The key represents some form of identity for the event while the value holds information about the event including
 the time the event occurred.
 2.An event is called a row composed of a series of columns as if it where a row in a relational database.
 3.There are some pseudo-columns available: 
   ROWTIME: Represents the time of the event.
   ROWPARTITION:Represents the partition of the record
   ROWOFFSET: Represents the offset of the original event.
   WINDOWSTART:The time a window operation starts
   WINDOWEND:The time when a window operation ends
 4.Kafka Headers are a list of  key-value pairs where the keys are strings and the values are byte arrays.
   Headers contain metadata about the event, which can be used for routing or processing.

 Stream is a partitioned,immutable ,append-only collection that represents a series of historical facts.Once a row is
inserted in the stream it can never change,as existing rows can not be updated or deleted.Rows are inserted in specific
partitions;each row has a key that represents its identity ,all rows with the same key reside in the same partition.
 Table is a mutable collection that models change over time.it represents what is "true" as of now, contrary to the 
stream which represents historical sequence of events.
Tables work by leveraging the keys of an event.
 1.If there is a sequence of rows (events,messages,records) sharing the same key then the last row for the given key
   represents the most up-to-date info about that key.
 2.A background process periodically runs and deletes the oldest rows for each key.

  Stream-Table duality: 
 A stream is a sequence of events that you can derive a table from.
 A table represents current state of events which is tha application of a sequence of changes that occurred. 
 Traditional DBs have redo logs which have short retention compared to Kafka's changelog topic.Moreover,applying the 
redo logs is cumbersome.
 1.KsqlDB leverages the stream-table duality by storing the 2 components of a table:
  (i) The current state of a table is stored locally and ephemerally using RocksDB
  (ii)The series of changes that are applied to a table are stored in a Kafka changelog topic
 Stream Processing: 
  A critical part of stream apps is filtering,transforming,joining,aggregating and manipulating events.Unlike Kafka 
where you declare collections and can work only with the events in their current form,in KsqlDB you derive new 
collections from existing ones by using the SELECT statement.
  Manipulating events in KsqlDB is done by deriving new collections from existing ones and describing the changes 
between them.
 1.We need not declare the schema when deriving a collection as KsqlDB infers column names and their types from 
the inner SELECT statement.The values of the pseudo-columns ROWTIME,ROWPARTITION,ROWOFFSET define the time timestamp 
the partition and the offset of the record written to kafka respectively.
 
 Queries:[persistent,push,pull]
 1.Persistent queries: Server side queries that run indefinitely processing rows of events.
   Issues persistent queries by deriving a new collection (stream,table) from existing ones.
 2.Pull queries:Are client side queries retrieving a result as of now like queries againnst traditional RDBMs 
   They return immediately a result and close the connection.
   Pull queries are expressed using a strict subset of ANSI SQL 
 3.Push queries: Are issued by clients that subscribe to a result as it changes over time.
   Are useful for asynchronous control flow.
   They are expressed using an SQL-like language and support a full set of SQL ,like filters,selects,partitioning 
   and joins.
   A push query emits refinements to a stream or a materialized table with a subscription to the results.
   To persist results of push queries use :CREATE {TABLE|STREAM} ...AS SELECT
 
 Materialized views: They evaluate a query on the changes only (delta) instead of evaluating queries over the entire
table
 1.Non-Materialized table is a table that is created on top of a kafka topic and cannot be queried.
 2.Materialized table is a table that is derived from an existing collection.KsqlDB materializes its results and
we can make queries against it.Recall that ,the current state of a table is stored locally on a node using RocksDB 
while the series of changes made area stored to a kafka changelog topic and replicated across Kafka brokers.

 Time semantics: [message.timestamp.type ={CreateTime,LogAppendTime}]
  Event-time is the time when an event,a record, is created by the data source.
Achieving event-time semantics requires embedding timestamps in records when events occur (when they are produced)
  Ingestion-time:The time when a record is stored in a topic partition by a Kafka broker.Ingestion time is related 
to embedding timestamps in the record when a Kafka Broker appends the record to a particular topic partition.
  Processing-time:is when the record is consumed by a stream processing app.This might occur milliseconds after 
ingestion-time  or seconds,minutes and even days after.
  Stream-time :is the maximum timestamp seen over all processed records so far.
 1.Timestamp assignment:An event's timestamp is either set by the record's producer or by the kafka broker,depending
on the topic's timestamp configuration. 
  CreateTime:The broker uses the record's timestamp as set by the producer,enforcing event-time semantics
  LogAppendTime:The broker overwrites the record's timestamp (as set by the producer) with the broker's local time 
    when it appends the record to the partition topic,enforcing ingestion-time semantics.
 
 B. Time & Windows
 A record is an  immutable representation of an event in time.Each record carries its own timestamp.

 A window has a start and end time which we can access through the pseudo-columns ,WINDOWSTART and WINDOWEND 
respectively
 A GROUP BY clause ,groups all records having the same key is a prerequisite for windowing operations.Aggregate 
functions will be applied to the specified records which occur within a specific time window
 3.Window Types:
  Tumbling Window :Time based, fixed duration non-overlapping windows;they are defined by:window's duration 
  Hopping Window:Time based ,fixed duration,possibly overlapping windows.They are defined by :[window's duration,advance interval]
                 The advance interval,hop, specifies how far a window moves forward in time relative to the previous window.
                 Records may belong to multiple windows.
  Sliding Window:Dynamically sized,non overlapping data driven windows.They aggregate records into a session.
                 A session represents a period of activity separated by a period of inactivity 
  Session Window:

 C.Joins
 Merging streams or tables of events is accomplished by using the JOIN statement, the result of which is a new stream 
or table that is populated with the values specified in the SELECT clause.
 We are allowed to join multiple streams or tables creating new collections  (Stream-Table join produces a new stream).
 Tables are always partitioned by the [PRIMARY KEY],while repartitioning the tables is not allowed.
 Streams don't have primary keys,they only have an optional KEY column,which defines the partitioning column 
 1.Join Requirements :Co-partitioning the data from both sides of the join
 Co-partitioning means that records having the same key on both sides of the join will be sent to the same stream task
during processing
 KsqlDB needs to compare records based on the joining column.The following requirements must be met:
 (i)The input records for the join must have the same number of partitions on both sides of the join.
    Use the [DESCRIBE <source> EXTENDED]
 (ii)Records must have the same key schema ,ie the same sql type.If they don't much,it might be possible to cast one 
     side to match the other.
 (iii)Records must have the same partitioning strategy on both sides of the join.
      If we are using the default partitioning settings while the producers don't specify an explicit partitioning
      scheme,then everything works ok.
     To repartition a collection, use the [PARTITION BY ] clause which moves the columns into the key.We need the 
     AS_VALUE() to keep them in the value too.
     
     CREATE {STREAM|TABLE| coll_rekeyed WITH (PARTITIONS= num) AS SELECT col1[,..]
      FROM existing_collection PARTITION BY col3;
   


 D.Data Types,Operators & Functions
    
     Data Types  (Java backing type)
     Numerical Types:  INT (Integer),BIGINT (Long),
                       DOUBLE (Double), DECIMAL (java.math.BigDecimal)
     String Types:     VARCHAR (String), STRING (String),
                       BYTES (byte[])
     Boolean Types:    BOOLEAN (Boolean)
     Date& Time Types: DATE (jva.sql.Date),TIME (jva.sql.Time),
                       TIMESTAMP (java.sql.Timestamp)
     Compound Types:   ARRAY<elementType> (),MAP<keyType,valueType>
                       STRUCT<fieldName fieldType,...> 
     Custom Types:     CREATE TYPE 

    /*** Operators *******/
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

 E.Serialization [KEY_FORMAT,VALUE_FORMAT,FORMAT]
 Serialization format refers to the manner in which a record's raw byutes are translated into and from structures that KsqlDB can understand at runtime.
The serialization format is specifed in the WITH clause where you can customize the formats for both the keys and values.
The available serialization formats are: [NONE,AVRO,DELIMITED,JSON,JSON_SR, PROTOBUF,PROTOBUF_NOSR,KAFKA]

                                             Requires        Multi-Column
          value fmt key fmt schema inference shema registry  Keys
NONE      No       Yes        No               No
DELIMITED Yes      Yes        No               No
JSON      Yes      Yes        No               No
AVRO      Yes      Yes        Yes              Yes
JSON_SR   Yes      Yes        Yes              Yes 
KAFKA     Yes      Yes        No               No
PROTOBUF

All serialization formats can be used for value_format except NONE
 1.Schema registry Integration:
 Integrating with Confluent Schema registry is available for [Avro,JSON_SR.Protobuf] formats .
 KsqlDB will automatically infer the schema, retrieving read and registering writes sparing us 
from manually defining columns and their data types in CREATE statements.
 # To use the schema inference we need to make sure that Schema Registry is up and running.Then
    Declare streams & tables on kafka topics for these formats by using CREATE STREAM|TABLE ...
    without needing to declare the key and value columns.
    Declare derived views using CREATE STREAM|TABLE AS SELECT ...
    Convert data to diff formats :CREATE STREAM|TABLE WITH(...) AS SELECT...
    
 Partial Schema Inference:Explicitly providing the columns and their data types for the format that does not support schema inference from Schema Registry.For example,inferring values for a keyless stream we can set key_format=NONE
  # Create a stream from a topic that has Avro values and a KAFKA-formatted INT message key
    CREATE STREAM pageviews (pageId INT KEY)
      WITH(KAFKA_TOPIC='pageviews-avro-topic',VALUE_FORMAT='AVRO',KEY_FORMAT='KAFKA');
 2.Schema Inference with ID :Specifying a KEY_SCHEMA_ID, or VALUE_SCHEMA_ID in the CREATE TABLE|STREAM statements KsqlDB retrieves and registers the schema specified by the ID from the Schema Registry.

    Declare streams and tables or materialized views specifying a KEY_SCHEMA_ID or  VALUE_SCHEMA_ID 
    --Partial Schema Inference
    CREATE TABLE pageviews( pageId INT PRIMARY KEY) WITH(
      KAFKA_TOPIC='pageviews-avro-topic',KEY_FORMAT='KAFKA',VALUE_FORMAT='AVRO',
      VALUE_SCHEMA_ID=1);
  3.The data is serialized by the specified physical schema (stored in Schema Registry)and is consumed by downstream systems.Note that the schema in the KsqlDB is the logical schema

   
 F. Connectors
 kafka Connect is an component of Apache Kafka that simplifies loading data to kafka & exporting data to external
storage systems.
 There are 2 ways to deploy KsqlDB_Connect integration :
 1.External : Set the [ksql.connect.url ] property (defaults to http://localhost:8083)
 2.Embedded:
 
  G.Processing Guarantees [processing.guarantee= "at_least_once"|"exactly_once_v2"]
  ksqlDB supports at-least-once and exactly-once processing guarantees.
 # At-least-once semantics: Records are never lost but they might be re-delivered and re-processed.
 # Exactly-once semantics:Records are read,processed and written exacly 1 time.
  All the processing is done once,including the materialized state created by the processing job that is written back to Kafka.

    SET 'processing.guarantee'='exactly_once_v2';


 
  H. Apache Kafka Terminology
 Records:The primary unit of data in Kafka , aka events (in KsqlDB),models that something has happened it the world.
A record carries info and is composed of the following: [key,value,timestamp,topic,partition,offset,headers]
 Key of a record is an arbitrary piece of info that is used to identify the record.
 Value of a record holds the data of interest for each record.
 Timestamp denotes the time the record occurred and can mean different things based on the employed time semantics.
 

 Appendix

  A .Capacity Guidelines
 How many ksqlDB server nodes do we need? Or do we  need to provision additional Kafka brokers to support ksqlDB?
 What kind of deployment mode makes sense ?

 # CPU:[At least 4 cores]:KsqlDB consumes CPU to serialize/deserialize messages into the streams/table schemas and then process each message as required.
 # Disk:[100 GB SSD] KsqlDB uses disk to persist temporary state for aggrefgations and joins
 # Memory:[16 GB RAM]: 
 # Network:[1 gbit NIC] KsqlDB relies on Kafka ,thus fast networking is important for optimal throughput.


  B. Generated Topics [Output,repartition,changelog] topics
 KsqlDB creates the following types of topics on a Kafka cluster:

# Output Topics: CREATE {STREAM|TABLE} AS SELECT queries write their results to an output topic which has the following properties:
   Name: Same as the stream or table name created by the statement (use kafka_topic to provide a custom name)
   Partitions:Same number as the input topic, (use PARTITIONS properrty)
   Replication Factor:Default RF=1,specify a custom factor using the REPLICAS property.

# Repartition Topics:Are intermediate topics that are named with "repartition" suffix,having the same number of REPLICAS nad PARTITIONS as the input stream
 
 # Changelog Topics: