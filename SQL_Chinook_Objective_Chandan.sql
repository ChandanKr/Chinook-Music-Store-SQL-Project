-- SUBMISSION BY: CHANDAN KUMAR
-- PROJECT: CHINOOK MUSIC STORE
-- SKILL USED: MYSQL WORKBENCH
-- BATCH: PROFESSIONAL CERTIFICATE COURSE IN DATA SCIENCE - DECEMBER 2024
-- DOCUMENTATION FOR: OBJECTIVE QUESTIONS


-- ******* SCHEMA *******
use chinook;
SELECT * FROM album; -- album_id, title, artist_id
SELECT * FROM artist; -- artist_id, name
SELECT * FROM customer; -- customer_id, first_name, last_name, company, address, city, state, country, postal_code, phone, fax, email, support_rep_id
SELECT * FROM employee; -- employee_id, last_name, first_name, title, reports_to, birthdate, hire_date, address, city, state, country, postal_code, phone, fax, email
SELECT * FROM genre; -- genre_id, name
SELECT * FROM invoice; -- invoice_id, customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total
SELECT * FROM invoice_line; -- invoice_line_id, invoice_id, track_id, unit_price, quantity
SELECT * FROM media_type; -- media_type_id, name
SELECT * FROM playlist; -- playlist_id, name
SELECT * FROM playlist_track; -- playlist_id, track_id
SELECT * FROM track; -- track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price

## ======================================= OBJECTIVE QUESTIONS =======================================
-- ---------------------------------------------------------------------------------------------------
## Q1. Does any table have missing values or duplicates? If yes how would you handle it ?
-- ---------------------------------------------------------------------------------------------------

/*
NO duplicate values in the whole dataset.
There are NULL values in: 
	-- customer table
    -- employee table and
    -- composer table
*/

-- ******** Checking for Null Values in customer table ********
SELECT * 
FROM customer 
WHERE first_name IS NULL 
   OR last_name IS NULL 
   OR company IS NULL 
   OR address IS NULL 
   OR city IS NULL 
   OR state IS NULL 
   OR country IS NULL 
   OR postal_code IS NULL 
   OR phone IS NULL 
   OR fax IS NULL 
   OR email IS NULL 
   OR support_rep_id IS NULL;

-- ******** Handling Null Values ********
SELECT customer_id, 
       COALESCE(company, 'UNKNOWN') AS company, 
       COALESCE(state, 'NONE') AS state,
       COALESCE(postal_code, 'N/A') AS postal_code,
       COALESCE(phone, 'N/A') AS phone,
       COALESCE(fax, 'N/A') AS fax 
FROM customer;

-- ******** Checking for Null Values in employee table ********
SELECT * 
FROM employee
WHERE last_name IS NULL 
   OR first_name IS NULL 
   OR title IS NULL 
   OR reports_to IS NULL 
   OR birthdate IS NULL 
   OR hire_date IS NULL 
   OR address IS NULL 
   OR city IS NULL 
   OR state IS NULL 
   OR country IS NULL 
   OR postal_code IS NULL 
   OR phone IS NULL 
   OR fax IS NULL 
   OR email IS NULL;

-- ******** Handling Null Values ********
SELECT 
	employee_id,
	first_name,
	last_name,
	COALESCE(reports_to, 'N/A') AS reports_to 
FROM employee;

-- ******** Checking for Null Values in track table ********
SELECT * 
FROM track
WHERE name IS NULL 
   OR album_id IS NULL
   OR media_type_id IS NULL 
   OR genre_id IS NULL 
   OR composer IS NULL 
   OR milliseconds IS NULL 
   OR bytes IS NULL 
   OR unit_price IS NULL;

-- ******** Handling Null Values ********
SELECT 
	track_id,
	name,
	COALESCE(composer, 'N/A') AS composer 
FROM track;

-- ---------------------------------------------------------------------------------------------------
## Q2. Find the top-selling tracks and top artist in the USA and identify their most famous genres.
-- ---------------------------------------------------------------------------------------------------
-- ******** Top Selling Track in USA ********
SELECT 
	t.track_id,
	t.name AS track_name,	
	SUM(il.quantity) AS total_sold,
	g.name AS genre,
	a.name AS artist
FROM
	invoice_line il
	INNER JOIN invoice i ON il.invoice_id = i.invoice_id
	INNER JOIN customer c ON i.customer_id = c.customer_id
	INNER JOIN track t ON il.track_id = t.track_id
	INNER JOIN album al ON t.album_id = al.album_id
	INNER JOIN artist a ON al.artist_id = a.artist_id
	INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE c.country = 'USA'
GROUP BY t.track_id, t.name, g.name, a.name
ORDER BY total_sold DESC
LIMIT 10;
    
-- ******** Top Artist in USA and Most Famous Genres of the Top Artist ********
SELECT 
	a.artist_id,
	a.name AS artist_name,
	g.name AS genre_name,
	SUM(il.quantity) AS total_sold
