-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

SELECT 
	gender AS gender, 
	COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT 
	race, 
	COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY race
ORDER BY total DESC;

-- 3. What is the age distribution of employees in the company?

SELECT 
	MAX(age) AS max_age, 
	MIN(age) AS min_age,
	MAX(age) - MIN(age) AS age_range
FROM hr;

WITH bins AS (
SELECT 
	GENERATE_SERIES(20, 55, 5) AS lower_bin,
	GENERATE_SERIES(25, 60, 5) AS upper_bin
	)

SELECT 
	lower_bin,
	upper_bin,
	COUNT(h.age) AS total
FROM bins AS b
LEFT JOIN hr AS h
	ON h.age > b.lower_bin
	AND h.age <= b.upper_bin
	AND h.termdate IS NULL
GROUP BY 
	lower_bin,
	upper_bin
ORDER BY lower_bin;
-----------------------------------
SELECT
	CASE
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
		WHEN age BETWEEN 25 AND 34 THEN '25-34'
		WHEN age BETWEEN 35 AND 44 THEN '35-44'
		WHEN age BETWEEN 45 AND 54 THEN '45-54'
		WHEN age BETWEEN 55 AND 64 THEN '55-64'
		ELSE '65+'
		END AS age_dist,
		COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY age_dist
ORDER BY age_dist;
-----------------------------------
SELECT
	CASE
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
		WHEN age BETWEEN 25 AND 34 THEN '25-34'
		WHEN age BETWEEN 35 AND 44 THEN '35-44'
		WHEN age BETWEEN 45 AND 54 THEN '45-54'
		WHEN age BETWEEN 55 AND 64 THEN '55-64'
		ELSE '65+'
		END AS age_dist,
		gender,
		COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY 
	age_dist,
	gender
ORDER BY age_dist, total DESC;

-- 4. How many employees work at headquarters versus remote locations?

SELECT 
	location,
	COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
	ROUND(AVG(EXTRACT(year FROM AGE(termdate, hire_date))),0) AS avg_length
FROM hr
WHERE termdate IS NOT NULL AND termdate <= CURRENT_DATE;

-- 6. How does the gender distribution vary across departments and job titles?

SELECT
	department,
	jobtitle,
	gender,
	COUNT(*) AS total
FROM hr
GROUP BY 
	department, 
	jobtitle,
	gender
ORDER BY 1, 2, 4 DESC;
	
-- 7. What is the distribution of job titles across the company?

SELECT
	jobtitle,
	COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY total DESC;

-- 8. Which department has the highest turnover rate?

SELECT 
	department,
	ROUND(
		SUM(
			CASE 
				WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE 
				THEN 1 
				ELSE 0
			END
		)::NUMERIC / COUNT(*), 2) AS termination_rate
FROM hr
GROUP BY department
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?

SELECT 
	location_state,
	COUNT(*) AS total
FROM hr
WHERE termdate IS NULL
GROUP BY
	location_state
ORDER BY total DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT
	year,
	hires,
	termination,
	hires - termination AS difference,
	ROUND((hires - termination)::NUMERIC / hires, 2) AS changeover_rate
FROM (
	SELECT
		EXTRACT(year FROM hire_date) AS year,
		COUNT(*) AS hires,
		SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS termination
	FROM hr
	GROUP BY year
	) AS table1
ORDER BY year;

-- 11. What is the tenure distribution for each department?

SELECT
	department,
	ROUND(AVG(EXTRACT(year FROM AGE(termdate, hire_date))),0) AS tenure
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department
ORDER BY tenure DESC;

