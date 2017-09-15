Package for trends


# Steps
## Step 1

The package needs data about events. There are two ways how to provide it.

## Step 1a produceimport data from CSV files 

Option a relies on the user to create compliant files use later


## Step 1b import data from Database

Option b can be used with datasets in OMOP CDM model. Connection details are needed. 
All OHDSI supperted db engines can be used. Function uses OHDSI package DatabaseConnector


```r
library(OHDSITrends)
#have your connection details ready 

inputDataFolder='c:/temp/input'
cdmDatabaseSchema='ccae'
cdmDatabaseSchema='myCdmData'




```

## megaStep  Preprocess the raw data extracted from the databse.

This steps requires data to be present in inputDataFolder and outputs one pager summary to outputDataFolder

```r
execute('local/two/,outputFolder)
```



# Assumptions

## concept IDs
concept.csv file in inputDataFolder has 2 columns, id and name
id is string  (at most institutions it would be integer)
but event ids such as 'ICD9CM:250.00' , 'RxNorm:13513', or 'ATC5:A01BB71', 'asthmaNOS'

## remaining TODOs
- why craching step 2 for sclaims
- shiny app
- plot topX using old trick with rmd
- params in Rmd 
- speed profiling of step 2

