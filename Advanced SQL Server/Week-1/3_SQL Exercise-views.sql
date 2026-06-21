--Exercise-1:Create a Simple View

CREATE VIEW vw_EmployeeBasicInfo AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM 
    Employees e
INNER JOIN 
    Departments d ON e.DepartmentID = d.DepartmentID;

--Excercise 2:Add computed Column-Full Name

CREATE VIEW vw_EmployeeFullName AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS FullName,
    d.DepartmentName
FROM 
    Employees e
INNER JOIN 
    Departments d ON e.DepartmentID = d.DepartmentID;

--Exercise 3:Add Computed Column - Annual Salary

CREATE VIEW vw_EmployeeAnnualSalary AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.Salary * 12 AS AnnualSalary
FROM 
    Employees e;

--Exercise 4:Add Multiple Computed Columns

CREATE VIEW vw_EmployeeReport AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS FullName,
    d.DepartmentName,
    e.Salary * 12 AS AnnualSalary,
    (e.Salary * 12) * 0.10 AS Bonus
FROM 
    Employees e
INNER JOIN 
    Departments d ON e.DepartmentID = d.DepartmentID;

