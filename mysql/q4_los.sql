-- 4. Length of stay distribution

USE mimic3;

-- DATEDIFF gives whole days in MySQL
SELECT
    CASE
        WHEN DATEDIFF(dischtime, admittime) < 1  THEN '1__Under 1 day'
        WHEN DATEDIFF(dischtime, admittime) < 3  THEN '2__1 to 3 days'
        WHEN DATEDIFF(dischtime, admittime) < 7  THEN '3__3 to 7 days'
        WHEN DATEDIFF(dischtime, admittime) < 14 THEN '4__7 to 14 days'
        WHEN DATEDIFF(dischtime, admittime) < 30 THEN '5__14 to 30 days'
        ELSE                                          '6__Over 30 days'
    END                                     AS los_bucket,
    COUNT(*)                                AS patient_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM admissions WHERE dischtime IS NOT NULL),
    1)                                      AS pct_of_total
FROM   admissions
WHERE  dischtime IS NOT NULL
GROUP  BY los_bucket
ORDER  BY los_bucket;  -- the numbered prefix keeps them in order in Power BI