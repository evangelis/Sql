 A.Show commands
 
    SHOW CREATE {DATABASE|TABLE|VIEW|EVENT|FUNCTION|PROCEDURE|TRIGGER} name
    SHOW {CHARACTER SET|CHARSET} [{like 'pattern |WHERE expr}]
    SHOW COLLATION [{LIKE pattern |WHERE expr}]
    SHOW DATABASES [{LIKE pattern|WHERE expr}]
    SHOW [FULL] TABLES [FROM dbName] [{LIKE pattern|WHERE expr}]
    SHOW TABLE STATUS [FROM dbName] [{LIKE patt|WHERE expr}]
    SHOW [FULL] COLUMNS FROM tblName [FROM dbName] [{LIKE pattern|WHERE expr}]
    SHOW INDEX FROM tblName  [{like 'pattern |WHERE expr}]
    SHOW {PROCEDURE|FUNCTION} STATUS [{like 'pattern |WHERE expr}]
    SHOW {FUNCTION|PROCEDURE} CODE routineName
    SHOW {EVENTS|TRIGGERS} [FROM dbName] [{like 'pattern |WHERE expr}]
    SHOW [{GLOBAL|SESSION}] VARIABLES [{like 'pattern |WHERE expr}]
    SHOW [FULL] PROCESSLIST
    SHOW [STORAGE] ENGINES
    SHOW ENGINE engName {STATUS|MUTEX}
    SHOW {ERRORS|WARNINGS} [LIMIT [offset,] rowCount]
    SHOW GRANTS FOR usr
    SHOW PRIVILEGES
    
 B.Authentication & Authorization [users,roles,privileges]

    --Users
    CREATE USER [IF NOT EXISTS] usr1 [auth_option] [,usr2 [auth_option]..]
         DEFAULT ROLE r1 [r2,..][REQUIRE {NONE|tls_option [[AND] tls_opt2..]]
         [WITH resource_option] [{password_option|lock_option}] [COMMENT 'comment']   
    RENAME USER old1 TO usr1 [oldUser2 to newUsr2...]
    DROP USER [IF EXISTS] usr1 [user2,..]
    ALTER USER [IF EXISTS] usr DEFAULT ROLE {NONE|ALL|r1[,r2..]}
    ALTER USER [IF EXISTS] USER() IDENTIFIED BY 'auth_string'  
            [REPLACE 'curr_auth_str'] [RETAIN CURRENT PASSWORD] | DISCARD OLD PASSWORD]
    ALTER USER [IF EXISTS]
    --Roles
    CREATE ROLE [IF NOT EXISTS] r1 [,r2,..]
    DROP ROLE [IF EXISTS] r1 [,r2,..]
    SET DEFAULT ROLE {NONE|ALL|r1 [,r2..]} TO usr1 [user2,..]}
    SET ROLE {DEFAULT|ALL|NONE|ALL EXCEPT r1 [,r2,..]|r1 [,r2..]}
    
    --Password  
    SET PASSWORD [FOR usr] {='auth_string'|TO RANDOM}
        [REPLACE 'curr_auth_string'] [RETAIN CURRENT PASSWORD]

    --Privileges: Grant & Revoke
    GRANT r1 [r2..] TO {usr1|role1} [WITH ADMIN OPTION]
    GRANT PROXY ON {user1|role1} TO {user2|role2} [WITH GRANT OPTION}
    GRANT privilege_type [(column_list)] ON {tbl|function|procedure} privilege_level
        TO {usr1|role1} [{user2|role2..}] [WITH GRANT OPTION]
        [AS usr2 [WITH ROLE DEFAULT|NONE|ALL|ALL EXCEPT r1..|r1..]
    REVOKE [IF EXISTS] privilege_type [(column_list)] [priv_type2 ...] ON {funcName|proc1|tblName}
        FROM {usr1|role1} [usr2|role2..] [IGNORE UNKOWN USER]
    REVOKE [IF EXISTS] r1 [r2..] FROM {usr1|role1..} [IGNORE UNKNOWN USER]
    REVOKE [IF EXISTS] PROXY ON {usr1|rol1} FROM {usr2|rol2..} [IGNORE UNKOWN USER]
    REVOKE [IF EXISTS] ALL [PRIVILEGES], GRANT OPTION FROM {usr1,role1...}
    
 Notes :
 privilege level :{dbName.tblName|dbName.routineName|tblName|dbName.*|
                   *.*,*}

    privilege types:
        Object Rights: SELECT,INSERT,UPDATE,DELETE,EXECUTE (routine),SHOW VIEW,
                       SHOW DATABASES 
        DDL Rights:CREATE (db & table),ALTER, DROP (db,table,view),CREATE VIEW, 
                   INDEX,FILE,CREATE ROUTINE,TRIGGER,REFERENCES,ALTER ROUTINE,
                   EVENT
        Other:   ALL,GRANT OPTION,CREATE USER,CREATE TEMPORARY TABLES,LOCK TABLES,
                 REPLICATION SLAVE,REPLICATION CLIENT,PROCESS,CREATE ROLE,
                 DROP ROLE,PROXY,SHUTDOWN ,SUPER,CREATE TABLESPACE,RELOAD (flush)
                
    

 C.Table Maintenance [check,analyze,repair,optimize,mysqlcheck]
    
    CHECK TABLE tbl1 [tbl2..] {MEDIUM|FAST|EXTENDED|QUICK|FOR UPGRADE} --check table/view for errors
    ANALYZE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 [tbl2...] --key distribution analysis
    ANALYZE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl  --Generte histogram stats,store them in 
        UPDATE HISTOGRAM ON colName1 [col2...] [WITH n BUCKETS] --the data dictionary
    ANALYZE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl UPDATE HISTOGRAM ON col1
        USING DATA 'jsonData'
    ANALYZE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl DROP HISTOGRAM ON col1 [col2...]
    OPTIMIZE [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 [tbl2...]
    REPAIR [NO_WRITE_TO_BINLOG|LOCAL] TABLE tbl1 [tbl2..] 
        [QUICK] [EXTENDED] [USE_FRM]
    mysqlcheck [{(--analyze,-a),(--check,c),(--repair,-r),(--optimize,-o)}] dbName [tbl1 ,..tbl2...]
    mysqlcheck [options] --all-databases

 D.Backup & Restore [mysqldump,Redirection Operators <,>,SOURCE,binlog]
    
    $mysqldump -h localhost -P port -u root -p dbName > /path/bckupFile.sql
    $mysqldump [-h localhost] -u usr -p dbName tbl1 [tbl2 ..] > /path/backupFile.sql
    $mysqldump [-h localhost] --u usr -p dbName1 [db2...] > backupFile.sql
    $mysqldump [-h localhost] -u root -p --all-databases --ignore-table=mysql.user >backupServer.sql
    $mysql -h hostname -P port -u usr -p dbName < dumpFile.sql
    $mysql
    
 E.MySQL command-line Utilities [mysqladmin]
    
    $mysqladmin [opts] command [cmd_opts] [cmd_args]
    $mysqladmin {processlist|reload|shutdown|flush-privileges|version}
    $mysqladmin {create|drop} db


    
    
    
    
    

    
    
    