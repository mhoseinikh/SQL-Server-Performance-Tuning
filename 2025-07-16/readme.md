# <Case Title – کوتاه و دقیق>

## 1) Context
- SQL Server: 2019
- Workload: <OLTP/Analytics/Mixed>
- Object(s): <Table/Index/SP/Query>
- حجم تقریبی: <n GB/rows>

## 2) Problem (Baseline)
- Symptom: <duration, CPU, logical reads, spills, timeouts>
- Baseline snapshot: (از STATISTICS IO/TIME و/یا Query Store)
- قبل از بهبود:
  - Duration: <ms>
  - CPU: <ms>
  - Logical Reads: <n>
  - Spills/TempDB: <n / none>

## 3) Investigation
- Plan highlights: <Top operators, estimate vs actual, key lookups, scans, …>
- Wait stats/DMVs (اگر مرتبط است)
- Root cause: <parameter sniffing / missing index / bad join / outdated stats / …>

## 4) Change Applied
- Action: <ایجاد/تغییر ایندکس، بازنویسی کوئری، OPTION(RECOMPILE)، بروزرسانی آمار، …>
- دلیل انتخاب: <چرا این راهکار؟ اثر مورد انتظار چیست?>

## 5) Results (After)
- بعد از بهبود:
  - Duration: <ms>
  - CPU: <ms>
  - Logical Reads: <n>
  - Spills/TempDB: <n / none>
- **Before/After**:
  | Before | After |
  |:-----:|:-----:|
  | ![Before](./images/before.png) | ![After](./images/after.png) |

## 6) Scripts Used
- `./scripts/<file>.sql`
- یا از `/scripts/common/` اگر استفاده شده

## 7) Risks & Rollback
- ریسک‌ها: <ریسک ایندکس جدید/plan regression/…>
- Rollback: <حذف/بازگشت تغییر، plan guide، …>

---
> Note: Run on **non-production** first. Adapt to your environment.
