-- Task 2: Employee Directory (Easy)
-- Scenario: HR department needs an employee system.
-- Create database hr_db
CREATE DATABASE hr_db;

-- Create table employees: emp_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, department VARCHAR(50) NOT NULL, salary NUMERIC(10,2) CHECK (salary >= 15000), joining_date DATE, is_active BOOLEAN DEFAULT TRUE
CREATE TABLE employees (
	emp_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	department VARCHAR(50) NOT NULL,
	salary DECIMAL(10, 2) CHECK (salary >= 15000),
	joining_date date DEFAULT current_date,
	is_active BOOLEAN DEFAULT TRUE
);

-- Insert 8 employees across 3+ departments
INSERT INTO
	employees (name, department, salary, joining_date, is_active)
VALUES
	(
		'Dr. Jawad Shafi',
		'Computer Science',
		450000,
		'2005-06-07',
		TRUE
	),
	(
		'Jawad Gilani',
		'Electrical Engineering',
		20000,
		'2004-09-08',
		FALSE
	),
	(
		'Muntaha Iqbal',
		'Software Engineering',
		40000,
		'2020-01-01',
		TRUE
	),
	(
		'Fahad Ali',
		'Artificial Intelligence',
		50000,
		'2019-08-07',
		FALSE
	),
	(
		'Naveed Aslam',
		'Physics',
		80000,
		'2017-08-08',
		TRUE
	),
	(
		'Mohsin Mehdi',
		'Game Development',
		50000,
		'2016-02-12',
		FALSE
	),
	(
		'Fizza Ali',
		'Chemistry',
		78000,
		'2014-09-23',
		TRUE
	),
	(
		'Yar Muhammad Uwaim',
		'Computer Science',
		150000,
		'2024-09-02',
		TRUE
	);

-- Show DISTINCT departments; find AVG salary per department using GROUP BY
SELECT DISTINCT
	department,
	AVG(salary) AS average_salary
FROM
	employees
GROUP BY
	department
ORDER BY
	average_salary DESC;

-- Show departments with average salary > 30000 using HAVING
SELECT DISTINCT
	department,
	AVG(salary) AS average_salary
FROM
	employees
GROUP BY
	department
HAVING
	AVG(salary) > 30000;

-- ALTER table: add column email VARCHAR(100) UNIQUE, rename name to full_name
ALTER TABLE employees
ADD COLUMN email VARCHAR(100) UNIQUE;

-- Use CASE to create a column seniority: 'Senior' if joined before 2015, 'Mid' if 2015–2020, 'Junior' otherwise
SELECT
	*,
	CASE
		WHEN joining_date < '2015-01-01' THEN 'Senior'
		WHEN joining_date BETWEEN '2015-01-01' AND '2020-01-01'  THEN 'Mid'
		ELSE 'Junior'
	END AS seniority
FROM
	employees;

-- Create a PROCEDURE add_employee that inserts a new employee given name, department, salary, and joining_date
CREATE OR REPLACE PROCEDURE add_employee (
	name VARCHAR(100),
	department VARCHAR(50),
	salary DECIMAL(10, 2),
	joining_date date
) LANGUAGE plpgsql AS $$
BEGIN 
	INSERT INTO employees (name, department, salary, joining_date) VALUES (name, department, salary, joining_date);	
END;
$$;

CALL add_employee (
	'Marghoob Ahmad',
	'Humanities',
	90000,
	'2023-09-08'
);

SELECT
	*
FROM
	employees;

-- Create a VIEW active_high_earners showing active employees earning above 100000
CREATE VIEW active_high_earners AS
SELECT
	*
FROM
	employees
WHERE
	is_active
	AND salary >= 100000;

SELECT
	*
FROM
	active_high_earners;