-- Chapter 17 Exercises

-- 17.1
--- Creating a table to test vacuuming
CREATE TABLE vacuum_test (
    integer_column integer
);

-- 17.2 
--- Determining the size of the vacuum_test table
SELECT pg_size_pretty(
           pg_total_relation_size('vacuum_test')
		);

--- Determine database size   
SELECT pg_size_pretty(
           pg_database_size('analysis')
       );

-- 17.3
--- Inserting 500,000 rows into the vacuum_test table
INSERT INTO vacuum_test
SELECT * FROM generate_series(1,500000);

--- Testing table size after adding rows
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

-- 17.4
--- Updating all rows in vacuum_test table
UPDATE vacuum_test
SET integer_column = integer_column + 1;

-- 17.5
--- Viewing autovacuum statistics for the vacuum_test table
SELECT relname,
       last_vacuum,
       last_autovacuum,
       vacuum_count,
       autovacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- 17.6
--- To see all columns available
SELECT *
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- 17.7
--- Using VACUUM FULL to reclaim disk space
VACUUM FULL vacuum_test;

-- Test its size again
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

--- SETTINGS ---

-- 17.8
SHOW config_file;

-- 17.9
--- Only shows a sample of you could change in the config file

-- 17.10
--- Show the location of the data directory
SHOW data_directory;