FROM
	invoice_line il
	INNER JOIN invoice i ON il.invoice_id = i.invoice_id
	INNER JOIN customer c ON i.customer_id = c.customer_id
	INNER JOIN track t ON il.track_id = t.track_id
	INNER JOIN album al ON t.album_id = al.album_id
	INNER JOIN artist a ON al.artist_id = a.artist_id
	INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE c.country = 'USA'
GROUP BY a.artist_id, a.name, g.name
ORDER BY total_sold DESC
LIMIT 1;

-- ---------------------------------------------------------------------------------------------------
## Q3. What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?
-- ---------------------------------------------------------------------------------------------------
WITH customer_information_cte as (
	SELECT 
		customer_id,
		first_name,
		last_name,
		city,
		COALESCE(state,'N.A') as state,
		country
	FROM customer
)	
SELECT
	country,
	state,
	city,
	COUNT(customer_id) as total_customers
FROM customer_information_cte
GROUP BY country, state, city
ORDER BY country, state, city;

-- ---------------------------------------------------------------------------------------------------
## Q4. Calculate the total revenue and number of invoices for each country, state, and city:
-- ---------------------------------------------------------------------------------------------------
SELECT
	c.country,
    COALESCE(c.state,'N.A') as state,
    c.city,
    SUM(i.total) as total_revenue,
    COUNT(i.invoice_id) as number_of_invoices
FROM customer c 
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country, c.state, c.city
ORDER BY total_revenue DESC, number_of_invoices DESC;

-- ---------------------------------------------------------------------------------------------------
## Q5. Find the top 5 customers by total revenue in each country.
-- ---------------------------------------------------------------------------------------------------
SELECT * FROM customer;
SELECT * FROM invoice;
WITH customer_wise_revenue_cte1 as(
	SELECT
		c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customers,
        c.country,
        SUM(i.total) as total_revenue
	FROM customer c 
	INNER JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customers, c.country
	ORDER BY c.country, total_revenue
),
ranked_customers_cte2 as (
	SELECT
		customer_id,
        customers,
        country,
        total_revenue,
        RANK() OVER (PARTITION BY country ORDER BY total_revenue desc) as customer_rank
	FROM customer_wise_revenue_cte1
)	
SELECT 
	customer_id,
	customers,
	country,
	total_revenue,
    customer_rank
FROM ranked_customers_cte2
WHERE customer_rank <= 5
ORDER BY country, customer_rank;

-- ---------------------------------------------------------------------------------------------------
## Q6. Identify the top-selling track for each customer.
-- ---------------------------------------------------------------------------------------------------
WITH Customer_track as (
	SELECT
		c.customer_id,
		CONCAT(c.first_name, ' ', c.last_name) as customers,
		SUM(il.quantity) as total_quantity
	FROM customer c 
	INNER JOIN invoice i ON c.customer_id = i.customer_id
	INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
	INNER JOIN track t ON t.track_id = il.track_id
	GROUP BY c.customer_id, customers
),
ranked_track as(
	SELECT
		Customer_track.customer_id,
        Customer_track.customers,
        Customer_track.total_quantity,
        t.track_id,
        t.name as track_name,
        ROW_NUMBER() OVER (PARTITION BY Customer_track.customer_id ORDER BY Customer_track.total_quantity DESC) as track_rank
	FROM Customer_track
	INNER JOIN invoice i ON Customer_track.customer_id = i.customer_id
	INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
	INNER JOIN track t ON t.track_id = il.track_id
)        
SELECT 
	customer_id,
    customers,
    track_id,
    track_name,
    total_quantity
FROM ranked_track
WHERE track_rank = 1
ORDER BY total_quantity DESC;

-- ---------------------------------------------------------------------------------------------------
## Q7. Are there any patterns or trends in customer purchasing behavior (e.g., frequency of purchases, 
--     preferred payment methods, average order value)?
-- ---------------------------------------------------------------------------------------------------
-- ********Frequency of Purchases ********
SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) as customers,
	YEAR(i.invoice_date) AS year,
	COUNT(i.invoice_id) AS purchase_count
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customers, YEAR(i.invoice_date)
ORDER BY c.customer_id, customers, YEAR(i.invoice_date);
    
-- ******** Calculate the average order value for each customer ********
SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) as customers,
    ROUND(AVG(i.total), 2) AS avg_order_value
FROM customer c 
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customers
ORDER BY avg_order_value desc;
    
-- ******** Calculate the total revenue generated by each customer ********
SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) as customers,
    SUM(i.total) AS total_revenue
FROM customer c 
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customers
ORDER BY total_revenue desc;
    
