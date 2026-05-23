-- 10. Admission type and its avg. LOS

USE mimic3;

SELECT
    admission_type,
    COUNT(*) AS patient_count,

    ROUND(
        AVG(
            DATEDIFF(dischtime, admittime)
        ),
        2
    ) AS avg_los_days

FROM admissions

WHERE admittime IS NOT NULL
  AND dischtime IS NOT NULL
  AND admission_type IS NOT NULL

GROUP BY admission_type

ORDER BY avg_los_days DESC;
