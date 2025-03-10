DROP TABLE IF EXISTS table1
PARALLEL WITH
DROP TABLE IF EXISTS table2;

CREATE TABLE table1(x Int32) ENGINE=MergeTree order by x
PARALLEL WITH
CREATE TABLE table2(y Int32) ENGINE=MergeTree order by y;

SHOW CREATE TABLE table1;
SHOW CREATE TABLE table2;

CREATE TABLE table1(x Int32) ENGINE=MergeTree order by x
PARALLEL WITH
CREATE TABLE table2(y Int32) ENGINE=MergeTree order by y; -- { serverError TABLE_ALREADY_EXISTS }

INSERT INTO table1 SELECT number FROM numbers(3)
PARALLEL WITH
INSERT INTO table1 SELECT number FROM numbers(10, 2)
PARALLEL WITH
INSERT INTO table2 SELECT number FROM numbers(20, 1);

SELECT 'table1:';
SELECT * FROM table1 ORDER BY x;
SELECT 'table2:';
SELECT * FROM table2 ORDER BY y;

DROP TABLE table1
PARALLEL WITH
DROP TABLE table2;

SELECT 'tables exist:';
EXISTS TABLE table1;
EXISTS TABLE table2;
