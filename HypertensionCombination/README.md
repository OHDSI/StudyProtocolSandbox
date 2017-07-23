# HypertensionCombination

The goal of this protocols is conducting comparative effectiveness research to establish evidences for optimal anti-hypertensive combination strategies among patients without cardiovascular outcome from various databases across world.

# Participate on HypertensionCombination study

## Step 1
Install packages for CohortMethod analysis

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/OhdsiRTools")
install_github("ohdsi/OhdsiSharing")
install_github("ohdsi/SqlRender")
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/Cyclops")
install_github("ohdsi/PatientLevelPrediction")
install_github("ohdsi/FeatureExtraction")
install_github("ohdsi/EmpiricalCalibration")
install_github("ohdsi/CohortMethod")
```

## Step 2.
Install the package HypertensionCombination.

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/StudyProtocolSandbox/HypertensionCombination")
library(HypertensionCombination)
```

## Step 3. 
Execute the following code:

```R
library(HypertensionCombination)

cdmDatabaseSchema<-"OMOP CDM DATABASE SCHEMA"
resultsDatabaseSchema<-"RESULT DATABASE SCHEMA"

connectionDetails<-DatabaseConnector::createConnectionDetails(dbms="DBMS",
                                                              server="SERVER IP",
                                                              user="ID",
                                                              password="PW")

execute(connectionDetails,
	cdmDatabaseSchema = cdmDatabaseSchema,
	resultsDatabaseSchema = resultsDatabaseSchema,
	exposureTable = "exposureTable",
	outcomeTable = "outcomeTable",
	cdmVersion = 5,
	outputFolder = "output",
	createCohorts = TRUE,
	runAnalyses = TRUE,
	maxCores = 4,
	packageResults = TRUE,
	createTableAndFigures=TRUE,
	writeReport = TRUE,
	compressResults = TRUE,
	submitResults = TRUE,
	yourEmail = "email_address")
```

+ ```cdmDatabaseSchema``` specify the schema name where your data in OMOP CDM format resides.
+ ```resultsDatabaseSchema``` specify the schema name where intermediate results can be stored.
+ ```exposureTable``` specify the name of table that will be created in the results database schema where the exposure and comparator cohorts will be stored.
+ ```outcomeTable``` specify the name of table that will be created in the results database schema where the outcome cohorts will be stored.
+ ```cdmVersion``` specify the version of OMOP CDM. now only available v5
+ ```outputFolder``` specify the path of result files will be stored.
+ ```createCohorts``` set TRUE to create cohorts into results database schema. 
+ ```runAnalyses``` set TRUE to run multiple analysis. outcome of createCohorts will be used.
+ ```packageResults``` set TRUE to package the result files as ```export/StudyResults.zip```. 
+ ```maxCores``` is the number of cores that are available for parallel processing.

## Step 3-1. 
This functions are under development.
DO NOT USE!

```R
submitResults("c:/temp/study_results/export", from_addr = "email_address")
writeReport("c:/temp/study_results/export", "c:/temp/study_results/report.html")
```

## Step 4.
E-mail to Seng Chan You (applegna@gmail.com) with ```StudyResults.zip```

# Contacts
- Study design: Seng Chan You (applegna@gmail.com)
- R package: Sungjae Jung (sungjae.2425@gmail.com)
