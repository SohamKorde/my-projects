-- 1. Check structure
SELECT * FROM uber_requests LIMIT 5;

-- 2. Check column types and nulls
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'uber_requests';

-- EDA
-- Trip Status Count
SELECT status, COUNT(*) AS count
FROM uber_requests
GROUP BY status;

-- Requests by Hour
SELECT request_hour, COUNT(*) AS total_requests
FROM uber_requests
GROUP BY request_hour
ORDER BY request_hour;

-- Pickup Point vs Status
SELECT "pickup_point", status, COUNT(*) AS count
FROM uber_requests
GROUP BY "pickup_point", status
ORDER BY "pickup_point", count DESC;

-- Time Slot vs Failed Requests
SELECT request_time_slot, status, COUNT(*) AS count
FROM uber_requests
WHERE status != 'Trip Completed'
GROUP BY request_time_slot, status
ORDER BY request_time_slot;

-- Business Insights (from SQL)
-- 1. Supply-Demand Gap by Time Slot
SELECT request_time_slot,
       COUNT(*) FILTER (WHERE status = 'Trip Completed') AS supply,
       COUNT(*) AS demand,
       COUNT(*) - COUNT(*) FILTER (WHERE status = 'Trip Completed') AS gap
FROM uber_requests
GROUP BY request_time_slot
ORDER BY gap DESC;


-- 2. Peak Failure Times (No Cars + Cancellations)
SELECT request_hour,
       COUNT(*) FILTER (WHERE status = 'Cancelled') AS cancelled,
       COUNT(*) FILTER (WHERE status = 'No Cars Available') AS no_cars
FROM uber_requests
GROUP BY request_hour
ORDER BY request_hour;


-- 3. Completion Rate by Pickup Point
SELECT "pickup_point",
       ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Trip Completed') / COUNT(*), 2) AS completion_rate
FROM uber_requests
GROUP BY "pickup_point";


-- 4. Time Slot with Highest Demand-Supply Mismatch (Failure Rate %)
SELECT 
  request_time_slot,
  COUNT(*) AS total_requests,
  COUNT(*) FILTER (WHERE status = 'Trip Completed') AS completed,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status != 'Trip Completed') / COUNT(*), 2) AS failure_rate_percent
FROM uber_requests
GROUP BY request_time_slot
ORDER BY failure_rate_percent DESC;


-- 5. Day-wise Completion Rate
SELECT 
  request_day,
  COUNT(*) AS total_requests,
  COUNT(*) FILTER (WHERE status = 'Trip Completed') AS completed,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Trip Completed') / COUNT(*), 2) AS completion_rate
FROM uber_requests
GROUP BY request_day
ORDER BY completion_rate ASC;


-- 6. Driver Utilization
SELECT 
  "driver_id",
  COUNT(*) AS total_trips,
  COUNT(*) FILTER (WHERE status = 'Trip Completed') AS completed_trips,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Trip Completed') / COUNT(*), 2) AS utilization_percent
FROM uber_requests
WHERE "driver_id" IS NOT NULL
GROUP BY "driver_id"
ORDER BY utilization_percent ASC;


-- 7. Pickup Point vs Failure Type
SELECT 
  "pickup_point",
  status,
  COUNT(*) AS failure_count
FROM uber_requests
WHERE status != 'Trip Completed'
GROUP BY "pickup_point", status
ORDER BY "pickup_point", failure_count DESC;


-- 8. Airport-specific Demand Pattern
SELECT 
  request_hour,
  COUNT(*) AS total_airport_requests
FROM uber_requests
WHERE "pickup_point" = 'Airport'
GROUP BY request_hour
ORDER BY request_hour;

-- 9. Top Failure Combinations (Time Slot + Pickup Point)
SELECT 
  request_time_slot,
  "pickup_point",
  status,
  COUNT(*) AS count
FROM uber_requests
WHERE status != 'Trip Completed'
GROUP BY request_time_slot, "pickup_point", status
ORDER BY count DESC
LIMIT 10;

-- 10. Completion Trends by Hour
SELECT 
  request_hour,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'Trip Completed') / COUNT(*), 2) AS completion_rate
FROM uber_requests
GROUP BY request_hour
ORDER BY request_hour;

-- 11. Hourly Cancellation vs No Cars
SELECT 
  request_hour,
  COUNT(*) FILTER (WHERE status = 'Cancelled') AS cancellations,
  COUNT(*) FILTER (WHERE status = 'No Cars Available') AS no_cars
FROM uber_requests
GROUP BY request_hour
ORDER BY request_hour;

-- 12. Net Lost Trips Per Slot
SELECT 
  request_time_slot,
  COUNT(*) FILTER (WHERE status != 'Trip Completed') AS failed,
  COUNT(*) FILTER (WHERE status = 'Trip Completed') AS completed,
  COUNT(*) FILTER (WHERE status != 'Trip Completed') - COUNT(*) FILTER (WHERE status = 'Trip Completed') AS net_lost
FROM uber_requests
GROUP BY request_time_slot
ORDER BY net_lost DESC;

-- 13. Busiest Pickup Time at Airport
SELECT 
  request_hour,
  COUNT(*) AS airport_requests
FROM uber_requests
WHERE "pickup_point" = 'Airport'
GROUP BY request_hour
ORDER BY airport_requests DESC
LIMIT 3;








