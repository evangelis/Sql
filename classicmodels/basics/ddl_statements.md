Data Definition Statements
 CREATE {DATABASE,EVENT,TABLE,FUNCTION,PROCEDURE,VIEW,TRIGGER,TABLESPACE,SERVER}
 ALTER {DATABASE,TABLE,FUNCTION,PROCEDURE,TRIGGER,VIEW,EVENT,TABLESPACE,SERVER}
 #Database
   
    #create database
    CREATE {DATABASE|SCHEMA} [IF NOT EXISTS] dbName create_option
        create_option:[DEFAULT ] {CHARACTER SET [=]chs| COLLATE [=] collation|ENCRYPTION [=]{'Y'|'N'}}
    #create table
    CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tblName 
        {LIKE tbl2| (LIKE tbl2)} #
    CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tblName create_def [tbl-options] [partition_options]
    CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tblName [create_def,..tbl_opts,..partition_options]
        [IGNORE|REPLACE] AS query_expesion

 create_def: 
     colName col_def | {INDEX|KEY} idxName [idx_type] (key_part) [idx_opt]
    [CONSTRAINT [symbol]] PRIMARY KEY  
         
      
     