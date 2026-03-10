# Tableau Dashboard Design — UAT Release Tracker

## Dashboard Title
**UAT Release Readiness Dashboard**

---

## Purpose
Give engineering and finance leadership a real-time view of UAT progress per release — surfacing pass rates, open defects, and GO/NO-GO status without manual status updates.

---

## Dashboard Layout (3 Sections)

### Section 1 — Release Health (Top Row)
Four KPI tiles:

| Tile | Metric | Colour Logic |
|------|--------|--------------|
| Total Tests Run | COUNT of all test executions | Neutral (blue) |
| Pass Rate % | % with PASS status | Green >95%, amber 85–95%, red <85% |
| Open Defects | COUNT of FAIL status | Red if >0 |
| Release Decision | GO or NO-GO | Green = GO, Red = NO-GO |

---

### Section 2 — Test Analysis (Middle Row)

**Left: Pass Rate by Release — Line Chart**
- X-axis: release_id
- Y-axis: pass_rate_pct
- Reference line at 95%
- Purpose: Shows whether release quality is trending up

**Right: Failures by Category — Bar Chart**
- X-axis: test_category
- Y-axis: COUNT of failures
- Colour by severity (red = CRITICAL/HIGH, amber = MEDIUM, grey = LOW)
- Purpose: Shows which categories need more attention

---

### Section 3 — Defect Detail (Bottom)

**Open Defect Table**
- Columns: Release, Severity, Test ID, Defect ID, Test Name, Category, Actual Result, Days Since Found
- Row colour: Red = HIGH/CRITICAL, Amber = MEDIUM
- Sorted by severity then days open
- Filterable by release, category, severity

---

## Filters
- Release ID
- Test Category
- Severity
- Execution Date range
- Status (PASS / FAIL / BLOCKED)

---

## Calculated Fields in Tableau

```
// Release Decision
IF COUNTD(IF [Status] = "FAIL" AND [Severity] = "HIGH"
    THEN [Test Id] END) > 0
THEN "NO-GO"
ELSE "GO"
END

// Pass Rate %
SUM(IF [Status] = "PASS" THEN 1 ELSE 0 END) / COUNT([Test Id])

// Days Since Found
DATEDIFF('day', [Execution Date], TODAY())

// Severity Sort Order
IF [Severity] = "CRITICAL" THEN 1
ELSEIF [Severity] = "HIGH" THEN 2
ELSEIF [Severity] = "MEDIUM" THEN 3
ELSE 4
END
```
