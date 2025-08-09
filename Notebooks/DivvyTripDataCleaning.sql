SELECT -- confirm the length of column
  MIN(LENGTH(trip_id)) AS min_tripId_length,
  MAX(LENGTH(trip_id)) AS max_tripId_length,
FROM 
  `first-provider-440421-n4.Divvy.Divvy_Trip_2024_Column_Cleaned`;
--confirmed that length of trip_column is consistent

SELECT -- check the distinct type of bike_id
  DISTINCT bike_type
FROM
  `first-provider-440421-n4.Divvy.Divvy_Trip_2024_Column_Cleaned`;
--confirmed there are no mispelled

SELECT -- check the distinct type of usertype
  DISTINCT user_type
FROM
  `first-provider-440421-n4.Divvy.Divvy_Trip_2024_Column_Cleaned`;
--confirmed there are no mispelled

--update the usertype casual rider to customer for better comprehensibility
UPDATE
  `first-provider-440421-n4.Divvy.Divvy_Trip_2024_Column_Cleaned`
SET
  user_type = 'customer'
WHERE
  user_type = 'casual';

-- Step-by-step trip data cleaning and preparation using CTEs
WITH cleaned_trips AS (
  -- Step 1: Remove records missing BOTH start and end station info
  SELECT *
  FROM `first-provider-440421-n4.Divvy.Divvy_Trip_2024_Column_Cleaned`
  WHERE NOT (start_station IS NULL AND start_station_id IS NULL)
    AND NOT (end_station IS NULL AND end_station_id IS NULL)
),

with_duration AS (
  -- Step 2: Calculate ride duration in minutes, extract day of week and weekend flag
  SELECT 
    *,
    ROUND(TIMESTAMP_DIFF(end_time, start_time, SECOND) / 60, 2) AS ride_duration_minutes, -- duration in minutes
    FORMAT_TIMESTAMP('%A', start_time) AS day_of_week, -- e.g., Monday, Tuesday
    CASE 
      WHEN EXTRACT(DAYOFWEEK FROM start_time) IN (1, 7) THEN 'Weekend' -- Sunday(1) or Saturday(7)
      ELSE 'Weekday'
    END AS weekend_flag
  FROM cleaned_trips
),

deduplicated AS (
  SELECT *
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (
             PARTITION BY trip_id
             ORDER BY start_time
           ) AS row_num
    FROM with_duration
  ) AS numbered
  WHERE row_num = 1  -- 保留每个 trip_id 的第一行
)

-- Step 4: Final result — clean, deduplicated data with enriched fields 
SELECT trip_id, bike_type, start_time, end_time, start_station, start_station_id, end_station, end_station_id,user_type
FROM deduplicated
WHERE trip_id IS NOT NULL; -- Filter out incomplete trip records


