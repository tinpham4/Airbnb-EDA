-- Question 5: does paying more actually get you a better stay?
-- Finding: barely. Average rating goes from 93.1 in the under $75 bucket to
-- 95.3 in the $350 plus bucket. Prices vary by more than 5x across those
-- buckets but ratings move 2.2 points on a 100 point scale. The trend is
-- consistent at every step so it is probably real, just small. Price signals
-- location and size, not guest satisfaction.
-- Side finding: review counts form an inverted U. Mid priced listings ($75 to
-- $200) average 29 to 31 reviews while the cheapest average 23.8 and the most
-- expensive average 19.1. Since reviews roughly track bookings, the middle of
-- the market looks like where the demand is.
-- Caveat: 16,722 listings (22.6 percent) have no rating at all, most likely
-- because they have never been booked. This only describes listings that have
-- had at least one stay.


-- first checking how many listings even have a rating, since a big gap here
-- changes how much I trust the rest of this file
SELECT
    COUNT(*) AS total_listings,
    COUNT(review_scores_rating) AS has_rating,
    COUNT(*) - COUNT(review_scores_rating) AS missing_rating,
    ROUND(
        (COUNT(*) - COUNT(review_scores_rating)) * 100.0 / COUNT(*)
    , 1) AS pct_missing
FROM airbnb_data;


-- do expensive listings get better reviews
-- bucketing by price so I can compare groups instead of eyeballing 74k rows.
-- the numbers on the bucket labels are there to force the sort order, since
-- text sorts alphabetically and "Under 75" would otherwise land in the wrong
-- place
SELECT
    CASE
        WHEN EXP(log_price) < 75 THEN '1. Under 75'
        WHEN EXP(log_price) < 125 THEN '2. 75 to 125'
        WHEN EXP(log_price) < 200 THEN '3. 125 to 200'
        WHEN EXP(log_price) < 350 THEN '4. 200 to 350'
        ELSE '5. 350 plus'
    END AS price_bucket,
    COUNT(*) AS listings,
    ROUND(AVG(review_scores_rating)::numeric, 1) AS avg_rating,
    ROUND(AVG(number_of_reviews)::numeric, 1) AS avg_review_count
FROM airbnb_data
WHERE review_scores_rating IS NOT NULL
GROUP BY price_bucket
ORDER BY price_bucket;