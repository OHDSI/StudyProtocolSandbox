PredictionNetworkStudySkeleton
======================

  Introduction
============
  Add the background for this study here


Features
========
  - what does the study do as the main thing
  - what else does it do?
  - what else does it do?

Technology
==========
  PredictionNetworkStudySkeleton is an R package.

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
install.packages("PredictionNetworkStudySkeleton")

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
                                                                
# Now run the following:
checkInstall(connectionDetails=connectionDetails)
createCohorts()

# If the check passes and you have cohort values submit the cohort counts to the study
# organizor to confirm the cohort definitions run across the network.  

# once the cohort definitions are finalised run the main study code:
# INPUTS:
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
outputLocation <- file.path(getwd(),'Network Study Output')
databaseName <- 'network study implementers database name'
cdmDatabaseschema <- 'CDM database schema'
cohortDatabaseschema <- 'cohort database schema'
cohortTable <- 'networkStudyTable'

main(connectionDetails=connectionDetails,
outputLocation=outputLocation,databaseName=databaseName, cdmDatabaseschema=cdmDatabaseschema,
cohortDatabaseschema=cohortDatabaseschema, cohortTable=cohortTable)

submitResults(exportFolder=outputLocation,
              dbName=databaseName, key, secret)


```

License
=======
  PredictionNetworkStudySkeleton is licensed under Apache License 2.0

Development
===========
  PredictionNetworkStudySkeleton is being developed in R Studio.

