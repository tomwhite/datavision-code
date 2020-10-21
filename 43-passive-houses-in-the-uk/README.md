
# Passive house database

The database is at https://passivehouse-database.org/, but unfortunately there is no raw download option.

I restricted the search to passive houses in the UK, then downloaded the results pages using the View Rendered Source Chrome plugin.

I then ran a small Python script to turn the results into a CSV file:

    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    python preprocess.py 

Next, I opened the CSV file in Google Sheets and manually fixed any obvious errors (in the `zipCode` and `city` fields).
I then ran the postcodes through the batch geocoder at https://www.doogal.co.uk/BatchGeocoding.php to get lat/long pairs.
I added a few locations that didn't have postcodes by hand.

I then ran _passive.R_ to generate the visualization.

