from bs4 import BeautifulSoup
import os
from pathlib import Path
import requests

base = "https://coronavirus.data.gov.uk"
with open("data/archive.html") as f:
    html = f.read()
    soup = BeautifulSoup(html, features="html.parser")
    for link in soup.findAll("a"):
        href = link.get("href")
        if "coronavirus-cases_" in href and href.endswith(".csv"):
            url = f'{base}{link.get("href")}'
            local_file = f'data/{os.path.basename(url)}'
            if not Path(local_file).exists():
                print(f"Downloading {url} to {local_file}")
                r = requests.get(url)
                with open(local_file, 'w') as fd:
                    fd.write(r.text)
            
