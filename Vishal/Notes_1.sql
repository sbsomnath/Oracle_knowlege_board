Playlist : https://www.youtube.com/watch?v=5nJmC8fjig0&list=PLNvBE2ODBJJ9kZqfIuAg8I_YcajKBLKcH


Day 1 :

https://www.youtube.com/watch?v=A_zVq78rjp4

what are different types of table?

heap organised table -  (default)  new data in new row

index organised table - data organised (takes time to insert) according to pk, faster way to retreive 
  [keyword : organisational index in the create statement]

It must have a pk

u cannot partition

external  - external files which is used to load data


temporary  - tables created just for the session

there are 2 types :

1. (GTT - Global Temporary Table)

on commit delete rows

on commit preserve rows

2. Private temporary tables (PTT) -- Oracle 18 onwards

on commit drop defination

on commit preserve defination

In case of gtt only the data will be lost , in case of ptt the table will be lost once the session is over


DML - data manipulation language

DDl - create

DQL - select

TCL - transaction control language commit / rollback / savepoint


Question :

row 1 ins statement in table

row 2 ins statement in table

create  index

row 3 ins statement in table

row 4 ins statement in table

rollback


how many records total ? answer : 2 as the ddl statement is autocommit

now .. if the ddl statement fails how many records will be there ?

it depends on the kind of failure

if suppose it is a runtime failure like the index name already exists ,in that  case the rows 1 and 2 will get persisted, 
  else if it was a syntax error then no records will persist

as it is a syntax issue , it will not be identified as a DDL statement and hence will not auto commit


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Number can be inserted into varchar but it gets converted into a varchar type, hence u can retrieve the values only through quotations

==> Difference between char and varchar columns

create table xyz (name varchar2(10), age char(10));

insert into xyz values ('som','30');

insert into xyz values ('a','1');

select name, length(name), age, length(age) from dual ;

name      length(name)       age           length(age)

som           3               30               10
a             1               1                10

in varchar, when a 3 lenghth string is used, it is only using 3 length, rest (10-3) are free
whereas in the char  columne it will utilise all 10, it is fixed length rest it will fill with blank character


==> Difference between varchar and varchar2

There is no difference beween varchar and varchar2, however it is advisable to use varchar2 as varchar is reserved 
  for future utilisation of storing some different type of data

==> Scenario , number column needs to adjust the values to the nearest hundred, like if the value entered is 2034, it should be 2000

so we can use a number column having precision and scale

here we can use negative precision [-2 means nearest hundred, -3 means nearest thousand]

create table test (number (5,-2));

insert into test values (1208);

select * from test; ==> 1200

insert into test values (1389);

select * from test; ==> 1400

==> increasing column size in a table is fast but decreasing the table column size is slow as it will check for 
  the size of the max value in the column and then only it will allow you to
  
decrease the size if it is still greater than the max value, it will check all the millions of records one by one  , 
  hence it is advisable to do decrease of column size during down time

 UNUSED COLUMN
 -------------- 

==> dropping of column is very expensive operation , it will block all other changes in the table

alter table <table name> set unused column address ==> this is an instant operation irrespective of how many records are present 
as it does not physically remove the column from the db but marks the column as unusable

this is irrevertable as it is a ddl statement

now we can remove the unused columns to clear the data

alter table <table name> drop unused columns

to find all the unused columns :  select * from dba_unused_col_tabs

dropping unused column is a non blocking operation and will not affect the application related to the table

INVISIBLE COLUMN
-----------------  
  
==> Invisible column for security purpose added feature in oracle 12c

create table abc(
a number ,
b number invisible);

as name suggests b will not be visible when u execute select * from abc

but if u specify the invisible column, then u can retrieve and insert data : select b from abc;

To find the hidden columns in a table , note no column id is assigned to a hidden column

select column_id, column_Name, hidden_column from user_tab_cols where table_name='<table name>';

note : u can also place constraints on invisible column

