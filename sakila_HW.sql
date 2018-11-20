use sakila;

SHOW tables;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name,last_name
from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `Actor Name`
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT actor_id, last_name, first_name
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country 
WHERE country IN 
('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description blob;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,
COUNT(*) AS 'Number of Actors' 
FROM actor GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT last_name, 
COUNT(*) AS 'Number of Actors' 
FROM actor GROUP BY last_name HAVING count(*) >=2;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor 
SET first_name = 'HARPO'
WHERE First_name = "Groucho" AND last_name = "Williams";


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
 -- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
 
UPDATE actor 
SET first_name = IF(first_name="HARPO", "GROUCHO", "MUCHO GROUCHO")
WHERE First_name = "HARPO";


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- first view the DDL information in table
DESCRIBE sakila.address;

-- then use the below syntax to create the address table
SHOW CREATE TABLE address;

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT first_name, last_name, address
FROM staff s 
JOIN address a
ON s.address_id = a.address_id;

-- to know the city and the country they are located use the below left join syntax

SELECT s.first_name, s.last_name, a.address, c.city, co.country
FROM staff AS s
LEFT JOIN address AS a
ON s.address_id = a.address_id
LEFT JOIN city AS c
ON a.city_id = c.city_id
LEFT JOIN country as co
ON c.country_id = co.country_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
-- first review both table to pick the field to create inner join
select * from payment;
select * from staff;

-- create join

SELECT s.staff_id,  s.first_name, s.last_name,
SUM(p.amount) as total_sales
FROM payment AS p
INNER JOIN staff AS s
ON p.staff_id = s.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY s.staff_id;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film_actor;
SELECT * FROM film;
-- then create the join
SELECT f.title AS 'Film Title', COUNT(fa.actor_id) AS `Number of Actors`
FROM film_actor fa
INNER JOIN film f 
ON fa.film_id= f.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, (
SELECT COUNT(*) FROM inventory
WHERE film.film_id = inventory.film_id
) AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) AS `Total Paid`
FROM customer c
JOIN payment p 
ON c.customer_id= p.customer_id
GROUP BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- select * from language;
SELECT title
FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(
SELECT title 
FROM film 
WHERE language_id = 1
);


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
Select actor_id
FROM film_actor
WHERE film_id IN 
(
SELECT film_id
FROM film
WHERE title = 'Alone Trip'
));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
--  Use joins to retrieve this information.

SELECT c.first_name, c.last_name, c.email
FROM customer AS c
INNER JOIN address AS a
    ON c.address_id = a.address_id
INNER JOIN city AS cy
    ON a.city_id = cy.city_id
INNER JOIN country AS co
    ON cy.country_id = co.country_id
WHERE co.country = "Canada";
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

SELECT title
FROM film 
WHERE film_id IN
(
SELECT film_id FROM film_category
WHERE category_id IN
(
SELECT category_id FROM category
WHERE name = "Family"
));


-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(rental_id) AS 'Times Rented'
FROM rental r
JOIN inventory i
ON (r.inventory_id = i.inventory_id)
JOIN film f
ON (i.film_id = f.film_id)
GROUP BY f.title
ORDER BY `Times Rented` DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT a.address, cy.city, co.country, SUM(p.amount) AS total_revenue
FROM store AS s
INNER JOIN address AS a
    ON s.address_id = a.address_id
INNER JOIN customer AS c
    ON s.store_id=c.store_id
INNER JOIN payment AS p
    ON p.customer_id = c.customer_id
INNER JOIN city AS cy
    ON cy.city_id = a.city_id
INNER JOIN country AS co
    ON co.country_id = cy.country_id
GROUP BY a.address, cy.city, co.country;
-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, a.address, cy.city, co.country
FROM store AS s
INNER JOIN address AS a
    ON s.address_id = a.address_id
INNER JOIN city AS cy
    ON cy.city_id = a.city_id
INNER JOIN country AS co
    ON co.country_id = cy.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name 
ORDER BY Gross  DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW genre_revenue AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name 
ORDER BY Gross  DESC
LIMIT 5;
-- 8b. How would you display the view that you created in 8a?

SELECT *
FROM genre_revenue;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP
VIEW IF EXISTS genre_revenue;


