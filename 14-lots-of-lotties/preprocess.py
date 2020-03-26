import csv
import gpxpy
import gpxpy.gpx
import pandas as pd
from pyproj import CRS, Transformer
import random
import string

transformer = Transformer.from_crs("EPSG:4326", "EPSG:27700")

# Get all of Lottie's 5K runs in 2019
df = pd.read_csv("export_37643766/activities.csv") # Lottie
df['Date'] = pd.to_datetime(df['Activity Date'])
df = df[df['Date'].dt.year == 2019]
df = df[df['Distance'] < 5.1]
df = df[df['Distance'] > 4.9]
df = df[df['Elapsed Time'] < 2050] # not a walk (for Lottie)
df = df.dropna(subset=['Filename'])

gpx_filenames = df['Filename'].tolist()
gpx_filenames = ['export_37643766/{}'.format(f) for f in gpx_filenames]

# Tom
# gpx_filenames = [
#     'export_6899019/activities/2052251767.gpx',
#     'export_6899019/activities/2223877856.gpx',
#     'export_6899019/activities/2427621150.gpx',
#     'export_6899019/activities/2516712744.gpx',
#     'export_6899019/activities/2721553488.gpx'
# ]

geo_privacy_offset = random.randrange(-50000, 50000)

with open("data/tom-running.csv", "w", newline="") as csvfile:
    header = ['id', 'x', 'y', 'duration']
    writer = csv.writer(csvfile)
    writer.writerow(header)
    for gpx_filename in gpx_filenames:
        id = gpx_filename[slice(gpx_filename.rindex("/") + 1, -4)]
        with open(gpx_filename, "r") as gpx_file:
            gpx = gpxpy.parse(gpx_file)

            for track in gpx.tracks:
                for segment in track.segments:
                    start_datetime = segment.points[0].time
                    sampled_points = segment.points[0::30]
                    sampled_points.append(segment.points[-1]) # include the last point too
                    for point in sampled_points:
                        easting, northing = transformer.transform(point.latitude, point.longitude)
                        easting = easting + geo_privacy_offset
                        northing = northing + geo_privacy_offset
                        writer.writerow([id, easting, northing, int((point.time - start_datetime).total_seconds())])
                        start_datetime = point.time
