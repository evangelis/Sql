A. MySQL Architecture
![img.png](img.png)
MySQL follows the client-server architecture which divides the system into 2 components:[Client,Server]
(i)Client
 The client is tha app that interacts with the MySQL db server
 The client sends SQL queries to the MySQL Server for processing
 It can be a standalone app, a web app or any program that needs a database
 MySQL Client tools:[Workbench (GUI-based),client,shell]
(ii)Server
 It is the MySQL db system responsible for storing ,managing and processing data
 It receives SQL queries ,processes them and returns the result sets
 It manages multiple clients' data storage,security & concurrent access
 MySQL Server daemon processes:
    NoSQL :Manages schema-less data storage, used for unstructured or semi-structured data
    SQL Interface:An interface that enables interacting with relational databases using
                  SQL queries  
    Query Parser:Is used to analyze SQL queries ,breaking them down into components to 
                 understand their structure
    Query Optimizer:Evaluates various execution plans for a query & selects the most efficient
                    one to enhance the performance of the database operations
   Buffers & Caches: Store frequently accessed data or query results in memory to improve performance
                    since they reduce the need repeatedly to access the underlying storage
 Storage Engines:A component that is in charge of storing,retrieving and managing the data in the db
 MySQL uses a pluggable storage engine allowing us to select among different engines (MyISAM,InnoDB,etc)
 File systems:


Start & Stop processes
#
$sudo systemctl start mysql
$sudo systemctl stop mysql
$sudo systemctl {restart|status|stop|start} mysql

