/* Q1: Who is the senior most employee based on job title?*/

select * 
from employee
order by levels desc
limit 1

/* Q2: Which countries have the most Invoices? */

select billing_country, count(*) as Number_of_Invoices
from invoice
group by billing_country
order by Number_of_Invoices desc


/* Q3: What are top 3 values of total invoice? */

select invoice_id, total
from invoice
order by total desc
limit 3


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city as city, sum(total) as total 
from invoice
group by billing_city
order by total desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money. */

select customer.customer_id, customer.first_name, customer.last_name, customer.country, sum(invoice.total) as total
from customer
join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email */

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock')
order by email

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.name, count(artist.artist_id) as Number_of_Songs
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
group by artist.artist_id, genre.name
having genre.name like 'Rock'
order by number_of_songs desc
limit 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as average_milliseconds from track)
order by milliseconds desc

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with best_selling_artist as
   (select artist.artist_id, artist.name, 
    sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by artist.artist_id
	order by total_sales desc
	limit 1)
select customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.name,
	sum(invoice_line.unit_price*invoice_line.quantity) as amount_spent
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	join invoice_line on invoice_line.invoice_id = invoice.invoice_id
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join best_selling_artist on best_selling_artist.artist_id = album.artist_id
	group by customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.name
	order by amount_spent desc

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

with popular_genre as
(
	Select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id, 
	row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) as row_number
	from invoice_line
	join invoice on invoice_line.invoice_id = invoice.invoice_id
	join customer on invoice.customer_id = customer.customer_id
	join track on invoice_line.track_id = track.track_id 
	join genre on track.genre_id = genre.genre_id
	group by customer.country, genre.genre_id, genre.name
	order by customer.country asc 
)
select * from popular_genre where row_number <= 1

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as
(
select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, sum(invoice.total) as total_spending,
row_number() over(partition by invoice.billing_country order by sum(invoice.total) desc) as row_number
from invoice
join customer on invoice.customer_id = customer.customer_id
group by customer.customer_id, invoice.billing_country
order by invoice.billing_country asc, total_spending desc
)

select * from customer_with_country where row_number <=1