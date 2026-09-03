-- Question 1: can I trust the price data?
-- Finding: means overstate typical prices by up to 74 percent. Only 2 to 3
-- percent of listings are over $1000 but they move the citywide average a lot.
-- Prices are also capped around $1999, which is a dataset artifact, not real.
-- Decision: use median for the rest of the project.


-- first look at the price range in each city
-- exp() undoes the log transform so I get real dollar prices
SELECT
    city,
    COUNT(*) AS listings,
    ROUND(AVG(EXP(log_price))::numeric, 2) AS avg_price,
    ROUND(MIN(EXP(log_price))::numeric, 2) AS min_price,
    ROUND(MAX(EXP(log_price))::numeric, 2) AS max_price
FROM airbnb_data
GROUP BY city
ORDER BY avg_price DESC;


-- the maxes all landed around 1999 which looked suspicious, so I checked how
-- many listings sit at the extremes and compared mean against median
SELECT
    city,
    COUNT(*) AS listings,
    SUM(CASE WHEN EXP(log_price) <= 25 THEN 1 ELSE 0 END) AS under_25,
    SUM(CASE WHEN EXP(log_price) >= 1000 THEN 1 ELSE 0 END) AS over_1000,
    ROUND(AVG(EXP(log_price))::numeric, 2) AS avg_price,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXP(log_price))::numeric
    , 2) AS median_price
FROM airbnb_data
GROUP BY city
ORDER BY avg_price DESC;