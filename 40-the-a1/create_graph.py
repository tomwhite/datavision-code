import itertools
import networkx as nx
import pandas as pd

df = pd.read_csv("data/mab.csv")

df = df[["startNode", "endNode", "roadClassificationNumber"]]

df = pd.melt(df, id_vars=["roadClassificationNumber"], value_vars=["startNode", "endNode"], value_name="node")
df = df[["node", "roadClassificationNumber"]]

# Create a graph, where nodes are roads and edges are if roads connect

grouped = df.groupby(["node"])
G = nx.Graph()
for name, group in grouped:
    if len(group) > 1:
        unique_roads = group["roadClassificationNumber"].unique()
        num = len(unique_roads)
        if num == 1:
            # ignore
            pass
        elif num == 2:
            # emit unique_roads
            G.add_edge(unique_roads[0], unique_roads[1])
        else:
            pairs = itertools.combinations(unique_roads, 2)
            G.add_edges_from(pairs)
    else:
        num = 1

nx.write_gpickle(G, "data/mab.pickle")
