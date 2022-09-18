CREATE DATABASE Manufacturer

USE Manufacturer

CREATE TABLE Product
(
prod_id INT NOT NULL PRIMARY KEY,
prod_name VARCHAR(50) NOT NULL,
quantity INT NOT NULL
);

CREATE TABLE Component
(
comp_id INT NOT NULL PRIMARY KEY,
comp_name VARCHAR(50) NULL,
description VARCHAR(50) NULL,
quantity_comp INT NULL
);

CREATE TABLE Prod_Comp
(
prod_id INT NOT NULL ,
comp_id INT NOT NULL ,
quantity_comp INT NULL,
CONSTRAINT prod_comp_id PRIMARY KEY (prod_id, comp_id),
CONSTRAINT FK1 FOREIGN KEY (prod_id) REFERENCES Product(prod_id),
CONSTRAINT FK2 FOREIGN KEY (comp_id) REFERENCES Component(comp_id)
);


CREATE TABLE Supplier
(
supp_id INT PRIMARY KEY,
supp_name VARCHAR(50) NULL,
supp_location VARCHAR(50) NULL,
supp_country VARCHAR(50) NULL,
is_active BIT NULL
);

CREATE TABLE Comp_Supp
(
supp_id INT NOT NULL,
comp_id INT NOT NULL,
order_date DATE NOT NULL,
quantity INT NOT NULL,
CONSTRAINT comp_supp_id PRIMARY KEY (supp_id, comp_id),
CONSTRAINT FK3 FOREIGN KEY (supp_id) REFERENCES Supplier(supp_id),
CONSTRAINT FK4 FOREIGN KEY (comp_id) REFERENCES Component(comp_id)
);


