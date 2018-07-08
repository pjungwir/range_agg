-- It combines with UNNEST
-- to implement the temporal database "coalesce" function
-- (see Snodgrass 6.5.2):
SELECT  room_id, t2.booked_during
FROM    (
          SELECT  room_id, range_agg(booked_during, true, true) AS booked_during
          FROM    reservations
          GROUP BY room_id
        ) AS t1,
        UNNEST(t1.booked_during) AS t2(booked_during)
ORDER BY room_id, booked_during
;
