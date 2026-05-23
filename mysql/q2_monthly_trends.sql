-- 2. Monthly admission trends


USE mimic3;

SELECT
    DATE_FORMAT(admittime, '%Y-%m') AS yr_mo,
    YEAR(admittime)                 AS yr,
    MONTH(admittime)                AS mo,

    COUNT(*) AS total_admissions,

    SUM(
        CASE 
            WHEN admission_type = 'EMERGENCY'
            THEN 1 ELSE 0
        END
    ) AS emergency_admissions,

    SUM(
        CASE 
            WHEN admission_type = 'ELECTIVE'
            THEN 1 ELSE 0
        END
    ) AS elective_admissions,

    SUM(
        CASE 
            WHEN admission_type = 'URGENT'
            THEN 1 ELSE 0
        END
    ) AS urgent_admissions,

    ROUND(
        AVG(DATEDIFF(dischtime, admittime)),
        2
    ) AS avg_los_days

FROM admissions

WHERE admittime IS NOT NULL
AND dischtime IS NOT NULL

GROUP BY
    YEAR(admittime),
    MONTH(admittime),
    DATE_FORMAT(admittime, '%Y-%m')

ORDER BY yr ASC, mo ASC;
