-- Question 3: which neighbourhoods are expensive, and does the ranking make sense?
-- Finding: 301 neighbourhoods across the six cities have enough listings to
-- rank. The results pass a sanity check. Back Bay and Beacon Hill top Boston,
-- Dorchester and Roslindale sit at the bottom. Streeterville and River North
-- lead Chicago. In LA the beach and hills neighbourhoods rank highest and the
-- inland and south areas rank lowest, which matches how those cities actually
-- price.


-- median price by neighbourhood, ranked inside each city
-- ranking within the city because ranking across all six just gives me SF over
-- and over. the HAVING drops neighbourhoods too small to trust, since a place
-- with 4 listings can top the chart on noise alone
SELECT
    city,
    neighbourhood,
    COUNT(*) AS listings,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price))::numeric
    , 2) AS median_price,
    RANK() OVER (
        PARTITION BY city
        ORDER BY PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price)) DESC
    ) AS price_rank_in_city
FROM airbnb_data
WHERE neighbourhood IS NOT NULL
GROUP BY city, neighbourhood
HAVING COUNT(*) >= 30
ORDER BY city, price_rank_in_city;


-- pulling out LA on its own to check the top and bottom of the list.
-- I wanted to make sure the wide spread I found later was a real slope and
-- not one weird neighbourhood at either end
SELECT
    neighbourhood,
    COUNT(*) AS listings,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price))::numeric
    , 2) AS median_price
FROM airbnb_data
WHERE city = 'LA'
  AND neighbourhood IS NOT NULL
GROUP BY neighbourhood
HAVING COUNT(*) >= 30
ORDER BY median_price DESC;