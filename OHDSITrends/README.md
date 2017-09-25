Package to analyze trends in medical events at a health-system-wide or national level. 

## Purpose
This package is optimally designed to analyze trends in interesting medical events from datasets built under the OMOP Common Data Model. 


There are two ways to use this package: Fully automatic Mode and varying levels of Manual Mode. Fully automatic mode is currently limited to OMOP datasets. Fully automatic Mode will give the best results, but is currently limited to OMOP datasets. This mode requires limited input from the user and will do a full analysis of all the data you ask of it. This process is described below.

If you do not use an OMOP dataset, you must use the Manual Mode described at the end of this document. It is quite a bit more complicated. 

## Package Contents
1. All the functions to execute this package in for OMOP datasts; 
2. Knowledge base for grouping OMOP drugEra events by type of drug class.

## Not included by necessary
CONCEPT file that allows the program to understand what types of medical events it is analyzing. 

## Dependencies and R Version
This package was built using R 3.4.1 and dplyr version 0.7.2.

Additionally, the following packages must be installed, but not loaded with the library() command:
plyr, dplyr, magrittr, readr, stringr, ggplot2, gridExtra, and DatabaseConnector; DatabaseConnector depends on SQLReadr and RJava.


# Installation
Run this code to install:
```r
devtools::install_github('ohdsi/StudyProtocolSandbox/OHDSITrends')
```

## How to run

# Automatic Mode Steps

# Step 1 -- Setting up

The best way to get the data for this program to analyze is automatically, as the package will create a sensible and well-organized hierarchy of all your data files. In fact, the code will not work well unless your data is well orgnanized. SO

The steps below will help you set up your workstation to allow the package to automatically fetch all the data of interest from your server and save it in sensible folders with just one commmand in R. 

To Begin:
Open a fresh R session with no loaded packages (best is to open the .Rproj file included in this package in a fresh R session by double-clicking that file.)

```r
options(java.parameters = "-Xmx8000m")
```

This command allocates allows R to collect a lot of data from your server without running into java.lang.OutOfMemoryErrors. It's imparative that you run this line BEFORE loading any packages. If you've loaded packages, restart R, or open a fresh R session.

Next, load database connections, by running these lines.

```r
library(OHDSITrends)
library(DatabaseConnector)
#have your connection details ready 

myConnDetails <- createConnectionDetails(dbms="postgresql"
                                     ,user='my_user_name', password = 'my_password'
                                             ,server='server/database')
```

Alternatively, you can store your database connection details in a conn.R file, as recommended elsewhere. 

Next, get your concept file, which is necessary for grouping medical evnets by ancestor-relationships. Two ways to get this file:

Method 1: From your OMOP Database.
If you have the concept file on your database, then run these lines:
 ```r
 conn <-  conn<-DatabaseConnector::connect(myConnDetails, schema = ConceptSchema)
 concept <- DatabaseConnector::querySql(conn,
             'select * from concept')
 
 ```
 
 Method 2:
 Read Athena CONCEPT.csv file
 
 ```r
 concept_file <- file_path_to_Athena_CONCEPT.csv
 ```
 
You can pass in either the concept R data.frame() object OR the filepath to a CONCEPT.csv file. The function will work with both approaches.

You will also need to identify the database schema from which to pull the results. This code will analyze the analysis_ids
904 = drugEra or drug ingredient per decile per calendar year
604 = procedures per decile per calendar year
404 = conditions per decile per calendar year

In addition, you will need to specify the pop_id  = 116, becuase this is the population id for OMOP sites.

In addition, it is helpful to specify a date range for which you expect most of your data to be complete. For example a database may begin collecting information from 1985, but the data for 2017 is only for half (or part) of the year. In this instance, you'd want to select a date range from 1985-2016, so that the incomplete annual data in 2017 does not bias trends.

Specify the path to an folder where you want all the result to go. Put a '/' at the end of this filepath.

Indicate if your site uses OMOP or not setting an OMOP variable to T or F

Putting it all together, your code should look  like this:

```r
options(java.parameters = "-Xmx8000m")

library(OHDSITrends)
library(DatabaseConnector)
#have your connection details ready 

myConnDetails <- createConnectionDetails(dbms="postgresql"
                                     ,user='my_user_name', password = 'my_password'
                                             ,server='server/database')


concept <- readr::read_csv(CONCEPT.csv)

conn <-  conn<-DatabaseConnector::connect(myConnDetails, schema = ConceptSchema)
concept <- DatabaseConnector::querySql(conn,
'select * from concept')


resultsDatabaseSchema = c(db_schema1, db_schema2, db_schema3)

result_event_ids  = c(904, 604, 404) # 904 is drugEra, 604 is procedure, 404 is condition

pop_id = 116 # Always true for OMOP site

dates = 1985:2016 # Appropriate for the example above

user_folder = paste0('myFilePath', '/') # Path to an empty folder to put all the exciting results with a '/')

OMOP = T # I am an OMOP site. F if false
```
Now, you are ready for step_2.

## Step 2: Run the analysis

The best way to do this step is using the function wrapper OHDSITrends, by running this command:

```r
OHDSITrends(site_id, connectionDetails, resultsDatabaseSchema, result_event_ids, pop_id = 116,
user_folder, OMOP, concept_file)
```
* The program may take a while to run. Conservatively estimate about 20 minutes to process each analysis_id in each database_schma you pass to the program. It may be slower or faster, depending on the size of the data being analyzed.

