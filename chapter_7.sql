--- Chapter 7 Exercises
-- 7.1
--- Column CONSTRAINT vs Table CONSTRAINT
CREATE TABLE natural_key_example (
	license_id varchar(10) CONSTRAINT lisence_key PRIMARY KEY,
	first_name varchar(50),
	last_name varchar(50)
);

DROP TABLE natural_key_example;

-- Works better when you have a composite primary key(multiple columns)
CREATE TABLE natural_key_example (
    license_id varchar(10),
    first_name varchar(50),
    last_name varchar(50),
	CONSTRAINT license_key PRIMARY KEY (license_id)
);

-- 7.2
-- Showing how the primary key prevents duplicate data inserts 
INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Sam', 'Tracy');

-- 7.3
-- Creating composite keys if a single column does not meet your requirements for a primary key 
--- Essentially 2 keys working together as one 
CREATE TABLE natural_key_composite_example (
    student_id varchar(10),
    school_day date,
    present boolean,
    CONSTRAINT student_key PRIMARY KEY (student_id, school_day)   
);

SELECT * FROM natural_key_composite_example;

-- 7.4
INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '2017/1/22', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '2017/1/23', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '2017/1/23', 'N');

SELECT CURRENT_TIMESTAMP; 

-- 7.5
--- Auto Incrementing surrogate key
CREATE TABLE surrogate_key_example (
 	order_number bigserial, --*
    product_name varchar(50),
    order_date date,
 	CONSTRAINT order_key PRIMARY KEY (order_number)   
);

INSERT INTO surrogate_key_example (product_name, order_date)
 	VALUES ('Beachball Polish', '2015-03-17'),
       		('Wrinkle De-Atomizer', '2017-05-22'),
       		('Flux Capacitor', '1985-10-26');
 
SELECT * FROM surrogate_key_example;

-- 7.6
--- Foreign Key example
CREATE TABLE licenses (
    license_id varchar(10),
    first_name varchar(50),
    last_name varchar(50),
 	CONSTRAINT licenses_key PRIMARY KEY (license_id)
);

INSERT INTO licenses (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

SELECT * FROM licenses;

CREATE TABLE registrations (
    registration_id varchar(10),
    registration_date date,
 	license_id varchar(10) REFERENCES licenses (license_id),
    CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);
 
INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A203391', '2017/3/17', 'T229901');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A75772', '2017/3/17', 'T000001');

SELECT * FROM registrations, licenses;

-- 7.7
--- CHECK Constriant
CREATE TABLE check_constraint_example (
    user_id bigserial,
    user_role varchar(50),
    salary integer,
    CONSTRAINT user_id_key PRIMARY KEY (user_id),
	CONSTRAINT check_role_in_list CHECK (user_role IN('Admin', 'Staff')),
 	CONSTRAINT check_salary_not_zero CHECK (salary > 0)
);


-- 7.8 
--- UNIQUE Constraint
CREATE TABLE unique_constraint_example (
    contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY,  
    first_name varchar(50),
    last_name varchar(50), 
    email varchar(200),
 	CONSTRAINT email_unique UNIQUE (email)   
);

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Samantha', 'Lee', 'slee@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Betty', 'Diaz', 'bdiaz@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Sasha', 'Lee', 'slee@example.org');

SELECT * FROM unique_constraint_example;

-- 7.9
--- NOT NULL Constraint
CREATE TABLE not_null_example (
    student_id bigserial,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    CONSTRAINT student_id_key PRIMARY KEY (student_id)
);

-- 7.10
-- Alter table examples
ALTER TABLE not_null_example DROP CONSTRAINT student_id_key;
ALTER TABLE not_null_example ADD CONSTRAINT student_id_key PRIMARY KEY (student_id);
ALTER TABLE not_null_example ALTER COLUMN first_name DROP NOT NULL;
ALTER TABLE not_null_example ALTER COLUMN first_name SET NOT NULL;

-- 7.11
CREATE TABLE new_york_addresses (
    longitude numeric(9,6),
    latitude numeric(9,6),
    street_number varchar(10),
    street varchar(32),
    unit varchar(7),
    postcode varchar(5),
    id integer CONSTRAINT new_york_key PRIMARY KEY
);

COPY new_york_addresses
FROM 'D:\SQL\external_data\city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM new_york_addresses;

-- 7.12
--- Benchmarking query performance
EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';

-- 7.13
--- Creating an index and comparing results to 7.12's output
CREATE INDEX street_idx ON new_york_addresses (street);

DROP INDEX street_idx;
