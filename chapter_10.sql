-- Chapter 10 Exercises

-- 10.1
--- Create Census 2011-2015 ACS 5-Year stats table and import data

CREATE TABLE acs_2011_2015_stats (
    geoid varchar(14) CONSTRAINT geoid_key PRIMARY KEY,
    county varchar(50) NOT NULL,
    st varchar(20) NOT NULL,
    pct_travel_60_min numeric(5,3) NOT NULL,
    pct_bachelors_higher numeric(5,3) NOT NULL,
    pct_masters_higher numeric(5,3) NOT NULL,
    median_hh_income integer,
    CHECK (pct_masters_higher <= pct_bachelors_higher) -- Ensures that the value in pct_masters_higher is always less than or equal to the value in pct_bachelors_higher
);

COPY acs_2011_2015_stats
FROM 'D:\SQL\external_data\acs_2011_2015_stats.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM acs_2011_2015_stats;

-- 10.2
--- Using corr(Y, X) to measure the relationship between education and income
---- corr(Y, X) is a binary aggregate function, Y is the dependant variable and X is the independant variable
---- meaning that the dependant variable's variation is dependant on the value of another variable whereas the independant variable is not dependant on the other variable
SELECT corr(median_hh_income, pct_bachelors_higher) 
	AS bachelors_income_r
FROM acs_2011_2015_stats;

-- 10.3
--- Checking correlation between other variables 
SELECT
 	round(
      corr(median_hh_income, pct_bachelors_higher)::numeric, 2 -- Casting to numeric type and rounding to two decimal places
      ) AS bachelors_income_r,
    round(
      corr(pct_travel_60_min, median_hh_income)::numeric, 2
      ) AS income_travel_r,
    round(
      corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_travel_r
FROM acs_2011_2015_stats;

-- 10.4
--- Regression slope and intercept functions
SELECT
    round(
        regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2 -- regr_slope indicates the AMOUNT median household income will increase when having a bachelor's degree
        ) AS slope,
    round(
        regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2 -- regr_intercept provides the baseline income level when no one has a bachelor's degree, helping to position the regression line visually on a graph
        ) AS y_intercept
FROM acs_2011_2015_stats;

-- 10.5
--- Calculating the coefficient of determination, or r-squared
---- In this case reg_r2 indicates that 47% of the variation in the median household income can be attributed to a bachelor's or higher
SELECT round(
       regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3
        ) AS r_squared 
FROM acs_2011_2015_stats;

-- Bonus: Additional stats functions.
-- Shows variance in houselhold income
--- In this case there is a high variance
SELECT var_pop(median_hh_income)
FROM acs_2011_2015_stats;

-- Standard deviation of the entire population
--- This number gives you an idea of how much household incomes differ from the average income
SELECT stddev_pop(median_hh_income)
FROM acs_2011_2015_stats;

-- Covariance
--- This tells you if there's a relationship between education level and income
SELECT covar_pop(median_hh_income, pct_bachelors_higher)
FROM acs_2011_2015_stats;

-- 10.6
--- rank() and dense_rank() are window functions, which perform calculations across sets of rows we specify using the OVER clause
CREATE TABLE widget_companies (
    id bigserial,
    company varchar(30) NOT NULL,
    widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
    ('Morse Widgets', 125000),
    ('Springfield Widget Masters', 143000),
    ('Best Widgets', 196000),
    ('Acme Inc.', 133000),
    ('District Widget Inc.', 201000),
    ('Clarke Amalgamated', 620000),
    ('Stavesacre Industries', 244000),
    ('Bowers Widget Emporium', 201000);

SELECT
    company,
    widget_output,
    rank() OVER (ORDER BY widget_output DESC),
    dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies;

-- 10.7
--- Applying rank() within groups using PARTITION BY
---- PARTITION BY allows us to rank per category, in this case by beer, cereal and ice cream, indicating which stores sold the most of each product
CREATE TABLE store_sales (
    store varchar(30),
    category varchar(30) NOT NULL,
    unit_sales bigint NOT NULL,
    CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
    ('Broders', 'Cereal', 1104),
    ('Wallace', 'Ice Cream', 1863),
    ('Broders', 'Ice Cream', 2517),
    ('Cramers', 'Ice Cream', 2112),
    ('Broders', 'Beer', 641),
    ('Cramers', 'Cereal', 1003),
    ('Cramers', 'Beer', 640),
    ('Wallace', 'Cereal', 980),
    ('Wallace', 'Beer', 988);

SELECT
    category,
    store,
    unit_sales,
    rank() OVER (PARTITION BY category ORDER BY unit_sales DESC)
FROM store_sales;

-- 10.8
--- Creating and filling a 2015 FBI crime data table
CREATE TABLE fbi_crime_data_2015 (
    st varchar(20),
    city varchar(50),
    population integer,
    violent_crime integer,
    property_crime integer,
    burglary integer,
    larceny_theft integer,
    motor_vehicle_theft integer,
    CONSTRAINT st_city_key PRIMARY KEY (st, city)
);

COPY fbi_crime_data_2015
FROM 'D:\SQL\external_data\fbi_crime_data_2015.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM fbi_crime_data_2015
ORDER BY population DESC;

-- 10-9 
--- Looking at property crime rates per thousand in cities with 500,000 or more people
SELECT
    city,
    st,
    population,
    property_crime,
    round(
        (property_crime::numeric / population) * 1000, 1
        ) AS pc_per_1000
FROM fbi_crime_data_2015
WHERE population >= 500000
ORDER BY (property_crime::numeric / population) DESC; 