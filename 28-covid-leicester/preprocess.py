import os
import pandas as pd
import re

pd.set_option('display.max_rows', None)

dfs = []
for file in sorted(os.listdir("data")):
    print(file)
    if file.endswith(".csv"):
        m = re.match("coronavirus-cases_(\d{4})(\d{2})(\d{2})\d{4}.csv", file)
        date = f"{m.group(1)}-{m.group(2)}-{m.group(3)}"

        df = pd.read_csv(f"data/{file}")
        df = df[df["Area code"] == "E06000016"]
        df = df[df["Area type"] == "Upper tier local authority"]
        df = df[["Specimen date", "Daily lab-confirmed cases"]]

        df.rename(columns={"Daily lab-confirmed cases": date}, inplace=True)
        #print(df)
        dfs.append(df)

merged = dfs[0]
for df in dfs[1:]:
    merged = pd.merge(merged, df, how="outer", on="Specimen date", right_index=False, left_index=False)

merged = merged.sort_values(by=["Specimen date"])
print(merged)
merged.to_csv("data/covid_leicester.csv", index=False)