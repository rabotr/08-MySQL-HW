USE sakila;

-- #1a You need a list of all the actors who have Display the first and last names of all actors from the table `actor`. 
SELECT * FROM actor;

-- #1b Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
ALTER TABLE actor
ADD Actor_Name VARCHAR(50);
	
UPDATE  actor 
SET Actor_Name = CONCAT(first_name, ' ', last_name);

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, Actor_Name
FROM actor
WHERE actor.Actor_Name LIKE 'Joe%';

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT Actor_Name
FROM actor
WHERE actor.last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE actor.last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50)
AFTER first_name;

SELECT * FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY middle_name BLOB;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor
DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS Num_of_Last_Names
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`,
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
SELECT first_name, last_name
FROM actor
WHERE last_name = 'WILLIAMS';

UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'MUCHO GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
-- Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
-- (Hint: update the record using a uniq\\ue identifier.)
SELECT first_name, last_name
FROM actor
WHERE first_name = 'GROUCHO' OR first_name = 'MUCHO GROUCHO';

UPDATE actor
SET first_name = 'MUCHO GROUCHO' 
WHERE first_name = 'GROUCHO';

UPDATE actor
SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- CREATE DATABASE sakila;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT s.first_name, s.last_name, SUM(p.amount) AS rung_up_Aug_2005
FROM staff s
LEFT JOIN payment p ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.staff_id
ORDER BY s.last_name ASC;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS num_actors
FROM film f
INNER JOIN film_actor fa on fa.film_id = f.film_id
GROUP BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.film_id) AS num_in_inventory
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT f.title, l.name
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
WHERE l.name = 'English' AND f.title LIKE 'K%' OR f.title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
	FROM film
    WHERE title = 'Alone Trip'
    );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 

SELECT email
FROM customer
WHERE address_id IN
(

	SELECT address_id
	FROM address
	WHERE city_id IN
	(
		SELECT city_id
		FROM city
		WHERE country_id IN
		(
			SELECT country_id
			FROM country
			WHERE country = 'CANADA'
			)
		)
	);


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title AS Family_Films
FROM film
WHERE film_id IN
	(
	SELECT film_id
	FROM film_category
	WHERE category_id IN
	(
		SELECT category_id
		FROM category
		WHERE name = 'Family'
		)
	);


-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.inventory_id) AS num_times_rented
FROM film f 
INNER JOIN (inventory i INNER JOIN rental r ON r.inventory_id = i.inventory_id) ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY num_times_rented DESC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in. JOINs
SELECT i.store_id, SUM(DATEDIFF(r.return_date, r.rental_date)*f.rental_rate) AS money_brought_in
FROM rental r
INNER JOIN (inventory i INNER JOIN film f ON i.film_id = f.film_id) ON i.inventory_id = r.inventory_id
GROUP BY i.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city.city, country.country
FROM store s
INNER JOIN (address a 
	INNER JOIN (city  
		INNER JOIN country ON country.country_id = city.country_id) 
	ON a.city_id = city.city_id) 
ON a.address_id = s.address_id;
 
-- 7h. List the top five genres in gross revenue in descending order. JOIN
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS Revenue
FROM category c
INNER JOIN (film_category fc 
	INNER JOIN (inventory i
		INNER JOIN (rental r
			INNER JOIN payment p ON p.rental_id = r.rental_id)
        ON r.inventory_id = i.inventory_id)
    ON i.film_id = fc.film_id)
ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. JOIN
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name, SUM(p.amount) AS Revenue
FROM category c
INNER JOIN (film_category fc 
	INNER JOIN (inventory i
		INNER JOIN (rental r
			INNER JOIN payment p ON p.rental_id = r.rental_id)
        ON r.inventory_id = i.inventory_id)
    ON i.film_id = fc.film_id)
ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY Revenue DESC
LIMIT 5;
    
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
