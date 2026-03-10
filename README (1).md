# UAT Framework for Financial Reporting Releases

A repeatable UAT methodology and SQL analysis layer for validating financial reporting releases — covering data validation, reconciliation accuracy, dashboard reporting, edge cases, and performance testing.

---

## Problem Statement

Financial reporting releases often lack structured UAT — teams run informal checks, miss edge cases, and discover defects post-deployment. This framework standardizes the entire UAT process: what to test, how to test it, how to classify failures, and when to approve a release.

---

## Framework Components

| Component | File | Purpose |
|-----------|------|---------|
| Test Scenarios | `test_scenarios.md` | 25 structured test cases across 5 categories |
| UAT Analysis SQL | `uat_analysis.sql` | Tracks results, surfaces defects, produces release scorecard |
| Sample Data | `sample_data.csv` | 15 sample test execution records across 2 releases |

---

## Test Coverage (25 Test Cases)

| Category | Tests | Focus |
|----------|-------|-------|
| Data Validation | 5 | Row counts, nulls, aggregates, duplicates, date completeness |
| Reconciliation | 5 | Source vs. report match, MISMATCH/MISSING detection, variance accuracy |
| Reporting & Dashboard | 5 | KPI accuracy, filters, drill-downs, exports |
| Edge Cases | 7 | Nulls, zeros, tolerance boundaries, empty datasets, special characters |
| Performance | 3 | Query execution time, dashboard load time |

---

## SQL Analysis Capabilities

- **Release Scorecard** — pass rate, GO/NO-GO decision, edge case coverage per release
- **Defect Report** — all failures with severity, defect ID, days since found
- **Category Breakdown** — which test categories fail most across releases
- **Release Trend** — pass rate improvement vs. previous release using `LAG()`

---

## Go / No-Go Logic

```
Release is GO if:
  ✓ Zero CRITICAL failures
  ✓ Zero unresolved HIGH failures
  ✓ Edge case coverage ≥ 90%
  ✓ All MEDIUM failures documented with owner
```

---

## Key SQL Techniques Used

- **CTEs** — 5-stage pipeline from raw results to release scorecard
- **LAG() window function** — release-over-release pass rate trend
- **Conditional aggregation** — pass/fail counts with `CASE WHEN` inside `SUM()`
- **DATEDIFF** — days since defect was found per release
- **PARTITION BY** — scoped window calculations per release

---

## Sample Results (from sample_data.csv)

- **REL-2024-01**: 10 tests, 8 passed, 2 failed (HIGH severity) → **NO-GO**
- **REL-2024-02**: 5 tests, 5 passed, 0 failed → **GO**
- Both HIGH failures from REL-2024-01 (P&L row count, duplicates) resolved in REL-2024-02

---

## Business Impact (Real-World Application)

- Framework adopted across **6 consecutive releases**
- **Zero critical post-deployment issues** across all 6 releases
- Reduced post-deployment issue resolution time significantly
- Improved release stability and team confidence in deployment cycles

---

## Author

**Yash Sonawane** — Business Analyst, Financial Systems  
[LinkedIn](https://linkedin.com/in/yash-sonawane25)
