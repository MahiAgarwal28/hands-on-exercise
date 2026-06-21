--Exercise 1: Create an After TriggerStep 
--1: Create the logging table

CREATE TABLE EmployeeChanges (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    OldSalary DECIMAL(10,2),
    NewSalary DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO

--Step 2: Create the AFTER UPDATE trigger

CREATE TRIGGER trg_LogSalaryChanges
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Salary)
    BEGIN
        INSERT INTO EmployeeChanges (EmployeeID, OldSalary, NewSalary)
        SELECT 
            i.EmployeeID,
            d.Salary AS OldSalary,
            i.Salary AS NewSalary
        FROM 
            inserted i
        INNER JOIN 
            deleted d ON i.EmployeeID = d.EmployeeID;
    END
END;
GO

--Exercise 2: Create an Instead of Trigger

CREATE TRIGGER trg_PreventEmployeeDelete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Raise an error and cancel the operation
    RAISERROR('Error: Deletions from the Employees table are strictly prohibited.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

--Exercise 3: Create a Logon Trigger

CREATE TRIGGER trg_RestrictLogonMaintenance
ON ALL SERVER
FOR LOGON
AS
BEGIN
    -- DATEPART(HOUR, GETDATE()) = 2 catches the window between 2:00 AM and 2:59 AM
    IF DATEPART(HOUR, GETDATE()) = 2
    BEGIN
        -- Rollback blocks the connection and prevents the login
        ROLLBACK; 
    END
END;
GO

--Exercise 4: Modify a Trigger using SSMS

ALTER TRIGGER trg_LogSalaryChanges
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Modified logic goes here
END;
GO

--Exercise 5:Delete a Trigger

DROP TRIGGER trg_LogSalaryChanges;
GO

--Exercise 6: Create a Trigger to Update a Computed Column
--Step 1: Add a new column named AnnualSalary to the Employees table

ALTER TABLE Employees 
ADD AnnualSalary DECIMAL(10,2);
GO

--Step 2 & 3: Create a trigger to calculate Salary * 12 whenever data is updated or inserted

CREATE TRIGGER trg_UpdateAnnualSalary
ON Employees
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Execute only if the Salary column is being modified or inserted
    IF UPDATE(Salary)
    BEGIN
        UPDATE e
        SET e.AnnualSalary = i.Salary * 12
        FROM Employees e
        INNER JOIN inserted i ON e.EmployeeID = i.EmployeeID;
    END
END;
GO


