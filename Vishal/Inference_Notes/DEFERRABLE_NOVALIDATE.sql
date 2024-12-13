The DEFERRABLE NOVALIDATE option allows you to add a Primary Key (PK) constraint to a table without enforcing it on existing data 
but ensuring that any future operations (inserts/updates) comply with the constraint.

Here’s a detailed explanation with examples:

Concept: DEFERRABLE NOVALIDATE

DEFERRABLE:
Allows the constraint enforcement to be deferred (i.e., checked at the end of a transaction instead of immediately for each operation).
Constraints defined as DEFERRABLE can be toggled between DEFERRED (checked at commit time) 
and IMMEDIATE (checked immediately after each DML operation).

NOVALIDATE:

Skips the validation of existing data when the constraint is added.
The constraint will not be checked for violations on rows that are already in the table.

Your Question: Can a column already having NULL values or duplicates be used in a DEFERRABLE NOVALIDATE primary key?
Answer:
Yes, you can create a primary key constraint using DEFERRABLE NOVALIDATE on a column that already contains NULLs or duplicates. However:

Existing NULL values and duplicates will not be validated when the constraint is added.
Any new inserts/updates must comply with the primary key constraint (i.e., no duplicates and no NULL values).

Example: Adding DEFERRABLE NOVALIDATE Primary Key

CREATE TABLE abc (
    sr NUMBER,
    name VARCHAR2(50)
);

-- Insert some duplicate and NULL values
INSERT INTO abc (sr, name) VALUES (1, 'John');
INSERT INTO abc (sr, name) VALUES (2, 'Jane');
INSERT INTO abc (sr, name) VALUES (1, 'Doe');  -- Duplicate
INSERT INTO abc (sr, name) VALUES (NULL, 'Mary'); -- NULL
INSERT INTO abc (sr, name) VALUES (NULL, 'Chris'); -- NULL

-- View the table
SELECT * FROM abc;

-- Output:
-- SR   | NAME
-- ---- | -----
-- 1    | John
-- 2    | Jane
-- 1    | Doe
-- NULL | Mary
-- NULL | Chris

2. Add the Primary Key Constraint with DEFERRABLE NOVALIDATE:

ALTER TABLE abc ADD CONSTRAINT pk PRIMARY KEY (sr) DEFERRABLE NOVALIDATE;

Effect:
The primary key constraint is added.
The current duplicate (1) and NULL values are not validated.
New rows must comply with the primary key rules (no duplicates and no NULL values).

3. Test the Constraint:

Insert Valid Data:


INSERT INTO abc (sr, name) VALUES (3, 'Alice');
-- Success
INSERT INTO abc (sr, name) VALUES (1, 'Bob');
-- Error:
-- ORA-00001: unique constraint (SCHEMA.PK) violated
INSERT INTO abc (sr, name) VALUES (NULL, 'Tom');
-- Error:
-- ORA-01400: cannot insert NULL into ("SCHEMA"."ABC"."SR")

Behavior of DEFERRABLE Primary Key
  
Immediate vs Deferred Enforcement
  
By default, constraints are IMMEDIATE, meaning they are checked after every statement.
You can defer the checking of a DEFERRABLE constraint until the end of the transaction by setting it to DEFERRED.

Switch to Deferred Mode:

SET CONSTRAINT pk DEFERRED;

INSERT INTO abc (sr, name) VALUES (1, 'Bob'); -- No immediate error
COMMIT;
-- At commit, Oracle checks constraints and raises:
-- ORA-00001: unique constraint (SCHEMA.PK) violated


