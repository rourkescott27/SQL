DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS salaries;
DROP TABLE overtime_hours CASCADE;
------------------------------------------------------------------------------------------------------------------
-- Department Table --
CREATE TABLE departments (
	depart_id bigserial CONSTRAINT department_id_key PRIMARY KEY,
	depart_name varchar(20),
	depart_city varchar(20)
);

INSERT INTO departments (
	depart_name,
	depart_city
); 

VALUES 
 	('Marketing', 'Johannesburg'),
 	('Human Resources', 'Cape Town'),
 	('Accounting', 'Bloemfontein'),
	('IT', 'Sandton'),
	('Finance', 'Nelspruit'),
    ('Manufacturing', 'Pretoria');

SELECT * FROM departments;
-----------------------------------------------------------------------------------------------------------------
-- Roles Table --
CREATE TABLE roles (
	role_id bigserial CONSTRAINT role_id_key PRIMARY KEY,
	_role varchar(30)
);

INSERT INTO roles (_role)

VALUES 
	('Product Manager'),  	  	   --Marketing
	('Promotion'),           	   --Marketing
    ('Workplace Safety'),    	   --HR
	('Recruiter'),           	   --HR
	('Payroll Clerk'),             --Accounting
	('Accounts Payable Clerk'),    --Accounting
	('Senior Software Developer'), --IT
	('Database Administrator'),    --IT
	('Senior Bookkeeper'),         --Finance
	('Auditor'),             	   --Finance
	('Quality Controller'), 	   --Manufacturing
	('Production Manager');  	   --Manufacturing

SELECT * FROM roles;
-------------------------------------------------------------------------------------------------------------------
-- Salaries Table --
CREATE TABLE salaries (
	salary_id bigserial CONSTRAINT salary_id_key PRIMARY KEY,
	salary_pa money  
);

INSERT INTO salaries (salary_pa)

VALUES
	(418561), --Product Manager
	(242002), --Promotion
	(288003), --Workplace Safety
	(162248), --Recruiter
	(130582), --Payroll Clerk
 	(228000), --Accounts Payable Clerk
	(713869), --Senior Software Developer
	(630000), --Database Administrator
	(309000), --Senior Bookkeeper
	(471000), --Auditor
	(240000), --Quality Controller
	(450000); --Production Manager

SELECT * FROM salaries;
---------------------------------------------------------------------------------------------------------------------
-- Overtime Hours Table --
CREATE TABLE overtime_hours (
	overtime_id bigserial CONSTRAINT overtime_hours_key PRIMARY KEY,
	overtime_hours_per_week numeric 
);

INSERT INTO overtime_hours (overtime_hours_per_week)

VALUES 
	(0),
	(7),
	(3),
	(5),
	(8),
 	(2),
	(12);

SELECT * FROM overtime_hours;
----------------------------------------------------------------------------------------------------------------------
-- Employees Table --
CREATE TABLE employees (
	emp_id bigserial CONSTRAINT emp_id_key PRIMARY KEY,
	first_name varchar(25) NOT NULL,
	surname varchar(25) NOT NULL,
	gender char(1) NOT NULL,
	address varchar(50),
	email varchar(50) UNIQUE NOT NULL,
	depart_id bigint REFERENCES departments (depart_id) ON DELETE CASCADE,
	role_id bigint REFERENCES roles (role_id) ON DELETE CASCADE,
	salary_id bigint REFERENCES salaries (salary_id) ON DELETE CASCADE ,
	overtime_id bigint REFERENCES overtime_hours (overtime_id) ON DELETE CASCADE
);

INSERT INTO employees (
	first_name,
	surname,
	gender, 
	address,
	email,
	depart_id,
	role_id,
	salary_id,
	overtime_id
)

VALUES 
    ('Jasmine', 'Adams', 'F', '1527 South St', 'JasmineAdams@armyspy.com', 2,4,4,3),
	('Elise', 'Duffy', 'F', '1041 St. John Street', 'EliseDuffy@dayrep.com', 1,2,2,2),
	('Leo', 'Henderson', 'M', '1562 Gleemoor Rd', 'LeoHenderson@gmail.com', 4,7,7,5),
	('Emma', 'Griffin', 'F', '763 Burger St', 'EmmaGriffin@codecollege.co.za', 3,5,5,4), 
	('Josh', 'Hartley', 'M', '981 Broad Rd', 'JoshHartley@rhyta.com', 5,9,9,6),
	('Billy', 'Clarke', 'M', '1662 Dickens St', 'BillyClarke@teleworm.us', 6,11,11,7),
	('Maya', 'Sinclair', 'F', '1722 Bhoola Rd', 'MayaSinclair@teleworm.us', 2,3,3,1),
	('Amelia', 'Bailey', 'F', '15 Bodenstein St', 'AmeliaBailey@rhyta.com', 4,8,8,5),
    ('James', 'Hussain', 'M', '1820 Daffodil Dr', 'JamesHussain@rhyta.com', 5,10,10,6),
    ('Amber', 'Charlton', 'F', '989 Roger St', 'AmberCharlton@dayrep.com', 3,6,6,4),
	('David', 'Young', 'M', '686 Amos St', 'DavidYoung@rhyta.com', 6,12,12,7),
	('Charlotte', 'Hamilton', 'F', '2218 Oranje St', 'CharlotteHamilton@gmail.com',1,1,1,2);
	
SELECT * FROM employees;
----------------------------------------------------------------------------------------------------------------------------
-- LEFT JOIN --
SELECT 
	departments.depart_name AS dept_name,
	roles._role AS job_title,
	salaries.salary_pa AS salary_figure,
	overtime_hours.overtime_hours_per_week AS overtime_hours_worked
FROM employees
LEFT JOIN salaries ON salaries.salary_id = employees.salary_id
LEFT JOIN departments ON departments.depart_id = employees.depart_id
LEFT JOIN roles ON roles.role_id = employees.role_id
LEFT JOIN overtime_hours ON overtime_hours.overtime_id = employees.overtime_id;




















