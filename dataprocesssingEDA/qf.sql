/*****************************************

  QUIN FABROS
*****************************************/



-- Check the status of local_infile
-- Enable local_infile if necessary
-- Check the directory for secure file privilege
show variables like "local_infile";
SET GLOBAL local_infile = 'ON';
show variables like "secure_file_priv";


-- Drop the existing ctr database if it exists, and create a new one
drop database if exists ctr;
create database if not exists ctr;
use ctr;

-- use if the rest does not work
# CREATE TABLE combined_data (
#     maid_transactions VARCHAR(255),
#     payment_time_transactions DATETIME,
#     money DECIMAL(10, 2),
#     kind_pay VARCHAR(50),
#     kind_card VARCHAR(50),
#     mid_transactions VARCHAR(255),
#     network VARCHAR(255),
#     industry VARCHAR(255),
#     sex VARCHAR(50),
#     adr TEXT,
#     view_time DATETIME,
#     payment_time_views DATETIME,
#     maid_views VARCHAR(255),
#     mid_views VARCHAR(255),
#     ad_id_tvca VARCHAR(255),
#     click_time DATETIME,
#     payment_time_clicks DATETIME,
#     maid_clicks VARCHAR(255),
#     mid_clicks VARCHAR(255),
#     ad_id_clicks VARCHAR(255),
#     clicked TINYINT(1)
# );
#
#
#
# load data local infile '/Users/irisfabros/Desktop/midterm/Python-ML_ Use for low-capacity computers/ctrdata.csv'
# into table combined_data
# character set 'utf8'
# fields terminated by '\t'
# Enclosed by '"'
# lines terminated by '\n'
# (maid_transactions, payment_time_transactions, money, kind_pay, kind_card, mid_transactions, network, industry, sex, adr, view_time, payment_time_views, maid_views, mid_views, ad_id_tvca, click_time, payment_time_clicks, maid_clicks, mid_clicks, ad_id_clicks, clicked);
# ;
#
# SELECT * FROM combined_data LIMIT 10;




-- make tables for csv files that contain views made on ads
-- I. Create the views table
drop table if exists views;
CREATE TABLE views (
    view_time DATETIME NOT NULL,
    user_id VARCHAR(255) BINARY NOT NULL,
    ad_id VARCHAR(255) BINARY NOT NULL,
    add_info VARCHAR(255),
    PRIMARY KEY (user_id, view_time)
) ;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-view-01-09.csv'
INTO TABLE views
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(view_time, @skip, user_id, ad_id, add_info);

LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-view-10.csv'
INTO TABLE views
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(view_time, @skip, user_id, ad_id, add_info);

LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-view-11-31.csv'
INTO TABLE views
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','  -- or '\t' if it's tab-separated
OPTIONALLY ENCLOSED BY '"'  -- remove if the fields are not enclosed by quotes
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(view_time, @skip, user_id, ad_id, add_info);


SELECT * FROM views LIMIT 10;




-- make tables for csv files that contain clicks made on ads
-- II.Create the clicks table

DROP TABLE IF EXISTS clicks;

CREATE TABLE clicks (
    click_time DATETIME NOT NULL,
    user_id VARCHAR(255) BINARY NOT NULL,
    ad_id VARCHAR(255) BINARY NOT NULL,
    PRIMARY KEY (user_id, click_time)
);

ALTER TABLE clicks ADD COLUMN add_info VARCHAR(255);

DESCRIBE clicks;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-click-01-09.csv'
INTO TABLE clicks
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(click_time, @skip, user_id, ad_id, add_info);



LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-click-10.csv'
INTO TABLE clicks
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'  --  values are quoted
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@click_time_str, @user_id, @ad_id, @add_info)
SET
    click_time = STR_TO_DATE(@click_time_str, '%Y-%m-%d %H:%i:%s'),
    user_id = NULLIF(REPLACE(@user_id, '"', ''), ''),  -- Remove double quotes and convert empty strings to NULL
    ad_id = NULLIF(REPLACE(@ad_id, '"', ''), ''),
    add_info = NULLIF(REPLACE(@add_info, '"', ''), '');


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-click-11-31.csv'
INTO TABLE clicks
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(click_time, @skip, user_id, ad_id, add_info);


SELECT * FROM clicks LIMIT 10;





