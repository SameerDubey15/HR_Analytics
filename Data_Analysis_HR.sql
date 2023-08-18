CREATE DATABASE projects_hr;

USE projects_hr;

# Remaning the table name
RENAME TABLE `human resources` TO hr;

SELECT * FROM hr;

-- DATA CLEANING AND PREPROCESSING

-- Correcting format of id column

# Changing name of id column
ALTER TABLE hr
CHANGE ï»¿id emp_id VARCHAR(20) NULL;

# Removing '-' and Converting into int
UPDATE hr
SET emp_id=REPLACE(emp_id,'-','');

ALTER TABLE hr
MODIFY emp_id INT;

DESC hr;
/* We can see that all the columns are in the 
form of text so we have to change type of columns */

-- Correcting format of birthdate

# We can see that birthdate is in the form of / or -
# Remove safe mode
#SET sql_safe_updates = 0;
UPDATE hr
SET birthdate = CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
ALTER TABLE hr
MODIFY birthdate DATE;

-- Correcting format of hire_date

UPDATE hr
SET hire_date = CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
		END;
        
ALTER TABLE hr
MODIFY hire_date DATE;

desc hr;

-- Correcting format of hire_date

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

# Filling null value in empty space
UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- Creating age column

ALTER TABLE hr
ADD age INT(3);

#Adding values in age column
update hr
SET age=timestampdiff(YEAR,birthdate,curdate());

-- Checking for null values
SELECT * from hr
where last_name is NULL;
# No null values present


/* Cleaning of dataset is completed.
 We can not start analysing it*/


-- ANALYSING DATASET

-- Q1- What is the gender breakdown of current employees in the company?
SELECT gender,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- Q2- What is the race breakdown of current employees in the company?
SELECT race,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY race;

-- Q3- What is the age distribution of employees in the company?
SELECT 
	CASE
		WHEN age>=18 AND age<=24 THEN 'Too Young adult'
        WHEN age>=25 AND age<=34 THEN 'Young adult'
        WHEN age>=35 AND age<=44 THEN 'Younger middle-aged adult'
        WHEN age>=45 AND age<=54 THEN 'Middle-aged adult'
        WHEN age>=55 AND age<=64 THEN 'Pre-retirement	'
        ELSE 'Older adult'
	END AS age_group,
    COUNT(*) AS count
    FROM hr
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group;

-- Q4- How many employees work at HQ vs remote?
SELECT location,Count(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY location;

-- Q5- What is the average length of employement who have been teminated?
SELECT ROUND(AVG(YEAR(termdate) - YEAR(hire_date)),0) as length_of_employemnt
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate();

-- Q6- How does the gender distribution vary acorss dept. and job titles?
SELECT department, jobtitle, gender, count(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender;

-- Q7- What is the distribution of jobtitles acorss the company
SELECT jobtitle, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY jobtitle;

-- Q8- Which dept has the higher turnover/termination rate
SELECT department,
		COUNT(*) AS total_count,
        COUNT(CASE
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
                    END)/COUNT(*))*100,2) AS termination_rate
		FROM hr
        GROUP BY department
        ORDER BY termination_rate DESC;
        
-- 9. What is the distribution of employees across location_state
SELECT location_state, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY location_state;

-- 10. How has the companys employee count changed over time based on hire and termination date.
SELECT year,
		hires,
        terminations,
        hires-terminations AS net_change,
        (terminations/hires)*100 AS change_percent
	FROM(
			SELECT YEAR(hire_date) AS year,
            COUNT(*) AS hires,
            SUM(CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 
				END) AS terminations
			FROM hr
            GROUP BY YEAR(hire_date)) AS subquery
GROUP BY year
ORDER BY year;

-- 11. What is the tenure distribution for each dept.
SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<= curdate()
GROUP BY department;

