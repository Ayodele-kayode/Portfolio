
SELECT sales.customer_id, order_date, join_date, menu.product_id, price
FROM danny_diner.dbo.sales AS sales
Join danny_diner.dbo.menu AS menu
ON sales.product_id = menu.product_id
JOIN danny_diner.dbo.members AS members
ON sales.customer_id = members.customer_id

-------------------------------------------------------------------------------------------------------
--Calculate the total amount spent by each customer

SELECT sales.customer_id,SUM(menu.price) AS TotalAmountSpent
FROM danny_diner.dbo.sales AS sales
Join danny_diner.dbo.menu AS menu
ON sales.product_id = menu.product_id
Group by sales.customer_id

-------------------------------------------------------------------------------------------------------
--How many days has each customer visited the restaurant?


SELECT sales.customer_id, Count(DISTINCT(order_date)) AS NoOfDays
FROM danny_diner.dbo.sales AS sales
Join danny_diner.dbo.menu AS menu
ON sales.product_id = menu.product_id
Group by sales.customer_id
Order by sales.customer_id

-------------------------------------------------------------------------------------------------------
--What was the first item from the menu purchased by each customer?
WITH RankedSales AS (
    SELECT
        sales.customer_id,
        menu.product_name,
        sales.order_date,
        ROW_NUMBER() OVER (PARTITION BY 
		sales.customer_id 
		ORDER BY sales.order_date) AS rowNumber
    FROM
        danny_diner.dbo.sales AS sales
    JOIN
       danny_diner.dbo.menu AS menu ON sales.product_id = menu.product_id
)
SELECT
    customer_id,
    product_name AS first_purchased_item
FROM
    RankedSales
WHERE
    rowNumber = 1
ORDER BY
    customer_id;

-------------------------------------------------------------------------------------------------------
--What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
    M.product_name AS most_purchased_item,
    COUNT(*) AS purchase_count
FROM
   danny_diner.dbo.sales S
JOIN
    danny_diner.dbo.menu M ON S.product_id = M.product_id
GROUP BY
    M.product_name
ORDER BY
    purchase_count DESC

-------------------------------------------------------------------------------------------------------
	--Which item was the most popular for each customer?
	--
	WITH RankedItems AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM
        danny_diner.dbo.sales s
    JOIN
        danny_diner.dbo.menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id, m.product_name
)
SELECT
    customer_id,
    product_name AS most_popular_item,
    purchase_count
FROM
    RankedItems
WHERE
    rn = 1
ORDER BY
    customer_id;

------------------------------------------------------------------------------------------------------
	--Which item was purchased first by the customer after they became a member?

	WITH RankedPurchases AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM
        danny_diner.dbo.sales s
    JOIN
        danny_diner.dbo.menu m ON s.product_id = m.product_id
    JOIN
       danny_diner.dbo.members mem ON s.customer_id = mem.customer_id
    WHERE
        s.order_date >= mem.join_date
)
SELECT
    customer_id,
    product_name AS first_purchase_after_membership
FROM
    RankedPurchases
WHERE
    rn = 1
ORDER BY
    customer_id;

	------------------------------------------------------------------------------------------------------
	--Which item was purchased just before the customer became a member?

	WITH LaggedPurchases AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        LAG(mem.join_date) OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS prev_membership_date
    FROM
        danny_diner.dbo.sales s
     JOIN
        danny_diner.dbo.menu m ON s.product_id = m.product_id
    JOIN
       danny_diner.dbo.members mem ON s.customer_id = mem.customer_id
	   )
SELECT
    customer_id,
    product_name AS last_purchase_before_membership,
    order_date AS purchase_date
FROM
    LaggedPurchases
WHERE
    prev_membership_date IS NOT NULL
ORDER BY
    customer_id, order_date DESC;

	------------------------------------------------------------------------------------------------------
	--What is the total items and amount spent for each member before they became a member?

	WITH MemberPurchases AS (
    SELECT
        s.customer_id,
        m.product_name,
        m.price,
        s.order_date
    FROM
       danny_diner.dbo.sales s
    JOIN
        danny_diner.dbo.menu m ON s.product_id = m.product_id
    JOIN
       danny_diner.dbo.members mem ON s.customer_id = mem.customer_id
    WHERE
        s.order_date < mem.join_date
)
SELECT
    customer_id,
    COUNT(*) AS total_items_purchased,
    SUM(price) AS total_amount_spent
FROM
    MemberPurchases
GROUP BY
    customer_id
ORDER BY
    customer_id;

------------------------------------------------------------------------------------------------------
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

	WITH PurchasePoints AS (
    SELECT
        s.customer_id,
        m.product_name,
        m.price,
        CASE WHEN m.product_name = 'sushi' THEN 2 ELSE 1 END AS points_multiplier
    FROM
        danny_diner.dbo.sales s
    JOIN
        danny_diner.dbo.menu m ON s.product_id = m.product_id
)
SELECT
    customer_id,
    SUM(price * points_multiplier * 10) AS total_points
FROM
    PurchasePoints
GROUP BY
    customer_id
ORDER BY
    customer_id;

------------------------------------------------------------------------------------------------------
--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH PurchasePoints AS (
    SELECT
        s.customer_id,
        m.product_name,
        m.price,
        s.order_date,
        mem.join_date,
        CASE
            WHEN (s.order_date <= DATEADD(WEEK, 1, mem.join_date)) THEN 2
            WHEN m.product_name = 'sushi' THEN 2
            ELSE 1
        END AS points_multiplier
   FROM
       danny_diner.dbo.sales s
    JOIN
        danny_diner.dbo.menu m ON s.product_id = m.product_id
    JOIN
       danny_diner.dbo.members mem ON s.customer_id = mem.customer_id
)
SELECT
    customer_id,
    SUM(price * points_multiplier * 10) AS total_points
FROM
    PurchasePoints
WHERE
    MONTH(order_date) = 1 -- Only consider purchases in January
GROUP BY
    customer_id
ORDER BY
    customer_id;
