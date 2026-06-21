--Excercise 1:Create a cursor
-- 1. Declare variables to store the fetched data

DECLARE @EmployeeID INT;
DECLARE @FirstName VARCHAR(50);
DECLARE @LastName VARCHAR(50);
DECLARE @DepartmentID INT;
DECLARE @Salary DECIMAL(10,2);
DECLARE @JoinDate DATE;

-- Step 1: Declare the cursor
DECLARE emp_cursor CURSOR FOR
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, JoinDate
FROM Employees;

-- Step 2: Open the cursor
OPEN emp_cursor;

-- Step 3: Fetch the first row into the variables
FETCH NEXT FROM emp_cursor 
INTO @EmployeeID, @FirstName, @LastName, @DepartmentID, @Salary, @JoinDate;

-- Loop through each row until there are no more rows left (@@FETCH_STATUS = 0)
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Step 4: Print the details of each employee
    PRINT 'Employee ID: ' + CAST(@EmployeeID AS VARCHAR(10)) + 
          ' | Name: ' + @FirstName + ' ' + @LastName + 
          ' | Dept ID: ' + ISNULL(CAST(@DepartmentID AS VARCHAR(10)), 'None') + 
          ' | Salary: ' + CAST(@Salary AS VARCHAR(20)) + 
          ' | Joined: ' + CAST(@JoinDate AS VARCHAR(10));

    -- Fetch the next row
    FETCH NEXT FROM emp_cursor 
    INTO @EmployeeID, @FirstName, @LastName, @DepartmentID, @Salary, @JoinDate;
END;

-- Step 5: Close the cursor
CLOSE emp_cursor;

-- Step 6: Deallocate the cursor to free memory
DEALLOCATE emp_cursor;

--📑 Exercise 2: Types of Cursors

-- 1. STATIC CURSOR
-- Creates a temporary copy of the data in tempdb. 
-- Changes made by other users after opening are not visible.
DECLARE static_emp_cursor CURSOR STATIC FOR
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, JoinDate 
FROM Employees;

-- 2. DYNAMIC CURSOR
-- Reflects all data modifications (inserts, updates, deletes) made by anyone while looping.
-- Scrolling can go in any direction (NEXT, PRIOR, FIRST, LAST).
DECLARE dynamic_emp_cursor CURSOR DYNAMIC FOR
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, JoinDate 
FROM Employees;

-- 3. FORWARD-ONLY CURSOR
-- The default and fastest cursor type. 
-- It can only scroll forward from the first row to the last row.
DECLARE forward_emp_cursor CURSOR FORWARD_ONLY FOR
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, JoinDate 
FROM Employees;

-- 4. KEYSET-DRIVEN CURSOR
-- Builds a unique list of keys in tempdb when opened.
-- Updates to existing rows are visible, but new inserts by other users are not.
DECLARE keyset_emp_cursor CURSOR KEYSET FOR
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, JoinDate 
FROM Employees;

