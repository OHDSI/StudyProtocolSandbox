ExistingBleedingValidationInAF
======================

  Introduction
============
A package for running the OHDSI network study to externally validate existing bleeding risk prediction models using the PatientLevelPrediction framework


Features
========
  - Creates target cohort of newly diagnosed with atrial fibrilation 
  - Creates outcome cohorts of hemorrhage
  - Implements 5 existing stroke risk prediciton models with HFRS model and validates on data in OMOP CDM for each target and outcome cohort combination
  - Sends summary results 

Technology
==========
  ExistingBleedingValidationInAF is an R package.

System Requirements
===================
  Requires R (version 3.3.0 or higher).

Dependencies
============
  * PatientLevelPrediction
  * PredictionComparison

Getting Started
===============
  1. In R, use the following commands to download and install:

  ```r
install.packages("drat")
drat::addRepo("OHDSI")
install.packages("PatientLevelPrediction")
install.packages("devtools")
devtools::install_github("OHDSI/PredictionComparison")
devtools::install_github("OHDSI/StudyProtocolSandbox/ExistingBleedingValidationInAF")

library('ExistingBleedingValidationInAF')
# Add inputs for the site:
options(fftempdir = 'C:/fftemp')
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv('server')
port <- Sys.getenv('port')

databaseName <- 'database name'
cdmDatabaseSchema <- 'cdmDatabase.dbo'
cohortDatabaseSchema <- 'cohortDatabase.dbo'
outputLocation <- file.path(getwd(),'External Stroke Validation')
cohortTable <- 'stroke_cohort'
getTable1 <- F

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)
# Now run the following:
checkPlpInstallation(connectionDetails=connectionDetails,
                     python=F)
                     
# view the models
viewModels()
                     
# NOTE IF THE ABOVE DOESN'T RETURN 1 THEN THERE IS AN ISSUE WITH THE PatientLevelPrediction INSTALL
# OR SETTINGS THAT NEEDS TO BE FIXED BEFORE YOU CONTINUE
              
# Check cohort definitions work for the database:                     
cohorts <- createCohorts(connectionDetails=connectionDetails,
                       cdmDatabaseSchema=cdmDatabaseSchema,
                       cohortDatabaseSchema=cohortDatabaseSchema,
                       cohortTable=cohortTable) 
                       
# If the check passes and you have cohort values submit the cohort counts to the study
# organizor to confirm the cohort definitions run across the network.  
                       
#================================= STEP 2: MAIN STUDY ==================================
#  Once definitons have been checked across sites run:
main(connectionDetails=connectionDetails,
                 databaseName=databaseName,
                 cdmDatabaseSchema=cdmDatabaseSchema,
                 cohortDatabaseSchema=cohortDatabaseSchema,
                 outputLocation=outputLocation,
                 cohortTable=cohortTable)
submitResults(exportFolder=outputLocation,
              dbName=databasename, key, secret)

# where key and secret are provided by request


```

License
=======
  ExistingBleedingValidationInAF is licensed under Apache License 2.0

Development
===========
  ExistingBleedingValidationInAF is being developed in R Studio.