==================================================================================================================================================================================================================

Day 3  [https://www.youtube.com/live/9JQxFD-IUsM?feature=share]

COLUMN ORDER
------------  
  
By default when u add a column to a table it will always be added at the last

How do i change the arrangement of the column?

Note : invisible columns do not have a column id and are always shifted to the last

so initially if a table has columns in this order :

create table a (id number ,name varchar2(100));

alter table a add email varchar2(100);

desc table

id,
name,
email

Now if i want the email column before the name column then , 
i will first mark the name column as invisible which will result in shifting the email column above the name column 
and then again mark the name column as visible


VIRTUAL COLUMN
--------------
  
scenario

table has 3 columns a, b, c, i want a column that will AUTOMATICALLY POPULATE the data based on the formula, (a+b)*c

create table person as (id_1 number, id_2 number, id_3 number, id_4 generated always as (id_1+id_2+id_3) virtual);

we can add a virtual column on an existing table

alter table t1 add col3  number generated always as (col1+1)

Note : virtual columns can be made invisible

alter table t1 modify col3 invisible;

Why Can't Virtual Columns Be Updated?
  
Virtual columns are derived from other columns using the specified expression.
They do not store data physically (unless explicitly defined as STORED in Oracle 11g and later).
Any attempt to update a virtual column would contradict its definition, as the column's value depends solely on the computation formula.

ORA-54013: INSERT or UPDATE operation disallowed on virtual columns

  
the virtual column can be varchar2 as well



NOTE : no where condition is allowed in the truncate command , it is a ddl command

Truncate is faster than delete

When data is deleted, it is written in the redo log buffer, so that rollbaack can retreive the data from this file, 
  but in truncate no need to write the entire data into the redo log buffer file and gets autocommitted


Truncate will reset the HWM and delete will not

HWM stands for High WAter Mark 
  --> it is the last block till which the data is written , it is the max amount of database block used by a segment

It is like a seperator between used block and free block

I have a table with 1 million records and i run a query and it takes 30 secs to execute

now i delete 90% of the records from the table and run the same query , still it is taking the same time to execute why??

This is because the HWM is not reset, still the query will search till the same last block where the query is written

There is no correct defined script to reveal the HWM , we can just assume that it is the last extend that was allocated to the table

Concept of shrinking can be used to reset the HWM



Scenario :

I have a table with 10 mil records and i need to delete 5 mil , how to do?

We cannot truncate the table as the entire data will get lost, 
and if we delete 5 mil records, it will hang your database or cause data base session block

so there are 2 ways of dealing with the issue

First -

create a temp table and insert the REQUIRED records into it from the main table .... create temp table as select * from main_table 
  where required records;

drop the main table

Disadvantage : u need to recompile all the invalid objects procedures ,functions related to it 
and provide the relevant access to the other users

Second

create a temp table and insert the REQUIRED records into it from the main table .... 
create temp table as select * from main_table where required records;

truncate the main table

insert records from the temp_table to the main table ,

drop the temp_table

insert/update/delete are dml operations which involves redo log buffer , 
but we can skip this by direct insert path using no logging option that will make the insert even faster  
or we can disable the index and then insert
==================================================================================================================================================================================================================

Day 4  [https://www.youtube.com/live/uSFQ0rPUZb8?feature=share]

key --> Uniquely identify the data

composite pk/ compound pk --> both denote the same , when multiple columns are needed to uniquely identify the data


unique key / candidate key/ super key

primary key - when one column is used to uniquely identify the data

composite primary key - 2-3 columns are needed to uniquely identify the data and NO NULL values are allowed in ANY OF THE COLUMNS

super key - 5 columns i am using to identify the unique record is called the super key

candidate key - a part of the super key is called candidate key


primary key does not allow NULL but in case of super key and candidate key , there is a possibility that a combination can be NULL

difference betwen primary key and unique key : uniques key allows null , unique key allows multiple rows to have NULL values as well

NULL = NULL and NULL <> NULL , both are wrong statements , NULL is undefined and unknown ,
NULL cannot be compared hence unique key allows multiple NULL values , 
hence it can be considered as unique

More than one unique keys are possible in the table but only 1 primary key is possible in the table

scenario : I have a table with 2 columns, how to identify the unique key and pri key

Based on the column data , if any one of the column has the possibility of having a NULL value then it cannot be a pk

Now if both the column will never have null values , then will prefer the number column to be the pk , 
it has to do with indexing , pk will have an index

If both are number as well then we can choose anyone of them

Can we create more than one primary keys are not created ?

NO we cannot create 2 primary keys on a table but we can mimic a secondary primary key by one of the two options

1) we can create a unique key with NOT NULL constraint

2) we can creat a unique index in another column

