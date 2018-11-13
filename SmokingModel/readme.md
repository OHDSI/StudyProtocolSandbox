SmokingModel
======================

  Introduction
============
  This package contains the smoking risk model - using the last 365 days what is the risk that the patient is a current smoker?


Features
========
  - code to validate the smoking model on data with smoking status recorded
  - code to create a smoking risk covariate
  - code to predict the current smoking status

Technology
==========
  SmokingModel is an R package.

System Requirements
===================
  Requires R (version 3.3.0 or higher).

Dependencies
============
  * PatientLevelPrediction

Getting Started
===============
  1. In R, use the following commands to download and install:

  ```r
install.packages("devtools")
devtools::install_github("OHDSI/StudyProtocolSandbox/SmokingModel")

library(SmokingModel)
#==============
# EXPLORE
#==============
# To view the model coefficients:
viewSmokingCoefficients()

# To view the model performance in a shiny app
viewSmokingShiny()

#==============
# APPLY
#==============
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
outputLocation <- file.path(getwd(),'Smoking Risk')
databaseName <- 'network study implementers database name'
cdmDatabaseschema <- 'CDM database schema'
cohortDatabaseschema <- 'cohort database schema'
cohortTable <- 'networkStudyTable'
oracleTempSchema <- NULL

cohortId <- 1  # the cohort definition id for the target cohort
outcomeId <- 2 # the cohort definition id for the outcome cohort

# Now run the following to check plp is working:
checkInstall(connectionDetails=connectionDetails)


# code to do prediction for each patient in the cohortTable with cohort_definition_id 1
prediction <- applySmokingModel(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                cohortDatabaseSchema = cohortDatabaseSchema,
                                oracleTempSchema = oracleTempSchema,
                                cohortTable = cohortTable,
                                cohortId=cohortId)

# code to externall validate the model
validation <- validateSmokingModel(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     cohortTable = cohortTable,
                     targetId = cohortId,
                     outcomeId = outcomeId)
                     
# code to create custom covariate corresponding to smoking risk
e <- environment()
smokingCov <- createSmokingCovariate(covariateConstructionName = 'SmokingStatusCov',
                                   analysisId = 967,
                                   eniviron=e)
#createSmokingStatusCovCovariateSettings()

```

License
=======
  SmokingModel is licensed under Apache License 2.0

Development
===========
  SmokingModel is being developed in R Studio.

