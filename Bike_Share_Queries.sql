

CREATE TABLE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata` as(

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202101-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202102-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202103-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202104-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202105-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202106-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202107-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202108-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202109-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202110-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202111-divvy-tripdata`

UNION ALL

SELECT * FROM `bike-share-project-2022.Bike_share_project_2022.202112-divvy-tripdata`);
---------------------

SELECT COUNT(*) FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`;

SELECT ended_at, started_at, DATE_DIFF(ended_at,started_at,MINUTE) as trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`;

ALTER TABLE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
ADD COLUMN trip_length_mins NUMERIC;

ALTER TABLE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
ADD COLUMN ride_happened NUMERIC;

UPDATE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
SET trip_length_mins = DATE_DIFF(ended_at,started_at,MINUTE)
WHERE ride_id IS NOT NULL;

#Cheking for anomalies, Cleaning the data
SELECT DISTINCT member_casual
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`;

SELECT MIN (end_lng), MAX(end_lng), MIN(end_lat), MAX(end_lat), MIN(start_lng), MAX(start_lng), MIN(start_lat), MAX(start_lat)
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`;

SELECT end_station_id, end_station_name, COUNT(*)
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
GROUP BY end_station_id, end_station_name;
# Cheking for rideable_type and if there are irregularities
SELECT rideable_type, COUNT(*)
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
GROUP BY rideable_type;
# Cheking for duplicate lines
SELECT ride_id , COUNT(*)
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
GROUP BY ride_id
HAVING COUNT(*)>1;
# Cheking for Null
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE started_at is NULL AND ended_at is NULL;
# Cheking for either of the statition is Null
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE started_at is NULL OR ended_at is NULL;
# Removing Null starting or ending location
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE start_lng is NULL OR end_lng is NULL OR ride_happened is NULL;
# Removing Null starting and ending location
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE start_lng is NULL AND end_lng is NULL AND ride_happened is NULL;
# Removing Null member casual
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE member_casual is NULL AND ride_happened is NULL;
# Removing Null rideable type
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE rideable_type is NULL AND ride_happened is NULL;
# Removing Anomalities
# Exclude Cases Where starting time greater than ending time
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE started_at >= ended_at;

UPDATE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
SET ride_happened = 0
WHERE started_at >= ended_at;

# Exclude trip length less than or equal to 0
SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE trip_length_mins <= 0;

UPDATE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
SET ride_happened = 0
WHERE trip_length_mins <= 0;

# Cheking for stations

SELECT COUNT(*)
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE start_station_name is null AND end_station_name is null;

SELECT COUNT(*)
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE start_station_name is null OR end_station_name is null;

UPDATE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
SET ride_happened = 0
WHERE start_station_name is null OR end_station_name is null;

#Cheking Station names

SELECT *
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
WHERE ride_happened is NULL
AND (LOWER(start_station_name) LIKE '%base%warehouse%' OR LOWER(end_station_name) LIKE '%base%warehouse%');

UPDATE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
SET ride_happened = 0
WHERE ride_happened is NULL AND
  (LOWER(start_station_name) LIKE '%base%warehouse%' OR LOWER(end_station_name) LIKE '%base%warehouse%');

# Create Tables for visualisations 

UPDATE `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
SET ride_happened = 1
WHERE ride_happened is NULL;

SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1;
-------------------------
WITH data as (SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1)

SELECT member_casual , COUNT(*)
FROM data
GROUP BY member_casual;

WITH data as (SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1)

SELECT member_casual, FORMAT_DATE("%b %Y", started_at) as new_date, COUNT(*)
FROM data
GROUP BY member_casual, new_date; 


WITH data as (SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1)

SELECT member_casual, COUNT(*)
FROM data
WHERE trip_length_mins >59 AND trip_length_mins <120
GROUP BY member_casual; 

WITH data as (SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1)

SELECT *
FROM (
        SELECT 'Origin' origin_destination, start_station_name AS station_name, start_lat lat, start_lng lng, member_casual
        FROM data
        
        UNION ALL
        
        SELECT 'Destination' origin_destination, end_station_name AS station_name, end_lat lat, end_lng lng, member_casual
        FROM data
);
-------- Ordering by Num Rank

WITH data as (SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1)

SELECT *
FROM (
        SELECT member_casual, start_station_name, end_station_name, num, rank() over (partition by member_casual order by num desc) num_rank
        FROM(
            SELECT member_casual, start_station_name, end_station_name, COUNT(*) as num
            FROM data
            GROUP BY member_casual,  start_station_name, end_station_name
        )
)
WHERE num_rank <= 30;
----------------

WITH data as (SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual, trip_length_mins
FROM `bike-share-project-2022.Bike_share_project_2022.divvy-tripdata`
where ride_happened = 1)

SELECT member_casual, start_station_name, end_station_name, count(*) AS num
FROM data
GROUP BY member_casual,  start_station_name, end_station_name    ;


---------------------