-- make tables for csv file that contain ads info
-- III.Create the ad_info table
drop table if exists ad_info;
CREATE TABLE ad_info (
    ad_id INT NOT NULL,
    ad_location VARCHAR(255) NOT NULL,
    ad_label VARCHAR(255) NOT NULL,
    unknown INT,
    begin_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    pic_url VARCHAR(500), -- Increased the size to accommodate potentially long URLs
    ad_url VARCHAR(500),
    ad_desc_url VARCHAR(500),
    ad_copy TEXT,
    min_money DECIMAL(10, 2),
    mid VARCHAR(255),
    order_num INT,
    maid VARCHAR(255),
    city_id INT,
    idu_category INT,
    click_hide BOOLEAN,
    price DECIMAL(10, 2),
    sys VARCHAR(255),
    network VARCHAR(255),
    user_gender ENUM('male', 'female', 'other') NOT NULL,
    payment_kind VARCHAR(255),
    PRIMARY KEY (ad_id)
) CHARSET=utf8mb4;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/aug-ad-info-with-tags.csv'
INTO TABLE ad_info
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ad_id, ad_label, ad_location, unknown, @begin_time, @end_time, @ad_url, @ad_desc_url, ad_copy,
 min_money, mid, order_num, maid, city_id, idu_category, click_hide, price, sys,
 network, user_gender, payment_kind)
SET
    begin_time = IF(@begin_time = '', NULL, STR_TO_DATE(@begin_time, '%Y-%m-%d %H:%i:%s')),
    end_time = IF(@end_time = '', NULL, STR_TO_DATE(@end_time, '%Y-%m-%d %H:%i:%s')),
    pic_url = @ad_url, --  @ad_url from CSV should map to pic_url in the database
    ad_url = @ad_desc_url; --  @ad_desc_url from CSV should map to ad_url in the database


SELECT * FROM ad_info LIMIT 10;






-- make table for csv file that contain transactions
-- IV. Create the transaction table
drop table if exists transactions;
CREATE TABLE transactions (
    user_id VARCHAR(255) NOT NULL,
    payment_time DATETIME NOT NULL,
    money DECIMAL(10, 2) NOT NULL,
    kind_pay VARCHAR(50),
    kind_card VARCHAR(50),
    mid VARCHAR(255),
    network VARCHAR(255),
    industry VARCHAR(255),
    gender VARCHAR(50),
    address TEXT,
    PRIMARY KEY (user_id, payment_time)
) CHARSET=utf8mb4;


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/trans_4.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/trans_5.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

SET GLOBAL innodb_lock_wait_timeout = 120; -- file is too large
OPTIMIZE TABLE transactions; -- encountered lock wait timeouts


LOAD DATA LOCAL INFILE '/Users/irisfabros/Desktop/midterm/trans_6.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

SELECT * FROM transactions LIMIT 10;




-- filter down to only one day ( data from '2017-08-01' to '2017-08-02')
-- V. Create Filtered Tables: For each table,  included only the data for specified date range


-- Filter 'views' table
CREATE TABLE views_filtered AS
SELECT *
FROM views
WHERE view_time BETWEEN '2017-08-01 00:00:00' AND '2017-08-02 00:00:00';

-- Filter 'clicks' table
CREATE TABLE clicks_filtered AS
SELECT *
FROM clicks
WHERE click_time BETWEEN '2017-08-01 00:00:00' AND '2017-08-02 00:00:00';

-- Filter 'ad_info' table
drop table if exists ad_info_filtered;
CREATE TABLE ad_info_filtered AS
SELECT *
FROM ad_info
WHERE begin_time BETWEEN '2017-08-01 00:00:00' AND '2017-08-02 00:00:00';

-- Filter 'transactions' table
CREATE TABLE transactions_filtered AS
SELECT *
FROM transactions
WHERE payment_time BETWEEN '2017-08-01 00:00:00' AND '2017-08-02 00:00:00';




-- VI. Exploring Filtered Tables
-- running exploratory queries on the filtered tables to understand the data
-- Count the number of distinct users who made transactions
SELECT COUNT(DISTINCT user_id) FROM transactions_filtered;

-- Count the number of ad views and clicks
SELECT
  (SELECT COUNT(*) FROM views_filtered) AS total_views,
  (SELECT COUNT(*) FROM clicks_filtered) AS total_clicks;




-- VII.Run database queries to prepare modeling datasets
-- How many days of data is there?
-- VIII. Answer the questions below in your queries
-- What are the total transactions, views, and clicks in your final table (after Joins/unions for all or selected days )? and what are the start and end Datetime of the dataset?
#after creating indices ..
#joining tables
-- Add labels to your table (clicked or not)




-- Indexing
-- Create indexes for views table
CREATE INDEX idx_user_id_views ON views(user_id);
CREATE INDEX idx_ad_id_views ON views(ad_id);

-- Create indexes for clicks table
CREATE INDEX idx_user_id_clicks ON clicks(user_id);
CREATE INDEX idx_ad_id_clicks ON clicks(ad_id);

