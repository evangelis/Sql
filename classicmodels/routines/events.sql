/**********************************************************************************************************
	Events 
 Are tasks that are execute according to a specified schedule
 Event scheduler is a special thread responsible for executing all scheduled events
Events are used for :
	Data Backup :Automating regular backup 
	Data purging:Scheduling tasks to remove old data,optimizing performance
	Reporting:Generate periodic reports & statistical analyses
	Maintainance tasks:Index rebuilding and table maintainance 

SET GLOBAL EVENT_SCHEDULER = ON; 
SHOW PROCESSLIST \G
CREATE [DEFINER=usr] EVENT [IF NOT EXISTS] evName ON SCHEDULE sch
	[ON COMPLETION [NOT] PRESERVE] [ENABLE|DISABLE|DISABLE ON SLAVE] [COMMENT 'str']
	DO event_body;

  sch: {AT tmsp [+INTERVAL intv] |
 		EVERY intv [STARTS tmsp [+ INTERVAL intv]] [ENDS tmsp [+INTERVAL intv]];
	   }
  intv: {YEAR|QUARTER|MONTH|DAY|HOUR |MINUTE|SECOND |WEEK|YEAR_MONTH|
  		 DAY_HOUR|DAY_MINUTE|DAY_SECOND|HOUR_MINUTE|HOUR_SECOND|MINUTE_SECOND	
  		 }

ALTER [DEFINER=usr] EVENT eventName [ON SCHEDULE sch] [ON COMPLETION [NOT]PRESERVE]
 	[RENAME TO viewName2] [ENABLE|DISABLE|DISABLE ON SLAVE] [COMMENT 'str']
 	[DO event_body];
ALTER EVENT evName RENAME TO newEvName;
ALTER EVENT evName DISABLE;
SHOW EVENTS {FROM|IN} dbName [WHERE expr|LIKE 'pattern'];
DROP EVENT [IF EXISTS] eventName;

**************************************************************************************************************/

USE studentdb;
SHOW FULL TABLES FROM studentdb WHERE TABLE_TYPE ='BASE TABLE' ;
SHOW EVENTS FROM studentdb;
CREATE TABLE IF NOT EXISTS messages(
	id int AUTO_INCREMENT PRIMARY KEY,
	message VARCHAR(255) NOT NULL,
	created_at DATETIME DEFAULT NOW()
);

CREATE DEFINER= CURRENT_USER EVENT [IF NOT EXISTS] one_time_log 
	ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE 
	ON COMPLETION PRESERVE
	COMMENT 'Inserts a row in messages table'
	DO
  INSERT INTO messages(message) VALUES ('Preserved One-time event');
 
CREATE DEFINER = CURRENT_USER EVENT IF NOT EXISTS recurring_log 
	ON SCHEDULE EVERY 1 MINUTE STARTS CURRENT_TIMESTAMP 
	ENDS CURRENT_USER + INTERVAL 1 HOUR 
	COMMENT 'Executes every minute for an hour & expires' DO 
  INSERT INTO messages(message) VALUES (CONCAT('Running at ',NOW()));	

CREATE DEFINER = CURRENT_USER EVENT IF NOT EXISTS test_event_msg 
	ON SCHEDULE EVERY 1 MINUTE DO  
  INSERT INTO messages(message) VALUES ('Test alter event');

ALTER EVENT test_event_msg ON SCHEDULE EVERY 2 MINUTE;
ALTER DEFINER =CURRENT_USER EVENT test_event_msg DO 
	INSERT INTO messages(message) VALUES ('New message');
ALTER EVENT test_event_msg RENAME TO test_event_message ;
ALTER EVENT test_event_message DISABLE;

CREATE TABLE IF NOT EXISTS event_logs LIKE messages;

CREATE DEFINER =CURRENT_USER EVENT IF  NOT EXISTS log_writer 
	ON SCHEDULE EVERY 1 SECOND STARTS CURRENT_TIMESTAMP 
	ENDS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
 DO INSERT INTO event_logs(message) VALUES (CONCAT('Event executed at ',NOW()));
