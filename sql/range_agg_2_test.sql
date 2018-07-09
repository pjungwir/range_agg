--
--
-- Forbidding gaps (and overlaps):
--
--
SELECT  room_id, range_agg(booked_during, false)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, false)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, false)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id;
--
--
-- Permitting gaps (but forbidding overlaps):
--
--
SELECT  room_id, range_agg(booked_during, true)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, true)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, true)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id;
