Create a Python virtual environment, then run the script as follows:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python waiting_times.py
```

The data was downloaded from [StatsWales](https://statswales.gov.wales/Catalogue/Health-and-Social-Care/NHS-Hospital-Waiting-Times/Accident-and-Emergency/performanceagainst4hourtargetallemergencycarefacilities-by-localhealthboard), with the help of a script I wrote to save having to download each month of data separately.

The instructions are at https://github.com/tomwhite/stats-wales-dataframe, and the command I used to download the data was:

```bash
python tocsv.py /tmp/wales-waiting-times.csv http://open.statswales.gov.wales/dataset/hlth0036 "LHBProvider_Code eq 'Wales' and Target_Code eq '4hr'"
```
