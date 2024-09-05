-- Chapter 13 Exercises 
--- Case formatting
SELECT upper('Neal7');
SELECT lower('Randy');
SELECT initcap('at the end of the day');
-- Note initcap's imperfect for acronyms
SELECT initcap('Practical SQL');

-- Character Information
SELECT char_length(' Pat ');
SELECT length(' Pat ');
SELECT position(', ' in 'Tan, Bella');

-- Removing characters
SELECT trim('s' from 'socks');
SELECT trim(trailing 's' from 'socks');
SELECT trim(' Pat ');
SELECT char_length(trim(' Pat ')); -- note the length change
SELECT ltrim('socks', 's');
SELECT rtrim('socks', 's');

-- Extracting and replacing characters
SELECT left('703-555-1212', 3); -- Syntax (string, number)
SELECT right('703-555-1212', 8); -- Syntax (string, number)
SELECT replace('bat', 'b', 'c'); -- Syntax (string, from , to)

-- 13.2.1 
--- Regular Expression Matching Examples

-- Any character one or more times
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '.+');
-- One or two digits followed by a space and p.m.
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{1,2} (?:a.m.|p.m.)');
-- One or more word characters at the start
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '^\w+');
-- One or more word characters followed by any character at the end.
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\w+.$');
-- The words May or June
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from 'May|June');
-- Four digits
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{4}');
-- May followed by a space, digit, comma, space, and four digits.
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from 'May \d, \d{4}');

