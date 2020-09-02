#!/usr/bin/env bash

cd data
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_2013.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_2014.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_2015.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2016.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2016.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2016.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2016.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2017.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2017.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2017.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2017.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2018.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2018.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2018.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2018.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2019.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2019.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2019.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2019.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2020.zip
curl -O https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2020.zip

# Directory structures vary, so need different unzip commands

unzip -o data_2013.zip
unzip -o data_2014.zip
unzip -o data_2015.zip

mkdir 2016
unzip -o data_Q1_2016.zip; mv data_Q1_2016/*.csv 2016; rm -rf data_Q1_2016
unzip -o data_Q2_2016.zip; mv data_Q2_2016/*.csv 2016; rm -rf data_Q2_2016
unzip -o data_Q3_2016.zip; mv data_Q3_2016/*.csv 2016; rm -rf data_Q3_2016
unzip -o data_Q4_2016.zip -d 2016

mkdir 2017
unzip -o data_Q1_2017.zip -d 2017
unzip -o data_Q2_2017.zip -d 2017
unzip -o data_Q3_2017.zip -d 2017
unzip -o data_Q4_2017.zip; mv data_Q4_2017/*.csv 2017; rm -rf data_Q4_2017

mkdir 2018
unzip -o data_Q1_2018.zip; mv data_Q1_2018/*.csv 2018; rm -rf data_Q1_2018
unzip -o data_Q2_2018.zip -d 2018
unzip -o data_Q3_2018.zip -d 2018
unzip -o data_Q4_2018.zip; mv data_Q4_2018/*.csv 2018; rm -rf data_Q4_2018

mkdir 2019
unzip -o data_Q1_2019.zip; mv drive_stats_2019_Q1/*.csv 2019; rm -rf drive_stats_2019_Q1
unzip -o data_Q2_2019.zip; mv data_Q2_2019/*.csv 2019; rm -rf data_Q2_2019
unzip -o data_Q3_2019.zip; mv data_Q3_2019/*.csv 2019; rm -rf data_Q3_2019
unzip -o data_Q4_2019.zip; mv data_Q4_2019/*.csv 2019; rm -rf data_Q4_2019

mkdir 2020
unzip -o data_Q1_2020.zip -d 2020
unzip -o data_Q2_2020.zip -d 2020

for y in $(ls -d 20*); do echo $y; ls $y | wc -l; done
