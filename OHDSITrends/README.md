This package is using Achilles precomputed metadata to analyze trends. The intent is to do data quality inspection. It is an extenstion of the Data Quality study.  The package can  analyze trends in medical events at a health-system-wide or national level. This package is optimally designed to analyze trends in interesting medical events from datasets built under the OMOP Common Data Model but can also be used on data in other models (see section at the end). 

A site running this package can run the analysis localy with no requiremnt to share any data with the study coordinating center. The package will generate data on events that may be interesting from Data Quality perspective to review localy. Sharing of data is optional step 4.  


## Dependencies and R Version
This package was built using R 3.4.1 and dplyr version 0.7.2.

Additionally, the following packages must be installed, but not loaded with the library() command:
plyr, dplyr, magrittr, readr, stringr, ggplot2, gridExtra, and DatabaseConnector; DatabaseConnector depends on `SqlRender` and `rJava`.



# Step 1 -- Setting up and installing

The best way to get the data for this program to analyze is automatically, as the package will create a sensible and well-organized hierarchy of all your data files. In fact, the code will not work well unless your data is well orgnanized. 

Start by executing these lines:

```r

options(java.parameters = "-Xmx8000m") #avoids out of memory errors

#This command allocates allows R to collect a lot of data from your server without running into java.lang.OutOfMemoryErrors. It's imparative that you run this line BEFORE loading any packages. If you've loaded packages, restart R, or open a fresh R session.

#install the trends package
devtools::install_github('ohdsi/StudyProtocolSandbox/OHDSITrends',args="--no-multiarch")

library(OHDSITrends)
library(DatabaseConnector)
#have your connection details ready 

myConnDetails <- createConnectionDetails(dbms="postgresql"
                                     ,user='my_user_name', password = 'my_password'
                                             ,server='server/database')
```

## Vocabulary

The graphical output of the package looks better if dictionary for codes are provided. At OMOP site, the package needs vocabulary data. 

Preferred Method: Set `concept_file` variable to the file path to the Athena concept file (or concept file from your database)
```r
#modify the path to point to vocabulary CSV files
concept_file = 'C:/modify_path/athena/concept.csv'


```

 
Alt Method 1:
 Read Athena CONCEPT.csv file
 
 ```r
 concept <- read.delim(file.path(folder,'concept.csv'),as.is=T,quote = "")
 ```


Alt Method 2: From your OMOP Database.
If you have the concept file on your database, then run these lines: (then skip to the next code chunk)
 ```r
 conn <-  DatabaseConnector::connect(myConnDetails, schema = ConceptSchema)
 concept <- DatabaseConnector::querySql(conn,
             'select * from concept')
 
 ```


## Other input data

It is required  to specify a date range for which you expect most of your data to be complete. For example a database may begin collecting information from 1985, but the data for 2017 is only for half (or part) of the year. In this instance, you'd want to select a date range from 1985-2016, so that the incomplete annual data in 2017 does not bias trends.

Specify the path to an folder where you want all the result to go. Put a '/' at the end of this filepath. Note: The code will work better if the folder already exists.

Putting it all together, your code should look  like this:

```r
options(java.parameters = "-Xmx8000m")
devtools::install_github('ohdsi/StudyProtocolSandbox/OHDSITrends',args="--no-multiarch")
library(OHDSITrends)
library(DatabaseConnector)
#have your connection details ready 

myConnDetails <- createConnectionDetails(dbms="postgresql"
                                     ,user='my_user_name', password = 'my_password'
                                             ,server='server/database')




#specify your results database (or databases if you want to analyze more than one

mySchemas = c('your_results_schema_with_achilles_tables')


result_event_ids  = c(904, 704, 1804, 604, 404) # 904 is drugEra (ingredient), 604 is procedure, 404 is condition, 704 = drugExposure, 1804 = measurements

dates = 1985:2016 # Appropriate for the example above

user_folder = paste0('c:/myfolder/Trends', '/') # Path to an empty folder to put all the exciting results with a '/')

```
This code will analyze the following analysis_ids.

904 = drugEra (ingredients) or drug ingredient per decile per calendar year
604 = procedures per decile per calendar year
404 = conditions per decile per calendar year
704 = drugExposure (clinical drugs)  per decile per calendar year
1804 = measurements per decile per calendar year

Now, you are ready for step_2.

## Step 2: Run the analysis

The best way to do this step is using the function wrapper OHDSITrends, by running this command:

```r
OHDSITrends(connectionDetails = myConnDetails,
   resultsDatabaseSchema = mySchemas, 
   result_event_ids,
   user_folder,
   concept, 
   dates)
```
* The program may take a while to run. Conservatively estimate about 20 minutes to process each analysis_id in each database_schma you pass to the program. It may be slower or faster, depending on the size of the data being analyzed.


The function creates output in two subfolders inside the user folder defined by the user. Result subfolder includes detailed output for local user to inspect (not to be shared). A much smaller subset of data (in the second folder (named export) is for doing a trend component of the Data Quality study (to be shared with the study PI).

## Step 3: Inspect output data

The package creates useful PDF files that highligh detected trends in drug ingredients, diagnoses, procedures, etc.
See the result folder for PDF output. Readme file in the results folder also provides more details.

## Step 4: Submit data

To submit data, inspect the extract folder (file names are identical to results folder), zip the content and send by email (encrypted) to the study coordinator. You may also use the S3 bucket OHDSI mechanism. Email the study PI for the key and secret to submit data for this mechanism.


# Using the package with non-OMOP data


The preferred way to execute the study  is to transform your data to OMOP CDM. If this is not feasible, see instructions below.

## Partialy converted OMOP data
If a site has local data, it may be best to convert data to OMOP using the xxx_source_value fields extensively. All the xxxx_concept_id will be 0 (not mapped).
To execute OHDSITrends with this data, queries need to be pointed to those xxx_source_value fields

## non OMOP format 

Prepare the data by producing analogous input data
### Data input

Analyze all relevant analysis_id that are required. E.g., population data in 116, and events data in 404,604,704,904,1804. Note that data type for all stratum_x is string.
This SQL file has all the necessary details for each analysis: 116 example:https://github.com/OHDSI/Achilles/blob/master/inst/sql/sql_server/Achilles_v5.sql#L1954 (scroll down for other measures, such as 404) 


### Vocabulary input

The trends package will work with just codes but for some pre-generated PDFs, having a file that explains all local codes is beneficial. Produce a two column file that has columns 
concept_code and concept_name


### non-OMOP Execution

Function OHDSITrends() calls several modular function. See code for analyze_all() function (that calls analyze_one() function))
Email the author for more instructions for non-OMOP sites.



