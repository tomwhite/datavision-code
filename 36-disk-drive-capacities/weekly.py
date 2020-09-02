import pandas as pd

df = pd.read_csv("data/drives.csv", names=["date", "serial_number", "model", "capacity_bytes", "failure"], parse_dates=["date"])

# Filter out first day to avoid impression of a large number of installations that week
df = df[df["date"] != "2013-04-10"]

# Filter out rows with no capacities
df = df[df["capacity_bytes"] != -1]

df["drive_type"] = df["model"].apply(lambda x: "SSD" if ("ssd" in x or "SSD" in x) else "HDD")

# Bin by week
df["year"] = df['date'].apply(lambda x: x.isocalendar()[0])
df["week"] = df['date'].apply(lambda x: x.isocalendar()[1])
df["week_start"] = pd.to_datetime(df.week.astype(str) +
    df.year.astype(str).add('-1') ,format='%V%G-%u')

# Find number of drives for each capacity, by week
df = df.groupby(["week_start", "capacity_bytes", "drive_type"]).size().to_frame("count")

df.to_csv("data/weeks.csv")
