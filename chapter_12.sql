-- Chapter 12 Exercises
-- Subqueries
-- Derived Tables
-- CTE's
-- Cross Tabulations
-- Using CASE

-- 12.1 
--- Using a subquery in a WHERE clause
---- Showing which U.S. counties are at or above the 90th percentile for population size
SELECT geo_name,
       state_us_abbreviation,
       p0010001
FROM us_counties_2010
WHERE p0010001 >= (
    SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001) -- Subquery to calculate 90th percentile
    FROM us_counties_2010
    )
ORDER BY p0010001 DESC;

-- 12.2
--- Using a subquery in a WHERE clause for DELETE
---- Making a copy of the census table and then deleting everything from that backup except the 315 counties in the 90th percentile of population
CREATE TABLE us_counties_2010_top10 AS
SELECT * FROM us_counties_2010;

DELETE FROM us_counties_2010_top10
WHERE p0010001 < (
    SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
    FROM us_counties_2010_top10
);

SELECT count(*) FROM us_counties_2010_top10;

-- 12.3
--- Subquery as a derived table in a FROM clause
---- Finding the average and median population of U.S. counties as well as the difference between them
SELECT round(calcs.average, 0) as average,
       calcs.median,
       round(calcs.average - calcs.median, 0) AS median_average_diff
FROM (
     SELECT avg(p0010001) AS average, -- Subquery 
            percentile_cont(.5)
                WITHIN GROUP (ORDER BY p0010001)::numeric(10,1) AS median
     FROM us_counties_2010
     )
AS calcs; -- Name of the subquery

-- 12.4
--- Joining two derived tables
---- Calculating the amount of processing plants per million people of each state 
SELECT census.state_us_abbreviation AS st,
       census.st_population,
       plants.plant_count,
       round((plants.plant_count/census.st_population::numeric(10,1)) * 1000000, 1)
           AS plants_per_million
FROM
    (
         SELECT st,
                count(*) AS plant_count -- Subquery
         FROM meat_poultry_egg_inspect -- Counting total processing plants per state
         GROUP BY st
    )
    AS plants
JOIN  -- Joining the derived tables from the 2 subqueries
    (
        SELECT state_us_abbreviation,
               sum(p0010001) AS st_population -- Subquery
        FROM us_counties_2010 				   -- Calculating the population per state
        GROUP BY state_us_abbreviation
    )
    AS census
ON plants.st = census.state_us_abbreviation
ORDER BY plants_per_million DESC;

-- 12.5
--Generating a column with  subquery 
---  Adding a subquery to a column list
---- Adding the U.S. median population per county to the table via a subquery
SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) ---*Book*--- You can also generate new columns of data with subqueries by placing a 
		FROM us_counties_2010) AS us_median							---* subquery in the column list after SELECT    
FROM us_counties_2010;

-- 12.6 
--- Using a subquery expression in a calculation
---- Calculating the deviation between the county median and that of all thes states combined median
SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
        FROM us_counties_2010) AS us_median,
       p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
                   FROM us_counties_2010) AS diff_from_median
FROM us_counties_2010
WHERE (p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
                   FROM us_counties_2010))
BETWEEN -1000 AND 1000;

--*** EXISTS is a type of subquery and is a true/false test***---

-- 12.7
--- Using a simple CTE(Common Table Expression) to find large counties
---- The code determines how many counties in each state have 100,000 people or more
WITH
    large_counties (geo_name, st, p0010001) -- Creating the temporary table, there is no need to define data types as it will be inherited from the main table
AS
    (
        SELECT geo_name, state_us_abbreviation, p0010001
        FROM us_counties_2010
        WHERE p0010001 >= 100000
    )
SELECT st, count(*)
FROM large_counties
GROUP BY st
ORDER BY count(*) DESC;

-- You can also write this query as:
SELECT state_us_abbreviation, count(*)
FROM us_counties_2010
WHERE p0010001 >= 100000
GROUP BY state_us_abbreviation
ORDER BY count(*) DESC;

-- 12.8
--- Using CTEs in a table join
---- Rewriting the example of 12.4 when joining derived tables to be more readable
WITH
    counties (st, population) AS
    (SELECT state_us_abbreviation, sum(population_count_100_percent) -- Calculating total population per state
     FROM us_counties_2010
     GROUP BY state_us_abbreviation),

    plants (st, plants) AS
    (SELECT st, count(*) AS plants -- Counting all processing plants and grouping by state
     FROM meat_poultry_egg_inspect
     GROUP BY st)

