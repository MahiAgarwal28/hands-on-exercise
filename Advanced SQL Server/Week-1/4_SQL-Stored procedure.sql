--Exercise 1: Create a Stored Procedure
--Task A: Retrieve Employee Details by Department

CREATE PROCEDURE sp_GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT 
        EmployeeID, 
        FirstName, 
        LastName, 
        DepartmentID, 
        JoinDate
    FROM 
        Employees
    WHERE 
        DepartmentID = @DepartmentID;
END;

--Task B: Insert Employee (As explicitly provided in Step 3)

CREATE PROCEDURE sp_InsertEmployee
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DepartmentID INT,
    @Salary DECIMAL(10,2),
    @JoinDate DATE
AS
BEGIN
    INSERT INTO Employees (FirstName, LastName, DepartmentID, Salary, JoinDate)
    VALUES (@FirstName, @LastName, @DepartmentID, @Salary, @JoinDate);
END;

--Exercise 2: Modify a Stored Procedure

ALTER PROCEDURE sp_GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT 
        EmployeeID, 
        FirstName, 
        LastName, 
        DepartmentID, 
        Salary, -- Added Salary column
        JoinDate
    FROM 
        Employees
    WHERE 
        DepartmentID = @DepartmentID;
END;

--Exercise 3: Delete a Stored Procedure

DROP PROCEDURE sp_GetEmployeesByDepartment;

--Exercise 4: Execute a Stored Procedure

EXEC sp_GetEmployeesByDepartment @DepartmentID = 1;

--Exercise 5: Return Data from a Stored Procedure

CREATE PROCEDURE sp_GetEmployeeCountByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT COUNT(*) AS TotalEmployees
    FROM Employees
    WHERE DepartmentID = @DepartmentID;
END;

--Exercise 6: Use Output Parameters in a Stored Procedure
--1. Creation Script:

CREATE PROCEDURE sp_GetTotalSalaryByDepartment
    @DepartmentID INT,
    @TotalSalary DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @TotalSalary = ISNULL(SUM(Salary), 0)
    FROM Employees
    WHERE DepartmentID = @DepartmentID;
END;

--2. Execution Script (To test the output):

DECLARE @Result DECIMAL(10,2);
EXEC sp_GetTotalSalaryByDepartment @DepartmentID = 1, @TotalSalary = @Result OUTPUT;
SELECT @Result AS DepartmentTotalSalary;

--Exercise 7: Create a Stored Procedure with Multiple Parameters
--1. Creation Script:

CREATE PROCEDURE sp_UpdateEmployeeSalary
    @EmployeeID INT,
    @NewSalary DECIMAL(10,2)
AS
BEGIN
    UPDATE Employees
    SET Salary = @NewSalary
    WHERE EmployeeID = @EmployeeID;
END;

--2. Execution Script (As requested in step 4):
EXEC sp_UpdateEmployeeSalary 1, 5500.00;

--Exercise 8: Create a Stored Procedure with Conditional Logic
--1. Creation Script:

CREATE PROCEDURE sp_GiveBonus
    @DepartmentID INT,
    @BonusAmount DECIMAL(10,2)
AS
BEGIN
    -- Updates the salary by adding the bonus for the specified department
    UPDATE Employees
    SET Salary = Salary + @BonusAmount
    WHERE DepartmentID = @DepartmentID;
END;

--2. Execution Script:

EXEC sp_GiveBonus 1, 500.00;

--Exercise 9: Use Transactions in a Stored Procedure

CREATE PROCEDURE sp_UpdateSalaryWithTransaction
    @EmployeeID INT,
    @NewSalary DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Employees
        SET Salary = @NewSalary
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Throws the error message back to the user
        THROW; 
    END CATCH
END;

--Exercise 10: Use Dynamic SQL in a Stored Procedure

CREATE PROCEDURE sp_GetEmployeesDynamic
    @FilterColumn NVARCHAR(50),
    @FilterValue NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Constructing the query safely using dynamic SQL
    -- Note: QUOTENAME prevents SQL injection on column names
    SET @SQL = N'SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, JoinDate ' +
               N'FROM Employees ' +
               N'WHERE ' + QUOTENAME(@FilterColumn) + N' = @Value';

    -- Executing the dynamically constructed string
    EXEC sp_executesql @SQL, N'@Value NVARCHAR(100)', @Value = @FilterValue;
END;

--Exercise 11: Handle Errors in a Stored Procedure

CREATE PROCEDURE sp_UpdateSalaryWithErrorHandling
    @EmployeeID INT,
    @NewSalary DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if the employee exists before updating to throw a custom error
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('Error: Employee ID does not exist in the database.', 16, 1);
            RETURN;
        END

        -- Perform the salary update query
        UPDATE Employees
        SET Salary = @NewSalary
        WHERE EmployeeID = @EmployeeID;

    END TRY
    BEGIN CATCH
        -- Catch system or thrown errors and return a clear custom message
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            N'An error occurred while updating the salary: ' + ERROR_MESSAGE() AS CustomErrorMessage;
    END CATCH
END;