But why we cannot create multiple primary keys ??

According to 2NF , fully funcional dependency , there cannot be multiple columns to uniquely identify a row

What is Second Normal Form (2NF)?

Second Normal Form (2NF) is a rule in database normalization aimed at reducing redundancy and dependency anomalies.

A table is in 2NF if:
It is already in First Normal Form (1NF) (all columns contain atomic values).

All non-key attributes are fully functionally dependent on the entire primary key.
Fully Functional Dependency

Functional Dependency: If column A determines column B, we say B is functionally dependent on A (A → B).
Full Functional Dependency: A non-key column is fully functionally dependent on a composite primary key only if it depends on all parts of the key, not just a subset.

Example:

For a table with columns (student_id, course_id, grade):

Primary Key: (student_id, course_id) (composite primary key).
grade depends on both student_id and course_id. Hence, it is fully functionally dependent on the composite primary key.

Why Multiple Primary Keys are Not Possible?

  Violation of 2NF:

If you allow multiple primary keys (e.g., PK1 and PK2), it suggests that two independent sets of columns can uniquely identify rows.
  
Scenario based question :

There is already a table in prod with exact duplicate date , how do i prevent creation of additional duplicate data 
without NOT me wanting to DELETE ANY DATA IN PROD ?

example there is a table having column sr and all the 4 rows of the table has the same value 1

now if i have to make the column sr a pk, then i will need to delete all the duplicated 
  and then only i will be allowed to add the primary key constraint

There is a concept of deferrable novalidate option that can be used 

alter table abc add constraint pk primary key (sr) deferrable novalidate ; 
(question ..can a column already having null values can it be used in deferrable) ==> yes

In this case i can create the pk which will allow the already present duplicates to exist but prevent 
any further duplicates from getting inserted

49:39

select * from the table where emp_id=... and empfname=... and emplame=... and email=... and phno=... 
all these columns are used to uniquely identify the data , then it is called a super key

candidate key is part of the super key ,  meaning min number of columns from the super key to uniquely identify the data

minimum of super key needed to uniquely identify the data is called primary key provided it is not having any null values

It is confirmed that every primary key is a candidate key , but it cannot be confirmed that every candidate key can be a primary key


Note : Distinct, union and analytical functions , they all internally combine all the nulls as 1
==================================================================================================================================================================================================================
Day 5   https://www.youtube.com/watch?v=7x6o5c-HuQc&list=PLNvBE2ODBJJ9kZqfIuAg8I_YcajKBLKcH&index=19

When more than 1 column comes into the primary key it is called the composite key , 
none of the columns in the composite primary key can be NULL

Surrogacy concept

Surrogate key : any column or set of column that can be declared as a primary key instead of a real key. 
We generated that key through sequence(artificially generated, 
which may not have any business meaning example patient id in a hospital)

But Aadhar card number,  Pan card number are part of data of the patient, it is not artificially generated

Surrogate key is never duplicate and it will never be NULL as it is generated with the purpose of uniquely identifying a record

If we create a primary key, db will create a unique index on that which will be a separate structure , 
this is the advantage of a surrogate key over primary key

