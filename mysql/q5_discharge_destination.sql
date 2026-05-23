-- 5. Discharge destination

USE mimic3;

SELECT
    COALESCE(discharge_location, 'Unknown')   AS discharge_location,
    COUNT(*)                                  AS patient_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM admissions WHERE dischtime IS NOT NULL),
    1)                                        AS pct_total,
    ROUND(AVG(
        DATEDIFF(dischtime, admittime)
    ), 1)                                     AS avg_los_days,
    -- Mortality flag for this discharge group
    ROUND(
        100.0 * SUM(hospital_expire_flag) / COUNT(*),
    1)                                        AS mortality_pct
FROM   admissions
WHERE  dischtime IS NOT NULL
GROUP  BY discharge_location
ORDER  BY patient_count DESC;