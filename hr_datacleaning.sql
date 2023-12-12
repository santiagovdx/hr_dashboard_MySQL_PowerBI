CREATE DATABASE IF NOT EXISTS hr_project;

-- We create the database where we will store the table with 
-- the data

CREATE TABLE IF NOT EXISTS hr (
	id TEXT,
	first_name TEXT,
	last_name TEXT,
	birthdate TEXT,
	gender TEXT,
	race TEXT,
	department TEXT,
	jobtitle TEXT,
	location TEXT,
	hire_date TEXT,
	termdate TEXT,
	location_city TEXT,
	location_state TEXT
	)

-- We create a table with all the fields found in the csv file, in the same order,
-- and with the datatype TEXT to ensure that we start off the cleaning process 
-- from 0

COPY hr FROM '/users/svd/desktop/human_resources.csv'
WITH (FORMAT CSV, HEADER);

-- We use the COPY FROM command to import the data in the csv file into the newly
-- created table "hr"

SELECT * FROM hr; 

-- We get all 22,214 rows from the human_resources csv file

/* DATA CLEANING */

ALTER TABLE hr
RENAME COLUMN id TO employee_id;

-- Change the name of the id column

ALTER TABLE hr
ALTER COLUMN employee_id TYPE VARCHAR(20);

-- Change the datatype of the new employee_id column

ALTER TABLE hr
ALTER COLUMN employee_id SET NOT NULL;

-- employee_id acts as the PK therefore we apply the NOT NULL constraint to it

SELECT
	column_name,
	data_type,
	is_nullable
FROM information_schema.columns
WHERE table_name = 'hr';

-- We check the columns to see that the changes have been applied

UPDATE hr
SET birthdate = 
	CASE
		WHEN birthdate LIKE '%/%' THEN TO_DATE(birthdate, 'MM/DD/YYYY')
		WHEN birthdate LIKE '%-%' THEN TO_DATE(birthdate, 'YYYY-MM-DD')
		WHEN birthdate LIKE '%-%' THEN TO_DATE(birthdate, 'MM-DD-YYYY')
		ELSE NULL
		END;

-- The format of the birthdate column follows different conventions
-- having the date elements (year, month, day) ordered differently,
-- so with the CASE statement we set the birthdate to follow the
-- standard SQL format of 'YYYY-MM-DD' when the string has a '/'
-- and the format of the string is 'MM/DD/YYYY', and for the string
-- with '-' and format of the string is 'YYYY-MM-DD'. The are also
-- a few string with '-' and format 'MM-DD-YYYY' so we use a statement
-- for those values as well.

ALTER TABLE hr
ALTER COLUMN birthdate TYPE DATE USING birthdate::DATE;

-- Now that the birthdate values are properly formatted we convert
-- the values to a DATE datatype

UPDATE hr 
SET birthdate = (birthdate + INTERVAL '1900 years')
WHERE EXTRACT(year FROM birthdate) < 1900;

-- Postgres intepretation of dates and handling of two digit formats 
-- for year is causing the year in birthdates that start with '00' to be 
-- interpret as the actual year with two digits thus yielding years 
-- between 0 and 100. To solve this problem we add 1900 years to this 
-- dates to bring them to the 20th century.

UPDATE hr
SET birthdate = (birthdate + INTERVAL '100 years')
WHERE EXTRACT(year FROM birthdate) <=1903;

-- Since there are people who were born in the 2000's we add an extra 
-- 100 years to their birthdates. Now everyone has the correct birthdate

UPDATE hr
SET hire_date = 
	CASE 
		WHEN hire_date LIKE '%/%' THEN TO_DATE(hire_date, 'MM/DD/YYYY')
		ELSE NULL
		END;

-- For the hire_date column the same case applies as in the birthdate
-- column

ALTER TABLE hr
ALTER COLUMN hire_date TYPE DATE USING hire_date::date;

UPDATE hr
SET hire_date = (hire_date + INTERVAL'2000 years')
WHERE EXTRACT(year FROM hire_date) < 2000;

-- Since the company data is for people who begin getting hired
-- in 2000 we also add years to their hire_date, just like we did
-- with the birthdates

UPDATE hr
SET termdate = TO_DATE(termdate, 'YYYY-MM-DD HH24:MI:SS UTC')
WHERE termdate IS NOT NULL;

-- Now we update the termdate which has a timestamp format by converting 
-- the values into a valid date format, but only those where the values 
-- meet the condition

ALTER TABLE hr
ALTER COLUMN termdate TYPE DATE USING termdate::DATE;

-- Now we convert the termdate values into a date datatype

ALTER TABLE hr
ADD COLUMN age INT;

-- We add a new age column

UPDATE hr
SET age = EXTRACT(year FROM AGE(CURRENT_DATE, birthdate));

-- We calculate the age of each person and add it to the newly created age 
-- column