If there is any change, insert/update/delete in the primary key or any one of the composite primary key, 
then the changes have to be maintained in the index as well

Index is a binary structure , hence it has to keep adjusting the index based on the changes in the values of the primary keys, 
this is called the concept of indexing and it is time expensive

Hence surrogate key is preferable over a composite primary key


Foreign Key : It is used to enforce a business rule

alter table child_table add constraint fk (child_col) references parent_table(parent column);

Can i insert NULL in foreign key ?

it is accepting insertion of null in the foreign key, reason being NULL cannot be compared against any of values in the parent column as NULL is undenfined and unknown

NULL by definition is not a value , hence data base cannot say whether null is there or not there in the parent columns and hence does not throw foreign key constraint error

Hence NULL can get inserted in the foreign key irrespective of NULL being present or not present in the parent column

alter table table_name disable constraint constraint_name --- to disable a constraint like foreign key

NOW i can insert ANY VALUE irrespective of its presence in the parent column and I do the same

Now i again try to enable the foreign key constraint but it will fail since i inserted certain values which are not present in the parent column, 
  it will check every record value for that foreign key column

but i cannot delete the data that has already been inserted

so we can enable it with no validate option

alter table table_name enable novalidate constraint fk;

so now it will not validate any previous value

scenario :

I try deleting record from a parent , but that value has a child, which again has a child on another table and so one.... 
  i cannot keep going to all the hierarchy right from the bottom to the top to keep deleting the records so i will use below :

alter table  child_table add constraint fk (child_col) references parent_table(parent column) on delete cascade;

even if suppose the parent row to be deleted is one, and it might have multiple child records, but it will show 1 record deleted

Now you can delete all the hierarchy of a value by a single delete statement



=================================================================================================================================================================================================================================

https://www.youtube.com/watch?v=64_nAtkIy8s&list=PLNvBE2ODBJJ9kZqfIuAg8I_YcajKBLKcH&index=19

B20: Technical Database Interviews for Success

if my block has suppose 4 dml statements within a Begin End block, and the third fails, all the dmls are rolled back because of ACID
  [Atmonicity Consistency Isolation Durability]property  (either whole transaction gets completed or nothing gets completed which is backbone of RDBMS)

Pragma Autonomous is challenging the ACID property

Pragma is a non executable code which gives instruction to compiler that u need to treat me differently , it will create a new transaction within a transaction

And irrespective of the child transaction commit or rollback,it does not affect the main transaction and vice versa , they are independent of the parent transaction

For pragma autonomous transaction we must issue , commit or rollback

create or replace procedure child_block ()

begin

insert into table values ('child');

commit;

end;
-----------------------------------------------------------------------------------------------------------
create or replace procedure parent_block ()

begin

insert into table values ('parent');

child_block;

rollback;

end;
-----------------------------------------------------------------------------------------------------------

exec parent_block

select * from table will see both the child and parent record inserted, as the commit statement inside the child_block has been executed

This commit statement is implementing atomicity, that is either everything should be completed or nothing should be completed , 
  meaning commit statement will commit every dml change irrespective of being in child or parent as
it is part of same transaction

Now, if i add pragma autonomous transaction to the child , then the result changes

create or replace procedure child_block ()

pragma autonomous_transaction;

begin

insert into table values ('child');

commit;

end;

Now in the table only the child statement gets inserted

Note : Prragma must have commit or rollback
-----------------------------------------------------------------------------------------------------------

Only use pragma for Logging purpose

should not be used in any business design as it denotes a wrong database design

we can use it in triggers

If we write dml into a function, we cannot call that in a select statement -- error : cannot call a dml operation inside a query

However we can call inspite of it having a dml statement provided the function return statement comes before the dml statement

Another exception is if you call that function as pragma automation transaction, then u can call that function in a dml statement

Note function must return something, if you do not define the return statement in the function signature, it will compile time error

