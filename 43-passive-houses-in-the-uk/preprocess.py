from bs4 import BeautifulSoup
import pandas as pd

text_keys = ["display_id", "zipCode", "land", "state", "objectType", "buildType", "baujahr", "constructionType", "units", "squareMeters"]
html_keys = ["city"]

rows = []
for i in range(1, 5):
    with open(f"data/{i}.html") as file:
        soup = BeautifulSoup(file, features="html.parser")
        for x in soup.find_all(attrs={"class": "huf-search-projekt-container"}):
            d = {}
            for key in text_keys:
                nodes = x.find_all(attrs={"data-bind": f"text: {key}"})
                value = nodes[0].text.strip() if len(nodes) > 0 else ""
                d[key] = value
            for key in html_keys:
                nodes = x.find_all(attrs={"data-bind": f"html: {key}"})
                value = nodes[0].text.strip() if len(nodes) > 0 else ""
                d[key] = value
            rows.append(d)

print(pd.DataFrame(rows))
pd.DataFrame(rows).to_csv("data/passive-uk.csv", index=False)

        