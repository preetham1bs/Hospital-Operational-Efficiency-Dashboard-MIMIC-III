-- 8. Patient age grp analysis

USE mimic3;

-- MySQL uses YEAR() and TIMESTAMPDIFF for age calculation
SELECT
    CASE
        WHEN age <  18 THEN '1_Under 18'
        WHEN age <  40 THEN '2_18 to 39'
        WHEN age <  60 THEN '3_40 to 59'
        WHEN age <  75 THEN '4_60 to 74'
        ELSE                '5_75 plus'
    END                             AS age_group,
    COUNT(*)                        AS admissions,
    ROUND(AVG(los_days), 1)         AS avg_los_days,
    ROUND(MAX(los_days), 0)         AS max_los_days,
    ROUND(
        100.0 * SUM(expired) / COUNT(*),
    1)                              AS mortality_pct
FROM (
    SELECT
        a.hadm_id,
        -- MIMIC quirk: patients over 89 shown as ~300 yrs — cap at 91
        LEAST(
            TIMESTAMPDIFF(YEAR, p.dob, a.admittime),
            91
        )                           AS age,
        DATEDIFF(a.dischtime, a.admittime) AS los_days,
        a.hospital_expire_flag      AS expired
    FROM   admissions a
    JOIN   patients   p ON a.subject_id = p.subject_id
    WHERE  a.dischtime IS NOT NULL
) sub
GROUP  BY age_group
ORDER  BY age_group;