-- 1.Overall KPI summary

USE mimic3;

SELECT
    COUNT(DISTINCT a.subject_id)                        AS total_patients,
    COUNT(DISTINCT a.hadm_id)                           AS total_admissions,
    ROUND(AVG(DATEDIFF(a.dischtime, a.admittime)), 2)   AS avg_hosp_los_days,
    ROUND(AVG(i.los), 2)                                AS avg_icu_los_days,
    COUNT(DISTINCT i.icustay_id)                        AS total_icu_stays,
    ROUND(
        100.0 * SUM(a.hospital_expire_flag) / COUNT(*), 2
    )                                                   AS mortality_rate_pct,
    SUM(CASE WHEN a.admission_type = 'EMERGENCY'
             THEN 1 ELSE 0 END)                         AS emergency_count,
    ROUND(100.0 * SUM(CASE WHEN a.admission_type = 'EMERGENCY'
             THEN 1 ELSE 0 END) / COUNT(*), 1)          AS emergency_pct
FROM   admissions a
LEFT   JOIN icustays i ON a.hadm_id = i.hadm_id
WHERE  a.dischtime IS NOT NULL;