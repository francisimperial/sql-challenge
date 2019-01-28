USE sakila;

-- 1a Display first/last names of actors
SELECT first_name, last_name FROM actor;
-- 1b Display first/last names of actors in one column
SELECT concat(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a Find ID number of actors with Joe in first name
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name LIKE 'Joe%';
-- 2b Find actors whose last name contains 'GEN'
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';
-- 2c Find actors whose last name contains 'LI' and order by last name and first name
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;
-- 2d Display country_id and country using IN from Afghanistan, Bangladesh, China
SELECT country_id, country FROM country 
WHERE country IN ('AFGHANISTAN', 'BANGLADESH', 'CHINA');

-- 3a Add column with data type blob
ALTER TABLE actor
ADD COLUMN description BLOB;
-- 3b Delete blob column
ALTER TABLE actor
DROP COLUMN description; 

-- 4a List last names of actors, as well as how many actors with that name
--    I went a little further and showed the first names along with their 
--    last name count just for fun heh
SELECT A.last_name, A.last_count, B.first_name FROM 
(
	SELECT last_name, count(*) AS last_count 
    FROM actor
    GROUP BY last_name) AS A
INNER JOIN actor AS B ON B.last_name = A.last_name;
-- 4b List last names of actors with at least two actors sharing last name
SELECT last_name, count(*) AS 'count' FROM actor
GROUP BY last_name
HAVING Count > 1;
-- 4c Change Groucho to Harpo
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- 4d Change Harpo to Groucho
UPDATE actor
SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a Recreate address table 
-- describe table for reference
describe address;
-- recreate table
SHOW CREATE TABLE address;
CREATE TABLE IF NOT EXISTS address(
	address_id SMALLINT(5) UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(50) NOT NULL,
    city_id SMALLINT(5) UNSIGNED NOT NULL,
    postal_code VARCHAR(10), 
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_update TIMESTAMP NOT NULL,
    FOREIGN KEY (city_id) REFERENCES city(city_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6a List first and last name and address of each staff member
SELECT first_name, last_name, address FROM staff
INNER JOIN address on staff.address_id = address.address_id;
-- 6b List total amount rung up by each staff member
SELECT B.first_name, B.last_name, A.Total_Amount FROM 
(
	SELECT staff_id, sum(amount) AS Total_Amount 
    FROM payment 
    GROUP BY staff_id) AS A
INNER JOIN staff AS B ON A.staff_id = B.staff_id;
-- 6c List each film and the number of actors in each film
SELECT title, count(actor_id)
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;
-- 6d List number of copies of Hunchback Impossible
SELECT title, count(inventory_id) FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE';
-- 6e Find total amount each customer has paid as well as first and last name ordered by last name
SELECT first_name, last_name, sum(amount) FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY first_name, last_name
ORDER BY last_name;

-- 7a List movies starting with K and Q
SELECT title FROM film
WHERE title LIKE 'k%' OR title LIKE 'q%'
AND language_id IN 
(
	SELECT language_id FROM language
    WHERE name = 'English');
-- 7b List names of actors in Alone Trip
SELECT first_name, last_name FROM actor
WHERE actor_id IN 
(
	SELECT actor_id FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id FROM film
        WHERE title = 'ALONE TRIP')
	);
-- 7c List names and emails of customers who live in Canada
SELECT first_name, last_name, email FROM customer cu
JOIN address a ON a.address_id = cu.address_id
JOIN city c ON c.city_id = a.city_id
JOIN country cn ON cn.country_id = c.country_id
WHERE cn.country = 'CANADA';
-- 7d List films categorized under Family
SELECT title FROM film 
WHERE film_id IN
(
	SELECT film_id FROM film_category
    WHERE category_id IN
    (
		SELECT category_id FROM category 
        WHERE name = 'Family')
	);
-- 7e List most frequently rented movies in descending order
SELECT title, count(f.film_id) AS Rental_Count
FROM film f 
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY title ORDER BY Rental_Count DESC;
-- 7f Show amount of money each store brought in
SELECT s.store_id, sum(amount) FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.store_id;
-- 7g Display store_id, and the city and country it's in
SELECT store_id, city, country FROM store s 
JOIN address a ON a.address_id = s.address_id
JOIN city c ON c.city_id = a.address_id
JOIN country cn ON c.country_id = cn.country_id;
-- 7h Show Top Five films in terms of total Gross Revenue in Descending order
SELECT c.name Top_Five, sum(p.amount) Gross_Revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON i.film_id = fc.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY Top_Five ORDER BY Gross_Revenue DESC LIMIT 5;

-- 8a Create a view that is easily accesses Top Five Revenue
DROP VIEW IF EXISTS Top_Five_Revenue;
CREATE VIEW Top_Five_Revenue AS
SELECT c.name Top_Five, sum(p.amount) Gross_Revenue
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN inventory i ON i.film_id = fc.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY Top_Five ORDER BY Gross_Revenue DESC LIMIT 5;
-- 8b Show Created View
SELECT * FROM Top_Five_Revenue;
-- 8c Delete Created View
DROP VIEW Top_Five_Revenue;