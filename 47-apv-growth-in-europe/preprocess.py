from dataclasses import dataclass
import pandas as pd
import string
from typing import List, Optional

@dataclass
class Metadata:
    date: str
    skiprows: int
    sheet_name: Optional[List[str]] = None

files = {
    # All passenger cars before 2018 (monthly)

    "data/20141118_PRPC-1410_-_FINAL_-_corrected.xls": Metadata("201410", 12, sheet_name=["By Market"]),
    "data/20141206_PRPC_1411_FINAL_corrected.xls": Metadata("201411", 12, sheet_name=["By Market"]),
    "data/PRPC_1412_FINAL_corrected.xlsx": Metadata("201412", 12, sheet_name=["By Market"]),

    "data/PRPC_1501_FINAL.xlsx": Metadata("201501", 12, sheet_name=["By Market"]),
    "data/20150317_PRPC_1502_FINAL.xlsx": Metadata("201502", 12, sheet_name=["By Market"]),
    "data/20150416_PRPC_1503_FINAL.xlsx": Metadata("201503", 12, sheet_name=["By Market"]),
    "data/20150519_PRPC_1504_FINAL.xlsx": Metadata("201504", 12, sheet_name=["By Market"]),
    "data/20150616_PRPC_1505_FINAL.xlsx": Metadata("201505", 12, sheet_name=["By Market"]),
    "data/20150716_PRPC_1506_FINAL_updated.xlsx": Metadata("201506", 12, sheet_name=["By Market"]),
    "data/20150915_PRPC_1507_FINAL.xlsx": Metadata("201507", 12, sheet_name=["By Market"]),
    "data/20150915_PRPC_1508_FINAL_update.xlsx": Metadata("201508", 12, sheet_name=["By Market"]),
    "data/20151016_PRPC_1509_FINAL.xlsx": Metadata("201509", 12, sheet_name=["By Market"]),
    "data/20151117-PRPC_1510_FINAL.xlsx": Metadata("201510", 12, sheet_name=["By Market"]),
    "data/20151215_PRPC_1511_FINAL.XLSX": Metadata("201511", 12, sheet_name=["By Market"]),
    "data/20160115-PRPC_1512_FINAL.XLSX": Metadata("201512", 12, sheet_name=["By Market"]),

    "data/20160216-PRPC_1601_FINAL.XLSX": Metadata("201601", 12, sheet_name=["By Market"]),
    "data/20160316_PRPC_1602_FINAL.XLSX": Metadata("201602", 12, sheet_name=["By Market"]),
    "data/20160415_PRPC_1603_FINAL.XLSX": Metadata("201603", 12, sheet_name=["By Market"]),
    "data/20160513_PRPC_1604_FINAL.XLSX": Metadata("201604", 12, sheet_name=["By Market"]),
    "data/20160616_PRPC_1605_FINAL.XLSX": Metadata("201605", 12, sheet_name=["By Market"]),
    "data/20160715_PRPC_1606_FINAL.XLSX": Metadata("201606", 12, sheet_name=["By Market"]),
    "data/20160915_PRPC_1607_FINAL.XLSX": Metadata("201607", 12, sheet_name=["By Market"]),
    "data/20160915_PRPC_1608_FINAL.XLSX": Metadata("201608", 12, sheet_name=["By Market"]),
    "data/20161014_PRPC_1609_FINAL.xlsx": Metadata("201609", 12, sheet_name=["By Market"]),
    "data/20161117_PRPC_1610_FINAL.XLSX": Metadata("201610", 12, sheet_name=["By Market"]),
    "data/20161215_PRPC_1611_FINAL.XLSX": Metadata("201611", 12, sheet_name=["By Market"]),
    "data/20170117_PRPC_1612_FINAL.XLSX": Metadata("201612", 12, sheet_name=["By Market"]),

    "data/20170215_PRPC_1701_FINAL.XLSX": Metadata("201701", 12, sheet_name=["By Market"]),
    "data/20170316_PRPC_1702_FINAL.XLSX": Metadata("201702", 12, sheet_name=["By Market"]),
    "data/20170419_PRPC_1703_FINAL.xlsx": Metadata("201703", 12, sheet_name=["By Market"]),
    "data/20170516_PRPC_1704_FINAL.XLSX": Metadata("201704", 12, sheet_name=["By Market"]),
    "data/20170615_PRPC_1705_FINAL(2).xlsx": Metadata("201705", 12, sheet_name=["By Market"]),
    "data/20170713_PRPC_1706_FINAL.XLSX": Metadata("201706", 12, sheet_name=["By Market"]),
    "data/20170914_PRPC_1707_FINAL.XLSX": Metadata("201707", 12, sheet_name=["By Market"]),
    "data/20170914_PRPC_1708_FINAL.XLSX": Metadata("201708", 12, sheet_name=["By Market"]),
    "data/20171017_PRPC_1709_FINAL.XLSX": Metadata("201709", 12, sheet_name=["By Market"]),
    "data/20171116_PRPC_1710_FINAL.XLSX": Metadata("201710", 12, sheet_name=["By Market"]),
    "data/20171214_PRPC_1711_FINAL.XLSX": Metadata("201711", 12, sheet_name=["By Market"]),
    "data/20180117_PRPC_1712_FINAL.XLSX": Metadata("201712", 12, sheet_name=["By Market"]),

    # Alternative fuel vehicles (passenger cars) before 2018 (quarterly)

    "data/ACEA_Electric_Vehicle_registrations_Q4_14-13.xlsx": Metadata("2014Q4", 19),
    "data/AFV_registrations_Q1_2015_FINAL.xlsx": Metadata("2015Q1", 19),
    "data/AFV_registrations_Q2_2015_FINAL_v2.xlsx": Metadata("2015Q2", 19),
    "data/AFV_registrations_Q3_2015_FINAL.xlsx": Metadata("2015Q3", 19),
    "data/AFV_registrations_Q4_2015_FINAL.XLSX": Metadata("2015Q4", 19),
    "data/20160513_AFV_Q1_2016_FINAL.xlsx": Metadata("2016Q1", 18),
    "data/20160907_AFV_Q2_2016_FINAL.XLSX": Metadata("2016Q2", 18),
    "data/20161028_AFV_Q3_2016_FINAL.XLSX": Metadata("2016Q3", 18),
    "data/20170201_AFV_Q4_2016_FINAL.XLSX": Metadata("2016Q4", 18),
    "data/20170504_AFV_Q1_2017_FINAL.XLSX": Metadata("2017Q1", 18),
    "data/20170907_AFV_Q2_2017_FINAL.XLSX": Metadata("2017Q2", 18),
    "data/20180130_AFV_Q3_2017_FINAL.xlsx": Metadata("2017Q3", 18),
    "data/20180201_AFV_Q4_2017_FINAL.XLSX": Metadata("2017Q4", 18),

    # All fuel types from 2018 (quarterly)

    "data/20180503_Fuel_type_Q1_2018_FINAL.xlsx": Metadata("2018Q1", 17),
    "data/20180905_Fuel_types_Q2_2018_FINAL.xlsx": Metadata("2018Q2", 17),
    "data/20181108_PRPC_fuel_Q3_2018_FINAL.xlsx": Metadata("2018Q3", 17),
    "data/20190207_PRPC_fuel_Q4_2018_FINAL.xlsx": Metadata("2018Q4", 17),
    "data/20190508_PRPC_fuel_Q1_2019_FINAL.xlsx": Metadata("2019Q1", 17),
    "data/20190904_PRPC_fuel_Q2_2019_FINAL.xlsx": Metadata("2019Q2", 17),
    "data/20191107_PRPC_fuel_Q3_2019_FINAL.xlsx": Metadata("2019Q3", 17),
    "data/20200206_PRPC_fuel_Q4_2019_FINAL.xlsx": Metadata("2019Q4", 17),
    "data/20200512_PRPC_fuel_Q1_2020_FINAL.xlsx": Metadata("2020Q1", 17),
    "data/20200903_PRPC_fuel_Q2_2020-FINAL.xlsx": Metadata("2020Q2", 17),
    "data/20201105_PRPC_fuel_Q3_2020_FINAL.xlsx": Metadata("2020Q3", 17),
}