and if you miss the return statement in the body of the function , the function will compile, but it will give runtime error


If a function has a dml statement , i cannot use that in a select statement, but if there is pragma automation, then it can be used in a select statement

create or replace function abc return number is

pragma automation_transaction;
begin

     insert into table values ();
     commit;

     return;

end;

select abc from dual; --> will give output since it has pragma automation statement

NOTE: Pragma automation is a plsql concept which can be placed only on a block to make it as a seperate transaction , 
  u cannot make pragma automation available at the dml statement level in case of multiple dml statements


Testing the pragma autonomous transaction
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Declare -- assume initial salary for both the employees is 17000
l_salary number;

procedure test_block is
pragma autonomous_transaction;
  begin

           update employees set salary= salary+15000 where emp_id=2 returning into l_salary; --returning is a substitute of creating a new statement to assign value of new salary to the variable
           commit;
  end;
Begin

    select salary into l_salary from employees where emp_id=1;
    dbms_output.put_line ('Before salary of emp 1 is : '||l_salary) ==> 17000

    select salary into l_salary from employees where emp_id=2;
    dbms_output.put_line ('Before salary of emp 2 is : '||l_salary) ==> 17000

    update employees set salary= salary+5000 where emp_id=1 returning into l_salary; --returning is a substitute of creating a new statement to assign value of new salary to the variable
    dbms_output.put_line ('Updated salary of emp 1 is : '||l_salary) ==> 22000

    test_block;
    rollback;

    select salary into l_salary from employees where emp_id=1;
    dbms_output.put_line ('After salary of emp 1 is : '||l_salary)==> 17000 -- since it got rolled back

    select salary into l_salary from employees where emp_id=2;
    dbms_output.put_line ('After salary of emp 2 is : '||l_salary)==> 32000 --since it called test block where there was a pragma autonomous commit that was a seperate transaction

End

note : if pragma autonomous was not there in the test_block, but commit was written then, the rollblock would be ineffective 
      and the updates of both the employees would have persisted
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table sal (emp number, salr number);
insert into sal values (1,100);
insert into sal values (2,200);
commit;

CREATE OR REPLACE PROCEDURE EMP_SAL_INNER AS
var_sal number;
pragma autonomous_transaction;
BEGIN
  select salr into var_sal from sal where emp=1;
  DBMS_OUTPUT.put_line('EMP_SAL_INNER_1:'||var_sal );
   update sal set salr=salr*2 where emp=1;
   commit;
  select salr into var_sal from sal where emp=1;
  DBMS_OUTPUT.put_line('EMP_SAL_INNER_2:'||var_sal );
END EMP_SAL_INNER;



create or replace PROCEDURE EMP_SAL_OUTER AS
var_sal NUMBER;
BEGIN

  select salr into var_sal from sal where emp=1;
  DBMS_OUTPUT.put_line('salr6:'||var_sal );

  update sal set salr=101 where emp=1;
  select salr into var_sal from sal where emp=1;
  DBMS_OUTPUT.put_line('salr9:'||var_sal );

  EMP_SAL_INNER;
  select salr into var_sal from sal where emp=1;
  DBMS_OUTPUT.put_line('salr12:'||var_sal );
  rollback;
  select salr into var_sal from sal where emp=1;
  DBMS_OUTPUT.put_line('salr14:'||var_sal );
END EMP_SAL_OUTER;

output :

salr6:100
salr9:101
EMP_SAL_INNER_1:100 <=== since the parent proc did not commit, it is still taking the older value : 100

ORA-00060: deadlock detected while waiting for resource <== update statement is failing with deadlock issue as the dml in the parent proc has not been committed
ORA-06512: at "FINREF_OWNER.EMP_SAL_INNER", line 7
ORA-06512: at "FINREF_OWNER.EMP_SAL_OUTER", line 12
ORA-06512: at line 2