-- Create an index on the 'ad_id' field for the ad_info table
CREATE INDEX idx_ad_id_ad_info ON ad_info(ad_id);

-- Create an index on the 'user_id' field for the transactions table
CREATE INDEX idx_user_id_transactions ON transactions(user_id);

-- Joins and modeling dataset  structured
-- How do we get the label? --- if a record exists in the clicks table for a corresponding view, then the ad was clicked

SELECT
    t.user_id,
    t.payment_time,
    t.money,
    t.kind_pay,
    v.view_time,
    c.click_time,
    ai.ad_label,
    ai.begin_time,
    ai.end_time,
    CASE WHEN c.click_time IS NOT NULL THEN 1 ELSE 0 END AS clicked --  create a label based on whether there was a click(derived by checking if an ad view resulted in a click)
FROM
    transactions t
LEFT JOIN views v ON t.user_id = v.user_id AND DATE(t.payment_time) = DATE(v.view_time)
LEFT JOIN clicks c ON t.user_id = c.user_id AND DATE(t.payment_time) = DATE(c.click_time)
LEFT JOIN ad_info ai ON v.ad_id = ai.ad_id OR c.ad_id = ai.ad_id
WHERE
    t.payment_time BETWEEN '2017-08-01' AND '2017-08-02'; --  filters the transactions to the specified dates( filter records from 2017-08-01 to 2017-08-02)

-- count of days in  dataset
-- difference in days between the earliest and the latest payment_time in transactions table
-- adding 1 to include both the start and end date in the count

SELECT
    DATEDIFF(MAX(payment_time), MIN(payment_time)) + 1 as total_days
FROM
    transactions;

-- store the datetime of when the view or click occurred
SELECT
    COUNT(*) AS total_views,
    MIN(view_time) AS start_datetime,
    MAX(view_time) AS end_datetime
FROM views
WHERE view_time BETWEEN '2017-08-01' AND '2017-08-02';

SELECT
    COUNT(*) AS total_clicks,
    MIN(click_time) AS start_datetime,
    MAX(click_time) AS end_datetime
FROM clicks
WHERE click_time BETWEEN '2017-08-01' AND '2017-08-02';



SELECT
  a.ad_label,
  COUNT(*) AS total_clicks,  -- Assuming each record in `clicks` is a click(- Count of all the clicks
  AVG(a.min_money) AS avg_min_spend -- Average minimum spend on ads
FROM
  clicks c -- From the 'clicks' table aliased as 'c'
JOIN
  ad_info a ON c.ad_id = a.ad_id ---- Joining 'ad_info' table aliased as 'a' on matching 'ad_id'
WHERE
  c.click_time BETWEEN '2017-08-01' AND '2017-08-02' ---- Only considering clicks within the specified date range
GROUP BY    -- Grouping results by 'ad_label' from 'ad_info' for aggregate functions
  a.ad_label;



-- drop when done
# DROP TABLE IF EXISTS transactions_filtered;
# DROP TABLE IF EXISTS views_filtered;
# DROP TABLE IF EXISTS clicks_filtered;
# DROP TABLE IF EXISTS ad_info_filtered;








-- Save the results to a table/view (use for the ML part


-- Create a table for view statistics
CREATE TABLE view_statistics AS
SELECT
    COUNT(*) AS total_views,
    MIN(view_time) AS start_datetime,
    MAX(view_time) AS end_datetime
FROM views
WHERE view_time BETWEEN '2017-08-01' AND '2017-08-02';

-- Create a table for click statistics
CREATE TABLE click_statistics AS
SELECT
    COUNT(*) AS total_clicks,
    MIN(click_time) AS start_datetime,
    MAX(click_time) AS end_datetime
FROM clicks
WHERE click_time BETWEEN '2017-08-01' AND '2017-08-02';



-- Get totals and date range for transactions, views, and clicks
SELECT
    (SELECT COUNT(*) FROM transactions_filtered) AS total_transactions,
    (SELECT COUNT(*) FROM views_filtered) AS total_views,
    (SELECT COUNT(*) FROM clicks_filtered) AS total_clicks,
    (SELECT MIN(payment_time) FROM transactions_filtered) AS start_datetime,
    (SELECT MAX(payment_time) FROM transactions_filtered) AS end_datetime;

-- Add labels to the transactions indicating whether there was a click
CREATE TABLE transactions_with_labels AS
SELECT
    t.*,
    IF(c.click_time IS NOT NULL, 1, 0) AS clicked
FROM
    transactions_filtered t
LEFT JOIN
    clicks_filtered c ON t.user_id = c.user_id AND t.payment_time = c.click_time;


Describe transac_view_click;
select * from ad_info_filtered;
