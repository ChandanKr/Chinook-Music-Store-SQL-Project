-- SUBMISSION BY: CHANDAN KUMAR
-- PROJECT: CHINOOK MUSIC STORE
-- SKILL USED: MYSQL WORKBENCH
-- BATCH: PROFESSIONAL CERTIFICATE COURSE IN DATA SCIENCE - DECEMBER 2024
-- DOCUMENTATION FOR: SUBJECTIVE QUESTIONS


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

## ======================================================================= SUBJECTIVE QUESTIONS =======================================================================
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q1. Recommend the three albums from the new record label that should be prioritised for advertising and promotion in the USA based on genre sales analysis.
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	g.genre_id,
	g.name AS genre_name,
	al.album_id,
	al.title AS new_record_label,
	SUM(il.unit_price * il.quantity) AS total_genre_sales,
	DENSE_RANK() OVER (ORDER BY SUM(il.unit_price * il.quantity) DESC) AS Ranking
FROM genre g
INNER JOIN track t ON g.genre_id = t.genre_id
INNER JOIN invoice_line il ON t.track_id = il.track_id 
INNER JOIN invoice i ON il.invoice_id = i.invoice_id
INNER JOIN customer c ON i.customer_id = c.customer_id
INNER JOIN album al on t.album_id = al.album_id
WHERE c.country = 'USA'
GROUP BY g.genre_id, g.name, al.album_id, al.title
ORDER BY total_genre_sales DESC;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q2. Determine the top-selling genres in countries other than the USA and identify any commonalities or differences.
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ******** Top Selling Genres in countries other than USA? ********
SELECT
	g.genre_id,
    g.name AS genre_name,
    c.country,
    SUM(il.quantity) AS quantity_sold
FROM genre g 
INNER JOIN track t ON g.genre_id = t.genre_id
INNER JOIN invoice_line il ON t.track_id = il.track_id
INNER JOIN invoice i ON il.invoice_id = i.invoice_id
INNER JOIN customer c ON i.customer_id = c.customer_id 
WHERE country <> 'USA'
GROUP BY g.genre_id, genre_name, c.country
ORDER BY quantity_sold DESC;

-- ******** Top Selling Genres in countries in USA? ********
SELECT
	g.genre_id,
    g.name AS genre_name,
    c.country,
    SUM(il.quantity) AS quantity_sold
FROM genre g 
INNER JOIN track t ON g.genre_id = t.genre_id
INNER JOIN invoice_line il ON t.track_id = il.track_id
INNER JOIN invoice i ON il.invoice_id = i.invoice_id
INNER JOIN customer c ON i.customer_id = c.customer_id 
WHERE country = 'USA'
GROUP BY g.genre_id, genre_name, c.country
ORDER BY quantity_sold DESC;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q3. Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new 
--     customers? What insights can these patterns provide about customer loyalty and retention strategies?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH CustomerPurchaseStats AS (
    SELECT 
        c.customer_id,
        COUNT(i.invoice_id) AS purchase_frequency,
        SUM(il.quantity) AS total_items_purchased,
        SUM(i.total) AS total_spent,
        AVG(i.total) AS avg_order_value,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS customer_tenure_days
    FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id
),
CustomerSegments AS (
    SELECT 
        customer_id,
        purchase_frequency,
        total_items_purchased,
        total_spent,
        avg_order_value,
        customer_tenure_days,
        CASE 
            WHEN customer_tenure_days >= 365 THEN 'Long-Term'
            ELSE 'New'
        END AS customer_segment
    FROM CustomerPurchaseStats
)
SELECT 
    customer_segment,
    ROUND(AVG(purchase_frequency),2) AS avg_purchase_frequency,
    ROUND(AVG(total_items_purchased),2) AS avg_basket_size,
    ROUND(AVG(total_spent),2) AS avg_spending_amount,
    ROUND(AVG(avg_order_value),2) AS avg_order_value
