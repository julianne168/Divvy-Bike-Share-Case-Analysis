SELECT
  ride_id AS trip_id,
  rideable_type AS bike_type,
  started_at AS start_time,
  ended_at AS end_time,
  start_station_name AS start_station,
  start_station_id, 
  end_station_name AS end_station,
  end_station_id, 
  member_casual AS user_type
FROM `first-provider-440421-n4.Divvy.DivvyTripData2024`