--Exercise 1: Create a Scalar Function
--1. Creation Script:

CREATE FUNCTION fn_CalculateAnnualSalary (
    @Salary DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Salary * 12;
END;

--2. Test Execution Script:

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    dbo.fn_CalculateAnnualSalary(Salary) AS AnnualSalary
FROM 
    Employees;

--Exercise 2: Create a Table-Valued Function
--1. Creation Script:

CREATE FUNCTION fn_GetEmployeesByDepartment (
    @DepartmentID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        EmployeeID, 
        FirstName, 
        LastName, 
        DepartmentID, 
        Salary, 
        JoinDate
    FROM 
        Employees
    WHERE 
        DepartmentID = @DepartmentID
);

--2. Test Execution Script (Testing with the IT department, which is ID 2):

SELECT * FROM dbo.fn_GetEmployeesByDepartment(2);

--Exercise 3: Create a User-Defined Function (Bonus)
--1. Creation Script:

CREATE FUNCTION fn_CalculateBonus (
    @Salary DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Salary * 0.10;
END;

--2. Test Execution Script:

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    dbo.fn_CalculateBonus(Salary) AS Bonus
FROM 
    Employees;

--Exercise 4: Modify a User-Defined Function
--1. Modification Script:

ALTER FUNCTION fn_CalculateBonus (
    @Salary DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Salary * 0.15;
END;

--2. Test Execution Script:

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    dbo.fn_CalculateBonus(Salary) AS ModifiedBonus
FROM 
    Employees;

--Exercise 5: Delete a User-Defined Function
--Step 1: Drop the function

DROP FUNCTION fn_CalculateBonus;

--Step 2: Verify that the function has been deleted

SELECT * 
FROM sys.objects 
WHERE name = 'fn_CalculateBonus' AND type IN ('FN', 'IF', 'TF');

--Exercise 6: Execute a User-Defined Function

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    dbo.fn_CalculateAnnualSalary(Salary) AS AnnualSalary
FROM 
    Employees;

--Exercise 7: Return Data from a Scalar Function

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    dbo.fn_CalculateAnnualSalary(Salary) AS AnnualSalary
FROM 
    Employees
WHERE 
    EmployeeID = 1;

--Exercise 8: Return Data from a Table-Valued Function

SELECT * FROM dbo.fn_GetEmployeesByDepartment(3);

--Exercise 9: Create a Nested User-Defined Function
--1. Creation Script:

CREATE FUNCTION fn_CalculateTotalCompensation (
    @Salary DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN dbo.fn_CalculateAnnualSalary(@Salary) + dbo.fn_CalculateBonus(@Salary);
END;

--2. Test Execution Script:

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    dbo.fn_CalculateTotalCompensation(Salary) AS TotalCompensation
FROM 
    Employees;

--Exercise 10: Modify a Nested User-Defined Function
--1. Modification Script:

ALTER FUNCTION fn_CalculateTotalCompensation (
    @Salary DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN dbo.fn_CalculateAnnualSalary(@Salary) + dbo.fn_CalculateBonus(@Salary);
END;

--2. Test Execution Script

SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    dbo.fn_CalculateTotalCompensation(Salary) AS UpdatedTotalCompensation
FROM 
    Employees;






