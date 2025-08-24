# <Case Title – Optimizing Reporting View RPT.vOrderSum for Performance>

## 1) Context
- SQL Server Version/Edition: #SQL Server 2019 Enterprise
- Workload Type: #OLTP
- Objects:  #Table / Query / View / UDF
- Approx. Data Size: #1 GB

---

## 2) Problem (Baseline)
- Symptom: long duration, excessive logical reads
- Baseline snapshot (captured with STATISTICS IO/TIME, Query Store, or Profiler):
  - Duration: 
  - CPU: <ms>
  - Logical Reads: <n>
  - Spills/TempDB: <n / none>
- Example (Before Plan):
![Before Plan](./images/before.png)

---

## 3) Investigation
Describe the analysis process, e.g.:
- Plan highlights: <scans, key lookups, missing indexes, parameter sniffing>
- DMV/Wait Stats evidence
- Root cause identified: <reason here>

### Step-by-Step Screenshots (if applicable)
**Step 1 – Original Plan**
![Step 1](./images/step1_plan.png)

**Step 2 – Index Analysis**
![Step 2](./images/step2_index.png)

**Step 3 – Statistics Update**
![Step 3](./images/step3_stats.png)

### Combined Results (Execution Time)
This screenshot shows both **before** and **after** execution times in a single view.
![Combined Execution Time](./images/combined_execution.png)

---

## 4) Change Applied
- Action taken: <created index, updated statistics, query rewrite, OPTION(RECOMPILE), etc.>
- Reasoning: <why this change was selected, expected impact>

---

## 5) Results (After)
- Duration: <ms>
- CPU: <ms>
- Logical Reads: <n>
- Spills/TempDB: <n / none>

### Before vs After Comparison
| Before | After |
|:------:|:-----:|
| ![Before](./images/before.png) | ![After](./images/after.png) |

| Combined Screenshot |
|:-------------------:|
| ![Combined](./images/combined_execution.png) |
*Note: This screenshot contains both Before and After execution times.*


### Data Evidence (optional)
Query runtime distribution before tuning:
![Before Data](./images/data_distribution.png)

Query runtime distribution after tuning:
![After Data](./images/data_distribution_after.png)

---

## 6) Scripts Used
- `./scripts/<file>.sql`
- Or reference to `/scripts/common/` if shared helpers were used

---

## 7) Risks & Rollback
- Risks: <index bloat, plan regression, query store capture, etc.>
- Rollback: <drop index, revert stats, remove hint, restore previous plan>

---

> ⚠️ **Important:** Always test changes on **non-production** environments before applying to live systems.
