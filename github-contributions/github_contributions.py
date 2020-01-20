from adjustText import adjust_text
from datetime import datetime
from dateutil import rrule
from itertools import accumulate
import json
import matplotlib.pyplot as plt

# TODO: use pandas?
# TODO: colours, axes, etc
# TODO: interpret (e.g. I working on projects in 2014 which were new, faster moving (Kite)), cross refer to github heatmap

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

    # make plot bigger so labels fit
    plt.rcParams["figure.figsize"] = (12, 9)

    cmap=plt.get_cmap("tab10") # see https://matplotlib.org/tutorials/colors/colormaps.html

    texts = []
    for i, yr in enumerate(("2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")):
        pairs = date_value_pairs(data, yr=yr)
        x, y = list(zip(*pairs))
        y = list(accumulate(y))
        plt.step(x, y, label=yr, color=cmap.colors[i % 10], lw=0.5, antialiased=None, snap=True)

        texts.append(plt.text(x[-1] + 10, y[-1], yr, color=cmap.colors[i % 10]))


    month_starts = [dt.timetuple().tm_yday for dt in rrule.rrule(freq=rrule.MONTHLY, count=12, dtstart=datetime(2019, 1, 1))]

    ax = plt.axes()
    ax.spines['left'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.yaxis.grid(True)
    ax.yaxis.set_tick_params(length=0)

    plt.xlim(1, 400)
    adjust_text(texts, only_move={'points':'y', 'text':'xy', 'objects':'xy'}, avoid_points=False)
    plt.xticks(month_starts, ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
    plt.ylabel("Commits")
    plt.title("A Decade of GitHub: github.com/tomwhite")
    plt.show()