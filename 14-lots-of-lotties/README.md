# Lots of Lotties: 5K runs in 2019

To build:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python preprocess.py 
```

Note that you can edit preprocess.py to use your own data downloaded from Strava.

To view locally:

```
python -m http.server
```

Then open http://localhost:8000/lots-of-lotties.html
