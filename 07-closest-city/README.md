
The list of UK cities was found on https://en.wikipedia.org/wiki/List_of_cities_in_the_United_Kingdom, by downloading the data powering the map (see https://en.wikipedia.org/w/index.php?title=List_of_cities_in_the_United_Kingdom&action=edit&section=3).

Cities in Ireland were taken from https://en.wikipedia.org/wiki/City_status_in_Ireland, and manually saved in a CSV file.

The two files were converted to geojson by running:

```bash
python togeojson.py > data/cities.geojson
```

To view, run a local webserver:

```bash
python -m SimpleHTTPServer 8008
```

then visit http://localhost:8008/.
