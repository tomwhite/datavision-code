# UK road connectivity

The data is from [OS Open Roads](https://www.ordnancesurvey.co.uk/business-government/products/open-map-roads).
Download the GeoPackage format (888 MB compressed), then extract in the _data_ directory.

Preprocess the data to extract Motorway, A, and B road links:

    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    python preprocess.py 

This will take a few minutes to run, and results in a file _data/mab.csv_ that is about 40 MB in size.

Next, create a graph representation of the data (using NetworkX):

    python create_graph.py

This is an unusual graph, since nodes represent roads, and edges are if roads connect at a junction.

Now let's analyse the graph to find the most connected nodes:

    python analyse.py

It turns out that the A1 is the most connected road based on betweenness and closeness centrality measures.

Create a visualization for the A1:

    python a1.py

The web visualization uses Cytoscape, and can be viewed by running a webserver

    http-server

then opening http://127.0.0.1:8080/a1.html in a browser.
