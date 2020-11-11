from collections import Counter, defaultdict
import csv
import re
import traces

postcode_csv = "data/NSPL_AUG_2020_UK.csv"

area_pattern = re.compile(r"[A-Z]{1,3}")  # 3 due to cases like GIR

def get_area(postcode):
    return area_pattern.match(postcode).group()

if __name__ == "__main__":

    introductions = defaultdict(Counter)
    terminations = defaultdict(Counter)
    diffs = defaultdict(Counter)
    changes = defaultdict(Counter)
    active = Counter()

    with open(postcode_csv) as f:
        reader = csv.reader(f)
        next(reader, None)  # skip the header
        for row in reader:
            pcds = row[2]  # full postcode
            dointr = row[3]  # date of introduction
            doterm = row[4]  # date of termination
            area = get_area(pcds)
            introductions[area][dointr] += 1
            diffs[area][dointr] += 1
            changes[area][dointr] += 1
            if doterm != "":
                terminations[area][doterm] += 1
                diffs[area][doterm] -= 1
                changes[area][doterm] += 1
            else:
                active.update({ area: 1 })

    areas = sorted(list(set(introductions.keys()) | set(terminations.keys()) | set(active.keys())))

    dates = set()
    for intro in introductions.values():
        dates.update(intro.keys())
    for term in terminations.values():
        dates.update(term.keys())
    dates = sorted(list(dates))
    dates = [date for date in dates if date > "1980"] # data before 1980 seems patchy/inconsistent

    # would good to show when large + and -, even if (or especially if) overall diff is small
    # e.g. NP in 199906
    # see changes variable

    # print(sorted(introductions["NP"].items()))
    # print(sorted(terminations["NP"].items()))
    # print(sorted(diffs["NP"].items()))

    # write counts in tidy format
    with open("data/postcode_counts.csv", "w+") as f:
        f.write("area,date,num_postcodes,num_changes\n")
        for area in areas:
            num_postcodes = active[area]
            ts = traces.TimeSeries()
            # iterate backwards in time to reconstruct number of postcodes
            for month, diff in sorted(diffs[area].items(), reverse=True):
                ts[month] = num_postcodes
                num_postcodes -= diff

            for month, num_postcodes in ts:
                date_string = f"{month[:4]}-{month[4:]}-01"
                num_changes = changes[area][month]
                f.write(f"{area},{date_string},{num_postcodes},{num_changes}\n")

    # write counts in wide format - easier to use with d3 multi-line chart
    with open("data/postcode_counts_wide.csv", "w+") as f:
        f.write(f"area,{','.join(dates)}\n")
        for area in areas:
            num_postcodes = active[area]
            ts = traces.TimeSeries()
            # iterate backwards in time to reconstruct number of postcodes
            for month, diff in sorted(diffs[area].items(), reverse=True):
                ts[month] = num_postcodes
                num_postcodes -= diff
            ts_dict = {k: v for (k, v) in ts.items()}
            counts = []
            for date in dates:
                count = ts.get(date, "previous")
                if count == 0 and date not in ts_dict:
                    # case where area is removed (e.g. NPT)
                    count = None
                counts.append(f"{count if count is not None else ''}")
            f.write(f"{area},{','.join(counts)}\n")
