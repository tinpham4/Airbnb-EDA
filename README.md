# Airbnb Pricing EDA

An exploratory analysis of 74,111 Airbnb listings across six US cities, done mostly in SQL with Python for the charts.

I started this wanting to know which neighbourhoods were expensive. The first thing I found was that I could not trust the averages, so the project turned into figuring out what the data would actually support before answering anything else.

## Findings

**Average prices overstate what a typical listing costs, by a lot.**

DC's mean nightly price is $217.93 but its median is $125.00. That is a 74 percent gap. LA runs $155.39 against $100.00. The cause is a small tail: only 2 to 3 percent of listings sit above $1,000 a night, and they move the citywide average by half again or more. Everything after this point uses medians.

The data also has a price ceiling. Four of the six cities max out between $1,995 and $1,999, which is not how real prices behave. Whoever built the dataset capped it at $2,000, so the top end is compressed.

**Location matters far more in some cities than others, and it is backwards from what I expected.**

Comparing the priciest neighbourhood to the cheapest one inside each city:

* LA: 9.4x ($395 in Malibu down to $42 in Gardena)
* NYC: 5.1x
* DC: 4.6x
* Chicago: 3.8x
* SF: 3.0x
* Boston: 2.8x

SF has the highest prices of any city here but nearly the narrowest spread. LA is only mid priced overall yet location swings it almost 10x. That makes sense geographically. SF is seven miles across and expensive nearly everywhere, while LA covers Malibu, the valleys, and everything between under one label.

I checked whether LA's number was one weird neighbourhood propping it up. It is not. The prices step down smoothly from $395 to $42 with no cliffs, and dropping Malibu entirely still leaves LA at 6.2x.

**Some of that spread was room type, not location.**

The obvious objection is that expensive LA neighbourhoods might just have more entire homes while cheap ones have more private rooms, which would make this a product finding dressed up as a location finding. Filtering to entire homes only, LA's spread drops from 9.4x to 7.0x. So location does most of the work, but roughly a quarter of the raw number was room type mix. Worth saying out loud rather than reporting the bigger figure.

**NYC is more expensive than it looks.**

NYC is only 50.2 percent entire homes, the lowest share of the six cities, which was dragging its citywide median down. Compare like for like and NYC entire homes go for $160 against DC's $155, even though the raw city medians say DC is pricier.

Private rooms turned out to cost about the same everywhere, between $60 and $71.50 in five of the six cities. So the price gaps between cities are almost entirely an entire home phenomenon.

**Paying more barely buys a better stay.**

Average rating goes from 93.1 in the under $75 bucket to 95.3 in the $350 plus bucket. Prices vary more than 5x across those buckets. Ratings vary by 2.2 points on a 100 point scale. The trend is consistent at every step so it is probably real, just small. Price seems to signal location and size rather than guest satisfaction.

One thing I did not expect: review counts form an inverted U. Mid priced listings between $75 and $200 average 29 to 31 reviews, while the cheapest average 23.8 and the most expensive average 19.1. Since review counts roughly track bookings, the middle of the market looks like where the demand actually is.

## Caveats

* 16,722 listings (22.6 percent) have no review score, most likely because they were never booked. The review analysis only describes listings that have had at least one stay.
* Prices are capped around $2,000 in the source data, so anything genuinely more expensive is compressed at the ceiling.
* Neighbourhood analysis only includes neighbourhoods with at least 30 listings. Below that, a handful of listings can produce a misleading median.
* This is a snapshot, not a time series. There is nothing here about seasonality.

## How it works

The CSV goes into PostgreSQL with a short pandas script, then all the analysis happens in SQL. Python only makes the charts.

Prices are stored as `log_price` in the source data, so every query wraps them in `EXP()` to get real dollars back.

```
sql/
  eda/
    01_explore.sql          price ranges, outliers, mean against median
    02_room_type.sql        what people are renting in each city
  pricing_analysis/
    03_neighbourhoods.sql   median price by neighbourhood, ranked per city
    04_spread.sql           how much location matters, plus robustness checks
    05_price_reviews.sql    does paying more get a better stay
analysis.ipynb              the charts
load_data.py                CSV into Postgres
```

Each SQL file opens with a comment block stating the question and what I found, so you can skim the five of them and get the whole project without reading any queries.

## Running it

You need PostgreSQL and a database called `airbnb`.

```bash
export AIRBNB_DB_PASSWORD='your_password'
python load_data.py
```

Then run the SQL files in order, or open the notebook, which pulls its own query results straight from Postgres.

## Data

Airbnb listings dataset from Kaggle. 74,111 rows, 29 columns, covering NYC, LA, SF, DC, Chicago, and Boston.

## Tools

PostgreSQL, Python, pandas, SQLAlchemy, matplotlib, seaborn, Jupyter.
