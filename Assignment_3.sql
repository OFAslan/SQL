---ASSIGNMENT 3--

--Discount Effects

--Generate a report including product IDs and discount effects on whether the increase in the discount rate positively impacts the number of orders for the products.

--In this assignment, you are expected to generate a solution using SQL with a logical approach. 

--First let's see the product IDS and discount rates and number of orders for each product and discount.

SELECT product_id, discount, SUM(quantity) ord_qty_per_product
FROM sale.order_item
GROUP BY product_id, discount
ORDER BY 1, 2

--It seems there there are four different discount level for each product.

WITH T1 AS
(
SELECT DISTINCT discount, 
	SUM(quantity) OVER (PARTITION BY discount) ord_qty_per_discount
FROM sale.order_item
)
SELECT *,
	CAST((1.0 * ord_qty_per_discount) / SUM(ord_qty_per_discount) OVER(ORDER BY ord_qty_per_discount ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)AS DECIMAL (4,2)) qty_rate_per_discount
FROM T1
ORDER BY 1

--The above query shows us, almost all the discount level for total  orders have the same order quantity rate.

--Now let's see this rate grouping the query with product id to have an insight.

WITH T1 AS
(
SELECT DISTINCT product_id, discount, 
	SUM(quantity) OVER (PARTITION BY product_id, discount) ord_qty_per_discount
FROM sale.order_item
)

SELECT *, 
	STDEV(discount) OVER(PARTITION BY product_id) std_disc,
	STDEV(ord_qty_per_discount) OVER(PARTITION BY product_id) std_ord_per_disc,
	AVG(discount * ord_qty_per_discount) - AVG(discount) * AVG(ord_qty_per_discount) OVER(PARTITION BY product_id) Correlation_Avg
INTO #temptable
FROM T1
GROUP BY product_id, discount, ord_qty_per_discount

--Now let's use above temptable for a new query

WITH T1 AS
(
SELECT product_id, Correlation_Avg / (std_disc * std_ord_per_disc) Correlation
FROM #temptable
WHERE std_disc IS NOT NULL AND std_disc <> 0 AND std_ord_per_disc IS NOT NULL AND std_ord_per_disc <> 0
), T2 AS
(
SELECT product_id, SUM(Correlation) Correlation_per_order
FROM T1
GROUP BY product_id
)
SELECT *,
	CASE 
		WHEN Correlation_per_order > 0 THEN 'POSITIVE'
		WHEN Correlation_per_order < 0 THEN 'NEGATIVE'
		ELSE 'Neutral'
	END AS discount_effect
FROM T2

/*
***************************************************
NOW I WILL ADD ANOTHER SOLUTION FOR THIS ASSIGNMENT
***************************************************
*/

-----ALTERNATIVE 2--------

WITH T1 AS
(
SELECT DISTINCT product_id, discount,
	SUM(quantity) qty_per_discount,
	LEAD(SUM(quantity)) OVER (PARTITION BY product_id ORDER BY discount) other_disc_qty
FROM sale.order_item
GROUP BY product_id, discount
), T2 AS
(
SELECT product_id, qty_per_discount, other_disc_qty,
	CASE
		WHEN (other_disc_qty - qty_per_discount) > 0 THEN 1
		WHEN (other_disc_qty - qty_per_discount) < 0 THEN -1
		ELSE 0
		END AS diff_qty
FROM T1
)
SELECT product_id, SUM(diff_qty) qty_difference,
	CASE
		WHEN SUM(diff_qty) > 0 THEN 'POSITIVE'
		WHEN SUM(diff_qty) < 0 THEN 'NEGATIVE'
		ELSE 'NEUTRAL'
	END AS discount_effect
FROM T2
GROUP BY product_id

