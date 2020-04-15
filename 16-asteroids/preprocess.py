import math
import pandas as pd

df = pd.read_csv("data/cneos_closeapproach_data_20ld.csv")
print(df)

def to_metres(s):
    if s.endswith("km"):
        return float(s[0:-2]) * 1000.0
    elif s.endswith("m"):
        return float(s[0:-1])
    return math.nan

def extract_diameter_range(s):
    if isinstance(s, float) and math.isnan(s):
        return math.nan, math.nan
    s = s.replace(" ", "").split("-")
    return to_metres(s[0]), to_metres(s[1])

# Example format is "2047-Feb-12 22:18 ±    14:25" - just extract the date
df['Date'] = df.apply(lambda row: pd.to_datetime(row['Close-Approach (CA) Date'].split(' ')[0]), axis=1)

# Example format is "0.37 | 0.00096" - just extract the first part (Lunar Distance)
df['Nominal Distance'] = df.apply(lambda row: pd.to_numeric(row['CA Distance Nominal (LD | au)'].split(' ')[0]), axis=1)

# Example format is "0.37 | 0.00096" - just extract the first part (Lunar Distance)
df['Minimum Distance'] = df.apply(lambda row: pd.to_numeric(row['CA Distance Minimum (LD | au)'].replace(">", "").strip().split(' ')[0]), axis=1)

print(df.columns)
print(df.dtypes)

# Example format is "11 m -   24 m", or "580 m -  1.3 km" - extract two columns
df['Lower Diameter Range'] = df.apply(lambda row: extract_diameter_range(row['Estimated Diameter'])[0], axis=1)
df['Upper Diameter Range'] = df.apply(lambda row: extract_diameter_range(row['Estimated Diameter'])[1], axis=1)

df = df[['Object', 'Date', 'Nominal Distance', 'Minimum Distance', 'Lower Diameter Range', 'Upper Diameter Range']]

df.to_csv("data/cneos_closeapproach_data_20ld_clean.csv", index=False)