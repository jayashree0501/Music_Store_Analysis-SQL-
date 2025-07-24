create database music_store;
use music_store;

-- 1. Genre 
CREATE TABLE Genre ( 
genre_id INT PRIMARY KEY auto_increment, 
name VARCHAR(120) 
); 


-- 2.MediaType 
CREATE TABLE MediaType ( 
media_type_id INT PRIMARY KEY auto_increment, 
name VARCHAR(120) 
); 


-- 3.Employee
CREATE TABLE Employee ( 
 employee_id INT PRIMARY KEY auto_increment, 
 last_name VARCHAR(120), 
 first_name VARCHAR(120), 
 title VARCHAR(120), 
 reports_to INT, 
  levels VARCHAR(255), 
 birthdate DATE, 
 hire_date DATE, 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100) 
);
drop table employee; 
 -- 4. Customer 
CREATE TABLE Customer ( 
 customer_id INT PRIMARY KEY auto_increment, 
 first_name VARCHAR(120), 
 last_name VARCHAR(120), 
 company VARCHAR(120), 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100), 
 support_rep_id INT, 
 FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id) 
 ON UPDATE CASCADE ON DELETE CASCADE
); 
 -- 5. Artist 
CREATE TABLE Artist ( 
 artist_id INT PRIMARY KEY auto_increment, 
 name VARCHAR(120) 
);
 -- 6.  Album 
CREATE TABLE Album ( 
 album_id INT PRIMARY KEY auto_increment, 
 title VARCHAR(160), 
 artist_id INT, 
 FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
 ON UPDATE CASCADE ON DELETE CASCADE
); 
 -- 7. Track 
CREATE TABLE Track ( 
 track_id INT PRIMARY KEY auto_increment, 
 name VARCHAR(200), 
 album_id INT, 
 media_type_id INT, 
 genre_id INT, 
 composer VARCHAR(220), 
 milliseconds INT, 
 bytes INT, 
 unit_price DECIMAL(10,2), 
 FOREIGN KEY (album_id) REFERENCES Album(album_id)
 ON UPDATE CASCADE ON DELETE CASCADE, 
 FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
 ON UPDATE CASCADE ON DELETE CASCADE, 
 FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) 
 ON UPDATE CASCADE ON DELETE CASCADE
);
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);
select * from Track;

-- 8. Invoice 
CREATE TABLE Invoice ( 
 invoice_id INT PRIMARY KEY auto_increment, 
 customer_id INT, 
 invoice_date DATE, 
 billing_address VARCHAR(255), 
 billing_city VARCHAR(100), 
 billing_state VARCHAR(100), 
 billing_country VARCHAR(100), 
 billing_postal_code VARCHAR(20), 
 total DECIMAL(10,2), 
 FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
 ON UPDATE CASCADE ON DELETE CASCADE
); 
 -- 9. InvoiceLine 
CREATE TABLE InvoiceLine ( 
 invoice_line_id INT PRIMARY KEY auto_increment, 
 invoice_id INT, 
 track_id INT, 
 unit_price DECIMAL(10,2), 
 quantity INT, 
 FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
 ON UPDATE CASCADE ON DELETE CASCADE, 
 FOREIGN KEY (track_id) REFERENCES Track(track_id) 
 ON UPDATE CASCADE ON DELETE CASCADE
); 
 -- 10. Playlist 
CREATE TABLE Playlist ( 
  playlist_id INT PRIMARY KEY auto_increment, 
 name VARCHAR(255) 
); 
 -- 11. PlaylistTrack 
CREATE TABLE PlaylistTrack ( 
 playlist_id INT, 
 track_id INT, 
 PRIMARY KEY auto_increment(playlist_id, track_id), 
 FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
 ON UPDATE CASCADE ON DELETE CASCADE, 
 FOREIGN KEY (track_id) REFERENCES Track(track_id)
 ON UPDATE CASCADE ON DELETE CASCADE
);

select * from Genre;
select * from MediaType;
select * from Employee;
select * from Customer;
select * from Artist;
select * from Album;
select * from Track;
select * from Invoice;
select * from InvoiceLine;
select * from Playlist ;
select * from PlaylistTrack ;

-- 1. Who is the senior most employee based on job title? 
select employee_id, concat(first_name ," ",last_name) as name,title,levels from Employee
order by levels desc
limit 1;

