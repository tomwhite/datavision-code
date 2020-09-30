import json
import matplotlib.pyplot as plt
import networkx as nx

G = nx.read_gpickle("data/mab.pickle")

# Restrict the graph to roads that connect to the A1
paths = nx.shortest_path_length(G, source="A1")
closest_nodes = [k for k, v in paths.items() if v <= 1]
G = G.subgraph(closest_nodes)

# Write out this subgraph in cytoscape format for the dataviz
cyjs = nx.cytoscape_data(G)
with open("data/a1.cyjs", "w") as outfile:
    json.dump(cyjs, outfile, indent=2)

# Use graphviz's neato algorithm to layout the subgraph
pos = nx.drawing.nx_pydot.pydot_layout(G, prog="neato")
# Use the positions to fix the layout in cytoscape, by pasting the dict into a1.html
print("pos", {k: dict(x=v[0]*5, y=v[1]*5) for k, v in pos.items()})

# Preview the dataviz using matplotlib
nx.draw_networkx(G, pos=pos)
plt.show()
