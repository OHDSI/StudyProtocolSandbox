# Data quality

This is an R package that has sume utilities and also supports an informatics study that focuses on data quality (rather than a clinical question).
For the study, the protocol is available in extras folder.

Forum link: http://forums.ohdsi.org/t/ohdsi-informatics-study-data-quality/1857/2

The package was extended to also provide additional function.
There are three usage scenarios.

1. Generate MIAD (minumum information about dataset) as .csv file that can be added to an OHDSI study
2. Participate on DataQuality study (with later step for sharing of the limited data about your dataset)
3. Run local report on Data Quality (not shared with anybody)
4. Run development version of Data Quality (DQ) checks



# 1.Generate MIAD (minumum information about a dataset)

A discussion about this function is in this [forum thread](http://forums.ohdsi.org/t/ohdsi-study-comparative-effectiveness-of-alendronate-and-raloxifene-in-reducing-the-risk-of-hip-fracture/2533/13?u=vojtech_huser). 
This is done by runing the following function. The function will generate a .csv file in 'export' subfolder of the output folder (e.g., c:/temp/export).
The function relies on existence of Achilles result tables in the workDatabaseSchema of your database.
This function can be copied to any study by incorporating the file DatasetDQ.R into your study package.


```R
install.packages("devtools");library(devtools);
install_github("ohdsi/StudyProtocolSandbox/DataQuality",args="--no-multiarch")
library(DataQuality)

# make sure achilles() has been executed some time prior running this function)
# workDatabseSchema should contain Achilles tables
# connectionDetails are standard OHDSI details for database connection

createMIAD <- function(connectionDetails,
                               cdmDatabaseSchema,
                               workDatabaseSchema,
                               outputFolder='c:/temp/
                               ,level = 3) 
```

# 2.Participate on DataQuality study

This takes a series of steps described below:

### Step 1
Execute the latest version of Achilles

### Step 2.
Install the package DataQuality. The --no-multiarch eliminates errors on some Windows computers (it is not always necessar). 

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/StudyProtocolSandbox/DataQuality",args="--no-multiarch")
library(DataQuality)

```

### Step 3. 
Execute the following code:

```R
#use your previous connectionDetails object with username and psw for database
#or get it from an external file 
source('c:/r/conn.R')  #

library(DataQuality)


workFolder <- 'c:/temp/DQStudy-dataset1'  #ideally, use one workFolder per database
dir.create(workFolder) 

#populate database parameters
cdmDatabaseSchema <-'datasetA'
resultsDatabaseSchema <-'datasetAResults' 


executeDQ(connectionDetails = connectionDetails,cdmDatabaseSchema = cdmDatabaseSchema,
          resultsDatabaseSchema = resultsDatabaseSchema,workFolder = workFolder)


#decide on a name under which you want to report results
dbName='myDatabase43'

#generate the zip file
packageResults(connectionDetails,cdmDatabaseSchema,workFolder,dbName)

#to see what is being used, inspect the zip file (or simply all files in the  export sub-folder of the workFolder (this  data subset is being submitted to the study team as a zip file)
```

### Step 4
Email the zip file to the study coordinator or use the OHDSI data submission mechanism described below. 
To use OHDSI mechanism for data submission, ask the study PI (Vojtech Huser) via email to provide you studyKey and  studySecret keys to allow you to upload the data to an OHDSI protected study cloud bucket.

To submit results, use R code below 

```R
submitResults(exportFolder =file.path(workFolder,'export'),
              dbName = dbName,
              studyBucketName = 'ohdsi-study-dataquality',
              key=studyKey,
              secret =studySecret
              )


```

### Step 5

If your site has more than one CDM-shaped datasets (databases) that you want to include in the overal study, repeat the process using a new workFolder and picking a different name (dbName) for the next dataset (database)



### Use of output data

If any site requires a formal Data Use Agreement between your site and the Data Quality Study Principal Investigator please fill in the  Data Use Agreement template (see  the extras folder) and email it to the DQ study PI (for second signature for data recipient).

We plan to compare several sites on how they use Achilles, however the final manuscript or any of its apendices will not expose publically any details about any given site.

If you share your site's data with the DataQuality study principal investigator or the study team, it will be only for the purpose of comparison. All compared sites will be refered to under meaningless site ID. All results will be pooled together so that any site or dataset will be hidden in a crowd of several sites/datasets.

This principle was used in the initial study of Achilles Heel evaluation. (precursor to this study)


### Additional tools
The tool relies on new computations done by the Achilles tool. Using Achilles version >=1.4 is required


# 3.Only run DataQuality locally

Generate local report (not shared with anyone, creates a local .DOCX file)
First the executeDQ function must be run. This creates a export subfolder.
Generation of local report relies on data in this export folder.

```R
workFolder <- 'c:/temp/DQStudy-dataset1'  #ideally, use one workFolder per database
dir.create(workFolder) 

#populate database parameters
cdmDatabaseSchema <-'datasetA'
resultsDatabaseSchema <-'datasetAResults' 


executeDQ(connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  workFolder = workFolder
  )

exportFolder<-file.path(workFolder,'export')

writeReport(exportFolder = exportFolder,
  outputFile = file.path(workFolder,'report.docx')
  )
```


# 4. Run developmental DQ checks

Themis aims to generate stricter conventions. The checks tested here will be incorporated into `Achilles Heel`.  

Current checks include testing if laboratory tests results (`analysis 1807`) are using units that were derived in [Themis study](https://github.com/OHDSI/StudyProtocolSandbox/tree/master/themis)


Results of the check are provided as data.frame output of the function (and also saved into `export` sub-folder of the `workFolder`) as file name `ThemisMeasurementsUnitsCheck.csv`.

```R
workFolder <- 'c:/temp/DQStudy-dataset1'  #ideally, use one workFolder per database
dir.create(workFolder) 

#populate database parameters
 cdmDatabaseSchema <-'datasetA'
 resultsDatabaseSchema <-'datasetAResults' 
 #connectionDetails #make sure this object exists


dq_check_results<-checkThemis(connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder = workFolder
  )
```

Example output is [here](inst/csv/ThemisMeasurementsUnitsCheck.csv)
