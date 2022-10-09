--1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”,
--“prod_dimen”, “shipping_dimen”, Create a new table, named as
--“combined_table”.

SELECT DISTINCT A.*, B.Customer_Name, B.Customer_Segment, B.Province, B.Region, C.Order_Date, C.Order_Priority, D.Product_Category, D.Product_Sub_Category, E.Ship_Date, E.Ship_Mode
INTO
combined_table
FROM market_fact A, cust_dimen B, orders_dimen C, prod_dimen D, shipping_dimen E
WHERE A.Cust_ID = B.Cust_ID
AND A.Ord_ID = C.Ord_ID
AND A.Prod_ID = D.Prod_ID
AND A.Ship_ID = E.Ship_ID

SELECT *
FROM combined_table

---------------------------------------------------------------------------------

--2. Find the top 3 customers who have the maximum count of orders

--Below query returns the 3 customers' maximum sum of the order_quantities
SELECT TOP 3 Cust_ID, Customer_Name, SUM(Order_Quantity) order_quantity
FROM combined_table
GROUP BY Cust_ID, Customer_Name
ORDER BY 3 DESC

--Below query returns the 3 customers' maximum count of the orders
SELECT	TOP 3 Cust_ID, Customer_Name, COUNT (DISTINCT Ord_ID) CNT_ORDERS
FROM	combined_table
GROUP BY Cust_ID, Customer_Name
ORDER BY CNT_ORDERS DESC

---------------------------------------------------------------------------------

--3. Create a new column at combined_table as DaysTakenForShipping that
--contains the date difference of Order_Date and Ship_Date.

ALTER TABLE combined_table
ADD DaysTakenForDelivery INT 



UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF (DAY, Order_Date, Ship_Date)

---------------------------------------------------------------------------------

--4. Find the customer whose order took the maximum time to get shipping.

SELECT Cust_ID, Customer_Name, DaysTakenForDelivery
FROM combined_table
WHERE DaysTakenForDelivery = 
(
SELECT MAX(DaysTakenForDelivery)
FROM combined_table
)

---------------------------------------------------------------------------------

--5. Count the total number of unique customers in January and how many of them
--came back every month over the entire year in 2011

--First let's find the cust_ID who had an order in Junuary 2011.
SELECT DISTINCT Cust_ID, Order_Date
FROM combined_table
WHERE MONTH(Order_Date) = 1
AND YEAR(Order_Date) = 2011

--

SELECT DISTINCT MONTH(Order_date) Month_No, DATENAME(MONTH, Order_Date) Month_Name, COUNT(DISTINCT Cust_ID) Order_Qty
FROM combined_table
WHERE YEAR(Order_Date) = 2011
AND Cust_ID IN
(
SELECT DISTINCT Cust_ID
FROM combined_table
WHERE MONTH(Order_Date) = 1
AND YEAR(Order_Date) = 2011
)
GROUP BY MONTH(Order_date), DATENAME(MONTH, Order_Date)
ORDER BY 1

---------------------------------------------------------------------------------

--6. Write a query to return for each user the time elapsed between the first
--purchasing and the third purchasing, in ascending order by Customer ID.


WITH T1 AS
(
SELECT Cust_ID, Ord_ID, Order_Date,
	MIN(Order_Date) OVER (PARTITION BY Cust_ID) First_Ord_Date,
	DENSE_RANK() OVER(PARTITION BY Cust_ID ORDER BY Ord_ID) order_number
FROM combined_table
), T2 AS
(
SELECT DISTINCT Cust_ID, First_Ord_Date, 
	CASE WHEN order_number = 3 THEN Order_Date END AS Third_Ord_Date
FROM T1
WHERE order_number = 3
)
SELECT *,
	DATEDIFF(DAY, First_Ord_Date, Third_Ord_Date) time_1st_to_3rd
FROM T2
ORDER BY 1

--Above we used min function to bring the first order, dense_rank to choose the third order because some order id has more than 1 repetition.
--Then we used this query to find the time difference between first and third orders.

---------------------------------------------------------------------------------

--7. Write a query that returns customers who purchased both product 11 and
--product 14, as well as the ratio of these products to the total number of
--products purchased by the customer.


--First we have got the quantity of prod 11 and 14 for each customers  who get them both.