drop procedure EMP_SAL_OUTER;
drop procedure EMP_SAL_INNER;
drop table sal;
=================================================================================================================================================================================================================================

SQL and PL/SQL interview questions and answers || Part 3

https://www.youtube.com/watch?v=5nJmC8fjig0&list=PLNvBE2ODBJJ9kZqfIuAg8I_YcajKBLKcH&index=1


Question : can we write commit in a trigger without pragma autonomous_transaction?

Answer : u can write commit and compile a trigger, but when you insert data into the table containing the trigger , 
  it will fail giving error that cannot commit in a trigger

Hence it gives a runtime error and not a compile time error

sequence :

create table abc (id number, name varchar2(10));

insert into abc values (1,'a');
insert into abc values (null,'b');
insert into abc values (5,'c');
insert into abc values (null,'d');
insert into abc values (11,'e');
insert into abc values (null,'f');

create sequence sequence_name start with 1 increment by 1;

select id,nvl(id,sequenc_name.nextval) from abc;

Every time the nvl function is called, the sequence value is getting generated, hence the null values will not be 1,2,3,
rather it will be 2,4,6

again if we execute the sequence, then the sequence value will be start the counter from 6 every time the nvl function is getting called
so now the null values witll be 8,10,12

cursor :

What is implicit cursor : any sequel statement executed by oracle, select, insert, update, delete are all implicit cursor

CTAS : create table as select

how to create a table from another table when the structure and the data , both get copied?

create table emp as select * from hr.emp; ==> this will create a new table with the same column, same data type and all the data will get copied

but the structure as a whole will never get copied , meaning all the constraints, primary data type , foreign key , index will not be copied

BUT CHECK CONSTRAINT  WILL GET COPIED

Not null constraint will be stored in the database with constraint c (check)

scenario :

Huge table having duplicates, do not want to delete the history data but would want to prevent insertion of any further duplicates

create table abc (id number);

insert into abc values (1);
insert into abc values (1);
insert into abc values (1);
insert into abc values (1);

alter table abc add constraint primary key (id) deferrable novalidate;

Note the parent of the foreign key does not have to be a primary key, it can also be a unique key constraint column

How many tables are needed to create a foreign key ?

if u answer 2 tables one for the parent and one for the child it is incorrect , it can also be done in the same table  as well

when one table is used, it is called self referencing foreign key

create table  abcd (
id number,
sub_id number,
name varchar2.
constraint fk foreign key(sub_id) references abcd(id)
);

can a null value be referenced to a null value in foreign key ?


BULK Collect -- fetch multiple rows in 1 shot in context switching

jumping of control from plsql to sql and back is called one context switch , if context switch is high, then performance is low

bulk collect will go to the sql block once, it will retreive all the records irrespective of how many millions in a single context switch

and 'for all' will be used to process all the records in  one shot

negative point is that my program will start consuming a lot of memory reason being as all the humdred million records that gets retrieved, gets stored in the memory
and then the records have to be processed which can improve the query performance but it brings down the database performance
Hence concept of limit comes here where i can limit that in 1 context switching retreive 50k records at a time

There is no as such formula to calculate the value of limit to be used it depends on our data , program and memory so hit and trial method is the only way

And without explicit cursor, we cannot use limit, it can be part of fetch into statement

we cannot use select * bulk collect by 'select into'   and also we cannot use limit by 'select into'

==> IN and EXISTS

Oracle never claims that 'exist' is faster than 'in' , it all depends on the scemario

Both are checking the record in the subquery

'exits' is written in boolean value , 'in' will go and evaluate the whole query and exist will return true and false , 
  if my inner query has a big date volume or a big table and I just want to check if data exists or not ,

exist will be faster here

==> merger faster than delete/update, oracle never claims it .... so then when to use them ??
=================================================================================================================================================================================================================================
SQL and PL/SQL interview questions and answers || Part 2