** if you are an OMOP site, there is nothing else for you to do. When the program is done, zip the export folder (if it isn't already) and email to the study coordinators.

This function, which requires minimal user input, will:

1. Extract data from database and store it in a 'Extracted Data' folder. This package is designed to work 
with data for annual trends and annual time-points. If your data is not structured this way, problems may arise. 

2. Process the extracted data locally

3. Analyze the data, and store the outputs in a 'Results' folder. Summary 1 pager .tsv files are created. There is also a '.csv' file containing the trend analysis results for all the medical events associated with a particular analysis_id as well.

4. Create an 'export' folder that will contain 1-pager files identical files to the 'Results' folder in both a human"readable" file format and one that is more easily read by a computer to faciliate centralized processing. In addition, graphss containing .pdfs for some items are also created. 

Because this folder is designed for sharing, ALL identifiable database schema information will be anonymized. The code generates a random three letter sequence for each database you run this program on. 

All these actions take place within a (preferably empty) user-created folder. This is the easiest (and best) way to use this package.

To use this function execute the following:

Once you've run the OHDSITrends function, you don't need to do anything else. The package run smoothly. When the program is done, check your user_folder, there should be some interesting files in the /Results and /export folder. 

If you're statisfied with the results in the /export folder, please zip (.zip) the folder and email it to the study curators for centralized processing. 

Quick note: If you look in the results folder, you will see your originial database schema is in the file names. This is to help you understand your outputs and distinguish what is what. In the export folder, your database_schemas are anonymized. Each schema is given three random letters, which represent your site, followed by a number. The number indicates whether this was the first, second, third, etc. schema you entered. Nothing in the export folder will contain your original schemas. Only the results folder will contain this information.

## Manual Mode
Can also be done manually. Execute the following code if you want to go that approach

It is STRONGLY recommended you use the {\code getData2} function in this package to download data, as this package requires a particular (sensibly organized) system of filepaths and filenames. 

Execute the following

```r
site_id <- sample(1:100, 1)

dataExportFolder <- paste0(user_folder, 'Extracted Data/')
resultsFolder <- paste0(user_folder, 'Results/')
exportFolder <- paste0(user_folder, 'export/')
kbFolder <- paste0(user_folder, 'kb/')
print(resultsDatabaseSchema)


for(dr in c(user_folder, dataExportFolder, resultsFolder, exportFolder))
    if(!dir.exists(dr)) dir.create(dr)
medical_event_ids <- c(result_event_ids, pop_id)
getData2(connectionDetails,resultsDatabaseSchema, dataExportFolder, medical_event_ids)

analyze_all(site_id, all_ids = result_event_ids, pop_id = pop_id, resultsDatabaseSchema, dataExportFolder,
              resultsFolder, exportFolder, kbFolder, write_full_cids = T, OMOP = T, concept_file)
```

If you don't want to use the getData function, or want to analyze just one item from .csv files, then execute these lines:

```r
OHDSITrends2(pop_file_path, event_file_path, concept_file = NULL, analysis_id, db_schema,  user_folder, OMOP = F)
```

If you want to do your own analysis from the raw data, then use thse commands to get started:
```r
pop <- readr::read_csv(pop_file_path)
event <- readr::read_csv(event_file_path)

# eventM2 is raw data
eventM2 <- step_2(event, pop, analysis_id, OMOP, concept_file) 
eventM2 %<>% dplyr::mutate(pt_count = ifelse(is.na(pt_count), 0, pt_count),
                             population_count = ifelse(is.na(population_count), 0, population_count))


# full_cids is classified trends
l <- lin_filter2(eventM2, alpha = 0.1, m = 2/2000)
full_cids <- l$good
```

# Assumptions

## concept IDs
concept.csv file in inputDataFolder has 2 columns, id and name
id is string  (at most institutions it would be integer)
but event ids such as 'ICD9CM:250.00' , 'RxNorm:13513', or 'ATC5:A01BB71', 'asthmaNOS'


## Additional (or different) knowledge base groupings. 
By default, the program will use the knowledge-bases included in the package's /inst folder. This included knowledge base is ONLY good for OMOP datasets.

To use your own knowledge base, it must be set up with concept_id, concept_name, ancestor_concept_id, and ancestor_concept_name. If not, errors will result. Verify and re-run. 


Currently, the main OHDSITrends wrapper function does not easily allow one to update or change the knowledge base that is used to group medical events by a hierarchy. To use your own knowledge base, MODIFY the exportResults function so that it uses the knowledge base you want. You may also need to edit the analysis_ids that are included in that if statement so that your code will run properly. 

You may also want to remove the call to the "make_and_save_kb" function if your knowledge base is set up properly. This function is useful if your knowledge base is quite bare-bones (this function is called in the base code below, becuase the knowledge base we provide with the package has been stripped of all human-interpretable information, and must be re-constituted on site to work properly. It is unlikely your own knowledge base will be set-up that way.)

```r

 # Group By
  if(event_type %in% c(904, 604))
  {
    if(event_type == 904)
    {
      # Edit this line to change the knowledge base
      kb3_path <- paste0('inst/kb-drug_era3.csv')
      kb2.csv <- make_and_save_kb(kb3_path, concept, kbFolder)
      dg <- OHDSI_shiny_dg(kb2.csv, eventM2, event_type)
      analyze_grouped_events(full_cids, eventM2, dg, kb2.csv, event_type, db_schema, dest_path)
    }
  }

```



