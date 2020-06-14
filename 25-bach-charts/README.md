# Bach charts

The dataset is v2.0.0 of the [MAESTRO Dataset](https://magenta.tensorflow.org/datasets/maestro). Download the MIDI files, and uncompress in the _data_directory.

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

Then open http://localhost:8000/bach-charts.html