WITH T1 AS
(
SELECT Cust_ID, 
	SUM(CASE WHEN Prod_ID = 11 THEN Order_Quantity else 0 END) cnt_of_11,
	SUM(CASE WHEN Prod_ID = 14 THEN Order_Quantity else 0 END) cnt_of_14
FROM combined_table
GROUP BY Cust_ID
HAVING
		SUM (CASE WHEN Prod_ID = 11 Then Order_Quantity else 0 end) > 0
		AND
		SUM(CASE WHEN Prod_ID = 14 Then Order_Quantity else 0 end) > 0
), T2 AS
(
SELECT A.Cust_ID, SUM(B.order_quantity) total_per_cust
FROM T1 A, combined_table B
WHERE A.Cust_ID = B.Cust_ID
GROUP BY A.Cust_ID
), T3 AS
(
SELECT T1.*, T2.total_per_cust
FROM T1, T2
WHERE T1.Cust_ID = T2.Cust_ID
)
SELECT Cust_ID, cnt_of_11, cnt_of_14,
	CAST(1.0 * cnt_of_11 / total_per_cust AS NUMERIC (4,2)) AS rate_of_11,
	CAST(1.0 * cnt_of_14 / total_per_cust AS NUMERIC (4,2)) AS rate_of_14
FROM T3
ORDER BY 1

--Customer Segmentation

--Categorize customers based on their frequency of visits. 

--First we will find the cust_IDs who never order then we will find the other customers' order counts.SELECT Cust_IDFROM cust_dimenEXCEPTSELECT Cust_IDFROM combined_table--with the above query we see that 96 of customers do not have any order however they are not included in our combined data table so we will ignore them.--Now below we checked monthly_visit of each customer, their visit rank to find the first and last order date ranks then we will use these infos--to count all orders of customers, and find the average monthly visit to have an insight to make a labeling models.CREATE VIEW Cust_Visit_Details AS WITH T1 AS(SELECT DISTINCT Cust_ID, YEAR(Order_Date) Ord_Year, MONTH(Order_Date) Ord_Month, Order_Date FROM combined_table
), T2 AS
(
SELECT DISTINCT *,
	COUNT(Cust_ID) OVER (PARTITION BY Cust_ID, Order_Date Order By Order_Date) Monthly_Visit,
	DENSE_RANK() OVER (PARTITION BY Cust_ID ORDER BY Order_Date) Visit_Ranks
FROM T1
)
SELECT *,
	MAX(Order_Date) OVER (PARTITION BY Cust_ID) Last_Order_Date,
	MIN(Order_Date) OVER (PARTITION BY Cust_ID) First_Order_Date
FROM T2

CREATE VIEW Monthly_Visit_Avg AS

WITH T1 AS
(
SELECT DISTINCT *,
	DATEDIFF(MONTH, First_Order_Date, Last_Order_Date) Month_Diff_Ord,
	MAX(Visit_Ranks) OVER (PARTITION BY Cust_ID) total_order_qty
FROM Cust_Visit_Details
)
SELECT DISTINCT Cust_ID, total_order_qty,
	Month_Diff_Ord / total_order_qty as Monthly_Order_Avg
FROM T1

---As we checked below, our time period has 47 months in our data set. So we will label customer regarding to their monthly order frequency.
SELECT DATEDIFF(MONTH, MIN(Order_Date), MAX(Order_Date))
FROM combined_table

--
SELECT Cust_ID,
	CASE 
		WHEN Monthly_Order_Avg = 0 THEN 'Churn'
		WHEN Monthly_Order_Avg > 20 THEN 'Rarely'
		WHEN Monthly_Order_Avg <= 20 AND Monthly_Order_Avg > 10 THEN 'Sometimes'
		WHEN Monthly_Order_Avg <= 10 AND Monthly_Order_Avg > 5 THEN 'Generally'
		WHEN Monthly_Order_Avg <= 5 THEN 'Always'
	END AS Customer_Visit_Label
FROM Monthly_Visit_Avg
ORDER BY 1
---------------Month-Wise Retention Rate
--Find month-by-month customer retention rate since the start of the business.

--1. Find the number of customers retained month-wise. (You can use time gaps)

CREATE VIEW Monthly_Customers AS
SELECT DISTINCT Ord_Year, Ord_Month, 
	COUNT(Cust_ID) OVER (PARTITION BY Ord_Year, Ord_Month) Total_Customers
FROM Cust_Visit_Details
ORDER BY 1, 2

--2. Calculate the month-wise retention rate.

WITH T1 AS
(
SELECT *,
	LAG(Total_Customers) OVER (ORDER BY Ord_Year, Ord_Month) Prev_month_count
FROM Monthly_Customers
), T2 AS
(
SELECT Ord_Year, Ord_Month, Total_Customers, ISNULL(Prev_month_count, 0) Prev_Month_Count
FROM T1
), T3 AS
(
SELECT *, Total_Customers - Prev_Month_Count AS Monthly_Difference
FROM T2
)
SELECT *,
	CAST(1.0 * Monthly_Difference / Total_Customers AS NUMERIC (4,2)) AS Retention_Rate 
FROM T3

--With above code, we firstly find the total customer numbers in each months of each year. Then with LAG function we put the previous months counts next to
--the current months for each. It means the difference between two months show the new customer gain or customer loss. 
--So then we used the formula of retention rate by dividing this difference to the current month's total customer numbers and made a new column as retention rate.