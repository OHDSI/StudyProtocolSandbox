#Data quality

This is an informatics study that focuses on data quality (rather than a clinical question).


#Participate on DataQuality study

##Step 1
Execute the latest version of Achilles

##Step 2.
Install the package DataQuality. The --no-multiarch eliminates errors on some Windows computers (it is not always necessar). 

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/StudyProtocolSandbox/DataQuality",args="--no-multiarch")
library(DataQuality)

```

##Step 3. 
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

##Step 4
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

##Step 5

If your site has more than one CDM-shaped datasets (databases) that you want to include in the overal study, repeat the process using a new workFolder and picking a different name (dbName) for the next dataset (database)

#Only run DataQuality locally

Generate local report (not shared with anyone, creates a local .DOCX file)

```R
exportFolder<-file.path(workFolder,'export')
writeReport(exportFolder = exportFolder,outputFile = file.path(workFolder,'report.docx'))
```


#Use of output data

If any site requires a formal Data Use Agreement between your site and the Data Quality Study Principal Investigator please fill in the  Data Use Agreement template (see  the extras folder) and email it to the DQ study PI (for second signature for data recipient).

We plan to compare several sites on how they use Achilles, however the final manuscript or any of its apendices will not expose publically any details about any given site.

If you share your site's data with the DataQuality study principal investigator or the study team, it will be only for the purpose of comparison. All compared sites will be refered to under meaningless site ID. All results will be pooled together so that any site or dataset will be hidden in a crowd of several sites/datasets.

This principle was used in the initial study of Achilles Heel evaluation. (precursor to this study)


#Additional tools
The tool relies on new computations done by the Achilles tool. Using Achilles version >=1.4 is required