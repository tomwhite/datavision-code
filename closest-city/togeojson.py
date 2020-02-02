import json
import re

geometries = []

pattern = r'.*lat=(-?\d+\.\d*)\|long=(-?\d+\.\d*)\|.*label=.*\[\[(.*)\]\]'
for line in open('data/wikipedia-list-of-cities-uk.txt', 'r'):
    m = re.match(pattern, line)
    if m:
        lat, lng, city = m.group(1), m.group(2), m.group(3)
        if '|' in city:
            pos = city.find('|') + 1
            city = city[pos:]
        geometries.append({
            "type": "Point",
            "coordinates": [lng, lat],
            "properties": {
                "name": city
            }
        })

for line in open('data/wikipedia-list-of-cities-ireland.csv', 'r'):
    city, lat, lng = line.strip().split(',')
    if city == 'city':
        continue # header
    geometries.append({
        "type": "Point",
        "coordinates": [lng, lat],
        "properties": {
            "name": city
        }
    })

places = {
    "type": "GeometryCollection",
    "geometries": geometries
}
print(json.dumps(places, indent=2))
