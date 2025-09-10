-- ============================================
-- Case Study: Running Total in SQL Server, Best Approach for Running Totals
-- Author: Sayyid Mohammad Hoseini
-- Date: 2025-09-10
-- ============================================

USE [master]; 
GO 
-- Create the required database and tables
IF DB_ID('Test_RunningTotals') IS NOT NULL 
BEGIN 
	ALTER DATABASE Test_RunningTotals SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
	DROP DATABASE Test_RunningTotals; 
END 
GO 

CREATE DATABASE Test_RunningTotals; 
GO	

USE Test_RunningTotals; 
SET NOCOUNT ON; 
GO 

-- Create sample table
DROP TABLE IF EXISTS dbo.Population 
GO
CREATE TABLE dbo.Population
( 
	[Date]	DATE NOT NULL PRIMARY KEY, 
	Births	INT ,
	Deaths	INT 
); 
GO 
  
-- Insert sample data (add your dataset as needed)
; WITH cte AS
(
	SELECT	DATEADD(DAY,sod.SalesOrderDetailID,'1899-12-31') As [Date], 
			(sod.ProductID*sod.OrderQty)%200 As Births,
			(sod.ProductID*sod.OrderQty)%210 As Deaths
		FROM AdventureWorks2022.Sales.SalesOrderDetail as sod
)
INSERT dbo.Population([Date], Births, Deaths) 
	SELECT	TOP 30000 
			c.[Date], c.Births, Deaths
		FROM cte AS c
GO
 
-- View inserted records
SELECT [Date], Births, Deaths
	FROM dbo.Population 
	ORDER BY [Date]; 
GO 

-- A query that calculates the total number of births and deaths on each day and the days before it.

-- First method : Using Inner join
SELECT  p1.[Date], 
		p1.Births, 
		SUM(p2.Births) AS RunningTotal_Births,
		p1.Deaths, 
		SUM(p2.Deaths) AS RunningTotal_Deaths
	FROM dbo.Population AS p1 
		INNER JOIN dbo.Population AS p2 
			ON p2.[Date] <= p1.[Date] 
	GROUP BY p1.[Date], p1.Births, p1.Deaths
	ORDER BY p1.[Date]; 
GO

-- Second method : Using Subquery
SELECT  [Date], 
		Births, 
		Births + COALESCE((SELECT SUM(Births) 
								FROM dbo.Population AS s 
								WHERE s.[Date] < o.[Date]), 0) AS RunningTotal_Births,
		Deaths, 
		Deaths + COALESCE((SELECT SUM(Deaths) 
								FROM dbo.Population AS s 
								WHERE s.[Date] < o.[Date]), 0) As RunningTotal_Deaths
	FROM dbo.Population AS o 
	ORDER BY [Date]; 
GO

-- Third method : Using Update
DECLARE @tmp TABLE 
( 
	[Date] DATE PRIMARY KEY, 
	Births INT, 
	RunningTotal_Births INT,
	Deaths INT, 
	RunningTotal_Deaths INT 
); 
  
DECLARE @RunningTotal_Births INT = 0; 
DECLARE @RunningTotal_Deaths INT = 0; 
  
INSERT @tmp([Date], Births, RunningTotal_Births, Deaths, RunningTotal_Deaths) 
	SELECT [Date], Births, RunningTotal_Births = 0, Deaths, RunningTotal_Deaths = 0 
		FROM dbo.Population 
		ORDER BY [Date]; 
  
UPDATE @tmp SET 
		@RunningTotal_Births = RunningTotal_Births = @RunningTotal_Births + Births,
		@RunningTotal_Deaths = RunningTotal_Deaths = @RunningTotal_Deaths + Deaths 
	FROM @tmp
	OPTION(FORCE ORDER);
  
SELECT [Date], Births, RunningTotal_Births, Deaths, RunningTotal_Deaths 
	FROM @tmp 
	ORDER BY [Date];
GO

-- Fourth method : Using Recursive CTE
;WITH x AS 
( 
	SELECT	[Date], 
			Births, Births AS RunningTotal_Births, 
			Deaths, Deaths AS RunningTotal_Deaths
		FROM dbo.Population 
		WHERE [Date] = '1900-01-01' 
	UNION ALL 
	SELECT	y.[Date], 
			y.Births, x.RunningTotal_Births + y.Births,
			y.Deaths, x.RunningTotal_Deaths + y.Deaths 
		FROM x 
			INNER JOIN dbo.Population AS y 
				ON y.[Date] = DATEADD(DAY, 1, x.[Date]) 
) 
SELECT	[Date], 
		Births, RunningTotal_Births, 
		Deaths, RunningTotal_Deaths 
	FROM x 
	ORDER BY [Date] 
	OPTION (MAXRECURSION 0); 
GO

-- Method Five : Using Cursor
DECLARE @tmp TABLE 
( 
	[Date] DATE PRIMARY KEY, 
	Births INT, 
	RunningTotal_Births INT,
	Deaths INT, 
	RunningTotal_Deaths INT 
); 
  
DECLARE 
	@Date		DATE, 
	@Births		INT, 
	@RunningTotal_Births INT = 0,
	@Deaths		INT, 
	@RunningTotal_Deaths INT = 0; 
  
DECLARE c CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR 
	SELECT [Date], Births, Deaths 
		FROM dbo.Population 
		ORDER BY [Date]; 
OPEN c; 
FETCH NEXT FROM c INTO @Date, @Births, @Deaths; 
WHILE @@FETCH_STATUS = 0 
BEGIN 
	SET @RunningTotal_Births = @RunningTotal_Births + @Births; 
	SET @RunningTotal_Deaths = @RunningTotal_Deaths + @Deaths; 
  
	INSERT @tmp([Date], Births, RunningTotal_Births, Deaths, RunningTotal_Deaths) 
		SELECT @Date, @Births, @RunningTotal_Births, @Deaths, @RunningTotal_Deaths; 
  
	FETCH NEXT FROM c INTO @Date, @Births, @Deaths; 
END 
CLOSE c; 
DEALLOCATE c; 
  
SELECT [Date], Births, RunningTotal_Births, Deaths, RunningTotal_Deaths
	FROM @tmp
	ORDER BY [Date]; 
GO

-- Method Six : Using Window Function
SELECT  [Date], 
		Births, 
		SUM(Births) OVER (ORDER BY [Date]) AS RunningTotal_Births,
		Deaths, 
		SUM(Deaths) OVER (ORDER BY [Date]) AS RunningTotal_Deaths
	FROM dbo.Population 
	ORDER BY [Date]; 
GO

