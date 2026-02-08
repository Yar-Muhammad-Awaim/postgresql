-- Task 1: Library Book Tracker (Easy)
-- Scenario: Build a simple library database.
-- Create a database library_db
-- Create a table books with: book_id SERIAL PRIMARY KEY, title VARCHAR(150) NOT NULL, author VARCHAR(100), genre VARCHAR(50), price NUMERIC(6,2) CHECK (price > 0), copies_available INT DEFAULT 1, is_available BOOLEAN DEFAULT TRUE, added_on DATE DEFAULT CURRENT_DATE
CREATE TABLE IF NOT EXISTS books (
	book_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	title VARCHAR(150) NOT NULL,
	author VARCHAR(100) NOT NULL,
	genre VARCHAR(50),
	price DECIMAL(6, 2) CHECK (price > 0),
	copies_available INTEGER DEFAULT 1,
	is_available BOOLEAN DEFAULT TRUE,
	added_on date DEFAULT current_date
);

-- Insert 6 books across at least 3 genres
INSERT INTO
	books (
		title,
		author,
		genre,
		price,
		copies_available,
		is_available,
		added_on
	)
VALUES
	(
		'Introduction to Artificial Intelligence',
		'Professor Dr. Jawad Shafi',
		'Tech',
		24.99,
		2000,
		TRUE,
		'2025-09-07'
	),
	(
		'48 Laws of Power',
		'Robert Greene',
		'Self-Growth',
		48.99,
		1000000,
		TRUE,
		'2005-06-07'
	),
	(
		'Seerah of Prophet Muhammad (P.B.U.H.)',
		'Molana Shibli Nomani',
		'Seerah',
		9.99,
		200000,
		TRUE,
		'1980-04-05'
	),
	(
		'Namal',
		'Nimrah Ahmad',
		'Novel',
		8.99,
		23000,
		TRUE,
		'2006-07-08'
	),
	(
		'Jannat ke Patte',
		'Nimrah Ahmad',
		'Fiction',
		9.87,
		0,
		FALSE,
		'2004-08-08'
	),
	(
		'Computer Science for Dummies',
		'Dr. Derek',
		'Curriculum',
		5.99,
		2350,
		TRUE,
		'2002-09-08'
	);

-- SELECT all books sorted by price descending, LIMIT to top 3
SELECT
	*
FROM
	books
ORDER BY
	price DESC
LIMIT
	3;

-- UPDATE one book's price
UPDATE books
SET
	price = 50
WHERE
	book_id = 3;

-- DELETE one book
DELETE FROM books
WHERE
	book_id = 6;

-- See if deletion was successful
SELECT
	*
FROM
	books;

-- Use UPPER(title) and LENGTH(author) in a SELECT
SELECT
	UPPER(title),
	author,
	LENGTH(author) AS length_of_authors_name,
	genre
FROM
	books;

-- Use CASE to label books as 'Affordable' (< 20), 'Mid-Range' (20–40), 'Premium' (> 40)
SELECT
	*,
	CASE
		WHEN price < 20 THEN 'Affordable'
		WHEN price BETWEEN 20 AND 40  THEN 'Mid-Range'
		WHEN price > 40 THEN 'Premium'
	END AS price_range
FROM
	books;

-- Create a VIEW available_books showing only books where is_available = TRUE
CREATE VIEW available_books AS
SELECT
	*
FROM
	books
WHERE
	is_available;

SELECT
	*
FROM
	available_books;