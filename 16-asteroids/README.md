# Asteroids

Data source: https://cneos.jpl.nasa.gov/ca/

Query for all available data, Nominal dist. <= 20LD (lunar distance), no H limit.
Then download as a CSV.

Preprocess to make columns numeric, etc.

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python preprocess.py 
```

To view locally:

```
python -m http.server
```

Then open http://localhost:8000/asteroids.html

I used the `analysis.R` script to do some initial exploratory data analysis before writing the d3 visualization.

## Old approach

Previously I tried to use the API

```bash
curl -X GET "https://ssd-api.jpl.nasa.gov/cad.api?dist-max=10LD&date-min=2018-01-01" | jq -r '.data[] | @csv' > data/close-approaches.csv
```

But then I would have to use https://cneos.jpl.nasa.gov/tools/ast_size_est.html to get a range of the sizes (albedos 0.25 and 0.05). Easier to just download the CSV directly.
