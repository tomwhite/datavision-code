
# Plant chromosome numbers

The data can be downloaded using the API described at http://ccdb.tau.ac.il/services/. Only the partial data (subset of columns) is needed.

```
curl -o data/bryophytes.csv http://ccdb.tau.ac.il/services/countsPartial/?majorGroup=Bryophytes&format=csv
curl -o data/pteridophytes.csv http://ccdb.tau.ac.il/services/countsPartial/?majorGroup=Pteridophytes&format=csv
curl -o data/gymnosperms.csv http://ccdb.tau.ac.il/services/countsPartial/?majorGroup=Gymnosperms&format=csv
curl -o data/angiosperms.csv http://ccdb.tau.ac.il/services/countsPartial/?majorGroup=Angiosperms&format=csv
```

Then run _plant-chromosome-numbers.R_ to generate the visualization.
