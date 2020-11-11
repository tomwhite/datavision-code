# Postcodes

I used the [National Statistics Postcode Lookup (NSPL)](https://geoportal.statistics.gov.uk/datasets/national-statistics-postcode-lookup-august-2020) from August 2020, published by the [Office for National Statistics](https://www.ons.gov.uk/).

The dataset is typically used by organisations who want to map postcodes to geographical areas, such as county, electoral division, etc,
but I used to look at how the number of active postcodes has changed over time.

Extract the dataset into the _data_ directory, then run the following:

    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    python preprocess.py 

Then run a webserver and open the _postcodes.html_ file.

There are a few other analyses and visualizations that I produced before settling on the final one.
