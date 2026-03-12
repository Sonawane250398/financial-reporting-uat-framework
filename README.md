# Financial Reporting UAT Framework

A structured **User Acceptance Testing (UAT) framework** for validating financial reporting releases.
The framework standardizes how finance and engineering teams test data accuracy, reconciliation logic, reporting outputs, and edge cases before production deployment.

---

## Business Problem

Financial reporting releases often lack a structured UAT process. Teams run informal checks, miss edge cases, and discover data defects only after deployment.

This framework standardizes the entire UAT lifecycle:

- what to test
- how to test it
- how to classify failures
- when a release should be approved

---

## Framework Components

| Component | File | Purpose |
|---|---|---|
| Test Scenarios | `test_scenarios.md` | 25 structured UAT test cases |
| UAT Analysis SQL | `uat_analysis.sql` | SQL layer for release scorecards |
| Sample Data | `sample_data.csv` | Example test execution dataset |
| Tableau Dashboard | `tableau_dashboard.md` | UAT release readiness dashboard spec |
| BRD Documentation | `BRD_SQL_Reconciliation_Framework.docx` | Full business requirements document |

---

## Results
- Zero critical post-deployment issues across 6 consecutive releases
- Framework adopted as standard across all financial reporting releases

---

## Author
**Yash Sonawane** — Business Analyst
LinkedIn: https://linkedin.com/in/yash-sonawane25
Portfolio: https://yashsonawane.vercel.app
