# Disk drive capacities

The data is at https://www.backblaze.com/b2/hard-drive-test-data.html.
Note that it is many GB of zip files, so may take a while to download depending on your connection.

Run the following to download, extract, and preprocess the data:

```bash
./download.sh
cat data/20*/*.csv | python preprocess.py > data/drives.csv
python weekly.py
```

Then run _drives.R_ to generate the visualization.
