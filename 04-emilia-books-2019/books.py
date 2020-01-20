import matplotlib.dates as dt
import matplotlib.pyplot as plt
import pandas as pd

pd.set_option('display.max_rows', 100)

# read CSV and restrict to columns of interest
books = pd.read_csv("data/2019_reading.csv")
books = books[['title', 'pages', 'date started', 'date finished', 'fiction/non-fiction']]

# convert date fields to datetime types
books['date started'] = pd.to_datetime(books['date started'], dayfirst=True)
books['date finished'] = pd.to_datetime(books['date finished'], dayfirst=True)
books['date finished'] +=  pd.to_timedelta(24, unit='h') # assume finished at end of day

# calculate cumulative pages
books['total_pages'] = books['pages'].cumsum()
books['start_pages'] = books['total_pages'] - books['pages']

print(books[['title', 'pages', 'date started', 'date finished']])

#plt.plot(books['date finished'], books.index)

plt.hlines(books['start_pages'], dt.date2num(books['date started']), dt.date2num(books['date finished']), linewidth=0.5)
plt.hlines(books['total_pages'], dt.date2num(books['date started']), dt.date2num(books['date finished']), linewidth=0.5)
plt.vlines(dt.date2num(books['date started']), books['start_pages'], books['total_pages'], linewidth=0.5)
plt.vlines(dt.date2num(books['date finished']), books['start_pages'], books['total_pages'], linewidth=0.5)
for i in range(len(books)):
    fiction = books['fiction/non-fiction'][i] == 'fiction'
    color = 'blue' if fiction else 'red'
    plt.plot([dt.date2num(books['date started'])[i], dt.date2num(books['date finished'])[i]], [books['start_pages'][i], books['total_pages'][i]], 'k-', color=color, linewidth=0.5)

plt.show()
