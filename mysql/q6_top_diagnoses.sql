-- 6. Top diagnoses by volume & avg. loss

USE mimic3;

-- JOIN diagnosis codes to their human-readable names
SELECT
    d.short_title                               AS diagnosis,
    d.icd9_code,
    COUNT(*)                                    AS patient_count,
    ROUND(AVG(
        DATEDIFF(a.dischtime, a.admittime)
    ), 1)                                       AS avg_los_days,
    ROUND(
        100.0 * SUM(a.hospital_expire_flag) / COUNT(*),
    1)                                          AS mortality_rate_pct,
    -- Volume × LOS = total bed-days consumed (operational burden score)
    ROUND(
        COUNT(*) * AVG(DATEDIFF(a.dischtime, a.admittime)),
    0)                                          AS total_bed_days
FROM   diagnoses_icd di
JOIN   admissions a      ON di.hadm_id    = a.hadm_id
JOIN   d_icd_diagnoses d ON di.icd9_code  = d.icd9_code
WHERE  di.seq_num    = 1          -- primary diagnosis only
  AND  a.dischtime   IS NOT NULL
GROUP  BY d.icd9_code, d.short_title
HAVING COUNT(*) >= 3              -- exclude very rare diagnoses
ORDER  BY patient_count DESC
LIMIT  20;