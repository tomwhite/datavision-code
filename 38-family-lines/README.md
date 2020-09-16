# Family lines

To build the data files from GEDCOM:

    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    python preprocess.py data/Wigzell_Duncan\ Family\ Tree.ged > data/wigzell.json

Then run a server to view the visualization (at http://127.0.0.1:8080/family-lines.html):

    http-server
