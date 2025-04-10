![image](https://github.com/user-attachments/assets/2b4972b5-e312-45da-91b8-1795b8e907d8)

#### Google Drive: https://shorturl.at/pEEhQ

- ## Agenda:
  ```
  > INTRODUCTION
  > PROBLEM STATEMENT
  > DATABASE SCHEMA
  > DATA DISCRIPTION
  > INSIGHTS
  > CONCLUSION
  ```
  
- ## Introduction:
  - The main objective of this project is to explore and analyse the chinook database using SQL to uncover valuable business insights.
  - This involves querying the database to gain a deeper understanding of customer behaviour, sales, trend,  and the management of the music library.
  - In the modern business environment, data analysis plays a vital role decision-making.
  - By leveraging SQL, businesses can extract meaningful patterns and trends from their data, enabling  them to make informed decisions, optimize strategies, and improve overall performance.

- ## Problem Statement:
  - Identify and address missing values and duplicates to ensure data integrity.
  - Determine top-selling tracks, artists, and genres, both in the USA and globally.
  - Analyze customer demographics and purchasing behavior, including churn rate and frequency.
  - Calculate total revenue and top customers by region, with a focus on geographical differences.
  - Recommend albums for promotion based on genre sales performance and customer preferences.
  - Segment customers based on purchase history to predict lifetime value and identify high-risk groups.

- ## Database Schema:
  ![image](https://github.com/user-attachments/assets/b4bd3033-89f7-48f1-aa4b-08d62dd5c013)

- ## Data Overview:
  -  **Customer Table:**
      - **_customer_id:_** Unique identifier assigned to each customer.
      - **_first_name:_** The given name or first name of a customer.
      - **_last_name:_** The surname or family name of a customer.
      - **_company:_** The name of the company associated with a customer.
      - **_address:_** The street address of a customer's location.
      - **_city:_** The city where a customer is located.
      - **_state:_** The state or province where a customer is located.
      - **_country:_** The country where a customer is located.
      - **_postal_code:_** The postal or zip code of a customer's address.
      - **_phone:_** The phone number of a customer.
      - **_fax:_** The fax number associated with a customer.
      - **_email:_** The email address of a customer.
      - **_support_rep_id:_** The employee ID of the support representative assigned to a customer.
        
  -  **Invoice Table:**
      - **_invoice_id:_** Unique identifier assigned to each invoice.
      - **_customer_id:_** The customer ID associated with the invoice.
      - **_invoice_date:_** The date when the invoice was generated or issued.
      - **_billing_address:_** The street address used for billing purposes.
      - **_billing_city:_** The city used for billing purposes.
      - **_billing_state:_** The state or province used for billing purposes.
      - **_billing_country:_** The country used for billing purposes.
      - **_billing_postal_code:_** The postal or zip code used for billing purposes.
      - **_total:_** The total amount due on the invoice.

  - **Invoice_line Table:**
      - **_invoice_line_id:_** Unique identifier assigned to each line item on an invoice.
      - **_invoice_id:_** The invoice ID to which the line item belongs.
      - **_track_id:_** The ID of the track or product included in the line item.
      - **_unit_price:_** The price per unit for the line item.
      - **_quantity:_** The quantity of units for the line item.

  - **Playlist Table:**
      - **_playlist_id_**: Unique identifier assigned to each playlist.
      - **_name:_** The name or title of the playlist

  - **Playlist_track Table:**
      - **_playlist_id:_** The ID of the playlist to which the track belongs.
      - **_track_id:_** The ID of the track included in the playlist.

  - **Track Table:**
      - **_track_id:_** Unique identifier assigned to each track or song.
      - **_name:_** The title or name of the track.
      - **_album_id:_** The ID of the album to which the track belongs.
      - **_media_type_id:_** The ID of the media type associated with the track.
      - **_genre_id:_** The ID of the genre associated with the track.
      - **_composer:_** The name of the composer or artist who composed the track.
      - **_milliseconds:_** The duration of the track in milliseconds.
      - **_bytes:_** The file size of the track in bytes.
      - **_unit_price:_** The price per unit for the track.

- ## Insights:
  - **Rock Rules!**
      - Rock genre had the highest global sales.
      - 3 top albums from Rock genre recommended for USA promotions.
  - **Diverse Listeners**
      - Customers like Leonie Köhler explored 14+ genres.
  - **Revenue Champs**
      - František Wichterlová topped with $144.54 total revenue.
  - **Customer Behavior**
      - USA had the highest number of customers but lower avg. spend.
      - Czech Republic had highest avg. revenue/customer: $136.62
      - High AOV spotted in Prague, London, and Mountain View.
  - **Affinity Analysis**
      - Metal & Rock frequently purchased together.
      - Common fan pairs: Green Day & Led Zeppelin, Nirvana & Rolling Stones.
  - **Regional Trends**
      - Brazil: Strong preference for Alternative & Punk.
      - Edmonton & Copenhagen: Need sales boost via promotions.

- ## Conclusion:
  - **_Data Integrity:_** Null values and duplicates were addressed to ensure data accuracy across the Chinook database.
  - **_Top Performers:_** Rock is the most popular genre, particularly in the USA. Focusing on Rock music can enhance market engagement.
  - **_Customer Behavior:_** Long-term customers show higher spending, indicating strong loyalty. New customers have growth potential through personalized promotions.
  - **_Market Analysis:_** Rock music dominates globally, except in regions like Brazil, which favor Alternative & Punk and Metal.
  - **_Product Affinity:_** Identified popular genres and artists can guide cross-selling and bundling strategies.
  - **_Risk Management:_** High-value customers need tailored engagement to prevent churn. Predictive models can identify at-risk customers.
  - **_Recommendations:_** Focus on high-performing genres, implement loyalty programs, and use data-driven insights for targeted marketing. 








