import re

pattern = r'.*lat=(-?\d+\.\d*)\|long=(-?\d+\.\d*)\|.*label=.*\[\[(.*)\]\]'
for line in open('data/wikipedia-list-of-cities-uk.txt', 'r'):
    m = re.match(pattern, line)
    if m:
        lat, lng, city = m.group(1), m.group(2), m.group(3)
        if '|' in city:
            pos = city.find('|') + 1
            city = city[pos:]
        print("%s,%s,%s" % (lat, lng, city))