FROM CustomerSegments
GROUP BY customer_segment;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q4. Product Affinity Analysis: Which music genres, artists, or albums are frequently purchased together by customers? How can this information guide product 
--     recommendations and cross-selling initiatives?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ******** 1. Genre Affinity Analysis ********
WITH track_combinations AS (
    SELECT 
        il1.track_id AS track_id_1,
        il2.track_id AS track_id_2,
        COUNT(*) AS times_purchased_together
    FROM invoice_line il1
    JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
    GROUP BY il1.track_id, il2.track_id
),
genre_combinations AS (
    SELECT 
        t1.genre_id AS genre_id_1,
        t2.genre_id AS genre_id_2,
        COUNT(*) AS times_purchased_together
    FROM track_combinations tc
    JOIN track t1 ON tc.track_id_1 = t1.track_id
    JOIN track t2 ON tc.track_id_2 = t2.track_id
    WHERE t1.genre_id <> t2.genre_id
    GROUP BY t1.genre_id, t2.genre_id
)
SELECT 
    g1.name AS genre_1,
    g2.name AS genre_2,
    gc.times_purchased_together
FROM genre_combinations gc
JOIN genre g1 ON gc.genre_id_1 = g1.genre_id
JOIN genre g2 ON gc.genre_id_2 = g2.genre_id
ORDER BY gc.times_purchased_together DESC;
    
-- ******** 2. Artist Affinity Analysis ********
WITH track_combinations AS (
    SELECT 
        il1.track_id AS track_id_1,
        il2.track_id AS track_id_2,
        COUNT(*) AS times_purchased_together
    FROM invoice_line il1
    JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
    GROUP BY il1.track_id, il2.track_id
),
artist_combinations AS (
    SELECT 
        a1.artist_id AS artist_id_1,
        a2.artist_id AS artist_id_2,
        COUNT(*) AS times_purchased_together
    FROM track_combinations tc
    JOIN track t1 ON tc.track_id_1 = t1.track_id
    JOIN album al1 ON t1.album_id = al1.album_id
    JOIN artist a1 ON al1.artist_id = a1.artist_id
    JOIN track t2 ON tc.track_id_2 = t2.track_id
    JOIN album al2 ON t2.album_id = al2.album_id
    JOIN artist a2 ON al2.artist_id = a2.artist_id
    WHERE a1.artist_id <> a2.artist_id
    GROUP BY a1.artist_id, a2.artist_id
)
SELECT 
    a1.name AS artist_1,
    a2.name AS artist_2,
    ac.times_purchased_together
FROM artist_combinations ac
JOIN artist a1 ON ac.artist_id_1 = a1.artist_id
JOIN artist a2 ON ac.artist_id_2 = a2.artist_id
ORDER BY ac.times_purchased_together DESC;

-- ******** 3. Album Affinity Analysis ********
WITH track_combinations AS (
    SELECT 
        il1.track_id AS track_id_1,
        il2.track_id AS track_id_2,
        COUNT(*) AS times_purchased_together
    FROM invoice_line il1
    JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id AND il1.track_id < il2.track_id
    GROUP BY il1.track_id, il2.track_id
),
album_combinations AS (
    SELECT 
        al1.album_id AS album_id_1,
        al2.album_id AS album_id_2,
        COUNT(*) AS times_purchased_together
    FROM track_combinations tc
    JOIN track t1 ON tc.track_id_1 = t1.track_id
    JOIN album al1 ON t1.album_id = al1.album_id
    JOIN track t2 ON tc.track_id_2 = t2.track_id
    JOIN album al2 ON t2.album_id = al2.album_id
    WHERE al1.album_id <> al2.album_id
    GROUP BY al1.album_id, al2.album_id
)
SELECT 
    al1.title AS album_1,
    al2.title AS album_2,
    ac.times_purchased_together
