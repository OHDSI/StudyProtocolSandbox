angioedemaInAceValidation
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
  angioedemaInAceValidation is an R package.

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
  # If not building locally uncomment and run:
#install.packages("devtools")
#devtools::install_github("OHDSI/StudyProtocolSandbox/angioedemaInAceValidation")

library(angioedemaInAceValidation)

# add details of your database setting:
databaseName <- 'add a shareable name for the database used to develop the models'

# add the cdm database schema with the data
cdmDatabaseSchema <- 'your cdm database schema'

# add the work database schema this requires read/write privileges 
cohortDatabaseSchema <- 'your work database schema'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'angioedemaInAceValidationCohortTable'

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
angioedemaInAceValidation::execute(connectionDetails = connectionDetails,
                 databaseName = databaseName,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 cohortDatabaseSchema = cohortDatabaseSchema,
                 cohortTable = cohortTable,
                 outputFolder = outputFolder,
                 createCohorts = T,
                 runValidation = T,
                 packageResults = T,
                 minCellCount = 5,
                 sampleSize = NULL)
                 
# add code to submit results to study admin here


```

License
=======
  PredictionNetworkStudySkeleton is licensed under Apache License 2.0

Development
===========
  PredictionNetworkStudySkeleton is being developed in R Studio.
