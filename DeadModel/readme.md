DeadModel
======================

  Introduction
============
  This package contains the DEAD risk model - using the last 365 days what is the risk that the patient with an end of observation is dead?


Features
========
  - code to validate the death model on data with death status recorded
  - code to create a death risk covariate
  - code to predict the current alive or dead status

Technology
==========
  DeadModel is an R package.

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
devtools::install_github("OHDSI/StudyProtocolSandbox/DeadModel")

# Now run the following to check plp is working:
checkInstall(connectionDetails=connectionDetails)

#==============
# EXPLORE
#==============
# To view the model coefficients:
viewDeadCoefficients()

# To view the model performance in a shiny app
viewDeadShiny()

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
outputLocation <- file.path(getwd(),'Death Risk')
cdmDatabaseSchema <- 'CDM database schema'
cohortDatabaseSchema <- 'cohort database schema'
cohortTable <- 'cohortTable containing people who you want to predict risk of being dead'
cohortId <- 'cohortDefinitionId for target cohort people in cohortTable'

cohortId <- '(if externally validating model) cohortDefinitionId for dead people in cohortTable'

# code to do prediction for each patient in the cohortTable with cohort_definition_id 1
prediction <- applyDeadModel(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                cohortDatabaseSchema = cohortDatabaseSchema,
                                oracleTempSchema = NULL,
                                cohortTable = cohortTable,
                                cohortId=cohortId)

# code to externall validate the model
validation <- validateDeadModel(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     oracleTempSchema = NULL,
                     cohortTable = cohortTable,
                     targetId = cohortId,
                     outcomeId = outcomeId)
                     
# code to create custom covariate corresponding to smoking risk
e <- environment()
createDeadCovariate(covariateConstructionName = 'DeadRiskCov',
                                   analysisId = 967,
                                   eniviron=e)
#createDeadRiskCovCovariateSettings()

```

License
=======
  DeadModel is licensed under Apache License 2.0

Development
===========
  DeadModel is being developed in R Studio.

