-- Active: 1679489118657@@127.0.0.1@3306@8_Days_SQL_challenge
--  Case Study #1 Questions *
-- 1. What is the total amount each customer spent at the restaurant?
SELECT
    s.customer_id,
    sum(m.price)
from
    sales as s
    JOIN menu as m on s.product_id = m.product_id
GROUP BY
    s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
    CUSTOMER_ID AS C_ID,
    COUNT(DISTINCT ORDER_DATE) AS N_DAYS
FROM
    SALES
GROUP BY
    CUSTOMER_ID
ORDER BY
    N_DAYS DESC;

-- 3. What was the first item from the menu purchased by each customer?
WITH
    First_order as (
        SELECT
            s.customer_id,
            m.product_name,
            ROW_NUMBER() OVER (
                PARTITION BY
                    s.customer_id
                ORDER BY
                    s.order_date,
                    s.product_id
            ) as RN
        FROM
            sales as s
            JOIN menu as m on s.product_id = m.product_id
    )
SELECT
    customer_id,
    product_name
from
    First_order
WHERE
    RN = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
    COUNT(s.product_id) as NPurchased,
    m.product_name
FROM
    menu as m
    JOIN sales as s on s.product_id = m.product_id
GROUP BY
    m.product_name
ORDER BY
    Npurchased DESC
LIMIT
    1;

-- 5. Which item was the most popular for each customer?
