-- 9. Patient flow

USE mimic3;

-- How do patients move between units during one admission?
-- This is a unique insight no basic project includes
SELECT
    COALESCE(prev_careunit, 'Admission')   AS from_unit,
    COALESCE(curr_careunit, 'Discharge')   AS to_unit,
    COUNT(*)                               AS transfer_count,
    ROUND(AVG(los), 2)                     AS avg_time_in_unit_days
FROM   transfers
WHERE  eventtype IN ('transfer', 'admit', 'discharge')
GROUP  BY from_unit, to_unit
HAVING COUNT(*) >= 3
ORDER  BY transfer_count DESC
LIMIT  15;