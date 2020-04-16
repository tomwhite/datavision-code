# Voronoi football

The dataset is from [Magglingen2013](https://old.datahub.io/dataset/magglingen2013), but it doesn't seem to still be available for download, so I found it here: https://github.com/alacroix/football-viewer/tree/master/res/tr-ft.

Copy the _tr-ft.json_ file to the _data_ directory.

To build:

```bash
python3 -m venv venv
source venv/bin/activate
python preprocess.py 
```

To view locally:

```
python -m http.server
```

Then open http://localhost:8000/voronoi-football.html
