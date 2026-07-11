USE sakira;
SHOW tables;

SELECT
    TABLE_NAME AS which_table_am_i_in,
    COLUMN_NAME AS my_column,
    REFERENCED_TABLE_NAME AS what_im_linked_to,
    REFERENCED_COLUMN_NAME AS its_column
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME IS NOT NULL
  AND TABLE_SCHEMA = 'Sakila';
  
-- --------------
-- Step 1: Create a View
CREATE OR REPLACE VIEW customer_information AS
SELECT c.customer_id, 
CONCAT(first_name, ' ', last_name) AS customer_name, 
c.email, 
COUNT(r.rental_id) AS rental_count
FROM customer AS c 
JOIN rental AS r ON c.customer_id = r.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

SELECT * FROM customer_information;

-- --------------
-- Step 2: Create a Temporary Table
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT ci.customer_id, ci.customer_name, ci.email,
       SUM(p.amount) AS total_paid
FROM customer_information AS ci
JOIN payment AS p ON ci.customer_id = p.customer_id
GROUP BY ci.customer_id, ci.customer_name, ci.email;

SELECT * FROM customer_information;
SELECT * FROM customer_payment_summary LIMIT 5;
-- --------------
-- Create a CTE and the Customer Summary Report
WITH customer_summary_cte AS (
    SELECT ci.customer_name, ci.email, ci.rental_count, cps.total_paid
    FROM customer_information AS ci
    JOIN customer_payment_summary AS cps ON ci.customer_id = cps.customer_id
)
SELECT customer_name, email, rental_count, total_paid,
       total_paid / rental_count AS average_payment_per_rental
FROM customer_summary_cte;

/*Challenge: Creating a Customer Summary Report

Step 1: Create a View
First, create a view that summarizes rental information for each customer. 
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include 
the customer's name, email address, rental count, and total amount paid.

Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid 
and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.*/