from collections import Counter, defaultdict
import csv
import json
import re

# https://en.wikipedia.org/wiki/Postcodes_in_the_United_Kingdom#Formatting
# SW1W 0NY ->
# SW -------> Area
#   1W -----> District
#      0 ---> Sector
#       NY -> Unit

# partial = re.compile(r"(?P<area>[A-Z]{1,2})(?P<district>[0-9][A-Z0-9]?) +(?P<sector>[0-9])")
# def parse_partial(postcode):
#     m = re.match(partial, postcode)
#     try:
#         d = m.groupdict()
#         return d["area"], d["district"], d["sector"]
#     except AttributeError:
#         print(postcode)

partial = re.compile(r"(?P<area>[A-Z]{1,2})(?P<district>[0-9][A-Z0-9]?)")
def parse_partial(postcode):
    m = re.match(partial, postcode)
    try:
        d = m.groupdict()
        return d["area"], d["district"]
    except AttributeError:
        print(postcode)


if __name__ == "__main__":

    sector_counts = Counter()
    with open("data/NSPL_AUG_2020_UK.csv") as f:
        reader = csv.reader(f)
        next(reader, None)  # skip the header
        for row in reader:
            pcds = row[2]
            doterm = row[4]  # date of termination
            # TODO: only count live postcodes
            # drop postcode unit
            if pcds == "GIR 0AA":
                continue
            if doterm != "":
                continue
            sector_counts.update({ pcds[:-4]: 1 })

    # infinitely-nesting defaultdict from https://stackoverflow.com/a/54688608
    NDict = lambda: None
    NDict = lambda: defaultdict(NDict)
    tree = NDict()
    for key, val in sector_counts.items():
        area, district = parse_partial(key)
        #tree[area][district][sector] = val
        tree[area][district] = val

    def transform(key, val):
        """Turn into representation used by d3"""
        if isinstance(val, dict):
            return {
                "name": key,
                "children": [transform(k, v) for k, v in val.items()]
            }
        return {
            "name": key,
            "value": val
        }

    with open("data/postcodes.json", mode="w") as f:
        json.dump(transform("All", tree), f, indent=2)