https://www.youtube.com/watch?v=4LWqVKqRUWA&list=PLNvBE2ODBJJ9kZqfIuAg8I_YcajKBLKcH&index=2


6+ years interview questions topic

- performance tuning
- pipeline function
- explain plan
- result cache
- bulk collect


Difference between function and proc

- function is to compute something and procedure is to execute something
- return is compulsory for function else it will give compile time error, but if i write return within a proc body, 
  there will not be any compilation error, the proc will also run smoothly
but when the control comes to the return keyword at the time of execution, it will return from there and not execute the statements after the return statement
- function has to return a value

can i write dml statement in a function?  yes u can , but you cannot use that function in a select clause

== what are the differences between global/local/reverse indexes

== like operator
if i am having an index on emp_name, will the below query work ?  : select * from table where emp_name like '%som%';

there are special types of indexes for like operator , need to check them

If there is a table where lots of inserts and updates are happening in the table , then what is happening to the indexes of the table ?

analyze table table_name compute statistics;
analyze index index_name compute statistics;

how the histogram will be updated , understand about histogram

so when lots of inserts and updates are happening we need to rebuild the indexes : alter table table_name rebuild index is the command

preferable to drop index and recreate index if it is possible in the env

10:46

what is pipeline funciton

if we need to query a function instead of a database table , we can use pipeline funciton

to query as : select * from plsql_function

it can be queried like a regular table using a 'table operator' in from clause to fetch the data

--firstly we are  creating a type , this is the type that the function will return the value in

create type num_ntt as a table of number


--crating a function with  pipeline keyword

create function row_generator (row_in in pls_integer)
return num_ntt popeline as

Begin

  for i in 1 .. row_in loop;
    pipe.row(i);
    end loop;
    return; ==>  note this is an empty return clause , does not mention the value of a paritcular variable that it has to return
End;

Note : here pipe.row statement is responsible to return a data , not the return statement, so the return clause is empty 
  but we are bound to mention the return statement as it is a function which makes it mandatory



select * from table(row_generator(10));

o/p :
1
2
3
4
5
6
7
8
9
10

==> result_cache in oracle 11g,

it is used to store the result of query for use in subsequent executions, caching helps in saving time of repeating the operation

select * from v$parameter where name liek '%result_cache'

1) result cache mode [default value is manual, meaning by default it is not using manual cache] 
  u can enable it by hint/alter system or session/or explicitly request the caching
2) result cache max_size [how much byte size is it storing in the result cache]
3) result cache max_result
3) result cache remote_expiration

20:23

Query performance :

When query is not performing well , there are 2 scenarios :

1) query was working fine earlier but now it is running slow, meaning there is a drastic change in the execution speed
2) query performance has been gradually decreasing over time

first scenario

check the explain plan which is the representation of the access path which is taken when a query is executed within runtime
the query processing can be divided into few phases :
first is syntactic
second is symantic , that is to check if all the data are accessible , all the objects like tables.views whould exist
third is view merging that is rewrite query as join as base tables
fourth is statement transformation , basically convert the steps into simpler statements
fifthe is optimization, to determine which access path to use (RBO/CBO now everything is default CBO)
QEP(Query evaluation plan)  generation
QEP execution

So how do we comprehend the explain plan?

There are access method is details

1) FTS = full table scan where whole table is read upto the highest WATERMARK (hwm= which is the last block in the table in 
  which data has ever had data written into it including deleted data )
so suppose i want data for emp_id =1, which is incidently may be in the first block itself, but query is using frs,means if table has 1k blocks,  
  will scan all the blocks of the table to get the data
second scenario is concerned with the data. either recreate index, or rebuild index or go for partitioning by analyzing the table

2) Index look up

a) index unique scan == method for looking for a single key value in your index  (select * from table where empid=1; where empid is the index)
b) index range scan == accessing the column data by a range like where empid>400 etc. or a closed range like between 500 to 1500
c) index full scan  == works only in RBO only (i.e. rule based optimisation) and not in CBO and i am working in oracle 11g, so no one is working in 10g
d) index fast full scan ==