-- 13.2.2
--- Creating and loading the crime_reports table
CREATE TABLE crime_reports (
    crime_id bigserial PRIMARY KEY,
    date_1 timestamp with time zone,
    date_2 timestamp with time zone,
    street varchar(250),
    city varchar(100),
    crime_type varchar(100),
    description text,
    case_number varchar(50),
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM 'D:\SQL\external_data\crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

SELECT original_text FROM crime_reports;

-- 13.3
--- Using regexp_match() to find the first date
---- regexp_match() returns each match as text in an array and no matches return a NULL
----- regexp_match also returns the first match it finds by default
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;

-- 13.4
--- Using the regexp_matches() function with the 'g' flag
---- In this case when adding the "g" flag the result returns each match in a separate row when having two dates 
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports;

-- 13.5
--- Using regexp_match() to find the second date
---- Note that the result includes an unwanted hyphen
----- Returning only the second date 
SELECT crime_id,
       regexp_match(original_text, '-\d{1,2}\/\d{1,2}\/\d{1,2}')
FROM crime_reports;


-- 13.6
--- Creating a capture group to eliminate the unwanted hyphen
SELECT crime_id,
       regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') 
FROM crime_reports;

-- See book for examples on how to match certain elements of the crime reports

-- 13.7
--- Matching case number, date, crime type, and city
SELECT 
    regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number,
    regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
    regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
    regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n')
        AS city
FROM crime_reports;

---- Extracting text from the regexp_match() result

-- 13.8
--- Retrieving a value from within an array
---- Extracting the case numbers from the returned array created by the regexp_match function 
SELECT
    crime_id,
    (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1]
        AS case_number
FROM crime_reports;

-- 13.9
--- Updating the crime_reports date_1 column
UPDATE crime_reports
SET date_1 = 
(
    (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] -- Matching the first date 
        || ' ' || -- Using the concatenation operator to concatenate the date and time into a suitable format for Postgre to handle 
    (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] -- Matching the time of the first date
        ||' US/Eastern' -- Concatenating the timezone
)::timestamptz; -- Then casting to a timestamp data type

SELECT crime_id,
       date_1,
       original_text
FROM crime_reports;

SET datestyle = "ISO, MDY"; -- Changed date style 

-- 13.10
--- Updating all crime_reports columns
UPDATE crime_reports
SET date_1 = 
    (
      (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]
          || ' ' ||
      (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] 
          ||' US/Eastern'
    )::timestamptz,
             
    date_2 = 
    CASE 
    -- The WHEN statement checks if there is no second date but there is a second hour, if that is true it will concatenate both values 
        WHEN (SELECT regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') IS NULL)
                     AND (SELECT regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL)
        THEN 
          ((regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]
              || ' ' ||
          (regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1] 
              ||' US/Eastern'
          )::timestamptz 

    -- If there is both a second date and second hour
        WHEN (SELECT regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') IS NOT NULL)
              AND (SELECT regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL)
        THEN 
          ((regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})'))[1]
              || ' ' ||
          (regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1] 
              ||' US/Eastern'
          )::timestamptz 
    -- If neither of those conditions exist, provide a NULL
        ELSE NULL 
    END,
    street = (regexp_match(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))'))[1],
    city = (regexp_match(original_text,'(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n'))[1],
    crime_type = (regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):'))[1],
    description = (regexp_match(original_text, ':\s(.+)(?:C0|SO)'))[1],
    case_number = (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1];

-- 13.11
--- Viewing selected crime data
SELECT date_1,
       street,
       city,
       crime_type
FROM crime_reports;

-- 13.12
--- Using regular expressions in a WHERE clause
SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '(.+lade.+|.+lare.+)' -- ~* is a case insensitive match
ORDER BY geo_name;

SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '.+ash.+' AND geo_name !~ 'Wash.+' -- Adding the (!~) negated tilde to exclude counties staring with "Wash"
ORDER BY geo_name;

-- 13.13
--- Regular expression functions to replace and split

SELECT regexp_replace('05/12/2018', '\d{4}', '2017');

SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

SELECT regexp_split_to_array('Phil Mike Tony Steve', ' ');

-- 13.14
--- Finding an array length
SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);

-- 13.15
--- to_tsvector create lexemes which are units of meaning in language
---- It eliminates unnecessary stop words as well as prefixes and suffixes 
---- to_tsvector also orders the words alphabetically when returned and notes their positions in the original string  
SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- 13.16 
--- Converting search terms to tsquery data
SELECT to_tsquery('walking & sitting');

-- 13.17 
--- Querying a tsvector type with a tsquery
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & sitting');
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & running');

-- 13.18
--- Creating and filling the president_speeches table
CREATE TABLE president_speeches (
    sotu_id serial PRIMARY KEY,
    president varchar(100) NOT NULL,
    title varchar(250) NOT NULL,
    speech_date date NOT NULL,
    speech_text text NOT NULL,
    search_speech_text tsvector
);

COPY president_speeches (president, title, speech_date, speech_text)
FROM 'D:\SQL\external_data\sotu-1946-1977.csv'
WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@');

SELECT * FROM president_speeches;

-- 13.19
--- Converting speeches to tsvector in the search_speech_text column
UPDATE president_speeches
SET search_speech_text = to_tsvector('english', speech_text);

-- 13.20
--- Creating a GIN index for text searchs
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);

-- 13.21 
--- Finding speeches containing the word "Vietnam"
SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;

-- 13.22
--- Displaying search results with ts_headline()
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('Vietnam'),
                   'StartSel = <, -- StartSel and StopSel will encapsulate the word Vietnam in this case, but can be specified to any word you choose
                    StopSel = >, 
                    MinWords=5, -- Min/MaxWords defines the amount of words before and after Start/StopSel, in this case after Vietnam
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam'); -- Filtering speeches that only include the word "Vietnam", the @@ is checking if the result from to_tsquery matches search_speech_text column 

-- 13.23
--- Finding speeches with the word "transportation" but not "roads"
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('transportation & !roads'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('transportation & !roads');

-- 13.24
--- Find speeches where "defense" follows "military"
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('military <-> defense'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <-> defense');

--Example with a distance of 2:
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('military <2> defense'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=2')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <2> defense');

-- 13.25
--- Scoring relevance with ts_rank()
---- ts_rank() determines the relevance of your search criteria by determining how often your preferred search word(lexemes) appears in whatever text you are searching
----- ts_rank_cd() considers how close the lexemes searched are to each other
SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('war & security & threat & enemy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;

-- 13.26
--- Normalizing ts_rank() by speech length
---- Comparing the freqeuncy of the following words by taking into account the length of the various speeches for a more accurate representation
SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('war & security & threat & enemy'), 2)::numeric 
               AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;


