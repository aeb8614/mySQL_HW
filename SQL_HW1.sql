USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT CONCAT(first_name,' ', last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know 
-- only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name from actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name from actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name from actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country from country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name varchar(50)
AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Actor Count'
    FROM actor
    GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
    FROM actor
    GROUP BY last_name
    HAVING COUNT(last_name) > 1;

-- 4c. Write a query to fix the record from GROUCHO WILLIAMS to HARPO WILLIAMS
UPDATE actor 
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO. (Hint: update the record using a unique identifier.)
UPDATE actor 
SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE address2 (
	address_id INT(100) auto_increment NOT NULL,
    address VARCHAR(100) NOT NULL,
    address2 VARCHAR(100),
    district VARCHAR(100) NOT NULL,
    city_id INT (100) NOT NULL,
    postal_code VARCHAR(100),
    phone VARCHAR(100),
    location BLOB NOT NULL,
    last_update DATE NOT NULL,
    PRIMARY KEY(address_id)
    );

SELECT * from address2;

DROP TABLE address2;

-- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address.

SELECT staff.first_name, staff.last_name, address.address 
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August 
-- of 2005. Use tables staff and payment.

SELECT staff.first_name, staff.last_name, pTable.sum_amount 
FROM staff
INNER JOIN 
(SELECT staff_id, sum(amount) as sum_amount
FROM payment
WHERE payment_date LIKE '2005-08%'
GROUP BY staff_id) as pTable ON staff.staff_id = pTable.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
SELECT table1.actor_count, film.title
    FROM 
	(SELECT COUNT(actor_id) as actor_count, film_id
	FROM film_actor
	GROUP BY film_id) as table1
    INNER JOIN film ON table1.film_id = film.film_id;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- film_id from film
SELECT title, Fcount FROM
	(SELECT inv_group.Fcount, film.title
    FROM 
	(SELECT COUNT(inventory_id) as Fcount, film_id
    FROM inventory
    GROUP BY film_id) as inv_group
    INNER JOIN film ON inv_group.film_id = film.film_id) as table2
WHERE title = 'Hunchback Impossible';
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, paid.sum_amount 
FROM 
(SELECT customer_id, sum(amount) as sum_amount
FROM payment
GROUP BY customer_id) as paid
INNER JOIN customer ON customer.customer_id = paid.customer_id
ORDER BY customer.last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film 
WHERE language_id = 
	(SELECT language_id
    FROM language 
    WHERE name = 'English')
AND title LIKE 'Q%' or title LIKE 'K%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN
	(Select actor_id FROM film_actor WHERE film_id = (Select film_id FROM film WHERE title = 'Alone Trip'));
    
-- 7c. You will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM 
	(SELECT customer.first_name, customer.last_name, customer.email, 
    address.address_id, city.city_id, country.country_id, country.country
    FROM customer
    INNER JOIN address ON address.address_id = customer.address_id
    INNER JOIN city ON city.city_id = address.city_id
    INNER JOIN country ON country.country_id = city.country_id) as canadians
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
SELECT title, name
FROM 
	(SELECT film.title, film.film_id, film_category.category_id, category.name
    FROM film
    INNER JOIN film_category ON film.film_id = film_category.film_id
    INNER JOIN category ON film_category.category_id = category.category_id) as fam_films
WHERE name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, r_count FROM
	(SELECT rent_count.r_count, film.title 
    FROM
		(SELECT COUNT(rental_id) as r_count, inventory_id
		FROM rental
		GROUP BY inventory_id) as rent_count
    INNER JOIN inventory ON inventory.inventory_id = rent_count.inventory_id
    INNER JOIN film ON inventory.film_id = film.film_id) table4
ORDER BY r_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id as store, SUM(amount) 
FROM payment
GROUP BY staff_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country 
FROM 
	(SELECT store.store_id, city.city, country.country
    FROM store
    INNER JOIN address ON address.address_id = store.address_id
    INNER JOIN city ON city.city_id = address.city_id
    INNER JOIN country ON country.country_id = city.country_id
    ) store_location;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name as category, sum(amount) as gross_revenue
FROM
	(SELECT name, amount
    FROM payment
    INNER JOIN rental ON rental.rental_id = payment.rental_id
    INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
    INNER JOIN film_category ON film_category.film_id = inventory.film_id
    INNER JOIN category ON category.category_id = film_category.category_id) rev_tab
GROUP BY category
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by 
-- gross revenue. Use the solution from the problem above to create a view. If you haven't 
-- solved 7h, you can substitute another query to create a view.
CREATE VIEW top_categories
AS SELECT name as category, sum(amount) as gross_revenue
FROM
	(SELECT name, amount
    FROM payment
    INNER JOIN rental ON rental.rental_id = payment.rental_id
    INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
    INNER JOIN film_category ON film_category.film_id = inventory.film_id
    INNER JOIN category ON category.category_id = film_category.category_id) rev_tab
GROUP BY category
ORDER BY gross_revenue DESC
LIMIT 5; 

-- 8b. How would you display the view that you created in 8a?
SELECT * from top_categories;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_categories;