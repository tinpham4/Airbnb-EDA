-- Question 2: what are people actually renting in each city?
-- Finding: NYC is only 50 percent entire homes, the lowest of the six cities,
-- which was dragging its citywide median down. Comparing entire homes only,
-- NYC ($160) is actually above DC ($155) even though the raw city numbers
-- said the opposite. SF is expensive on the merits, not on mix.
-- Private rooms cost about the same everywhere ($60 to $71), so the gaps
-- between cities are almost entirely an entire home thing.


-- room type mix per city, and what each type costs
SELECT
    city,
    room_type,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY city)
    , 1) AS pct_of_city,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price))::numeric
    , 2) AS median_price
FROM airbnb_data
GROUP BY city, room_type
ORDER BY city, listings DESC;