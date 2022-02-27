-- Tutorial.
-- Covers Subquerys , various types of subquerys and their uses.
-- Covers Window functions/Analytical functions and their uses.


-- Find those employees whose salary ismore than the average salary in this table
select * from salaries
where salary > ( select avg(salary) from salaries);

select count(*) from salaries;
select count(*) from salaries where salary > ( select avg(salary) from salaries);

-- Subquery runs first, prior to outer query.
-- Subquery runs only once in this case.
-- Subquery types - Scalar, Multiple row, Correlated.

-- Scalar subquery - always returns one row and one column.


-- Another way to write the same query. When we join the subquery with the table, the output of the subquery is treated as a table.
select s.emp_no
from salaries s
join (select avg(salary) salary from salaries) avg_sal
on s.salary > avg_sal.salary;

-- Multiple row subquery. Two subtypes -
-- Multiple row single column
-- Multiple row multiple columns

select * from employees limit 10;
select * from departments limit 10;
select * from salaries limit 10;

-- Question - Find the employees who earn the highest salary in each department
-- First created a view that will containt the relavant data.
-- Will run the query on the given view

create or replace view empsal as
select e.emp_no,e.first_name,d.dept_name, s.salary
from employees e join dept_emp de
on e.emp_no = de.emp_no
join departments d
on de.dept_no = d.dept_no
join salaries s
on e.emp_no = s.emp_no
limit 1000;

select distinct(dept_name) from empsal;
select * from empsal limit 10;

-- Trying using a window function first
select * from
(
	select 	dept_name,
			first_name,
			salary,
			max(salary) over (partition by dept_name) as max_dept_sal
	from empsal
) s
where salary >= max_dept_sal;

-- Both work. The below solution uses a Multiple row, multiple column level subquery.
select * from empsal
where (dept_name,salary) in
(
		select dept_name, max(salary) as max_sal
		from empsal
		group by dept_name
);

-- Single column multiple row subquery
select * from departments
where dept_name not in
(
	select distinct(dept_name) from empsal
);

select * from departments
where dept_name in
(
	select distinct(dept_name) from empsal
);

-- Using correlated subquery.
-- Find employees in each department who earn mopre than the average salary in that department.


select * from empsal o
where salary  >
(
		select avg(i.salary) from empsal i where i.dept_name = o.dept_name
);

select dept_name,count(*)
from empsal o
where 1=1
and exists
(
	select 1 from departments d where d.dept_name = o.dept_name
)
group by dept_name;

select dept_name,count(*)
from empsal o
where 1=1
and exists
(
	select 1 from departments d where d.dept_name != 'Customer Service' and d.dept_name = o.dept_name
)
group by dept_name;

-- FOUR PLACES WHERE WE CAN USE SUBQUERYS - SELECT, FROM, WHERE, HAVING
select * from empsal limit 10;
-- SUBQUERY IN SELECT
select first_name, salary, (case when salary > (select avg(salary) from empsal) then 'Higher than Average Salary' else null end) as remark
from empsal
order by remark desc;
-- PLACING SUBQUERY IN JOIN
select first_name, salary, avgsal.sal, (case when salary >  avgsal.sal then 'Higher than Average Salary' else null end) as remark
from empsal join (select avg(salary) as sal from empsal) avgsal
order by remark desc;

-- STARTING WITH WINDOW FUNCTIONS--
-- rank,dense rank, row number,lead,lag
select * from employee;

drop table employee;
create table employee
( emp_ID int
, emp_NAME varchar(50)
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);
COMMIT;

select * from employee;

# Note in the below example, we have left over() empty.
# This means that the window function will have only one partition and that is the entire table
# Instead, if we add over(partition by dept_name) , then the data set will be diided into partitions, each conaining the data for the given dept, and the average salary of the respective
# department will appear alongside every given record in the output.alter

select e.*, max(salary) over()
from employee e;

select e.*, max(salary) over(partition by dept_name) as max_dept_salary
from employee e;

select
e.*,
max(salary) over(partition by dept_name) as max_dept_salary,
case when salary >= max(salary) over(partition by dept_name) then "Y" else "N" end as highest_paid_in_dept
from employee e;

-- ROW NUMBER --
-- assigns a unique number (starting with 1 and increasing by 1) to every row within each partition.
-- If over() is left empty then the entire data set is treated as a single partition.
select e.*,row_number() over() as rn
from employee e;
select e.*,row_number() over(partition by dept_name) as rn
from employee e;
-- USe of rn - example
-- get the first two employees(in alphabetical order) from each department
select * from (
	select e.*,row_number() over(partition by dept_name order by emp_name) as rn
	from employee e
    ) x
    where x.rn <= 2;
-- RANK --
-- Fetch top 3 employees from each department earning max salary
select * from
(
		select e.*, rank() over(partition by dept_name order by salary desc) rnk
		from employee e
)x   where x.rnk < 4;

select e.*,
rank() over(partition by dept_name order by salary desc) rnk,
dense_rank() over(partition by dept_name order by salary desc) dns_rnk
from employee e;

-- only difference between the two - dens rank does not skip values.

-- LEAD/LAG
select e.*,
lag(salary) over(partition by (dept_name) order by emp_id) as prev_emp_salary
from employee e;

