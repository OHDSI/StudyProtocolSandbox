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
connectionDetails <- myConnectionDetails
resutlsDatabaseSchema <- c(schema1, schema2)

inputDataFolder='c:/temp/input'
cdmDatabaseSchema='ccae'
cdmDatabaseSchema='myCdmData'

```

## Step 1c Install OHDSIVocab package
```r
devtools::install_github("vojtechhuser/OHDSIVocab")
```

## MegaStep 2 Get Data from database and analyze it
The best way to do this step is using the function wrapper \code{OHDSITrends}. This function requires
minimal user input and will:

1. Extract data from database and store it in a 'Extracted Data' folder. This package is designed to work 
with data for annual trends and annual time-points. If your data is not structured this way, problems may arise. 

2. Process the extracted data locally

3. Analyze the data, and store the outputs in a 'Results' folder. Summary 1 pager .tsv files are created. There is also a '.csv' file containing the trend analysis results for all the medical events associated with a particular analysis_id as well.

4. Create an 'export' folder that will contain 1-pager files identical files to the 'Results' folder in both a human"readable" file format and one that is more easily read by a computer to faciliate centralized processing. In addition, graphss containing .pdfs for some items are also created. 

Because this folder is designed for sharing, ALL identifiable database schema information will be anonymized. The code generates a random three letter sequence for each database you run this program on. 

5. Zip the export folder into a .zip format. 

All these actions take place within a (preferably empty) user-created folder. This is the easiest (and best) way to use this package.

To use this function execute the following:

```r

connectionDetails <- myConnectionDetails
resutltsDatabaseSchema <- c(schema1, schema2, ..., scheman) #pass as many schema as you like

result_event_ids <- c(medical_events_I_want_to_analyze) #e..g 904 = drugExposure, 604 = procedures
# be sure all these event_ids are present in each resultsDatabaseSchema you pass to this function.

pop_d <- myPopId # e.g. 116

user_folder <- folder_to_put_all_the_results_from_this_function


# You should have been given a site ID by the study coordinators. If not, no matter. You can still run 
# this program and get a result that can be shared. (just leave the site_id blank or as NULL)
site_id <- mySiteId

# If your data is OMOP data and your concept_ids line-up nicely with the Athena concept_ids, then run this
concept_file <- OHDSIVocab::concept


OHDSITrends(site_id, connectionDetails, resultsDatabaseSchema, result_event_ids, pop_id = 116,
              user_folder, OMOP = T/F, concept_file)

# The program may take a while to run. Conservatively estimate about 15 minutes to process each database_schma you pass to the program. It may be slower or faster, depending on the size of the schema
```

Can also be done manually. Execute the following code if you want to go that approach

```r


```

There is also an option to analyze item by item. Here is the code for this approach.
N.B. This will NOT automatically create an export folder. Use one of the approaches above for that.

```r

OHDSITrends(site_id, connectionDetails,resultsDatabaseSchema, result_event_ids,
                        pop_id, user_folder, OMOP = T/F, concept_file)


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

