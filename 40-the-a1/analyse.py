import networkx as nx

# Read in the pickled graph (from create_graph.py) and show some information about it
G = nx.read_gpickle("data/mab.pickle")
print(nx.info(G))
print("Connected:", nx.is_connected(G))
print()

# Run various centrality algorithms to find the most connected road
# following https://arxiv.org/abs/2002.11103

print("Roads by order of number of connections")
nodes = sorted(G.degree, key=lambda item: item[1], reverse=True)
for road, n_connections in nodes[:10]:
    print(f"{road}: {n_connections}")
print()

print("Degree centrality")
D = nx.degree_centrality(G)
L = sorted(D.items(), key=lambda item: item[1], reverse=True)
for road, centrality in L[:10]:
    print(f"{road}: {centrality}")
print()

print("Betweenness centrality")
D = nx.betweenness_centrality(G, k=1000)
L = sorted(D.items(), key=lambda item: item[1], reverse=True)
for road, centrality in L[:10]:
    print(f"{road}: {centrality}")
print()

print("Closeness centrality")
V = [L[i][0] for i in range(len(L))]
D = {}
for i in range (1000):
    D[V[i]] = nx.closeness_centrality(G, V[i])
L = sorted(D.items(), key=lambda item: item[1], reverse=True)
for road, centrality in L[:10]:
    print(f"{road}: {centrality}")
print()
