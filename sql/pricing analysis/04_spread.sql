-- Question 4: how much does location matter within a city, and does it matter
-- more in some cities than others?
-- Finding: the spread between the priciest and cheapest neighbourhood runs
-- from 9.4x in LA down to 2.8x in Boston. SF has the highest prices of the six
-- cities but nearly the narrowest spread, which is the opposite of what I
-- expected. LA sprawls from Malibu to the inland valleys so one city label
-- covers very different markets.
-- Robustness: dropping Malibu still leaves LA at 6.2x. Filtering to entire
-- homes only leaves it at 7.0x. So location does most of the work, but about
-- a quarter of the raw spread was room type mix rather than geography.


-- spread ratio per city
-- using a CTE because this needs two rounds of aggregation. first I collapse
-- listings into one median per neighbourhood, then I collapse those
-- neighbourhoods into a min and max per city. SQL will not let me nest
-- aggregates like MAX(PERCENTILE_CONT(...)) in a single pass
WITH neighbourhood_prices AS (
    SELECT
        city,
        neighbourhood,
        COUNT(*) AS listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price)) AS median_price
    FROM airbnb_data
    WHERE neighbourhood IS NOT NULL
    GROUP BY city, neighbourhood
    HAVING COUNT(*) >= 30
)

SELECT
    city,
    COUNT(*) AS neighbourhoods,
    ROUND(MIN(median_price)::numeric, 2) AS cheapest,
    ROUND(MAX(median_price)::numeric, 2) AS priciest,
    ROUND((MAX(median_price) / MIN(median_price))::numeric, 2) AS spread_ratio
FROM neighbourhood_prices
GROUP BY city
ORDER BY spread_ratio DESC;


-- robustness check on LA. the worry was that the 9.4x spread came from LA
-- having more entire homes in the expensive areas and more private rooms in
-- the cheap ones, which would make it a room type finding rather than a
-- location finding. filtering to entire homes only makes it like for like.
-- the spread stayed at 7.0x so location is doing most of the work.
-- note this drops LA from 79 neighbourhoods to 58, since some fall below the
-- 30 listing threshold once private rooms are excluded
WITH la_hoods AS (
    SELECT
        neighbourhood,
        COUNT(*) AS listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price)) AS median_price
    FROM airbnb_data
    WHERE city = 'LA'
      AND room_type = 'Entire home/apt'
      AND neighbourhood IS NOT NULL
    GROUP BY neighbourhood
    HAVING COUNT(*) >= 30
)

SELECT
    COUNT(*) AS neighbourhoods,
    ROUND(MIN(median_price)::numeric, 2) AS cheapest,
    ROUND(MAX(median_price)::numeric, 2) AS priciest,
    ROUND((MAX(median_price) / MIN(median_price))::numeric, 2) AS spread_ratio
FROM la_hoods;