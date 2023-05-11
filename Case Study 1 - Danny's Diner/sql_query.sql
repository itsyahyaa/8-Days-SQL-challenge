-- Active: 1679489118657@@127.0.0.1@3306@8_Days_SQL_challenge
--  Case Study #1 Questions *
-- 1. What is the total amount each customer spent at the restaurant?
SELECT
    s.customer_id,
    sum(m.price) as Total_Price
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
    C_ID
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
WITH
    fav_item_cte AS (
        SELECT
            s.customer_id,
            m.product_name,
            COUNT(m.product_id) as order_count,
            DENSE_RANK() OVER (
                PARTITION BY
                    s.customer_id
                ORDER BY
                    COUNT(s.customer_id) DESC
            ) as rank1
        FROM
            menu as m
            JOIN sales as s ON s.product_id = m.product_id
        GROUP BY
            s.customer_id,
            m.product_name
    )
SELECT
    customer_id,
    product_name,
    order_count
from
    fav_item_cte
where
    rank1 = 1;

--6. Which item was purchased first by the customer after they became a member?
WITH
    member_sales_cte AS (
        SELECT
            s.customer_id,
            m.join_date,
            s.order_date,
            s.product_id,
            DENSE_RANK() OVER (
                PARTITION BY
                    s.customer_id
                ORDER BY
                    s.order_date
            ) as Ranking
        FROM
            members as m
            JOIN sales as s ON s.customer_id = m.customer_id
        WHERE
            m.join_date <= s.order_date
    )
SELECT
    s.customer_id,
    s.order_date,
    m2.product_name
from
    member_sales_cte as s
    join menu as m2 ON s.product_id = m2.product_id
WHERE
    Ranking = 1;

--7. Which item was purchased just before the customer became a member?
WITH
    prior_member_purchased_cte AS (
        SELECT
            s.customer_id,
            m.join_date,
            s.order_date,
            s.product_id,
            DENSE_RANK() OVER (
                PARTITION BY
                    s.customer_id
                ORDER BY
                    s.order_date DESC
            ) as ranking
        from
            sales as s
            JOIN members as m ON s.customer_id = m.customer_id
        WHERE
            s.order_date < m.join_date
    )
SELECT
    s.customer_id,
    s.order_date,
    s.join_date,
    m2.product_name
FROM
    prior_member_purchased_cte as s
    join menu as m2 on s.product_id = m2.product_id
WHERE
    ranking = 1
ORDER BY
    s.customer_id;

--8. What is the total items and amount spent for each member before they became a member?
SELECT
    s.customer_id,
    COUNT(DISTINCT s.product_id) as unique_menu_item,
    SUM(m2.price) as total_sales
FROM
    sales as s
    join members as m on s.customer_id = m.customer_id
    join menu as m2 on s.product_id = m2.product_id
WHERE
    m.join_date < s.order_date
GROUP BY
    s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH
    price_points_cte AS (
        SELECT *,
            CASE
                WHEN product_name = 'sushi' THEN price * 20
                ELSE price * 10
            END as points
        FROM
            menu
    )
SELECT
    s.customer_id,
    sum(p.points) as total_points
FROM
    price_points_cte as p
    JOIN sales as s ON s.product_id = p.product_id
    GROUP BY s.customer_id;

SELECT 
    *, 
    DATEADD(DAY, 6, join_date) AS valid_date, 
		EOMONTH('2021-01-31') AS last_date
	FROM members AS m