29:46

JOINS in explain plan :

there are 2 types of joins

1) sort merge join
2) nested loops
3) hash join

1)So i will check the explain plan
2)see why full table scan or range scan is happening , i need to rebuild/recreate the indexes
3) in the query i need to go for analyze table or analyze indexes i need to follow


Suppose my procedure is taking a lot of time , how to identify which query is taking time in the proc ?

Ask the DBA to  generate the AWR report and read it

AWR report gives the top 5 queries execution time elapsed and the queries are identified by a hexadecimal number query ID along with the query statement

Then i will take that sequel query and use that explain plan to see how it is rinning , if required i will do the index monitoring (need to understand index monitoring)


Scenario :

i have range partitioning in a table : 1-1000 , 1001-2000
now if i insert a row with id : 2001, then till oracle 10g it was giving an error 
  but now we can resolve this by interval paritioning with the extention of range partition that will be automatically generated at the time
if there is any data coming which is outside the range partitioning , oracle will generate a new partition at the runtime and there will be no error


==> Save exceptions

How the save exceptions work in a bulk collect ?

For all rdx in query.1 to 100 save exceptions

if there is any exceptions coming in the first 100 records , it will not rollback, it will insert the correct records 
  and the erronous records will go to the exception block

With clause can be used instead of joining huge tables, materialised views and paralell hint can also fasten the query performance

=================================================================================================================================================================================================================================
SQL and PL/SQL interview questions and answers

https://www.youtube.com/watch?v=2R2R2unKOJY&list=PLNvBE2ODBJJ9kZqfIuAg8I_YcajKBLKcH&index=3

- note if data has to be taken from n tables there should be (n-1) joins


Scenario:

Begin

  select emp_id from table where name='a'; ==> suppose now there is no data with name='a' (question, should control go to no data found or others? 
  because others is getting called first)

Exception

  when others then

    dbms_output.put_line('hi');

  when 'No data found' then

    dbms_output.put_line('hello');

End

Answer : it gives error when this block is run because when others cannot be called before 'no data found' , when others is always the last option

Note : exception block can handle a function inside

suppose in the exception block when 'no data found' , you want to call an exception

Begin

Exception
    when no data found
    Begin
      function
    End
End

Triggers - u CANNOT call a trigger, it gets automatically called

cannot write a trigger in select... only i/u/d

row level, and statement level triggers both the types work on i/u/d

 there will be before and after variations for i/u/d

2*3*2=12 plus 1 (instead of trigger which is used for updating views) total 13 triggers are there


WE wrote one row level trigger and a statement level trigger, and i write an update statement that updates 100 rows, so how many times the trigger will be fired?

Statement level trigger is called once for one update statement and row level trigger is called 100 times

Note ; tell yourself i am 7 or 8 out of 10

Use of index : to fetch the data quickly , but update and delete will be slow

reverse index :


Having clause is a where clause on group by

function : row_number : i want to generate autoincrement ids in oracle, which is not a sequence , then row_number() can be the analytical function which we can use

secomd highest sal query using rank

lead nd lag analytical queries

view : does not take any space in the db , secure data

materilazed view :  reporting env every day at some interval of time, instead of running the complex sql, we use mview 
  and we have a refresh clause that will refresh only after the fixed time interval

Tuning : you have a query that is taking time to execute, so what will you do ?

if it is gradually slowing down , then it is due to the data volumen , so will check the explain plan and check the indexes, 
  if they are fine then go for partitioning

if it is suddenly slowing down, go to explain plan will give you idea how the query is running, if there is any full table scan?, 
  if all the tables and indexes which are used, the statistics are computed or not , in user_tables ,user_indexes
column: last_analyzed_dt (histogram.. etc)


how to fetch explain plan?

explain plan for <query>

select * from plan_table


=================================================================================================================================================================================================================================

