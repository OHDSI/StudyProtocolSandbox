SkeletonValidationStudy
======================

  Introduction
============
  Add the background for this study here


Features
========
  - what does the study do as the main thing
  - what else does it do?

Technology
==========
  SkeletonValidationStudy is an R package.

System Requirements
===================
  Requires R (version 3.3.0 or higher).

Dependencies
============
  * PatientLevelPrediction

Getting Started
===============
  1. In R, use the following commands to run the study:

  ```r
install.packages("devtools")
devtools::install_github("OHDSI/SkeletonValidationStudy")
package <- F

# add details of your database setting:
databaseName <- 'add a shareable name for the database used to develop the models'

# add the cdm database schema with the data
cdmDatabaseschema <- 'cdm_yourdatabase.dbo'

# add the work database schema this requires read/write privileges 
cohortDatabaseschema <- 'cdm_yourworkdatabase.dbo'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'studyCohortTable'

# the location to save the prediction models results to:
outputFolder <- getwd()

# add connection details:
options(fftempdir = 'T:/fftemp')
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv('server')
port <- Sys.getenv('port')
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Now run the study
execute(connectionDetails = connectionDetails,
                 databaseName = databaseName,
                 cdmDatabaseschema = cdmDatabaseschema,
                 cohortDatabaseschema = cohortDatabaseschema,
                 cohortTable = cohortTable,
                 outputFolder = outputFolder,
                 createCohorts = T,
                 runValidation = T,
                 packageResults = T,
                 minCellCount = 5)
                 
# now package and submit results to study admin 
if(package == T){
submitResults(exportFolder=outputLocation,
              dbName=databaseName, key, secret)
            }


```

License
=======
  PredictionNetworkStudySkeleton is licensed under Apache License 2.0

Development
===========
  PredictionNetworkStudySkeleton is being developed in R Studio.

