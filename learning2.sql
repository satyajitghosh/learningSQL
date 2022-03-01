--Practicing SQL on the following website
-- https://www.w3resource.com/sql-exercises/sql-joins-exercises.php
'''
  From the following tables write a SQL query to find the salesperson and
  customer who belongs to same city. Return Salesman, cust_name and city
'''

select s.name,c.cust_name,c.city
from salesman s join customer c
on s.city = c.city

'''
From the following tables write a SQL query to find those orders where order
amount exists between 500 and 2000. Return ord_no, purch_amt, cust_name, city
'''

select
o.ord_no,
o.purch_amt,
c.cust_name,
c.city
from orders o
left outer join customer c
on o.customer_id = c.customer_id
where o.purch_amt between 500 and 2000

'''
From the following tables write a SQL query to find the salesperson(s) and the
customer(s) he handle. Return Customer Name, city, Salesman, commission.
'''
select
c.cust_name,
c.city,
s.name,
s.commission
from salesman s
join customer c
on s.salesman_id = c.salesman_id

'''
From the following tables write a SQL query to find those salespersons who
received a commission from the company more than 12%. Return Customer Name,
customer city, Salesman, commission.
'''
select
c.cust_name,
c.city,
s.name,
s.commission
from salesman s
join customer c
on s.salesman_id = c.salesman_id
where s.commission > 0.12

'''
From the following tables write a SQL query to find those salespersons do not
live in the same city where their customers live and received a commission
from the company more than 12%. Return Customer Name, customer city, Salesman,
salesman city, commission
'''

SELECT a.cust_name AS "Customer Name",
a.city, b.name AS "Salesman", b.city,b.commission
FROM customer a
JOIN salesman b
ON a.salesman_id=b.salesman_id
WHERE b.commission>.12
and a.city != b.city

'''
Important Concept - Comparison with null
Comparison with null can neither be true nor be false.
For example if a.city is not null and b.city is null.
"New York" == NULL? - We dont know.
"New York" != NULL? - We dont know.
As it cannot be determined, the respective record will be
excluded from the final result.
'''

'''
From the following tables write a SQL query to find the details of an order.
Return ord_no, ord_date, purch_amt, Customer Name, grade, Salesman, commission
'''

SELECT a.ord_no,a.ord_date,a.purch_amt,
b.cust_name AS "Customer Name", b.grade,
c.name AS "Salesman", c.commission
FROM orders a
LEFT OUTER JOIN customer b
ON a.customer_id=b.customer_id
LEFT OUTER JOIN salesman c
ON a.salesman_id=c.salesman_id

'''
Write a SQL statement to make a join on the tables salesman,
customer and orders in such a form that the same column of each
table will appear once and only the relational rows will come.

Natural join does two thins -
1) Joins the given tables using columns with common names in the join condition.
2) The common columns appear only once in the resultant table.

'''
SELECT *
FROM orders
NATURAL JOIN customer
NATURAL JOIN salesman;

'''
From the following tables write a SQL query to display the cust_name,
customer city, grade, Salesman, salesman city.
The result should be ordered by ascending on customer_id.
'''

select
a.cust_name,
a.city,
a.grade,
b.name,
b.city
from customer a left join salesman b
on a.salesman_id = b.salesman_id
order by a.customer_id

'''
From the following tables write a SQL query to find those customers
whose grade less than 300. Return cust_name, customer city, grade,
Salesman, saleman city. The result should be ordered by ascending
customer_id.
'''
SELECT a.cust_name,a.city,a.grade,
b.name AS "Salesman", b.city
FROM customer a
LEFT OUTER JOIN salesman b
ON a.salesman_id=b.salesman_id
WHERE a.grade<300
ORDER BY a.customer_id;

'''
Write a SQL statement to make a report with customer name, city, order number,
order date, and order amount in ascending order according to the order date to
find that either any of the existing customers have placed no order or
placed one or more orders
'''
SELECT a.cust_name,a.city, b.ord_no,
b.ord_date,b.purch_amt AS "Order Amount"
FROM customer a
LEFT OUTER JOIN orders b
ON a.customer_id=b.customer_id
order by b.ord_date;

'''
Write a SQL statement to make a report with customer name, city, order number,
order date, order amount salesman name and commission to find that either any
of the existing customers have placed no order or placed one or more orders
by their salesman or by own.
'''
SELECT a.cust_name,a.city, b.ord_no, b.ord_date,b.purch_amt AS "Order Amount",
c.name,c.commission
FROM customer a LEFT OUTER JOIN orders b ON a.customer_id=b.customer_id
LEFT OUTER JOIN salesman c ON c.salesman_id=b.salesman_id;

'''
Write a SQL statement to make a list in ascending order for the salesmen
who works either for one or more customer or
not yet join under any of the customers
'''
SELECT a.cust_name,a.city,a.grade,
b.name AS "Salesman", b.city
FROM customer a
RIGHT OUTER JOIN salesman b
ON b.salesman_id=a.salesman_id
ORDER BY b.salesman_id;

'''
Display the list for the salesmen who works either for one or more customer
or not yet join under any of the customers who placed either
one or more orders or no order to their supplier
'''

SELECT a.cust_name,a.city,a.grade,
b.name AS "Salesman",
c.ord_no, c.ord_date, c.purch_amt
FROM customer a
RIGHT OUTER JOIN salesman b
ON b.salesman_id=a.salesman_id
RIGHT OUTER JOIN orders c
ON c.customer_id=a.customer_id;

'''
Write a SQL statement to make a list for the salesmen who either work for one
or more customers or yet to join any of the customer. The customer may have
placed, either one or more orders on or above order amount 2000 and must have
a grade, or he may not have placed any order to the associated supplier
'''
