# <Case Title – short and precise>

## 1) Context
- SQL Server Version/Edition: <e.g., SQL Server 2019 Enterprise>
- Workload Type: <OLTP / Analytics / Mixed>
- Objects: <Table / Index / Stored Procedure / Query>
- Approx. Data Size: <n rows / n GB>

---

## 2) Problem (Baseline)
- Symptom: <high CPU, long duration, excessive logical reads, spills, timeouts>
- Baseline snapshot (captured with STATISTICS IO/TIME, Query Store, or Profiler):
  - Duration: <ms>
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

---

## 4) Combined Results
This screenshot shows both **before** and **after** execution times in a single view.
### Combined Results 1
![Combined Execution Time](./images/RPT.vOrderSum.jpg)
### Combined Results 2
![Combined Execution Time](./images/RPT.vOrderSum_2.jpg)

---

## 5) Performance Comparison
| Metric        | Before       | After   | Improvement |
|---------------|-------------:|--------:|------------:|
| Duration      | 299,405 ms   | 6,192 ms | 97.9% ↓ |
| CPU           | 197,376 ms   | 2,969 ms | 98.5% ↓ |
| Logical Reads | 2,142,556    | 12,306   | 99.4% ↓ |

---

## 6) Change Applied
- Action taken: <created index, updated statistics, query rewrite, OPTION(RECOMPILE), etc.>
- Reasoning: <why this change was selected, expected impact>

---

## 7) Results
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

## 8) Scripts Used
- `./scripts/<file>.sql`
- Or reference to `/scripts/common/` if shared helpers were used

---

## 9) Risks & Rollback
- Risks: <index bloat, plan regression, query store capture, etc.>
- Rollback: <drop index, revert stats, remove hint, restore previous plan>

---

> ⚠️ **Important:** Always test changes on **non-production** environments before applying to live systems.


