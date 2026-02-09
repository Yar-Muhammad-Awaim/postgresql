-- Task 4: Gym Membership System (Medium)
-- Scenario: A gym needs to track members, their physical profiles, and payment history.
--
-- Store members (name, phone — must be unique, when they joined, whether they're still active).
-- Each member has exactly one profile (weight, height, fitness goal).
-- Each member can make many payments (amount, date, which plan they paid for).
--
-- Your mission:
--
-- Design three tables.
CREATE TABLE IF NOT EXISTS members
(
    member_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         TEXT               NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL CHECK ( LENGTH(phone_number) > 9 ),
    joining_date DATE    DEFAULT CURRENT_DATE,
    is_active    BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS profiles
(
    profile_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id     BIGINT UNIQUE NOT NULL,
    weight        DECIMAL(5, 2) NOT NULL CHECK (weight > 0),
    height        DECIMAL(3, 2) NOT NULL CHECK (height > 0),
    fitness_goals TEXT DEFAULT 'Get in shape and live a healthy life.',
    FOREIGN KEY (member_id) REFERENCES members (member_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments
(
    payment_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id    BIGINT        NOT NULL,
    amount       DECIMAL(7, 2) NOT NULL CHECK (amount >= 0),
    payment_date DATE DEFAULT CURRENT_DATE,
    plan         TEXT          NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members (member_id) ON DELETE CASCADE
);

INSERT INTO members (name, phone_number, joining_date, is_active)
VALUES ('Alice Johnson', '+1234567890', '2024-01-15', TRUE),
       ('Bob Smith', '+1234567891', '2024-02-20', TRUE),
       ('Charlie Brown', '+1234567892', '2024-03-10', TRUE),
       ('Diana Prince', '+1234567893', '2024-04-05', FALSE),
       ('Ethan Hunt', '+1234567894', '2024-05-18', TRUE),
       ('Fiona Green', '+1234567895', '2024-06-22', TRUE),
       ('George Clark', '+1234567896', '2024-07-01', FALSE),
       ('Hannah Lee', '+1234567897', '2024-08-14', TRUE),
       ('Ivan Torres', '+1234567898', '2024-09-30', TRUE),
       ('Julia Adams', '+1234567899', '2024-10-12', TRUE);

INSERT INTO profiles (member_id, weight, height, fitness_goals)
VALUES (1, 65.5, 1.68, 'Lose weight and tone up'),
       (2, 82.3, 1.80, 'Build muscle mass'),
       (3, 74.0, 1.75, 'Get in shape and live a healthy life'),
       (4, 58.2, 1.62, 'Improve flexibility'),
       (5, 90.1, 1.85, 'Train for marathon'),
       (6, 70.4, 1.70, 'Maintain overall fitness'),
       (7, 88.6, 1.78, 'Strength training and conditioning'),
       (8, 55.9, 1.60, 'Yoga and mobility improvement'),
       (9, 79.2, 1.82, 'Body recomposition'),
       (10, 63.7, 1.66, 'Stay active and healthy');

INSERT INTO payments (member_id, amount, payment_date, plan)
VALUES (1, 29.99, '2024-01-15', 'Monthly Basic'),
       (1, 29.99, '2024-02-15', 'Monthly Basic'),
       (1, 49.99, '2024-03-15', 'Monthly Premium'),
       (2, 99.99, '2024-02-20', 'Quarterly Basic'),
       (2, 149.99, '2024-05-20', 'Quarterly Premium'),
       (3, 29.99, '2024-03-10', 'Monthly Basic'),
       (3, 29.99, '2024-04-10', 'Monthly Basic'),
       (4, 49.99, '2024-04-05', 'Monthly Premium'),
       (4, 49.99, '2024-05-05', 'Monthly Premium'),
       (5, 199.99, '2024-05-18', 'Annual Basic'),
       (5, 0.00, '2024-06-18', 'Free Trial Bonus'),
       (6, 29.99, '2024-06-22', 'Monthly Basic'),
       (6, 29.99, '2024-07-22', 'Monthly Basic'),
       (7, 99.99, '2024-07-01', 'Quarterly Basic'),
       (7, 99.99, '2024-10-01', 'Quarterly Basic'),
       (8, 49.99, '2024-08-14', 'Monthly Premium'),
       (8, 49.99, '2024-09-14', 'Monthly Premium'),
       (9, 29.99, '2024-09-30', 'Monthly Basic'),
       (9, 29.99, '2024-10-30', 'Monthly Basic'),
       (10, 149.99, '2024-10-12', 'Quarterly Premium'),
       (10, 149.99, '2025-01-12', 'Quarterly Premium');


-- Query across all three tables at once — show a member's name, goal, payment amount, and plan in one result.
SELECT m.name, pr.fitness_goals, pa.amount, pa.plan
FROM members m
         JOIN payments pa ON m.member_id = pa.member_id
         JOIN profiles pr ON m.member_id = pr.member_id;
-- Find total revenue per plan, average payment, and how many members chose each plan.
SELECT plan,
       SUM(amount)               AS total_revenue,
       AVG(amount)               AS average_spendings,
       COUNT(DISTINCT member_id) AS total_members
FROM payments
GROUP BY plan
ORDER BY SUM(amount) DESC;

-- Categorize payments into tiers based on amount.
SELECT *,
       CASE
           WHEN amount > 90 THEN 'VIP'
           WHEN amount BETWEEN 40 AND 90 THEN 'Premium'
           WHEN amount BETWEEN 20 AND 40 THEN 'Pro'
           ELSE 'Basic'
           END AS member_tier
FROM payments;
-- The gym realizes they also want to start collecting emails. Make these structural changes.
CREATE EXTENSION IF NOT EXISTS citext;

ALTER TABLE members
    ADD COLUMN email citext UNIQUE CHECK ( email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' );

-- Mask phone numbers — only show the first 4 digits and the last digit. Clean up names by removing accidental spaces.
SELECT TRIM(phone_number),
       "left"(phone_number, 4) || REPEAT('*', LENGTH(phone_number) - 5) ||
       "right"(phone_number, 1) AS masked_phone_numbers
FROM members;
-- Create a virtual table showing only members whose total payments cross a certain high threshold.

CREATE OR REPLACE VIEW vip_members AS
SELECT m.name, m.phone_number, pa.amount, pa.plan
FROM members m
         JOIN payments pa ON m.member_id = pa.member_id
         JOIN profiles pr ON m.member_id = pr.member_id
WHERE amount > 90;

SELECT *
FROM vip_members;

-- Build a stored procedure that registers a new member AND creates their profile in one call.
CREATE OR REPLACE PROCEDURE register_member(p_name TEXT, p_email citext, p_phone_number VARCHAR(20),
                                            p_weight DECIMAL(5, 2),
                                            p_height DECIMAL(3, 2), p_fitness_goals TEXT)
    LANGUAGE plpgsql AS
$$
DECLARE
    new_member_id BIGINT;
BEGIN
    INSERT INTO members (name, email, phone_number)
    VALUES (p_name, p_email, p_phone_number)
    RETURNING member_id INTO new_member_id;

    INSERT INTO profiles (member_id, weight, height, fitness_goals)
    VALUES (new_member_id, p_weight, p_height, p_fitness_goals);
END;
$$;

CALL register_member('Sani Sahib', 'sanisahib@gmail.com', '+123456799', 87.50, 5.10,
                     'Impress My Crush.');
