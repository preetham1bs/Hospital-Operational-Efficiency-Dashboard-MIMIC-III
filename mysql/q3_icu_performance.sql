-- 3. ICU unit performance

USE mimic3;

SELECT
    first_careunit                          AS icu_unit,
    COUNT(*)                                AS total_stays,
    ROUND(AVG(los), 2)                      AS avg_los_days,
    ROUND(MIN(los), 2)                      AS min_los_days,
    ROUND(MAX(los), 2)                      AS max_los_days,
    ROUND(STDDEV(los), 2)                   AS stddev_los,
    -- % of stays longer than 7 days (prolonged)
    ROUND(
        100.0 * SUM(CASE WHEN los > 7 THEN 1 ELSE 0 END)
        / COUNT(*), 1
    )                                       AS pct_prolonged_stay,
    -- % of stays under 1 day (very short — possible transfers)
    ROUND(
        100.0 * SUM(CASE WHEN los < 1 THEN 1 ELSE 0 END)
        / COUNT(*), 1
    )                                       AS pct_short_stay
FROM   icustays
WHERE  first_careunit IS NOT NULL
GROUP  BY first_careunit
ORDER  BY total_stays DESC;