--QUIN IRIS 


/*
 sql practice 

 Instructions:
 - There are 4 tables in the folder, make sure to correctly import the tables
   (using code) and write queries to answer each of the questions below.
 */

#best practice
show databases;
drop database if exists iris; -- drop a database
create database iris;

use iris;
show tables;
drop table if exists customer; -- drop table if it already exists

-- create table first to avoid duplicate entries
-- Creating the customer table
create table  customer (
    cust_id INT,
    name VARCHAR(255),
    city VARCHAR(255),
    grade INT,
    salesman_id INT
);
describe customer;
truncate customer; -- empties the table no to repeat addition of the same data
truncate nobel_win;
truncate orders;
truncate salesman;

drop table if exists nobel_win;
drop table if exists orders;
drop table if exists salesman;

-- Creating the nobel_win table
CREATE TABLE nobel_win (
    year INT,
    subject VARCHAR(100),
    winner VARCHAR(100),
    country VARCHAR(100),
    category VARCHAR(100)
);


-- Creating the orders table
CREATE TABLE orders (
    ord_no INT PRIMARY KEY,
    purch_amt DECIMAL(10, 2),
    ord_date DATE,
    customer_id INT,
    salesman_id INT
);

-- Creating the salesman table
CREATE TABLE salesman (
    salesman_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    commission DECIMAL(10, 2)
);


-- Loading Data from the CSV
-- set global local_infile = 1;
-- SHOW VARIABLES LIKE 'secure_file_priv';
-- SET GLOBAL secure_file_priv = "/tmp/";


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/Python and SQL Quiz/customer.csv'
INTO TABLE customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/Python and SQL Quiz/nobel_win.csv'
INTO TABLE nobel_win
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/Python and SQL Quiz/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/Python and SQL Quiz/salesman.csv'
INTO TABLE salesman
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM orders;

SELECT count(*) from customer;
SELECT count(*) from nobel_win;
SELECT count(*) from orders;
SELECT count(*) from salesman;


 -- Question 1
    -- Using the `nobel_win` table, write a SQL query to show all the winners of the
    -- Nobel prize in the year 1970, excluding the subject Physiology and Economics.

SELECT *
FROM nobel_win
WHERE year = 1970
  AND subject NOT IN ('Physiology', 'Economics');




-- Question 2
    -- Using the `order` table, write a SQL statement to exclude the rows which satisfy:
    -- (1) Order dates are 2012-08-17 and purchase amount is below 1000
    -- OR
    -- (2) Customer id is greater than 3005 and purchase amount is below 1000.

--  Exclude rows from the orders table based on specific conditions
SELECT *
FROM orders
WHERE NOT (
    (ord_date = '2012-08-17' AND purch_amt < 1000) OR
    (customer_id > 3005 AND purch_amt < 1000)
);




-- Question 3
    -- Using the `customer` table, write a SQL statement to find the information of all
    -- customers whose first name and/or last name ends with "n".
    -- E.g. Ryan Reynolds, Ed Sheeran, Elton John (note: these names are just examples)

-- find customers whose first or last name ends with 'n'
SELECT *
FROM customer
WHERE name LIKE '% n' OR name LIKE '%n';


-- Question 4
    -- Using the `orders` table, write a SQL statement to find the highest purchase
    -- amount ordered by each customer on a particular date with their ID, order date,
    -- and highest purchase amount.

-- finds the highest purchase amount by each customer on each order date
SELECT customer_id, ord_date, MAX(purch_amt) AS max_purchase_amount
FROM orders
GROUP BY customer_id, ord_date
ORDER BY customer_id, ord_date;


-- Question 5
    -- Using the `salesman` and `customer` tables, write a SQL statement to prepare a list
    -- with the salesman name, customer name, and cities for the salesmen and customer who
    -- belong to the same city.

-- to List salesman name, customer name, and city for those in the same city
SELECT s.name AS salesman_name, c.name AS customer_name, s.city
FROM salesman s
JOIN customer c ON s.city = c.city
ORDER BY s.city;
