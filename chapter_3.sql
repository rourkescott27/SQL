-- Chapter 3 Exercises
DROP TABLE char_data_types;
-- 3.1

CREATE TABLE char_data_types (
	varchar_column varchar(10),
	char_column char(10),
	text_column text
);

INSERT INTO
	char_data_types
VALUES
	('abc', 'abc', 'abc'),
	('defghi', 'defghi', 'defghi');

COPY char_data_types TO 'D:\SQL\typetest.txt'
WITH
	(FORMAT CSV, HEADER, DELIMITER '|');

SELECT * FROM char_data_types;

-- 3.2

CREATE TABLE number_data_types (
	numeric_column numeric(20, 5),
	real_column real,
	double_column double precision
);

INSERT INTO number_data_types
VALUES 
	(.7, .7, .7),
	(2.13579, 2.13579, 2.13579),
    (2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;

-- 3.3

SELECT
	numeric_column * 10000000 AS "Fixed",
	real_column * 10000000 AS "Float"
FROM number_data_types
WHERE numeric_column = .7;

-- 3.4

CREATE TABLE date_time_types (
	timestamp_column timestamp with time zone,
	interval_column interval
);

INSERT INTO date_time_types 
VALUES 
    ('2018-12-31 01:00 EST','2 days'),
    ('2018-12-31 01:00 -8','1 month'),
    ('2018-12-31 01:00 Australia/Melbourne','1 century'),
 	(now(),'1 week');

SELECT * FROM date_time_types;

-- 3.5

SELECT
	timestamp_column,
	interval_column,
	timestmp_column - interval_column AS new_date
FROM
	date_time_types;

-- 3.6

SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT numeric_column, 
       CAST(numeric_column AS integer), 
       CAST(numeric_column AS varchar(6)) 
FROM number_data_types; 

SELECT CAST(char_column AS integer) FROM char_data_types;


