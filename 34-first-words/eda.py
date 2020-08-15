import pandas as pd
pd.set_option('display.max_rows', None)

df = pd.read_csv("data/datasets_1752_3039_main_data.csv")

df = df[["Word_NW", "Word_CDI", "Translation", "AoA", "VSoA", "Freq", "Broad_lex"]]

df = df[df.AoA.notnull()]

df = df.drop_duplicates(("Word_NW", "Word_CDI", "Translation"))

df = df.sort_values(by=["Translation", "AoA", "Freq"], ascending=[True, True, False])

df2 = df.drop_duplicates(("Translation"))
df2 = df2.sort_values(by=["AoA", "VSoA", "Freq"], ascending=[True, True, False])

print(df2)