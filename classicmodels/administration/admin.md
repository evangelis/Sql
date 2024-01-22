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
    1.NoSQL :Manages schema-less data storage, used for unstructured or semi-structured data
    2.SQL Interface:An interface that enables interacting with relational databases using SQL queries  
    3.Query Parser:Is used to analyze SQL queries ,breaking them down into components to understand their structure
    4.Query Optimizer:Evaluates various execution plans for a query & selects the most efficientone to enhance the performance of the database operations
   5.Buffers & Caches: Store frequently accessed data or query results in memory to improve performance since they reduce the need repeatedly to access the underlying storage

 Storage Engines:A component that is in charge of storing,retrieving and managing the data in the db
 MySQL uses a pluggable storage engine allowing us to select among different engines (MyISAM,InnoDB,etc)
 File systems:


Start & Stop processes

    $sudo systemctl start mysql
    $sudo systemctl stop mysql
    $sudo systemctl {restart|status|stop|start} mysql

Authentication & Authorization
 A.Users & Roles
 
 A MySQL db may have multiple users with the same set of privileges
 Modifying the same privileges to multiple users might be time-consuming and error prone
 Roles come into play ,being a named collection of privileges.
 Create a role ->grant privileges to the role ->grant the role to users

    CREATE USER [IF NOT EXISTS] userName[@hostName] IDENTIFIED BY 'passwd';
    SELECT user,host FROM mysql.user;
    GRANT ALL PRIVILEGES ON classicmodels1.* TO myuser@localhost;
    DROP USER [IF EXISTS] accountName1 [,accountName2,...];
    SHOW PROCESSLIST \G
    KILL <id>;
    SELECT user,host,db,command FROM information_schema.processlist;
    RENAME USER usr1 TO newUser1 [,usr2 TO newUsr2 ...];

    --Alter User 
    ALTER USER [IF EXISTS] usr [auth_opt]
    ALTER USER [IF EXISTS] usr DEFAULT ROLE {NOE|ALL|r1,..};
    ALTER USER [IF EXISTS] usr {IDENTIFIED BY 'auth_string' [REPLACE 'curr_auth_str'] [RETAIN CURRENT PASSWORD]|
        DISCARD OLD PASSWARD}

    --Lock& Unlock user accounts
    CREATE USER account_name IDENTIFIED BY 'str' ACCOUNT LOCK;
    ALTER USER account_name IDENTIFIED BY 'str_pwd' ACCOUNT LOCK;

    --Roles
    SELECT CURRENT_ROLE();
    CREATE ROLE  [IF NOT EXISTS] r1 [,r2,...];
    DROP ROLE [IF EXISTS] r1 [,r2,...];
    SET DEFAULT ROLE {NONE|ALL|r1,..} TO usr1 [,usr2,...];
    SET ROLE {DEFAULT|NONE|ALL|r1,..|ALL EXCEPT r1..}; #current user's roles

    --GRANT & REVOKE statements
    GRANT priv_type1[(column_lst)] [..] ON [{TABLE|FUNCTION|PROCEDURE}] 
        priv_level TO usr1_or_rol1 [..] [WITH GRANT OPTION]
        [AS usr2 [WITH ROLE {r1..|DEFAULT|NONE|ALL|ALL EXCEPT r1..}]];
    GRANT PROXY ON usr_or_role TO usr_)or_role2 [WITH GRANT OPTION];
    GRANT r1 [..] TO usr_or_role1 [..] [WITH GRANT OPTION];
    REVOKE [IF EXISTS ] priv_type[(col_list)] [..] ON [{TABLE|FUNCTION|PROCEDURE}]
        FROM usr_or_role1 [..] [IGNORE UNKNOWN USER];
    REVOKE [IF EXISTS] r1 [..] FROM usr1_or_role1 [..] [IGNORE UNKWOWN USER]
    REVOKE [IF EXISTS] ALL [PRIVILEGES] ,GRANT OPTION FROM usr1_or_rol1 
        [IGNORE UNKOWN USER];
    REVOKE [IF EXISTS] PROXY ON usr_or_role FROM usr_or_role2 [..] 
        [IGNORE UNKNOWN USER];
    --privilege level : {*|tblName|dbName.*|dbName.tblName|dbName.routineName|*.*}

 Privilege Types (meaning):
  ALL [PRIVILEGES] CREATE (db,table),ALTER (table),CREATE TABLESPACES,CREATE TEMPORARY TABLES, DELETE
  CREATE VIEW, ALTER VIEW, CREATE ROUTINE ,ALTER ROUTINE, DROP (table,view),EXECUTE (routines)
  EVENT ,TRIGGER,INDEX (create,drop indexes),REFERENCES ,
  CREATE ROLE,CREATE USER, PROXY, EXECUTE (routines for user), USAGE (no privilages), SUPER ,GRANT OPTION
  SELECT,INSERT,UPDATE (db,table,column),DELETE
  SHOW DATABASES,SHOW VIEW,PROCESS (show processlist)
  LOCK TABLES,RELOAD (flush), SHUTDOWN (msqladmin shutdown),FILE
  REPLICATION CLIENT,REPLICATION SLAVE

 Checking tables 

    CHECK TABLE tbl1 [..] {QUICK|FOR UPGRADE|FAST|MEDIUM|EXTENDED|CHANGED};
    ANALYZE TABLE [NO_WRITE_TO_BINLOG|LOCAL] tbl1 [..];
    ANALYZE TABLE [NO_WRITE_TO_BIONLOG|LOCAL] tblName 
        UPDATE HISTOGRAM ON col1 [..]
    ANALYZE TABLE [] tblName 
        UPDATE HISTOGRAM ON col1 [USING json_data];
    ANALYZE TABLE NO_WRITE_TO_BINLOG] tbl 
        DROP HISTOGRAM ON col1 [..];
    REPAIR [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 [..] [QUICK] [EXTENDED] [USE_FRM]; --requires a table lock
    --optimize table reorganises physical storage of a table
    SHOW TABLE STATUS LIKE  '<tbl>' \G
    OPTIMIZE TABLE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 [...];

##Other Administrative Tasks 

#Execute Script in batch mode 
    
    $mysql -u myuser -p -t -vvv < ~/Desktop/SQL/classicmodels/administration/script.sql \
        > ~/Desktop/SQL/output.txt 
    $mysql -u myuser -p vvv -t -e "USE mysql;SELECT user,host FROM user; SHOW SCHEMAS ;"
#Execute scripts using the SOURCE command 
    
    mysql>SOURCE ~/Desktop/SQL/classicmodels/administration/script2.sql 

# Backup & Restore [mysqldump,SELECT ..INTO OUTFILE,mysqlimport,LOAD DATA INFILE]
 Cold backups are performed when the database is offline and no write operations occur
 Hot backups are performed while the database is actively running ,serving requests.This method ensures continuous availability and mininm a disruption to users
 Logical backup :Allows us to recreate table structures anb data without copying the actual data files
 Physical backup is associated with copying and making an  entire backup of a  database server 
 Physical backups capture the binary data files which provide an exact copy of the database at a point in time
 There is a tool for performing physical backups ,called Percona XtraBackup

    xtrabackup -backup --user=[usr] --password=[pwd] --target-dir=/path/to/backup

 There is also a tool for performing logical backups ,called mysqldump that is used to export a database & its data into a backup .sql file

    sudo service mysql stop --Perform a cold backup
    mysqldump -u[sername] -p[assword] [dbName.]tblName > /path/tobackup_file.sql 
    sudo service mysql start

 Usage of the mysqldump & mysqlimport tools

    mysqldump -u myuser -p [options] tbl1 [,tbl2..] > output_file.sql --Dump >=1 
    tables
    mysqlimport dbName tbl1 [tbl2,..]
 Options : --user (u),--password (p),--all-databases (A),--databases (B),--routines (R),
    --no-create-db (n),--no-create-info (-t) [suppresses the create table stmts],
    --result-file (r),--no-data (-d),--add-locks ,
    --add-drop-tigger ,--add-drop-table ,--add-drop-database (before a create trigger,table database stamements)

    mysqldump -u myuser -p --databases db1 [,db2,..] >out_file.sql --dump >=1 databases
    mysqldump -u root -p --all-databases --ignore-table mysql.user \
         > out_file.sql --dump all databases
    --Create a backup of the database structure only
    mysqldump -u myuser -p dbName --no-data >bakcup_file.sql
    --Create a backup of data only
    mysqldump -u myuser -p --no-create-info classicmodels1 > /path/to/backup_file.sql 
 # Binary Logs
  A binary log keeps all changes made to the db (CREATE TABLE,UPDATE,DELETE,INSERT ) 
  It is used to replicate slave backup server or bring a backup server up-to-date by executing all the changes logged
  To enable binary logs start MySQL server with the [--log-bin=baseName] option
  The server will append a number next to the baseName and creates a new log file whenever it starts or when the log is flushed
  mysqld creates an indewx file that contains the names of the binary log files
  To update a db server using the binary log files pipe the output of mysqlbinlog to a mysql client
  The binlog files are stored at var/lib/mysql/binlog.000001
    $mysqlbinlog logfile.001 [logfile.002...] | more #display binary logs onm console
    $mysqlbinlog logfile.001 [logfile.002...] > /path/to/binlog.sql --save 
    $mysqlbinlog /p;ath/to/binlog.sql | mysql -u usr -p  
  Bin log formats:
    --binlog-format=STETEMENT :Statement-based logging ,keeps track of statement changes
    --binlog-format=ROW: Keeps track of how idnividual row changes were introduced
    --binlog-format=MIXED: Uses statement-based logging and turns to row logging for special cases
 # Point-in-Time Recovery 
 Allows us to restore a db to a specific point in time in the past. Components:
    Full backup :Serves as the foundation for recovery ,providing the startiong state of the database
    Binary logs: Log files ,record all changes made to the db ,allowing us to replay these changes to a desired point


#kill a process in MySQL 

    SHOW PROCESSLIST \G
    KILL <id>;
    DESC information_schema.processlist;
    $mysqladmin -u root -p processlist; --using the mysqladmin
    $mysqladmin -u root -p kill <id>;
