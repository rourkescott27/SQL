DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS order_header;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-------------------Creating all neccesary tables--------------------
--------------------------------------------------------------------
--Products Table--
--------------------------------------------------------------------
CREATE TABLE products (
	product_id bigserial PRIMARY KEY,
	prod_name varchar(50) NOT NULL,
	price money NOT NULL CHECK (price >= '0')
);

INSERT INTO products (prod_name, price)

VALUES 
	('Cold Drink', 10.00),
	('Chips', 5.99),
	('Bread', 18.50),
	('Milk', 28.95),
	('Chocolate', 14.99),
	('Sweets', 11.99);

SELECT * FROM products;

--------------------------------------------------------------------
--Customers Table--
--------------------------------------------------------------------
CREATE TABLE customers (
	customer_id bigserial PRIMARY KEY,
	customer varchar(25) NOT NULL
);

INSERT INTO customers (customer)

VALUES 
	('Arnold'),
	('Sheryl');

SELECT * FROM customers;

-------------------------------------------------------------------
--Cart Table--     
-------------------------------------------------------------------
CREATE TABLE cart (
	product_id bigint UNIQUE REFERENCES products(product_id),
	quantity bigint CHECK (quantity >= 0)
);

-------------------------------------------------------------------
--Order Header Table--
-------------------------------------------------------------------
CREATE TABLE order_header (
	order_id bigserial PRIMARY KEY,
	customer_id bigint REFERENCES customers(customer_id) ON DELETE CASCADE,
	order_date timestamp DEFAULT current_timestamp
	);

-------------------------------------------------------------------
--Order Details Table--
-------------------------------------------------------------------
CREATE TABLE order_details (
	order_id bigint REFERENCES order_header(order_id) ON DELETE CASCADE,
	product_id bigint REFERENCES products(product_id) ON DELETE CASCADE,
	quantity bigint CHECK(quantity >= 0)
);


----------------------------Functions------------------------------
-------------------------------------------------------------------
--Add item to Cart function--
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_to_shopping_cart(prod_id bigint)
RETURNS void AS $$
BEGIN
IF EXISTS (SELECT * FROM cart WHERE prod_id = product_id)
    THEN
        UPDATE cart SET quantity = quantity + 1  WHERE prod_id = product_id;
    ELSE
        INSERT INTO cart (product_id, quantity) VALUES (prod_id , 1);
    END IF; 

END;
$$ LANGUAGE plpgsql;
; 

-------------------------------------------------------------------
--Remove item from cart funtion
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION delete_product(prod_id bigint)
RETURNS void AS $$
BEGIN
    IF EXISTS (SELECT * FROM cart WHERE product_id = prod_id
                                  AND quantity > 1)
    THEN
        UPDATE  cart
        SET quantity = quantity - 1
        WHERE product_id = prod_id;
    ELSE
        DELETE FROM cart 
        WHERE product_id = prod_id;
    END IF; 
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------
--Simulating the Shopping Cart experience--
-------------------------------------------------------------------

-----------------Adding items to Sheryl's Cart---------------------
        --Sheryl Adds the following items to her cart--
SELECT add_to_shopping_cart(1); --Run query to add Cold Drink
SELECT * FROM cart;
SELECT add_to_shopping_cart(3); --Run query to add Bread
SELECT * FROM cart;
SELECT add_to_shopping_cart(4); --Run query to add Milk
SELECT * FROM cart;
SELECT add_to_shopping_cart(4); --Run query to add Milk
SELECT * FROM cart;
SELECT add_to_shopping_cart(6); --Run query to add Sweets
SELECT * FROM cart;
SELECT add_to_shopping_cart(6); --Run query to add Sweets
SELECT * FROM cart;

-------------------------Checking Out #1---------------------------
--Sheryl decides she has what she needs and checks out--
INSERT INTO order_header (customer_id)
	VALUES
		('2');

SELECT * FROM order_header; 
	
INSERT INTO order_details (order_id, product_id, quantity)
	VALUES 
		('1', '1', '1'),
		('1', '3', '1'),
		('1', '4', '2');


-----------------Removing items from the cart #1-------------------
--Sheryl decides to remove the sweets from her cart--
SELECT delete_product(6); --Run query to remove Sweets

SELECT * FROM cart;
SELECT * FROM order_details;
DELETE FROM cart; --Clear cart completely for next order

