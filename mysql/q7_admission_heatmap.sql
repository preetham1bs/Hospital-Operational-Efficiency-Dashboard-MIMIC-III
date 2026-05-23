-- 7. Admission hour & day heatmap

USE mimic3;

-- MySQL uses HOUR() and DAYOFWEEK() instead of strftime
SELECT
    HOUR(admittime)                         AS admission_hour,
    DAYOFWEEK(admittime)                    AS day_num,   -- 1=Sun, 7=Sat
    CASE DAYOFWEEK(admittime)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END                                     AS day_of_week,
    COUNT(*)                                AS admission_count,
    ROUND(AVG(
        DATEDIFF(dischtime, admittime)
    ), 1)                                   AS avg_los_days
FROM   admissions
WHERE  admittime IS NOT NULL
  AND  dischtime IS NOT NULL
GROUP  BY admission_hour, day_num, day_of_week
ORDER  BY day_num, admission_hour;