def remove_superscript(x):
    if x.startswith("EU"):
        return x.strip()
    return x.strip(string.digits).strip()

dfs = []
for filename, metadata in files.items():
    sheets = pd.read_excel(filename,
        sheet_name=metadata.sheet_name,
        header=None,
        names=["country", "value"],
        usecols="C:D",
        skiprows=list(range(metadata.skiprows)),
        na_values=["-", "n.a"])

    for key, df in sheets.items():
        df = df.copy()
        df = df.dropna()
        df["country"] = df["country"].apply(remove_superscript)
        df["date"] = metadata.date
        df["fuel_type"] = key if key != "By Market" else "All"
        dfs.append(df)

data = pd.concat(dfs)

# restrict to countries (filter out groupings)

countries = [
    'AUSTRIA',
    'BELGIUM',
    'BULGARIA',
    'CROATIA',
    'CYPRUS',
    'CZECH REPUBLIC',
    'DENMARK',
    'ESTONIA',
    'FINLAND',
    'FRANCE',
    'GERMANY',
    'GREECE',
    'HUNGARY',
    'IRELAND',
    'ITALY',
    'LATVIA',
    'LITHUANIA',
    'LUXEMBOURG', 
    'LUXEMBURG',
    'NETHERLANDS',
    'POLAND',
    'PORTUGAL',
    'ROMANIA',
    'SLOVAKIA',
    'SLOVENIA',
    'SPAIN',
    'SWEDEN',
    'UNITED KINGDOM',
    'ICELAND',
    'NORWAY',
    'SWITZERLAND',
]

data = data[data["country"].isin(countries)]

# with pd.option_context('display.max_rows', None, 'display.max_columns', None):
#     print(data)
data.to_csv("data/passenger_car_registrations_by_fuel_type.csv", index=False)
