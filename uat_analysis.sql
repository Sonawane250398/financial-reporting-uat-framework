-- ============================================================
-- UAT Framework for Financial Reporting Releases
-- Author: Yash Sonawane
-- Description: SQL-based analysis layer for UAT execution results.
--              Tracks test outcomes per release, surfaces failures,
--              and produces release readiness scorecards.
-- ============================================================


-- ============================================================
-- STEP 1: Test execution summary per release
-- ============================================================

WITH release_summary AS (
    SELECT
        release_id,
        COUNT(*)                                               AS total_tests,
        SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END)      AS passed,
        SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END)      AS failed,
        SUM(CASE WHEN status = 'BLOCKED' THEN 1 ELSE 0 END)   AS blocked,
        ROUND(
            SUM(CASE WHEN status = 'PASS' THEN 1.0 ELSE 0 END)
            / COUNT(*) * 100, 2
        )                                                      AS pass_rate_pct,
        MIN(execution_date)                                    AS uat_start_date,
        MAX(execution_date)                                    AS uat_end_date,
        -- Release go/no-go: pass only if zero HIGH/CRITICAL failures
        CASE
            WHEN SUM(CASE WHEN status = 'FAIL'
                          AND severity IN ('HIGH', 'CRITICAL')
                          THEN 1 ELSE 0 END) = 0
            THEN 'GO'
            ELSE 'NO-GO'
        END AS release_decision
    FROM uat_results
    GROUP BY release_id
),


-- ============================================================
-- STEP 2: Test category breakdown
-- Shows which categories have the most failures
-- ============================================================

category_breakdown AS (
    SELECT
        release_id,
        test_category,
        COUNT(*)                                              AS tests_in_category,
        SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END)    AS failures,
        ROUND(
            SUM(CASE WHEN status = 'PASS' THEN 1.0 ELSE 0 END)
            / COUNT(*) * 100, 2
        )                                                     AS category_pass_rate
    FROM uat_results
    GROUP BY release_id, test_category
),


-- ============================================================
-- STEP 3: Failed test detail — defect tracking
-- ============================================================

defect_report AS (
    SELECT
        release_id,
        test_id,
        test_name,
        test_category,
        severity,
        defect_id,
        expected_result,
        actual_result,
        tester,
        execution_date,
        -- Days open (relative to UAT end date per release)
        DATEDIFF(
            MAX(execution_date) OVER (PARTITION BY release_id),
            execution_date
        ) AS days_since_found
    FROM uat_results
    WHERE status = 'FAIL'
),


-- ============================================================
-- STEP 4: Edge case coverage analysis
-- Ensures critical edge cases were tested each release
-- ============================================================

edge_case_coverage AS (
    SELECT
        release_id,
        COUNT(*)                                              AS total_edge_cases,
        SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END)    AS edge_cases_passed,
        ROUND(
            SUM(CASE WHEN status = 'PASS' THEN 1.0 ELSE 0 END)
            / COUNT(*) * 100, 2
        )                                                     AS edge_case_pass_rate
    FROM uat_results
    WHERE test_category = 'Edge Case'
    GROUP BY release_id
),


-- ============================================================
-- STEP 5: Release-over-release trend
-- Tracks whether test quality is improving across releases
-- ============================================================

release_trend AS (
    SELECT
        release_id,
        pass_rate_pct,
        failed,
        release_decision,
        LAG(pass_rate_pct) OVER (ORDER BY release_id)        AS prev_pass_rate,
        pass_rate_pct
            - LAG(pass_rate_pct) OVER (ORDER BY release_id)  AS pass_rate_change
    FROM release_summary
)


-- ============================================================
-- FINAL OUTPUT 1: Release readiness scorecard
-- ============================================================

SELECT
    rs.release_id,
    rs.total_tests,
    rs.passed,
    rs.failed,
    rs.pass_rate_pct,
    rs.release_decision,
    ec.edge_case_pass_rate,
    rt.pass_rate_change        AS improvement_vs_prev_release,
    rs.uat_start_date,
    rs.uat_end_date
FROM release_summary rs
LEFT JOIN edge_case_coverage ec USING (release_id)
LEFT JOIN release_trend rt USING (release_id)
ORDER BY rs.release_id;


-- ============================================================
-- FINAL OUTPUT 2: Open defect report
-- ============================================================

SELECT
    release_id,
    severity,
    test_id,
    defect_id,
    test_name,
    test_category,
    actual_result,
    days_since_found
FROM defect_report
ORDER BY
    CASE severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH'     THEN 2
        WHEN 'MEDIUM'   THEN 3
        ELSE                 4
    END,
    days_since_found DESC;