SELECT counties.st,
       population,
       plants,
       round((plants/population::numeric(10,1))*1000000, 1) AS per_million
FROM counties JOIN plants
ON counties.st = plants.st
ORDER BY per_million DESC;

-- 12.9
--- Using CTEs to minimize redundant code
---- Rewriting 12.6 to be less redundant by using percentile_cont only once
WITH us_median AS 
    (SELECT percentile_cont(.5) 
     WITHIN GROUP (ORDER BY p0010001) AS us_median_pop
     FROM us_counties_2010)

SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       us_median_pop,
       p0010001 - us_median_pop AS diff_from_median 
FROM us_counties_2010 CROSS JOIN us_median
WHERE (p0010001 - us_median_pop)
       BETWEEN -1000 AND 1000;
---CROSS TABULATIONS---
CREATE EXTENSION tablefunc;

-- 12.10 
--- Creating and filling the ice_cream_survey table
CREATE TABLE ice_cream_survey (
    response_id integer PRIMARY KEY,
    office varchar(20),
    flavor varchar(20)
);

COPY ice_cream_survey
FROM 'D:\SQL\external_data\ice_cream_survey.csv'
WITH (FORMAT CSV, HEADER);

SELECT * 
FROM ice_cream_survey
LIMIT 5;

-- 12.11
--- Generating the ice cream survey crosstab
---- Cross tabulations are used to to simplify or summarize data and compare variables by displaying them in a table
SELECT *
FROM crosstab('SELECT office, -- Supplies the row names 
                      flavor, -- Supplies the category columns(in terms of values)
                      count(*) -- Supplies the intersect count of offices and categories
               FROM ice_cream_survey
               GROUP BY office, flavor
               ORDER BY office',
										-- The crosstab function requires this subquery to return only 1 column
              'SELECT flavor 
               FROM ice_cream_survey
               GROUP BY flavor -- GROUP BY is used to return unique values of the flavor column 
               ORDER BY flavor')

AS (office varchar(20),
    chocolate bigint,
    strawberry bigint,
    vanilla bigint);

-- 12.12
--- Creating and filling a temperature_readings table
CREATE TABLE temperature_readings (
    reading_id bigserial PRIMARY KEY,
    station_name varchar(50),
    observation_date date,
    max_temp integer,
    min_temp integer
);

COPY temperature_readings 
     (station_name, observation_date, max_temp, min_temp)
FROM 'D:\SQL\external_data\temperature_readings.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM  temperature_readings;

-- 12.13
--- Generating the temperature readings crosstab
SELECT *
FROM crosstab('SELECT
                  station_name,
                  date_part(''month'', observation_date), -- Extracting the month from observation_date using the date_part() function
                  percentile_cont(.5)					   -- Determining the maximum median temp for each month using percentile_cont()
                      WITHIN GROUP (ORDER BY max_temp)
               FROM temperature_readings
               GROUP BY station_name,
                        date_part(''month'', observation_date)
               ORDER BY station_name',

              'SELECT month
               FROM generate_series(1,12) month')

AS (station varchar(50),
    jan numeric(3,0),
    feb numeric(3,0),
    mar numeric(3,0),
    apr numeric(3,0),
    may numeric(3,0),
    jun numeric(3,0),
    jul numeric(3,0),
    aug numeric(3,0),
    sep numeric(3,0),
    oct numeric(3,0),
    nov numeric(3,0),
    dec numeric(3,0)
);

-- 12.14
--- Re-classifying temperature data with CASE
---- CASE allows you to employ if... then... logic and is good for reclassifying data into certain categories 
SELECT max_temp,
       CASE WHEN max_temp >= 90 THEN 'Hot'
            WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
            WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
            WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
            WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
            ELSE 'Inhumane'
        END AS temperature_group
FROM temperature_readings;

-- 12.15
--- Using CASE in a Common Table Expression
WITH temps_collapsed (station_name, max_temperature_group) AS
    (SELECT station_name,
           CASE WHEN max_temp >= 90 THEN 'Hot'
                WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
                WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
                WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
                WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
                ELSE 'Inhumane'
            END
    FROM temperature_readings)

SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, count(*) DESC;