-- ******** Identify the preferred purchase periods ********
SELECT 
    c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) as customers,
    DAYOFWEEK(i.invoice_date) AS day_of_week,
    COUNT(i.invoice_id) AS purchase_count
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, DAYOFWEEK(i.invoice_date)
ORDER BY c.customer_id, customers, purchase_count DESC;
-- ---------------------------------------------------------------------------------------------------
## Q8. What is the customer churn rate?
-- ---------------------------------------------------------------------------------------------------
WITH MostRecentInvoice AS (
    SELECT MAX(invoice_date) AS most_recent_invoice_date
    FROM invoice
),
CutoffDate AS (
    SELECT DATE_SUB(most_recent_invoice_date, INTERVAL 1 YEAR) AS cutoff_date
    FROM MostRecentInvoice
),
ChurnedCustomers AS (
    SELECT 
        c.customer_id,
        COALESCE(c.first_name, ' ',c.last_name) as customers,
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
	LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, customers
    HAVING MAX(i.invoice_date) IS NULL OR MAX(i.invoice_date) < (SELECT cutoff_date FROM CutoffDate)
)
-- ******** Calculate the churn rate ********
SELECT (SELECT COUNT(*) FROM ChurnedCustomers) / (SELECT COUNT(*) FROM customer) * 100 AS churn_rate;

-- ---------------------------------------------------------------------------------------------------
## Q9. Calculate the percentage of total sales contributed by each genre in the USA and identify the 
--     best-selling genres and artists.
-- ---------------------------------------------------------------------------------------------------
WITH genre_sales_in_usa AS (
	SELECT
		g.genre_id,
		g.name AS genre_name,
		SUM(il.unit_price * il.quantity) AS total_genre_sales
	FROM genre g
	INNER JOIN track t ON g.genre_id = t.genre_id
	INNER JOIN invoice_line il ON t.track_id = il.track_id 
	INNER JOIN invoice i ON il.invoice_id = i.invoice_id
	INNER JOIN customer c ON i.customer_id = c.customer_id
	WHERE c.country = 'USA'
	GROUP BY g.genre_id, g.name
),        
total_sales as(
	SELECT
		SUM(total_genre_sales) as total_usa_sales
	FROM genre_sales_in_usa
),

genre_sales_percentage AS(
	SELECT
		gs.genre_id,
        gs.genre_name,
        gs.total_genre_sales,
        ts.total_usa_sales,
        (gs.total_genre_sales/ts.total_usa_sales) * 100 AS percentage_contribution
	FROM genre_sales_in_usa gs
	CROSS JOIN total_sales ts
),
best_selling_artist AS (
	SELECT
		g.genre_id,
        g.name AS genre_name,
        a.artist_id,
        a.name AS artist_name,
        SUM(il.unit_price * il.quantity) AS total_artists_sales
	FROM genre g 
	INNER JOIN track t ON g.genre_id = t.genre_id
    INNER JOIN album al ON al.album_id = t.album_id
    INNER JOIN artist a ON a.artist_id = al.artist_id
    INNER JOIN invoice_line il ON il.track_id = t.track_id
    INNER JOIN invoice i ON i.invoice_id = il.invoice_id
    INNER JOIN customer c ON c.customer_id = i.customer_id
	WHERE c.country = 'USA'
	GROUP BY g.genre_id, g.name, a.artist_id, a.name
)        
SELECT
	genre_id,
	genre_name,
	artist_id,
	artist_name,
	total_artists_sales,
	DENSE_RANK() OVER (PARTITION BY genre_id ORDER BY total_artists_sales DESC) AS artist_rank
FROM best_selling_artist;


-- ---------------------------------------------------------------------------------------------------
## Q10. Find customers who have purchased tracks from at least 3 different genres.
-- ---------------------------------------------------------------------------------------------------
SELECT 
    c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) as customers,
    COUNT(DISTINCT g.genre_id) AS genre_count
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.customer_id, customers
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY genre_count DESC;


-- ---------------------------------------------------------------------------------------------------
## Q11. Rank genres based on their sales performance in the USA.
-- ---------------------------------------------------------------------------------------------------
WITH genre_sales_in_usa AS (
	SELECT
		g.genre_id,
		g.name AS genre_name,
		SUM(il.unit_price * il.quantity) AS total_genre_sales
	FROM genre g
	INNER JOIN track t ON g.genre_id = t.genre_id
	INNER JOIN invoice_line il ON t.track_id = il.track_id 
	INNER JOIN invoice i ON il.invoice_id = i.invoice_id
	INNER JOIN customer c ON i.customer_id = c.customer_id
	WHERE c.country = 'USA'
	GROUP BY g.genre_id, g.name
)        
SELECT
	genre_id,
    genre_name,
    total_genre_sales,
    RANK() OVER (ORDER BY total_genre_sales DESC) AS genre_rank
FROM genre_sales_in_usa
ORDER BY genre_rank;


-- ---------------------------------------------------------------------------------------------------
## Q12. Identify customers who have not made a purchase in the last 3 months.
-- ---------------------------------------------------------------------------------------------------
WITH recent_purchases AS (
	SELECT c.customer_id
	FROM customer c 
	INNER JOIN invoice i ON c.customer_id = i.customer_id 
	WHERE i.invoice_date >= CURDATE() - INTERVAL 3 MONTH
)        
SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customers
FROM customer c
LEFT JOIN recent_purchases rp ON c.customer_id = rp.customer_id
WHERE rp.customer_id IS NULL
ORDER BY c.customer_id;   


## ======================================= END OF OBJECTIVE QUESTIONS =======================================