------------------------------------------------------------------
------------------------------------------------------------------
------------------Adding items to Arnolds cart--------------------
        --Arnold adds the following items to his cart--
SELECT add_to_shopping_cart(1); --Run query to add Cold Drink
SELECT * FROM cart;
SELECT add_to_shopping_cart(2); --Run query to add Chips
SELECT * FROM cart;
SELECT add_to_shopping_cart(2); --Run query to add Chips
SELECT * FROM cart;
SELECT add_to_shopping_cart(3); --Run query to add Bread
SELECT * FROM cart;
SELECT add_to_shopping_cart(5); --Run query to add Chocolate
SELECT * FROM cart;
SELECT add_to_shopping_cart(5); --Run query to add Chocolate
SELECT * FROM cart;
SELECT add_to_shopping_cart(6); --Run query to add Sweets
SELECT * FROM cart;

-------------------------Checking Out #2---------------------------
--Arnold decides he has what he needs and checks out--
INSERT INTO order_header (customer_id)
	VALUES
		('1');
		
SELECT * FROM order_header;

INSERT INTO order_details (order_id, product_id, quantity)
	VALUES
		('2', '1', '1'),
		('2', '2', '2'),
		('2', '3', '1'),
		('2', '6', '1');
		

-----------------Removing items from the cart #2------------------
--Arnold decides to remove the chocolates from his cart--
SELECT delete_product(5); --Run query to remove Chocolate

SELECT * FROM order_details;
SELECT * FROM cart;
DELETE FROM cart; --Clear cart completely for next order


------------------------------------------------------------------
                        --INNER JOINS--
------------------------------------------------------------------
            --INNER JOIN showing Sheryl's individual order--
SELECT cust.customer, oh.order_date, prod.prod_name, prod.price, od.quantity
FROM order_header oh
INNER JOIN customers cust 
ON oh.customer_id = cust.customer_id
INNER JOIN order_details od 
ON oh.order_id = od.order_id
INNER JOIN products prod
ON od.product_id = prod.product_id
WHERE cust.customer_id = 2;

--INNER JOIN showing Sheryl's total--
-------------------------------------------------------------------
SELECT cust.customer, od.order_id, SUM(od.quantity * prod.price)
FROM order_details od
INNER JOIN products prod
ON od.product_id = prod.product_id
INNER JOIN order_header oh
ON oh.order_id = od.order_id
INNER JOIN customers cust
ON cust.customer_id = oh.customer_id
WHERE cust.customer_id = 2
GROUP BY cust.customer, od.order_id
ORDER BY cust.customer, od.order_id;

-----------------------------------------------------------------
            --INNER JOIN showing Arnold's individual order--
SELECT cust.customer, oh.order_date, prod.prod_name, prod.price, od.quantity
FROM order_header oh
INNER JOIN customers cust 
ON oh.customer_id = cust.customer_id
INNER JOIN order_details od 
ON oh.order_id = od.order_id
INNER JOIN products prod
ON od.product_id = prod.product_id
WHERE cust.customer_id = 1;

			--INNER JOIN showing Arnold's total--
----------------------------------------------------------------
SELECT cust.customer, od.order_id, SUM(od.quantity * prod.price)
FROM order_details od
INNER JOIN products prod
ON od.product_id = prod.product_id
INNER JOIN order_header oh
ON oh.order_id = od.order_id
INNER JOIN customers cust
ON cust.customer_id = oh.customer_id
WHERE cust.customer_id = 1
GROUP BY cust.customer, od.order_id
ORDER BY cust.customer, od.order_id;

-----------------------------------------------------------------
       --INNER JOIN showing all the orders for the day--
SELECT cust.customer, oh.order_date, prod.prod_name, prod.price, od.quantity
FROM order_header oh
INNER JOIN customers cust 
ON oh.customer_id = cust.customer_id
INNER JOIN order_details od 
ON oh.order_id = od.order_id
INNER JOIN products prod
ON od.product_id = prod.product_id
WHERE date_part ('year', order_date) = '2023'; -- Will only work for the year 2023

--INNER JOIN showing both totals--
----------------------------------------------------------------
SELECT od.order_id, SUM(od.quantity * prod.price)
FROM order_details od
INNER JOIN products prod
ON od.product_id = prod.product_id
GROUP BY od.order_id
ORDER BY od.order_id;















