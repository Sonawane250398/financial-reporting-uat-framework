# UAT Test Scenarios — Financial Reporting Releases

Structured test scenarios aligned to reporting controls and edge cases. This document defines the repeatable UAT methodology used across release cycles.

---

## Test Categories

| Category | Purpose |
|----------|---------|
| Data Validation | Verify record counts, nulls, and aggregate totals match source |
| Reconciliation | Confirm source vs. reporting layer alignment |
| Reporting | Validate dashboard KPIs, filters, and visual accuracy |
| Edge Case | Test system behaviour at boundaries and with unusual inputs |
| Performance | Confirm queries execute within acceptable time thresholds |

---

## Test Scenarios by Category

### Category 1 — Data Validation

| Test ID | Test Name | Steps | Expected Result | Severity if Fail |
|---------|-----------|-------|-----------------|-----------------|
| DV-001 | Row Count Verification | 1. Run COUNT on reporting table 2. Run COUNT on source 3. Compare | Counts match within 0% tolerance | HIGH |
| DV-002 | Null Field Check | 1. Run NULL check on all critical fields 2. Verify zero nulls | Zero nulls in amount, account_id, date fields | HIGH |
| DV-003 | Aggregate Total Match | 1. SUM amounts in source 2. SUM in reporting 3. Compare | Match within $0.01 tolerance | CRITICAL |
| DV-004 | Duplicate Record Check | 1. Run duplicate check on primary key 2. Verify zero duplicates | Zero duplicate transaction IDs | HIGH |
| DV-005 | Date Range Completeness | 1. Check MIN and MAX dates 2. Verify full period covered | No gaps in date range for reporting period | MEDIUM |

---

### Category 2 — Reconciliation

| Test ID | Test Name | Steps | Expected Result | Severity if Fail |
|---------|-----------|-------|-----------------|-----------------|
| RC-001 | Source vs Report Match | 1. Run reconciliation query 2. Check MATCHED % | >95% of records MATCHED | CRITICAL |
| RC-002 | MISMATCH Classification | 1. Introduce known mismatch 2. Run query 3. Verify classification | Record classified as MISMATCH correctly | HIGH |
| RC-003 | MISSING Record Detection | 1. Remove one source record 2. Run query 3. Verify detection | Missing record surfaced in break report | HIGH |
| RC-004 | Variance Amount Accuracy | 1. Check variance = source minus reported 2. Verify calculation | Variance calculation is accurate | HIGH |
| RC-005 | Break Severity Accuracy | 1. Load records at each severity threshold 2. Run query | HIGH >$1000, MEDIUM >$100, LOW otherwise | MEDIUM |

---

### Category 3 — Reporting & Dashboard

| Test ID | Test Name | Steps | Expected Result | Severity if Fail |
|---------|-----------|-------|-----------------|-----------------|
| RP-001 | KPI Value Accuracy | 1. Note KPI values in dashboard 2. Run SQL query 3. Compare | Values match within 0.1% | HIGH |
| RP-002 | Filter Functionality | 1. Apply each filter 2. Verify all charts update 3. Clear and reset | Filters apply and clear correctly | MEDIUM |
| RP-003 | Date Filter Accuracy | 1. Apply date range filter 2. Verify data scope | Only data within selected range displayed | HIGH |
| RP-004 | Drill-Down Navigation | 1. Click on chart element 2. Verify drill-down loads | Correct detail view loads | LOW |
| RP-005 | Export Functionality | 1. Export dashboard data to CSV 2. Verify row count and values | Export matches dashboard display | MEDIUM |

---

### Category 4 — Edge Cases

| Test ID | Test Name | Steps | Expected Result | Severity if Fail |
|---------|-----------|-------|-----------------|-----------------|
| EC-001 | Null Amount Handling | 1. Load record with NULL amount 2. Run reconciliation 3. Verify no crash | NULL treated as 0, classified as MISSING | HIGH |
| EC-002 | Zero Value Transaction | 1. Load $0 transaction 2. Run reconciliation | Classified as MATCHED, no division errors | MEDIUM |
| EC-003 | Tolerance Boundary | 1. Load record at exact tolerance value 2. Run control | Classified as PASS_WITH_TOLERANCE | MEDIUM |
| EC-004 | Tolerance Boundary +1 | 1. Load record at tolerance + $0.01 2. Run control | Classified as FAIL | HIGH |
| EC-005 | Maximum Variance Record | 1. Load record with very large variance 2. Run break investigation | Classified as HIGH severity, surfaced first in report | HIGH |
| EC-006 | Empty Dataset | 1. Run queries against empty table | Graceful handling, no errors, zero counts returned | MEDIUM |
| EC-007 | Special Characters in Account Name | 1. Load account with special characters 2. Run queries | No parsing errors, name displayed correctly | LOW |

---

### Category 5 — Performance

| Test ID | Test Name | Steps | Expected Result | Severity if Fail |
|---------|-----------|-------|-----------------|-----------------|
| PF-001 | Reconciliation Query (10K rows) | 1. Load 10,000 rows 2. Execute reconciliation.sql 3. Time it | Completes within 30 seconds | MEDIUM |
| PF-002 | Control Framework (all domains) | 1. Load full dataset 2. Execute validation.sql | Completes within 60 seconds | MEDIUM |
| PF-003 | Dashboard Load Time | 1. Open Tableau dashboard with full data 2. Time initial load | Dashboard loads within 10 seconds | LOW |

---

## Go / No-Go Criteria

| Condition | Decision |
|-----------|----------|
| Zero CRITICAL or HIGH failures | GO |
| Any CRITICAL failure | NO-GO |
| Any HIGH failure unresolved | NO-GO |
| All MEDIUM failures documented with owner | GO with conditions |
| Edge case coverage ≥ 90% | Required for GO |

---

## Defect Severity Definitions

| Severity | Definition |
|----------|-----------|
| CRITICAL | Data corruption, incorrect financial totals, system crash |
| HIGH | Wrong classification, missing records, incorrect KPI values |
| MEDIUM | Minor calculation edge case, non-critical filter issue |
| LOW | UI cosmetic issue, export formatting, non-critical navigation |
