--Exercise 1: Ranking and Window Functions
-- Goal: Find the top 3 most expensive products in each category using ROW_NUMBER(), RANK(), DENSE_RANK()

SELECT 
    ProductID,
    ProductName,
    Category,
    Price,
    ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Price DESC) AS RowNum,
    RANK() OVER (PARTITION BY Category ORDER BY Price DESC) AS RankNum,
    DENSE_RANK() OVER (PARTITION BY Category ORDER BY Price DESC) AS DenseRankNum
FROM Products;

-- Exercise 2: Aggregation with GROUPING SETS, CUBE, and ROLLUP
-- Goal: Generate a report showing total quantity sold by Region and Category\

SELECT 
    c.Region,
    p.Category,
    SUM(od.Quantity) AS TotalQuantitySold
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    CUBE (c.Region, p.Category); 

-- Exercise 3: CTEs and MERGE
-- Goal: a) Recursive CTE for calendar table b) MERGE statement from staging table
WITH CalendarCTE AS (
    SELECT CAST('2025-01-01' AS DATE) AS CalendarDate
    UNION ALL
    SELECT DATEADD(day, 1, CalendarDate)
    FROM CalendarCTE
    WHERE CalendarDate < '2025-01-31'
)
SELECT CalendarDate FROM CalendarCTE;

-- Part b: Create Staging Products Table
CREATE TABLE StagingProducts (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);

-- Insert sample change to merge
INSERT INTO StagingProducts VALUES (1, 'Laptop Pro', 'Electronics', 1400.00); 

-- MERGE Statement to update existing or insert new products
MERGE Products AS target
USING StagingProducts AS source
ON (target.ProductID = source.ProductID)
WHEN MATCHED THEN
    UPDATE SET 
        target.ProductName = source.ProductName,
        target.Category = source.Category,
        target.Price = source.Price
WHEN NOT MATCHED THEN
    INSERT (ProductID, ProductName, Category, Price)
    VALUES (source.ProductID, source.ProductName, source.Category, source.Price);

-- Exercise 4: PIVOT and UNPIVOT
-- Goal: Show monthly sales quantities per product in pivoted and unpivoted formats

-- Part a: PIVOT (Aggregating quantities by Month name dynamically or hardcoded)
SELECT ProductID, [January], [February], [March], [April]
FROM (
    SELECT od.ProductID, DATENAME(month, o.OrderDate) AS OrderMonth, od.Quantity
    FROM OrderDetails od
    JOIN Orders o ON od.OrderID = o.OrderID
) AS SourceTable
PIVOT (
    SUM(Quantity)
    FOR OrderMonth IN ([January], [February], [March], [April])
) AS PivotTable;

-- Exercise 5: Using CTE to Simplify a Query
-- Goal: Find customers who have placed more than 3 orders in total


WITH CustomerOrderCountCTE AS (
    SELECT 
        CustomerID,
        COUNT(OrderID) AS TotalOrders
    FROM Orders
    GROUP BY CustomerID
)
SELECT 
    c.CustomerID,
    c.Name,
    cte.TotalOrders
FROM Customers c
JOIN CustomerOrderCountCTE cte ON c.CustomerID = cte.CustomerID
WHERE cte.TotalOrders > 3;
