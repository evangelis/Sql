###Operators
/*****************************************************
 * Comparison Operators : <,>,<=, >=, <>,!,== ,
 *    Logical Operators : AND ,&&,OR ||,XOR,^ ,NOT !
 *    Assignment Operators : :=,= (part of the SET clause)
 *    Arithmetic Operators : +,-,/,*,%,MOD
 *    Bitwise Operators: & (AND),>>,<<,
 ******************************************************/
SELECT !TRUE,TRUE!=NULL, !NULL ,NULL != NULL -- FALSE, NULL,NULL,NULL
SELECT -10 IS TRUE,NOT 10 ;--1,0 (ie TRUE,FALSE)
SELECT 1 0R 0, 1 OR NULL, 0 OR NULL; -- 1,1,NULL