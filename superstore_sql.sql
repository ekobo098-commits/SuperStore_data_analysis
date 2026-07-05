-- ============================================================
-- Project      : Superstore Sales Analysis
-- Database     : PostgreSQL
-- Dataset      : Superstore
-- Description  : Business insights using SQL
-- ============================================================


SELECT *
FROM superstore;

---------------------------------------------------------------
-- Question 1
-- What is the total sales and total profit of the company?
---------------------------------------------------------------

SELECT
    ROUND(SUM(sales)::numeric,2) AS total_sales,
    ROUND(SUM(profit)::numeric,2) AS total_profit
FROM superstore;

---------------------------------------------------------------
-- Question 2
-- Which region generates the highest sales?
---------------------------------------------------------------

SELECT
    region,
    ROUND(SUM(sales)::numeric,2) AS total_sales
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

---------------------------------------------------------------
-- Question 3
-- Which city generates the highest sales?
---------------------------------------------------------------

SELECT
    city,
    ROUND(SUM(sales)::numeric,2) AS total_sales
FROM superstore
GROUP BY city
ORDER BY total_sales DESC;

---------------------------------------------------------------
-- Question 4
-- Which states generate the highest sales?
---------------------------------------------------------------

SELECT
    state,
    ROUND(SUM(sales)::numeric,2) AS total_sales
FROM superstore
GROUP BY state
ORDER BY total_sales DESC;

---------------------------------------------------------------
-- Question 5
-- Which states,city,region generate the highest profit?
---------------------------------------------------------------

SELECT
    state,
    ROUND(SUM(profit)::numeric,2) AS total_profit
FROM superstore
GROUP BY state
ORDER BY total_profit DESC;

SELECT
    city,
    ROUND(SUM(profit)::numeric,2) AS total_profit
FROM superstore
GROUP BY city
ORDER BY total_profit DESC;

SELECT
    region,
    ROUND(SUM(profit)::numeric,2) AS total_profit
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;

---------------------------------------------------------------
-- Question 6
-- Which product category generates the highest profit and sales?
---------------------------------------------------------------

SELECT
    category,
    ROUND(SUM(profit)::numeric,2) AS total_profit
FROM superstore
GROUP BY category
ORDER BY total_profit DESC;

SELECT
    category,
    ROUND(SUM(sales)::numeric,2) AS total_sales
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

---------------------------------------------------------------
-- Question 7
-- Which sub-category generates the highest sales?
---------------------------------------------------------------

SELECT
    sub_category,
    ROUND(SUM(sales)::numeric,2) AS total_sales
FROM superstore
GROUP BY sub_category
ORDER BY total_sales DESC;

---------------------------------------------------------------
-- Question 8
-- What are the top 3 most profitable sub-categories
-- within each category?
---------------------------------------------------------------

WITH cte AS
(
    SELECT
        category,
        sub_category,
        SUM(profit) AS total_profit,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY SUM(profit) DESC
        ) AS rn

    FROM superstore

    GROUP BY category, sub_category
)

SELECT
    category,
    sub_category,
    total_profit
FROM cte
WHERE rn <= 3;

---------------------------------------------------------------
-- Question 9
-- What are the top 3 most profitable products
-- within each category?
---------------------------------------------------------------

WITH cte AS
(
    SELECT
        category,
        product_name,
        SUM(profit) AS total_profit,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY SUM(profit) DESC
        ) AS rn

    FROM superstore

    GROUP BY category, product_name
)

SELECT
    category,
    product_name,
    total_profit
FROM cte
WHERE rn <= 3;

---------------------------------------------------------------
-- Question 10
-- Which customers are the most valuable?
-- Classify customers into Platinum, Gold,
-- Silver and Bronze based on total sales.
---------------------------------------------------------------

SELECT

    customer_name,

    ROUND(SUM(sales)::numeric,2) AS total_sales,

    CASE

        WHEN SUM(sales) > 10000 THEN 'Platinum'
        WHEN SUM(sales) >= 5000 THEN 'Gold'
        WHEN SUM(sales) >= 2000 THEN 'Silver'
        ELSE 'Bronze'

    END AS customer_tier

FROM superstore

GROUP BY customer_name

ORDER BY total_sales DESC;

---------------------------------------------------------------
-- Question 11
-- Which products consistently lose money?
-- (Negative total profit and sold more than 20 units.)
---------------------------------------------------------------

SELECT

    product_name,

    SUM(quantity) AS total_quantity,

    SUM(profit) AS total_profit

FROM superstore

GROUP BY product_name

HAVING
    SUM(profit) < 0
    AND SUM(quantity) > 20

ORDER BY total_profit;

---------------------------------------------------------------
-- Question 12
-- Which sub-categories receive the highest average
-- discount and how does that affect profitability?
---------------------------------------------------------------

SELECT

    sub_category,

    ROUND(AVG(discount)::numeric,2) AS avg_discount,

    ROUND(AVG(profit)::numeric,2) AS avg_profit,

    ROUND(SUM(sales)::numeric,2) AS total_sales

FROM superstore

GROUP BY sub_category

ORDER BY avg_discount DESC,
         avg_profit;

---------------------------------------------------------------
-- Question 13
-- How have sales and profits changed over the years?
---------------------------------------------------------------

SELECT

    EXTRACT(YEAR FROM order_date) AS year,

    ROUND(SUM(sales)::numeric,2) AS total_sales,

    ROUND(SUM(profit)::numeric,2) AS total_profit

FROM superstore

GROUP BY year

ORDER BY year;

---------------------------------------------------------------
-- Question 14
-- Which months generate the highest sales and profit?
---------------------------------------------------------------

SELECT

    EXTRACT(MONTH FROM order_date) AS month,

    ROUND(SUM(sales)::numeric,2) AS total_sales,

    ROUND(SUM(profit)::numeric,2) AS total_profit

FROM superstore

GROUP BY month

ORDER BY month;

---------------------------------------------------------------
-- Question 15
-- How do different discount levels affect
-- sales and profitability?
---------------------------------------------------------------

WITH discount_analysis AS
(
    SELECT

        CASE

            WHEN discount = 0 THEN 'No Discount'

            WHEN discount <= 0.20 THEN 'Low (1-20%)'

            WHEN discount <= 0.40 THEN 'Medium (21-40%)'

            ELSE 'High (>40%)'

        END AS discount_level,

        sales,

        profit

    FROM superstore
)

SELECT

    discount_level,

    COUNT(*) AS total_orders,

    ROUND(AVG(sales)::numeric,2) AS avg_sales,

    ROUND(AVG(profit)::numeric,2) AS avg_profit,

    ROUND(SUM(profit)::numeric,2) AS total_profit

FROM discount_analysis

GROUP BY discount_level

ORDER BY

CASE discount_level

    WHEN 'No Discount' THEN 1

    WHEN 'Low (1-20%)' THEN 2

    WHEN 'Medium (21-40%)' THEN 3

    ELSE 4

END;