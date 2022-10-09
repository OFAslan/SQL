---We will alter all the tables to assign the keys.

UPDATE shipping_dimen
SET Ship_ID = SUBSTRING(Ship_ID, PATINDEX('%[0-9]%', Ship_ID), LEN(Ship_ID))

ALTER TABLE shipping_dimen
ALTER COLUMN Ship_ID INT NOT NULL

ALTER TABLE shipping_dimen
ADD CONSTRAINT PK1 PRIMARY KEY(Ship_ID)

ALTER TABLE shipping_dimen
ALTER COLUMN Order_ID INT NOT NULL

ALTER TABLE shipping_dimen
ALTER COLUMN Ship_Mode VARCHAR(50) NOT NULL

ALTER TABLE shipping_dimen
ALTER COLUMN Ship_Date DATE NOT NULL

---

UPDATE cust_dimen
SET Cust_ID = SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID))

ALTER TABLE cust_dimen
ALTER COLUMN Cust_ID INT NOT NULL
ALTER TABLE cust_dimen
ADD CONSTRAINT PK2 PRIMARY KEY (Cust_ID)

---
UPDATE orders_dimen
SET Ord_ID = SUBSTRING(Ord_ID, PATINDEX('%[0-9]%', Ord_ID), LEN(Ord_ID))

ALTER TABLE orders_dimen
ALTER COLUMN [Ord_ID] INT NOT NULL

ALTER TABLE orders_dimen
ADD CONSTRAINT PK_ord PRIMARY KEY(Ord_ID)

ALTER TABLE orders_dimen
ALTER COLUMN [Order_Date] DATE NOT NULL

ALTER TABLE orders_dimen
ALTER COLUMN [Order_Priority] VARCHAR(50) NOT NULL

---

UPDATE prod_dimen
SET Prod_ID = SUBSTRING(Prod_ID, PATINDEX('%[0-9]%', Prod_ID), LEN(Prod_ID))

ALTER TABLE prod_dimen
ALTER COLUMN Prod_ID INT NOT NULL

ALTER TABLE prod_dimen
ADD CONSTRAINT PK4 PRIMARY KEY(Prod_ID)

ALTER TABLE prod_dimen
ALTER COLUMN Product_Category VARCHAR(50) NOT NULL

ALTER TABLE prod_dimen
ALTER COLUMN Product_Sub_Category VARCHAR(50) NOT NULL

---
UPDATE market_fact
SET Ord_ID = SUBSTRING(Ord_ID, PATINDEX('%[0-9]%', Ord_ID), LEN(Ord_ID))

UPDATE market_fact
SET Prod_ID = SUBSTRING(Prod_ID, PATINDEX('%[0-9]%', Prod_ID), LEN(Prod_ID))

UPDATE market_fact
SET Ship_ID = SUBSTRING(Ship_ID, PATINDEX('%[0-9]%', Ship_ID), LEN(Ship_ID))

UPDATE market_fact
SET Cust_ID = SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID))


ALTER TABLE market_fact
ALTER COLUMN Ord_ID INT NOT NULL
ALTER TABLE market_fact
ALTER COLUMN Prod_ID INT NOT NULL
ALTER TABLE market_fact
ALTER COLUMN Ship_ID INT NOT NULL
ALTER TABLE market_fact
ALTER COLUMN Cust_ID INT NOT NULL

ALTER TABLE market_fact
ALTER COLUMN Sales BIGINT NOT NULL

ALTER TABLE market_fact
ALTER COLUMN Discount FLOAT NOT NULL

ALTER TABLE market_fact
ALTER COLUMN Order_Quantity TINYINT NOT NULL

--Now the relations between tables will be established

ALTER TABLE market_fact
ADD CONSTRAINT FK_Author FOREIGN KEY (Ord_ID) REFERENCES orders_dimen (Ord_ID)

ALTER TABLE market_fact
ADD CONSTRAINT FK_Author2 FOREIGN KEY (Prod_Id) REFERENCES prod_dimen (Prod_ID)

ALTER TABLE market_fact
ADD CONSTRAINT FK_Author3 FOREIGN KEY (Ship_ID) REFERENCES shipping_dimen (Ship_ID)

ALTER TABLE market_fact
ADD CONSTRAINT FK_Author4 FOREIGN KEY (Cust_ID) REFERENCES cust_dimen (Cust_ID)

--We can check constraint details with the below code.

SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE  