--
--
-- Forbidding gaps and overlaps:
--
--
SELECT  room_id, range_agg(booked_during)
FROM    reservations
WHERE   room_id = 1
GROUP BY room_id
ORDER BY room_id;

SELECT  room_id, range_agg(booked_during)
FROM    reservations
WHERE   room_id = 6
GROUP BY room_id
ORDER BY room_id;

SELECT  room_id, range_agg(booked_during)
FROM    reservations
WHERE   room_id NOT IN (1, 6)
GROUP BY room_id
ORDER BY room_id;
--
--
-- Obeying discrete base types:
--
--
SELECT	range_agg(r)
FROM		(VALUES 
  (int4range( 0,  9, '[]')),
  (int4range(10, 19, '[]'))
) t(r);
