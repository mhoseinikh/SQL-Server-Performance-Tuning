# SQL Server Query Performance Tuning – Case Study (2025-09-17)

This case study demonstrates a **real-world SQL Server query optimization** where a slow-performing query was analyzed, tuned, and significantly improved in terms of CPU usage, duration, and logical reads.

---

## 📂 Repository Structure

```
SQL-Server-Performance-Tuning/
└── Case-Studies/
    └── 2025-09-17_SELECT-Query/
        ├── images/        # Profiler screenshots & table statistics
        ├── scripts/       # Original and optimized SQL scripts
        └── sqlplan/       # Execution plans (before & after)
```

---

## 📁 Folders

- **images/** → Contains profiler screenshots and table statistics for execution comparison.  
- **scripts/** → Includes the original [scripts/SELECT-Query_OLD.sql](`SELECT-Query_OLD.sql`) and optimized [scripts/SELECT-Query_NEW.sql](`SELECT-Query_NEW.sql`) query scripts.  
- **sqlplan/** → Execution plan files (`.sqlplan`) showing before and after optimization.  

---

## 📊 Initial Problem

The original query (`SELECT-Query_OLD.sql`) contained:
- Multiple **nested subqueries**.
- **UDF calls**.
- A costly **ROW_NUMBER() + subquery** pattern inside the main SELECT.
- Complex joins across several large tables.

### Original Query Performance (Profiler)
- **CPU:** 313,719  
- **Duration:** 321,853 ms  
- **Reads:** 1,786,840  
- **Writes:** 26  
- **Results:** 19 rows  

📷 See images:  
- `images/SELECT-Query_OLD_EXECUTE-1.jpg`  
- `images/SELECT-Query_OLD_EXECUTE-2.jpg`  

📑 Execution plan:  
- `sqlplan/SELECT-Query_OLD-Execution-Plan.sqlplan`

---

## 🔎 Identified Bottleneck

The main performance issue was the following subquery:

```sql
SELECT *
FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY di.DocItemID ORDER BY dar.DocArticleRelationID) Rowid,
         dr.DocHeadTargetID, dha.VoucherID, dha.DocDate, dha.DocNo, da.DebtorType,
         da.DirectionType, ah.Title AS Certain, p.Title AS Headlines, dha.DocHeaderType,
         di.DocItemID, da.AccountingHeadlinesID
  FROM WAS.Voucher AS dha
       INNER JOIN WAS.DocRelation AS dr ON dr.VoucherID = dha.VoucherID
       INNER JOIN WAS.DocArticle AS da ON da.VoucherID = dha.VoucherID
       INNER JOIN WAS.DocArticleRelation AS dar ON dar.DocArticleID = da.DocArticleID
       INNER JOIN WAS.DocItem AS di ON di.DocItemID = dar.DocItemTargetID
       INNER JOIN WAS.AccountingHeadlines AS ah ON ah.AccountingHeadlinesID = da.AccountingHeadlinesID
       LEFT JOIN WAS.AccountingHeadlines p ON p.AccountingHeadlinesID = ah.ParentID
  WHERE ah.ParentID IN (11)
    AND dha.ConvertStatus = 0
) AS f
WHERE f.Rowid = 1;
```

This part introduced high **I/O cost**, excessive **reads**, and long execution times.

---

## 🛠 Optimization Approach

The query was restructured in `SELECT-Query_NEW.sql` with the following changes:
- Replaced nested subquery with **OUTER APPLY (TOP 1 + ORDER BY)** for more efficient row selection.  
- Simplified joins and reduced **row materialization**.  
- Removed unnecessary **scalar UDF calls**.  
- Used **NOLOCK hints** where appropriate for reporting workloads.  
- Reduced intermediate dataset size before joining.  

---

## 🚀 Optimized Query Performance

Profiler results for the new query:

- **CPU:** 266  
- **Duration:** 271 ms  
- **Reads:** 4,241  
- **Writes:** 0  
- **Results:** 19 rows  

📷 See images:  
- `images/SELECT-Query_NEW_EXECUTE-1.jpg`  
- `images/SELECT-Query_NEW_EXECUTE-2.jpg`  

📑 Execution plan:  
- `sqlplan/SELECT-Query_NEW-Execution-Plan.sqlplan`

---

## 📈 Performance Comparison

| Metric      | Old Query | New Query | Improvement |
|-------------|-----------|-----------|-------------|
| CPU         | 313,719   | 266       | **>99.9%**  |
| Duration    | 321,853ms | 271ms     | **>99.9%**  |
| Reads       | 1,786,840 | 4,241     | **>99.7%**  |
| Writes      | 26        | 0         | Reduced     |
| Result Rows | 19        | 19        | Same output |

---

## ✅ Key Takeaways

- Replacing **ROW_NUMBER() in subqueries** with **TOP 1 + OUTER APPLY** can drastically improve performance.  
- Eliminating **unnecessary UDFs and nested subqueries** reduces CPU and logical reads.  
- Careful review of the **execution plan** is critical in finding the exact bottlenecks.  
- Even small queries (returning only 19 rows) can be extremely costly if not optimized.  

---

## 📎 Files

- **Old query script:** `scripts/SELECT-Query_OLD.sql`  
- **New query script:** `scripts/SELECT-Query_NEW.sql`  
- **Execution plans:** `sqlplan/`  
- **Profiler screenshots:** `images/`  

---

## 🏷 Tags

`SQL Server` `Performance Tuning` `Execution Plan` `Query Optimization` `Profiler` `Case Study`
