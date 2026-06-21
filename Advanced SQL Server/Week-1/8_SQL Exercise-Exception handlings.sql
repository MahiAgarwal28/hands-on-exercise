-- Question 1: Stored Procedure with TRY...CATCH

CREATE PROCEDURE AddEmployee
    @EmployeeID INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Salary DECIMAL(10,2),
    @DepartmentID INT
AS
BEGIN
    -- Turn off extra row-count messages for clean execution
    SET NOCOUNT ON;

    BEGIN TRY
        -- Attempt to insert the new employee details
        INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, Salary, DepartmentID)
        VALUES (@EmployeeID, @FirstName, @LastName, @Email, @Salary, @DepartmentID);
        
        PRINT 'Employee added successfully.';
    END TRY
    
    BEGIN CATCH
        -- If an error happens (e.g., duplicate email violation), catch it here
        DECLARE @ErrorMsg VARCHAR(4000);
        SET @ErrorMsg = ERROR_MESSAGE();

        -- Log the failure details into the AuditLog table
        INSERT INTO AuditLog (Action, ErrorMessage)
        VALUES ('INSERT EMPLOYEE FAILED', @ErrorMsg);
        
        PRINT 'An error occurred. Check the AuditLog table for details.';
    END CATCH
END;

-- Question 2: Using THROW to Re-raise Errors

ALTER PROCEDURE AddEmployee
    @EmployeeID INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Salary DECIMAL(10,2),
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, Salary, DepartmentID)
        VALUES (@EmployeeID, @FirstName, @LastName, @Email, @Salary, @DepartmentID);
        
        PRINT 'Employee added successfully.';
    END TRY
    
    BEGIN CATCH
        -- 1. Log the error into AuditLog table
        DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();

        INSERT INTO AuditLog (Action, ErrorMessage)
        VALUES ('INSERT EMPLOYEE FAILED', @ErrorMsg);
        
        -- 2. Use THROW without parameters to re-raise the caught error
        THROW; 
    END CATCH
END;

-- Question 3: Custom Error with RAISERROR

ALTER PROCEDURE AddEmployee
    @EmployeeID INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Salary DECIMAL(10,2),
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Validate business rule: Salary must be greater than zero
        IF @Salary <= 0
        BEGIN
            -- RAISERROR syntax: ('Message', Severity, State)
            -- Severity 16 indicates user-correctable errors
            RAISERROR('Salary must be greater than zero.', 16, 1);
        END

        -- 2. If valid, proceed with insert
        INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, Salary, DepartmentID)
        VALUES (@EmployeeID, @FirstName, @LastName, @Email, @Salary, @DepartmentID);
        
        PRINT 'Employee added successfully.';
    END TRY
    
    BEGIN CATCH
        -- 3. Log whatever error occurred (custom validation or system constraints)
        DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();

        INSERT INTO AuditLog (Action, ErrorMessage)
        VALUES ('INSERT EMPLOYEE FAILED', @ErrorMsg);
        
        -- 4. Re-raise the error back to the caller
        THROW;
    END CATCH
END;

-- Question 4: Nested TRY...CATCH with RAISERROR

CREATE PROCEDURE TransferEmployee
    @EmployeeID INT,
    @NewDepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Outer TRY block
    BEGIN TRY
        
        -- Nested/Inner TRY block for verification and operation
        BEGIN TRY
            -- Check if the target department exists in the Departments table
            IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentID = @NewDepartmentID)
            BEGIN
                -- Raise custom exception if the department is missing
                RAISERROR('Target department does not exist.', 16, 1);
            END

            -- If it exists, update the employee's department
            UPDATE Employees
            SET DepartmentID = @NewDepartmentID
            WHERE EmployeeID = @EmployeeID;

            PRINT 'Employee department transferred successfully.';
        END TRY
        
        -- Inner CATCH block to intercept and log the inner exception
        BEGIN CATCH
            DECLARE @InnerErrorMsg VARCHAR(4000) = ERROR_MESSAGE();

            -- Log the specific transfer failure event
            INSERT INTO AuditLog (Action, ErrorMessage)
            VALUES ('TRANSFER EMPLOYEE FAILED', @InnerErrorMsg);

            -- Re-throw the custom validation error so outer catch (or client) knows
            THROW;
        END CATCH

    END TRY
    
    -- Outer CATCH block to capture any higher-level unexpected system/database errors
    BEGIN CATCH
        -- Re-throw to inform the application client layer
        THROW;
    END CATCH
END;

-- Question 5: Logging All Errors in a Transaction

CREATE PROCEDURE BatchInsertEmployees
    -- Records for Employee 1
    @EmpID1 INT, @FName1 VARCHAR(50), @LName1 VARCHAR(50), @Email1 VARCHAR(100), @Salary1 DECIMAL(10,2), @DeptID1 INT,
    -- Records for Employee 2
    @EmpID2 INT, @FName2 VARCHAR(50), @LName2 VARCHAR(50), @Email2 VARCHAR(100), @Salary2 DECIMAL(10,2), @DeptID2 INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Start the explicit transaction block
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insert the first employee
        INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, Salary, DepartmentID)
        VALUES (@EmpID1, @FName1, @LName1, @Email1, @Salary1, @DeptID1);

        -- Insert the second employee
        INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, Salary, DepartmentID)
        VALUES (@EmpID2, @FName2, @LName2, @Email2, @Salary2, @DeptID2);

        -- If both statements complete without error, save the changes permanent
        COMMIT TRANSACTION;
        PRINT 'Batch insert completed successfully.';
    END TRY
    
    BEGIN CATCH
        -- Check if there is an active uncommitted transaction to discard
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Log the error details into the AuditLog table
        DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
        INSERT INTO AuditLog (Action, ErrorMessage)
        VALUES ('BATCH INSERT FAILED - TRANSACTION ROLLED BACK', @ErrorMsg);

        -- Propagate the error message back to the application user
        THROW;
    END CATCH
END;

--Question 6: Dynamic RAISERROR with Severity and State

ALTER PROCEDURE AddEmployee
    @EmployeeID INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Salary DECIMAL(10,2),
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Condition 1: If salary is negative, raise a strict runtime error (Severity 16)
        IF @Salary < 0
        BEGIN
            RAISERROR('Salary cannot be negative. Record rejected.', 16, 1);
        END

        -- Condition 2: If salary is too low (< 1000), raise an informational warning (Severity 10)
        -- Note: Severity 10 does not transfer execution to the CATCH block
        IF @Salary >= 0 AND @Salary < 1000
        BEGIN
            RAISERROR('Warning: Salary is unusually low (< 1000).', 10, 1);
        END

        -- Proceed with data insertion
        INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, Salary, DepartmentID)
        VALUES (@EmployeeID, @FirstName, @LastName, @Email, @Salary, @DepartmentID);
        
        PRINT 'Employee added successfully.';
    END TRY
    
    BEGIN CATCH
        -- Logs only terminal errors (like Severity 16 negative salary or PK/UK violations)
        DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();

        INSERT INTO AuditLog (Action, ErrorMessage)
        VALUES ('INSERT EMPLOYEE FAILED', @ErrorMsg);
        
        THROW;
    END CATCH
END;
