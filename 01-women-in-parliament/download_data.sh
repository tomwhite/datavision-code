#!/bin/bash

function ipu {
  field=$1
  structure=$2
  for yr in {1945..2018}; do
    echo $yr
    curl "https://data.ipu.org/api/comparison.csv?year=$yr&load-entity-refs=taxonomy_term%2Cfield_collection_item&max-depth=2&langcode=en&field=chamber%3A%3A$field&structure=$structure" -o "data/${field}_${structure}_${yr}.csv"
    echo $?
    sleep 5
  done
  # download latest without specifying year as it seems to miss data otherwise
  yr=2019
  curl "https://data.ipu.org/api/comparison.csv?load-entity-refs=taxonomy_term%2Cfield_collection_item&max-depth=2&langcode=en&field=chamber%3A%3A$field&structure=$structure" -o "data/${field}_${structure}_${yr}.csv"
}

ipu "current_women_percent" "any__lower_chamber"
ipu "field_current_members_number" "any__lower_chamber"
ipu "current_women_percent" "any__upper_chamber"
ipu "field_current_members_number" "any__upper_chamber"
