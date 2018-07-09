--
--
-- Forbidding gaps and overlaps:
--
--
SELECT  room_id, range_agg(booked_during, false, false)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, false, false)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, false, false)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id;
--
--
-- Forbidding gaps but permitting overlaps
--
--
SELECT  room_id, range_agg(booked_during, false, true)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, false, true)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, false, true)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id;
--
--
-- Permitting gaps but forbidding overlaps
--
--
SELECT  room_id, range_agg(booked_during, true, false)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, true, false)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, true, false)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id;
--
--
-- Permitting gaps and overlaps:
--
--
SELECT  room_id, range_agg(booked_during, true, true)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, true, true)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id;

SELECT  room_id, range_agg(booked_during, true, true)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id;
--
--
-- Obeying discrete base types:
--
--
SELECT	range_agg(r, false, false)
FROM		(VALUES 
  (int4range( 0,  5, '[]')),
  (int4range( 7,  9, '[]'))
) t(r);

SELECT	range_agg(r, false, false)
FROM		(VALUES 
  (int4range( 0,  5, '[]')),
  (int4range( 5,  9, '[]'))
) t(r);

SELECT	range_agg(r, true, true)
FROM		(VALUES 
  (int4range( 0,  9, '[]')),
  (int4range(10, 15, '[]')),
  (int4range(20, 26, '[]')),
  (int4range(26, 29, '[]'))
) t(r);
