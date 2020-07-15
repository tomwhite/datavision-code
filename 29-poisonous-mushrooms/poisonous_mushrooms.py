import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import umap

if __name__ == "__main__":

    # Load original data
    df = pd.read_csv("data/agaricus-lepiota.data", header=None)

    def ep_to_colour(ep):
        return "green" if ep == "e" else "red"
    label_colours = [ep_to_colour(ep) for ep in df[0].tolist()]

    # Remove label - edible vs poisonous
    df_no_label = df.drop(0, axis=1)

    #print("De-duped")
    #print(df_no_label.drop_duplicates())

    # get a sparse matrix (mushrooms vs features - cf beer style vs reviewers at https://github.com/jc-healy/EmbedAllTheThings)
    # mushrooms are a set of features - not a bag, since counts don't matter (there aren't any counts!)
    dummies = pd.get_dummies(df_no_label).to_numpy()
    np.savetxt("data/mushrooms.csv", dummies, fmt='%i', delimiter=",")

    # distance - jaccard, for sets. 1 is disjoint, 0 is identical
    embedding = umap.UMAP(n_neighbors=5, n_components=2, metric='jaccard', min_dist=0.2, random_state=42).fit_transform(dummies)

    plt.figure(figsize=(10, 10)) 
    plt.scatter(embedding[:, 0], embedding[:, 1], s=0.5, c=label_colours, alpha=0.5)
    plt.gca().set_aspect("equal", "datalim")
    plt.title("UMAP projection of mushrooms", fontsize=24)
    plt.axis("off")

    edible = mpatches.Patch(color="green", label="Edible")
    poisonous = mpatches.Patch(color="red", label="Poisonous")
    plt.legend(handles=[edible, poisonous], loc="lower right")

    plt.figtext(.02, .02, "Graphic: Tom White 2020. Data source: Audubon Society/Jeff Schlimmer")

    plt.tight_layout()

    #plt.show()
    plt.savefig("poisonous-mushrooms.png", dpi=300)