FROM album_combinations ac
JOIN album al1 ON ac.album_id_1 = al1.album_id
JOIN album al2 ON ac.album_id_2 = al2.album_id
ORDER BY ac.times_purchased_together DESC;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q5. Regional Market Analysis: Do customer purchasing behaviors and churn rates vary across different geographic regions or store locations? How might these correlate
--     with local demographic or economic factors?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ******** Customer Purchasing Behaviors by Region ********
WITH purchase_frequency AS (
    SELECT 
        customer_id,
        COUNT(invoice_id) AS total_purchase_freq,
        SUM(total) AS total_spending,
        AVG(total) AS avg_order_value
    FROM invoice
    GROUP BY customer_id
),
customer_region_summary AS (
    SELECT 
        c.customer_id,
        c.country,
        COALESCE(c.state,'N.A') as state,
        c.city,
        pf.total_purchase_freq,
        pf.total_spending,
        pf.avg_order_value
    FROM customer c
    JOIN purchase_frequency pf ON c.customer_id = pf.customer_id
),
regional_summary AS (
    SELECT 
        country,
        state,
        city,
        ROUND(COUNT(DISTINCT customer_id),2) AS total_customers,
        ROUND(SUM(total_purchase_freq),2) AS total_purchases,
        ROUND(SUM(total_spending),2) AS total_spending,
        ROUND(AVG(avg_order_value),2) AS avg_order_value,
        ROUND(AVG(total_purchase_freq),2) AS avg_purchase_frequency
    FROM customer_region_summary
    GROUP BY country, state, city
)
SELECT 
    country,
    state,
    city,
    total_customers,
    total_purchases,
    total_spending,
    avg_order_value,
    avg_purchase_frequency
FROM regional_summary
ORDER BY total_spending DESC;
    
-- ******** Churn Rate by Region ********
WITH last_purchase AS (
    SELECT 
        c.customer_id,
        c.country,
        COALESCE(c.state,'N.A') as state,
        c.city,
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country, c.state, c.city
),
churned_customers AS (
    SELECT 
        country,
        state,
        city,
        COUNT(customer_id) AS churned_customers
    FROM last_purchase
    WHERE last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY country, state, city
)
SELECT 
    lc.country,
    lc.state,
    lc.city,
    lc.churned_customers,
    COUNT(c.customer_id) AS total_customers,
    (lc.churned_customers / COUNT(c.customer_id)) * 100 AS churn_rate
FROM churned_customers lc
JOIN customer c ON lc.country = c.country AND lc.state = c.state AND lc.city = c.city
GROUP BY lc.country, lc.state, lc.city
ORDER BY churn_rate DESC;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q6. Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history), which customer segments are more likely to churn or pose a higher 
--     risk of reduced spending? What factors contribute to this risk?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH customer_profile AS (
    SELECT 
        c.customer_id,
        c.country,
        COALESCE(c.state,'N.A') as state,
        c.city,
        MAX(i.invoice_date) AS last_purchase_date,
        SUM(i.total) AS total_spending,
        COUNT(i.invoice_id) AS purchase_frequency,
        AVG(i.total) AS avg_order_value
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
churn_risk AS (
    SELECT 
        cp.customer_id,
        cp.country,
        cp.state,
        cp.city,
        cp.total_spending,
        cp.purchase_frequency,
        cp.avg_order_value,
        CASE 
            WHEN cp.last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) THEN 'High Risk'
            WHEN cp.total_spending < 100 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_profile
    FROM customer_profile cp
),
risk_summary AS (
    SELECT 
        country,
        state,
        city,
        risk_profile,
        ROUND(COUNT(customer_id),2) AS num_customers,
        ROUND(AVG(total_spending),2) AS avg_total_spending,
        ROUND(AVG(purchase_frequency),2) AS avg_purchase_frequency,
        ROUND(AVG(avg_order_value),2) AS avg_order_value
    FROM churn_risk
    GROUP BY country, state, city, risk_profile
)
SELECT 
    country,
    state,
    city,
    risk_profile,
    num_customers,
    avg_total_spending,
    avg_purchase_frequency,
    avg_order_value