-- 2. Which countries have the most Invoices? 
select billing_country, count(invoice_id) as country_counts from Invoice 
group by billing_country 
order by country_counts desc limit 5;

-- 3. What are the top 3 values of total invoice? 
select total from Invoice
order by total desc limit 3;

/* 4. Which city has the best customers? - We would like to throw a promotional Music Festival in 
the city we made the most money. Write a query that returns one city that has the highest sum of 
invoice totals. Return both the city name & sum of all invoice totals */
 
select sum(total) as total_invoice, billing_city from invoice
group by billing_city
order by total_invoice desc;

/* 5. Who is the best customer? - The customer who has spent the most money will be declared 
the best customer. Write a query that returns the person who has spent the most money */
select first_name ,last_name, count(total) from Customer 
join Invoice on Customer.customer_id = Invoice .customer_id
group by first_name,last_name
order by count(total) desc;

/* 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */
Select distinct Customer.email,Customer.first_name,Customer.last_name,
Genre.name as genre FROM Customer 
JOIN Invoice on Customer.customer_id = Invoice .customer_id
JOIN InvoiceLine on Invoice.invoice_id = InvoiceLine.invoice_id
JOIN Track  on InvoiceLine.track_id = track.track_id
JOIN Genre on Track.genre_id = Genre.genre_id
WHERE Genre.name = "Rock"
ORDER BY Customer.email ASC;
/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that 
returns the Artist name and total track count of the top 10 rock bands */ 
SELECT Artist.name as ArtistName, count(Artist.artist_id) as Total_Tracks
FROM Track 
JOIN Album on Album.album_id = Track.album_id
JOIN Artist on Artist.artist_id = Album.artist_id
Join genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE '%Rock%'
GROUP BY Artist.name
ORDER BY Total_Tracks DESC
LIMIT 10;
/* 8. Return all the track names that have a song length longer than the average song length.- 
Return the Name and Milliseconds for each track. Order by the song length, with the longest 
songs listed first */

SELECT name, milliseconds from Track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM Track)
ORDER BY milliseconds DESC;

/* 9. Find how much amount is spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */ 
SELECT CONCAT(Customer.first_name, ' ',Customer.last_name) customer_name, Artist.name artist_name,
SUM(InvoiceLine.unit_price * InvoiceLine.quantity) as total_spent
FROM Customer 
JOIN Invoice ON Customer.customer_id = Invoice.customer_id
JOIN InvoiceLine ON Invoice.invoice_id = InvoiceLine.invoice_id
JOIN Track ON InvoiceLine.track_id = Track.track_id
JOIN Album ON Track.album_id = Album.album_id
JOIN Artist ON Album.artist_id = Artist.artist_id
GROUP BY Customer.customer_id, Artist.artist_id
ORDER BY total_spent DESC;



/* 10. We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that returns 
each country along with the top Genre. For countries where the maximum number of purchases 
is shared, return all Genres */ 

WITH popular_genre AS (SELECT COUNT(InvoiceLine.quantity) AS purchases,
customer.country,genre.name as genre_name,genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY customer.country  
ORDER BY COUNT(InvoiceLine.quantity) DESC) AS ranking
FROM InvoiceLine JOIN Invoice ON Invoice.invoice_id = InvoiceLine.invoice_id
JOIN Customer ON Customer.customer_id = invoice.customer_id
JOIN Track ON Track.track_id = InvoiceLine.track_id
JOIN Genre ON Genre.genre_id = track.genre_id
GROUP BY Customer.country, genre.name, genre.genre_id
ORDER by  Customer.country asc)
Select * from popular_genre where ranking =1;

-- Assigns a rank (r) to each genre within each country, based on purchase count.
/* 11. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how much they 
spent. For countries where the top amount spent is shared, provide all customers who spent this 
amount */

SELECT * FROM (SELECT CONCAT(Customer.first_name, ' ',Customer.last_name)
Customer_name ,Customer.country,SUM(Invoice.total) AS total_spent,
RANK() OVER (PARTITION BY Customer.country 
ORDER BY SUM(Invoice.total) DESC) AS firstrank
FROM Customer JOIN Invoice ON Invoice.customer_id = Customer.customer_id
GROUP BY Customer.first_name,Customer.last_name,Customer.country) AS ranked_customers                     
WHERE firstrank = 1;