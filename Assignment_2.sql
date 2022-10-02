---ASSIGNMENT 2 ----

/*
1. Product Sales
You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' 
buy the product below or not.

1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)

To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.
*/

--First we should change the database

USE SampleRetail

--Created a view with the details of customer who bought the first product

CREATE VIEW customer_HDD_product
AS
SELECT DISTINCT A.customer_id, A.First_Name, A.Last_Name
FROM sale.customer A, sale.orders B, sale.order_item C, product.product D
WHERE A.customer_id = B.customer_id
AND B.order_id = C.order_id
AND C.product_id = D.product_id
AND D.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'

--Created a view with the details of customer who bought the second product

CREATE VIEW customer_polk_product
AS
SELECT DISTINCT A.customer_id, A.First_Name, A.Last_Name
FROM sale.customer A, sale.orders B, sale.order_item C, product.product D
WHERE A.customer_id = B.customer_id
AND B.order_id = C.order_id
AND C.product_id = D.product_id
AND D.product_name = 'Polk Audio - 50 W Woofer - Black'

--Created a view with the details of customer who bought the both, buy using above tables.

CREATE VIEW buyed_both AS
SELECT *, other_product = 'YES'
FROM customer_HDD_product
WHERE customer_id IN (
SELECT customer_id
FROM customer_polk_product)

--Created a view with the details of customer who bought only one, buy using above tables.

CREATE VIEW buyed_one AS
SELECT *, other_product = 'NO'
FROM customer_HDD_product
WHERE customer_id NOT IN (
SELECT customer_id
FROM customer_polk_product)

--Made a union to see the customers who bought both products and who bought only one product.

(
 SELECT 
  * 
   FROM buyed_both
)
UNION
(
 SELECT 
  * 
   FROM buyed_one
)
ORDER BY customer_id ASC


/*
2. Conversion Rate
Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements 
given by an E-Commerce company. 
Write a query to return the conversion rate for each Advertisement type.
*/

--First lest create our table.

CREATE TABLE Actions (
Visitor_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
Adv_Type VARCHAR(10),
Action VARCHAR(20)
);

--Now inserting the values as below.

INSERT INTO Actions(Adv_Type, Action)
VALUES 
('A', 'Left' ),
('A', 'Order' ),
('B', 'Left' ),
('A', 'Order' ),
('A', 'Review' ),
('A', 'Left' ),
('B', 'Left' ),
('B', 'Order' ),
('B', 'Review' ),
('A', 'Review' )

--It is query time. Let's check the insights in our table.

SELECT Action, COUNT(Action) Cnt_Act
FROM Actions
GROUP BY Action


--Made a temperory table to be able to use the count of adv type for next query.
SELECT Adv_Type, Count(Action) Cnt_Adv_Type
INTO #Total_Cnt_Adv_Type
FROM Actions
GROUP BY Adv_Type

SELECT Adv_Type, Count(Action) Cnt_Order
INTO #Total_Cnt_Order
FROM Actions
WHERE Action = 'Order'
GROUP BY Adv_Type, Action

--Let's get the conversion rate by using above temporary tables.

SELECT A.Adv_Type, CAST(ROUND((A.Cnt_Order * 0.1) / (B.Cnt_Adv_Type * 0.1),2)AS DECIMAL(10,2)) Conversion_Rate
FROM #Total_Cnt_Order A, #Total_Cnt_Adv_Type B
WHERE A.Adv_Type = B.Adv_Type