-- second argument takes the number of lag records to be considered and 3rd argument is the default value
select e.*,
lag(salary,1,0) over(partition by (dept_name) order by emp_id) as prev_emp_salary
from employee e;

select e.*,
lag(salary,1,0) over(partition by (dept_name) order by emp_id) as prev_emp_salary,
lead(salary,1,0) over(partition by (dept_name) order by emp_id) as next_emp_salary
from employee e;

DROP TABLE product;
CREATE TABLE product
(
    product_category varchar(255),
    brand varchar(255),
    product_name varchar(255),
    price int
);

INSERT INTO product VALUES
('Phone', 'Apple', 'iPhone 12 Pro Max', 1300),
('Phone', 'Apple', 'iPhone 12 Pro', 1100),
('Phone', 'Apple', 'iPhone 12', 1000),
('Phone', 'Samsung', 'Galaxy Z Fold 3', 1800),
('Phone', 'Samsung', 'Galaxy Z Flip 3', 1000),
('Phone', 'Samsung', 'Galaxy Note 20', 1200),
('Phone', 'Samsung', 'Galaxy S21', 1000),
('Phone', 'OnePlus', 'OnePlus Nord', 300),
('Phone', 'OnePlus', 'OnePlus 9', 800),
('Phone', 'Google', 'Pixel 5', 600),
('Laptop', 'Apple', 'MacBook Pro 13', 2000),
('Laptop', 'Apple', 'MacBook Air', 1200),
('Laptop', 'Microsoft', 'Surface Laptop 4', 2100),
('Laptop', 'Dell', 'XPS 13', 2000),
('Laptop', 'Dell', 'XPS 15', 2300),
('Laptop', 'Dell', 'XPS 17', 2500),
('Earphone', 'Apple', 'AirPods Pro', 280),
('Earphone', 'Samsung', 'Galaxy Buds Pro', 220),
('Earphone', 'Samsung', 'Galaxy Buds Live', 170),
('Earphone', 'Sony', 'WF-1000XM4', 250),
('Headphone', 'Sony', 'WH-1000XM4', 400),
('Headphone', 'Apple', 'AirPods Max', 550),
('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
('Smartwatch', 'Apple', 'Apple Watch Series 6', 1000),
('Smartwatch', 'Apple', 'Apple Watch SE', 400),
('Smartwatch', 'Samsung', 'Galaxy Watch 4', 600),
('Smartwatch', 'OnePlus', 'OnePlus Watch', 220);
COMMIT;

select * from product;
-- FIRST_VALUE - print the most expensive product under each category, for every given record.
select p.*,
first_value(product_name) over(partition by product_category order by price desc) as most_expensive_item
from product p;

-- LAST_VALUE - print the least expensive product under each category, for every given record.

select p.*,
first_value(product_name) over(partition by product_category order by price desc) as most_expensive_item,
last_value(product_name) over(partition by product_category order by price desc) as least_expensive_item
from product p

-- the result is counter-intutive, we dont get the same prouduct in the least_expesive item column of each partition.
-- this is due to the default frame clause in SQL.

select p.*,
first_value(product_name) over(partition by product_category order by price desc) as most_expensive_item,
last_value(product_name) over(	partition by product_category
								order by price desc
                                range between unbounded preceding and current row) as least_expensive_item -- default frame clause
from product p;

-- this works
select p.*,
first_value(product_name) over(partition by product_category order by price desc) as most_expensive_item,
last_value(product_name) over(	partition by product_category
								order by price desc
                                range between unbounded preceding and unbounded following) as least_expensive_item -- changed frame clause
from product p;

-- frame clause can start with range/rows

-- another (less wordy) way to write the same sql query
select p.*,
first_value(product_name) over(partition by product_category order by price desc) as most_expensive_item,
last_value(product_name) over(	partition by product_category order by price desc range between unbounded preceding and unbounded following) as least_expensive_item
from product p;


select p.*,
first_value(product_name) over w as most_expensive_item,
last_value(product_name) over w as least_expensive_item
from product p
where product_category = 'Phone'
window w as (partition by product_category order by price desc range between unbounded preceding and unbounded following);

-- NTH VALUE - fetched value from the nth row in the respective partition.
-- example - get the second most expensive product in the given category.alter

select p.*,
first_value(product_name) over w as most_expensive_item,
last_value(product_name) over w as least_expensive_item,
nth_value(product_name,2) over w as second_most_expensive_item
from product p
window w as (partition by product_category order by price desc range between unbounded preceding and unbounded following);

-- NTILE - write a query to seggregate all the expensive, mid range and cheaper phones.
select 	x.product_name,
		case
			when x.bckts = 1 then 'Expensive Phone'
            when x.bckts = 2 then 'Mid Range Phone'
            when x.bckts = 3 then 'Cheap Phone'
		end as phone_caegory
from
(
	select p.*,
	NTILE(3) over (partition by product_category order by price desc) as bckts
	from product p
)x
where x.product_category = 'Phone';

-- CUME_DIST
-- fetch all the products which constitute the first 30% based on price in each product category
select * from
(
select p.*,
round((CUME_DIST() over (partition by product_category order by price desc)*100),2) as cum_dist_pct
from product p
)x where cum_dist_pct <=30;
