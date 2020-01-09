from datetime import datetime
from itertools import accumulate
import json
import matplotlib.pyplot as plt

# TODO: label at end of line
# TODO: use pandas
# TODO: colours, axes, etc
# TODO: interpret (e.g. I working on projects in 2014 which were new, faster moving (Kite))

def date_value_pairs(data, yr="2019"):
    # get contribution counts for every date
    x = [(contribution['date'], contribution['count']) for contribution in data['contributions']]

    # sort by date
    x = sorted(x, key=lambda tup: tup[0])

    # restrict to one year
    x = [elt for elt in x if elt[0].startswith(yr)]

    # turn into day of year numbers
    x = [(yday(elt[0]), elt[1]) for elt in x]

    return x

def yday(str):
    return datetime.strptime(str, '%Y-%m-%d').timetuple().tm_yday

with open("tomwhite-gh.json") as f:
    data = json.load(f)
    print(data.keys())
    print(data['years'])
    print(data['contributions'][0])

    for yr in ("2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019"):
        pairs = date_value_pairs(data, yr=yr)
        x, y = list(zip(*pairs))
        y = list(accumulate(y))
        plt.step(x, y, label=yr)

    plt.legend(title='Year')
    plt.show()