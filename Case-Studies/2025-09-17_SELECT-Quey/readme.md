# SQL Server Performance Tuning – Running Total Case Study

This repository contains all files related to the case study **"Optimizing Heavy Queries in SQL Server: Running Total"**.  
The study evaluates multiple approaches for calculating running totals in SQL Server and compares their performance.

📖 Full article with details, explanations, and screenshots is available here:  
👉 [Optimizing Heavy Queries in SQL Server – Running Total Case Study](https://smhoseini.ir/optimizing-heavy-queries-in-sql-server-running-total-case-study/)

---

## Repository Structure

SQL-Server-Performance-Tuning/
└── Case-Studies/
    └── 2025-09-10_Running-Total/
        ├── images/ # Query execution screenshots & visuals
        ├── scripts/ # SQL script with all queries
        └── sqlplan/ # SQL Server execution plan files

---

### 📂 Folders

- **`images`** → Contains execution plan screenshots and profiler results.  
- **`scripts`** → Includes a single SQL script with the implementation of all six methods for calculating running totals.  
- **`sqlplan`** → Raw SQL Server execution plan files for deeper analysis.  

---

## Methods Compared

1. **INNER JOIN** – Self-join approach  
2. **Subquery** – Row-by-row aggregation  
3. **Update with Variables** – Temporary table and cumulative variables  
4. **Recursive CTE** – Common Table Expression with recursion  
5. **Cursor** – Row-by-row cursor-based calculation  
6. **Window Function (OVER ... ORDER BY)** – Most efficient and optimized by SQL Server engine  

---

## Final Results (Summary)

| Method            | CPU    | Duration (ms) | Reads     | Writes | Code Simplicity | Algorithm Complexity | Suitable For                   |
|-------------------|--------|---------------|----------:|-------:|-----------------|----------------------|--------------------------------|
| INNER JOIN        | 122,484| 80,442        | 1,189,435 | 0     | Simple          | O(n²)                | Educational / Small data        |
| Subquery          | 272,297| 301,638       | 4,755,824 | 0     | Simpler than Join | O(n²)              | Educational / Small data        |
| Update + Variables| 265    | 574           | 226,926   | 177   | Medium          | O(n)                 | Large data / High performance   |
| Recursive CTE     | 357    | 660           | 330,125   | 0     | Medium          | O(n) (but expensive) | Experimental / Special cases    |
| Cursor            | 891    | 2,701         | 181,934   | 109   | Complex         | O(n) with high cost  | Special scenarios, not production|
| Window Function   | 234    | 318           | 285,771   | 32    | Very simple     | Optimized O(n)       | Best choice for Production      |

---

## How to Use
1. Open the **`scripts/Scripts_SQL-Server.sql`** file in SQL Server Management Studio (SSMS).
2. Execute the queries step by step to reproduce the case study results.
3. Use the **`.sqlplan`** files to compare actual execution plans before and after optimization.
4. Refer to the screenshots in **images/** for visual results.

---

## Script Content

For convenience, the full SQL script is included here as well.  
📂 You can also open it directly: [scripts/Scripts_SQL-Server.sql](./scripts/Scripts_SQL-Server.sql)

```sql
-- ============================================
-- Case Study: Running Total in SQL Server
-- Author: Sayyid Mohammad Hoseini
-- Date: 2025-09-10
-- ============================================

-- Create sample table
CREATE TABLE dbo.Population
(
    [Date] DATE PRIMARY KEY,
    Births INT,
    Deaths INT
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

-- A query that calculates the total number of births and deaths on each day and the days before it.

------------------------------------------------------------
-- Method 1: Using INNER JOIN
------------------------------------------------------------
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

------------------------------------------------------------
-- Method 2: Using Subquery
------------------------------------------------------------
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

------------------------------------------------------------
-- Method 3: Using Update with Variables
------------------------------------------------------------
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

------------------------------------------------------------
-- Method 4: Using Recursive CTE
------------------------------------------------------------
;WITH x AS
(
    SELECT [Date],
           Births, Births AS RunningTotal_Births,
           Deaths, Deaths AS RunningTotal_Deaths
    FROM dbo.Population
    WHERE [Date] = '1900-01-01'
    UNION ALL
    SELECT y.[Date],
           y.Births, x.RunningTotal_Births + y.Births,
           y.Deaths, x.RunningTotal_Deaths + y.Deaths
    FROM x
        INNER JOIN dbo.Population y
            ON y.[Date] = DATEADD(DAY, 1, x.[Date])
)
SELECT [Date],
       Births, RunningTotal_Births,
       Deaths, RunningTotal_Deaths
    FROM x
    ORDER BY [Date]
    OPTION (MAXRECURSION 0);
GO

------------------------------------------------------------
-- Method 5: Using Cursor
------------------------------------------------------------
DECLARE @tmp TABLE
(
    [Date] DATE PRIMARY KEY,
    Births INT,
    RunningTotal_Births INT,
    Deaths INT,
    RunningTotal_Deaths INT
);

DECLARE @Date DATE,
        @Births INT,
        @RunningTotal_Births INT = 0,
        @Deaths INT,
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
        VALUES (@Date, @Births, @RunningTotal_Births, @Deaths, @RunningTotal_Deaths);

    FETCH NEXT FROM c INTO @Date, @Births, @Deaths;
END

CLOSE c;
DEALLOCATE c;

SELECT [Date], Births, RunningTotal_Births, Deaths, RunningTotal_Deaths
    FROM @tmp
    ORDER BY [Date];
GO

------------------------------------------------------------
-- Method 6: Using Window Function
------------------------------------------------------------
SELECT [Date],
       Births,
       SUM(Births) OVER (ORDER BY [Date]) AS RunningTotal_Births,
       Deaths,
       SUM(Deaths) OVER (ORDER BY [Date]) AS RunningTotal_Deaths
    FROM dbo.Population
    ORDER BY [Date];
GO
```
---

## Feedback & Contributions

I welcome your **feedback, alternative approaches, or performance test results** on different datasets.  
You can also connect with me here:  

- [Website](https://smhoseini.ir)  
- [GitHub Profile](https://github.com/mhoseinikh)  
- [LinkedIn](https://www.linkedin.com/in/sm-hoseini/)  

---

⭐ If you find this case study helpful, consider starring the repository!