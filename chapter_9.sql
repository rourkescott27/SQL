-- Chapter 9 Exercises
-- 9.1
CREATE TABLE meat_poultry_egg_inspect (
    est_number varchar(50) CONSTRAINT est_number_key PRIMARY KEY,
    company varchar(100),
    street varchar(100),
    city varchar(30),
    st varchar(2),
    zip varchar(5),
    phone varchar(14),
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_inspect
FROM 'D:\SQL\external_data\MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

CREATE INDEX company_idx ON meat_poultry_egg_inspect (company);

SELECT count(*) FROM meat_poultry_egg_inspect;
SELECT * FROM meat_poultry_egg_inspect;

-- 9.2
--- Finding multiple companies at the same address
SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_inspect
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;

-- 9.3
--- Tallying the number of times US states/territories appear in the table using count()
---- Show null value in row 57
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_inspect
GROUP BY st
ORDER BY st;

-- 9.4
--- Using NULL to find missing values 
SELECT est_number,
       company,
       city, 
       st,
       zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;

-- 9.5
--- Using GROUP BY and count() to find inconsistent company names
SELECT company, 
       count(*) AS company_count
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company ASC;

-- 9.6
--- Counting the amount of ZIP codes with 3, 4 and 5 characters
---- ZIP codes with 3 or 4 characters most likely had leading zero's that got erased the main reasons could be that integers cant start with zero's or errors during file consversion
SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;

-- 9.7
--- Filtering with length() to find short zip values
---- Confirming which states have lost leading zero's by filtering with length()
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_inspect
WHERE length(zip) < 5
GROUP BY st 
ORDER BY st ASC;

-- 9.8
--- Creating a backup table before updating 
CREATE TABLE meat_poultry_egg_inspect_backup AS
SELECT * FROM meat_poultry_egg_inspect;

-- Confirming successfull table backup by counting rows of both
SELECT 
    (SELECT count(*) FROM meat_poultry_egg_inspect) AS original,
    (SELECT count(*) FROM meat_poultry_egg_inspect_backup) AS backup;

-- 9.9
--- Taking extra caution by creating a backup for the st column to prevent data loss
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN st_copy varchar(2);
UPDATE meat_poultry_egg_inspect
SET st_copy = st;

-- 9.10
---  Confirming backup of st colunm
SELECT st,
       st_copy
FROM meat_poultry_egg_inspect
ORDER BY st;

-- 9.11
--- Updating missing data
UPDATE meat_poultry_egg_inspect
SET st = 'MN'
WHERE est_number = 'V18677A';

UPDATE meat_poultry_egg_inspect
SET st = 'AL'
WHERE est_number = 'M45319+P45319';

UPDATE meat_poultry_egg_inspect
SET st = 'WI'
WHERE est_number = 'M263A+P263A+V263A';

-- 9.12 
--- Restoring original st column values

-- Restoring from the column backup
UPDATE meat_poultry_egg_inspect
SET st = st_copy;

-- Restoring from the table backup
UPDATE meat_poultry_egg_inspect original
SET st = backup.st
FROM meat_poultry_egg_inspect_backup backup
WHERE original.est_number = backup.est_number;

-- 9.13
--- Creating a new column to save original company name data in to prevent data loss  
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN company_standard varchar(100);
UPDATE meat_poultry_egg_inspect
SET company_standard = company;

-- 9.14
--- Using UPDATE to modify field values that match a string

---- Correcting company name data in newly created column but keeping old inconsistent data for comparison
UPDATE meat_poultry_egg_inspect
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%';

SELECT company, company_standard
FROM meat_poultry_egg_inspect
WHERE company LIKE 'Armour%';

-- 9.15
--- Creating a new column to save original zip codes when updating
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN zip_copy varchar(5);

UPDATE meat_poultry_egg_inspect
SET zip_copy = zip;

-- 9.16
--- Modifying codes in the zip column that are missing two leading zeros
UPDATE meat_poultry_egg_inspect
SET zip = '00' || zip
WHERE st IN('PR','VI') AND length(zip) = 3;

-- 9.17
--- Modifying codes in the zip column that are missing one leading zero
UPDATE meat_poultry_egg_inspect
SET zip = '0' || zip -- concatenating 
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;

-- Confirming updates by checking length of all zip codes
SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;

-- 9.18
--- Creating and filling a state_regions table

CREATE TABLE state_regions (
    st varchar(2) CONSTRAINT st_key PRIMARY KEY,
    region varchar(20) NOT NULL
);

COPY state_regions
FROM 'D:\SQL\external_data\state_regions.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM state_regions;

-- 9.19
--- Adding and updating an inspection_date column

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN inspection_date date;

UPDATE meat_poultry_egg_inspect inspect
SET inspection_date = '2019-12-01'
WHERE EXISTS (SELECT state_regions.region -- Subquery is matching st to state_regions to update inspection dates in "New England"
              FROM state_regions
              WHERE inspect.st = state_regions.st 
                    AND state_regions.region = 'New England');

-- 9.20
--- Viewing updated inspection_date values
SELECT st, inspection_date 
FROM meat_poultry_egg_inspect
GROUP BY st, inspection_date
ORDER BY st;

-- 9.21
--- DELETING ROWS
---- Deleting establishments that reside outside of the USA
DELETE FROM meat_poultry_egg_inspect
WHERE st IN('PR','VI');

-- 9.22
--- DELETING COLUMN
ALTER TABLE meat_poultry_egg_inspect DROP COLUMN zip_copy;

-- 9.23
--- DROPPING TABLE
DROP TABLE meat_poultry_egg_inspect_backup;

-- 9.24
--- Using a transaction block to check changes before finalizing them
START TRANSACTION; -- Can also be BEGIN

UPDATE meat_poultry_egg_inspect
SET company = 'AGRO Merchantss Oakland LLC'
WHERE company = 'AGRO Merchants Oakland, LLC';

SELECT company
FROM meat_poultry_egg_inspect
WHERE company LIKE 'AGRO%'
ORDER BY company;

ROLLBACK;

-- 9.25
--- Backing up a table while adding and filling a new column
CREATE TABLE meat_poultry_egg_inspect_backup AS
SELECT *,
 	'2018-02-07'::date AS reviewed_date 
FROM meat_poultry_egg_inspect;

-- 9.26
--- Using the ALTER TABLE and RENAME TO, to essentially use the backup created in 9.25 as the original 
ALTER TABLE meat_poultry_egg_inspect RENAME TO meat_poultry_egg_inspect_temp;
ALTER TABLE meat_poultry_egg_inspect_backup 
RENAME TO meat_poultry_egg_inspect;

ALTER TABLE meat_poultry_egg_inspect_temp 
    RENAME TO meat_poultry_egg_inspect_backup;