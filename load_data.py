import os
import re

import pandas as pd
from sqlalchemy import URL, create_engine


airbnb = pd.read_csv("data/Airbnb_Data.csv")

airbnb.columns = [
    re.sub(r"[^a-z0-9]+", "_", column.lower()).strip("_")
    for column in airbnb.columns
]


password = os.environ.get("AIRBNB_DB_PASSWORD")

if not password:
    raise RuntimeError(
        "Set AIRBNB_DB_PASSWORD before running this script."
    )


connection_url = URL.create(
    drivername="postgresql+psycopg",
    username="postgres",
    password=password,
    host="127.0.0.1",
    port=5432,
    database="airbnb",
)


engine = create_engine(connection_url)


airbnb.to_sql(
    "airbnb_data",
    engine,
    if_exists="replace",
    index=False
)


print("CSV loaded into PostgreSQL")