FROM risk_summary
ORDER BY risk_profile DESC, avg_total_spending DESC;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q7. Customer Lifetime Value Modeling: How can you leverage customer data (tenure, purchase history, engagement) to predict the lifetime value of different customer 
--     segments? This could inform targeted marketing and loyalty program strategies. Can you observe any common characteristics or purchase patterns among customers 
--     who have stopped purchasing?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH customer_profile AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customers,
        c.country,
        COALESCE(c.state,'N.A') AS state,
        c.city,
        MIN(i.invoice_date) AS first_purchase_date,
        MAX(i.invoice_date) AS last_purchase_date,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS customer_tenure_days,
        COUNT(i.invoice_id) AS total_purchases,
        SUM(i.total) AS total_spending,
        AVG(i.total) AS avg_order_value
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
customer_lifetime_value AS (
    SELECT 
        cp.customer_id,
        cp.customers,
        cp.country,
        cp.state,
        cp.city,
        cp.customer_tenure_days,
        cp.total_purchases,
        cp.total_spending,
        cp.avg_order_value,
        CASE 
            WHEN cp.customer_tenure_days >= 365 THEN 'Long-Term'
            ELSE 'Short-Term'
        END AS customer_segment,
        CASE 
            WHEN cp.last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) THEN 'Churned'
            ELSE 'Active'
        END AS customer_status,
        (cp.total_spending / GREATEST(cp.customer_tenure_days, 1)) * 365 AS predicted_annual_value,
        cp.total_spending AS lifetime_value
    FROM customer_profile cp
),
segment_analysis AS (
    SELECT 
        customer_segment,
        customer_status,
        COUNT(customer_id) AS num_customers,
        AVG(customer_tenure_days) AS avg_tenure_days,
        AVG(total_spending) AS avg_lifetime_value,
        AVG(predicted_annual_value) AS avg_predicted_annual_value
    FROM customer_lifetime_value
    GROUP BY customer_segment, customer_status
),
churn_analysis AS (
    SELECT 
        country,
        state,
        city,
        customer_segment,
        COUNT(customer_id) AS churned_customers,
        AVG(total_spending) AS avg_lifetime_value
    FROM customer_lifetime_value
    WHERE customer_status = 'Churned'
    GROUP BY country, state, city, customer_segment
)
SELECT * 
FROM customer_lifetime_value
ORDER BY lifetime_value DESC;

--  Additional queries to analyze the results:
-- ******** Segment Analysis ********
SELECT * 
FROM segment_analysis
ORDER BY avg_lifetime_value DESC;

-- ******** Churn Analysis ********
SELECT * 
FROM churn_analysis
ORDER BY churned_customers DESC;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q8. If data on promotional campaigns (discounts, events, email marketing) is available, how could you measure their impact on customer acquisition, retention, and 
--     overall sales?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ****** Answered in Documented pdf file ******


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q9. How would you approach this problem, if the objective and subjective questions weren't given?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ****** Answered in Documented pdf file ******


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q10. How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE Album
ADD COLUMN ReleaseYear INT;
select * from Album;

UPDATE album
SET ReleaseYear = 2017
WHERE album_id = 1;

UPDATE album
SET ReleaseYear = 2017
WHERE album_id = 2;

UPDATE album
SET ReleaseYear = 2017
WHERE album_id = 3;

UPDATE album
SET ReleaseYear = 2017
WHERE album_id = 4;

UPDATE album
SET ReleaseYear = 2017
WHERE album_id = 5;

UPDATE album
SET ReleaseYear = 2018
WHERE album_id = 6;

UPDATE album
SET ReleaseYear = 2018
WHERE album_id = 7;

UPDATE album
SET ReleaseYear = 2018
WHERE album_id = 8;

UPDATE album
SET ReleaseYear = 2018
WHERE album_id = 9;

UPDATE album
SET ReleaseYear = 2018
WHERE album_id = 10;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Q11. Chinook is interested in understanding the purchasing behavior of customers based on their geographical location. 
-- They want to know the average total amount spent by customers from each country, along with the number of customers and the average number of tracks purchased per customer. 
-- Write an SQL query to provide this information.
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH tracks_per_customer AS (
    SELECT 
        i.customer_id,
        SUM(il.quantity) AS total_tracks
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY i.customer_id
),
customer_spending AS (
    SELECT 
        c.country,
        c.customer_id,
        SUM(i.total) AS total_spent,
        tpc.total_tracks
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN tracks_per_customer tpc ON c.customer_id = tpc.customer_id
    GROUP BY c.country, c.customer_id, tpc.total_tracks
)
SELECT 
    cs.country,
    COUNT(DISTINCT cs.customer_id) AS number_of_customers,
    ROUND(AVG(cs.total_spent),2) AS average_amount_spent_per_customer,
    ROUND(AVG(cs.total_tracks),2) AS average_tracks_purchased_per_customer
FROM customer_spending cs
GROUP BY cs.country
ORDER BY average_amount_spent_per_customer DESC;



## ======================================= END OF SUBJECTIVE QUESTIONS =======================================