# Preprocess Open Roads data to find the network graph of roads
import fiona
import geopandas as gpd
import pandas as pd

file = "data/oproad_gpkg_gb/data/oproad_gb.gpkg"

# RoadLink has 3719381 rows
# Read in parts so as not to overwhelm memory
# Discard geometry since we are only interested in connectivity
for i, row_slice in enumerate((slice(0, 1_000_000), slice(1_000_000, 2_000_000), slice(2_000_000, 3_000_000), slice(3_000_000, 3_719_381))):
    data = gpd.read_file(file, rows=row_slice, ignore_geometry=True)
    print(data)
    data.to_csv(f"data/all_{i}.csv", index=False)

# combine all files and restrict to Motorway, A, and B roads
dfs = []
for i in range(4):
    df = pd.read_csv(f"data/all_{i}.csv")
    df = df[["startNode", "endNode", "roadClassification", "roadClassificationNumber"]]
    df = df[df.roadClassificationNumber.notnull()]
    dfs.append(df)

df = pd.concat(dfs)
df.to_csv("data/mab.csv", index=False)
