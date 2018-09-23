EndometriosisRiskModels
======================

  Introduction
============
  This package contains 16 models trained using two different target populations defining an ER visit with abdominal pain and , two outcome defintions for endometriosis and four different datasets.
  
  The functions in this package enable users to replicate the cohorts, implement the models on their data or develop a model for their data.


Features
========
  - Contains the 16 developed models
  - Enables external validation of these models on any OMOP CDM database
  - Enables the development of a new model to predict endometriosis

Technology
==========
  EndometriosisRiskModels is an R package.

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
devtools::install_github('OHDSI/PatientLevelPrediction')
devtools::install_github('OHDSI/PredictionComparison')
devtools::install_github('OHDSI/StudyProtocolSandbox/EndometriosisRiskModels')

# add connection details:
library('EndometriosisRiskModels')
data(models)

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
##checkInstall(connectionDetails=connectionDetails)

# INPUTS:
outputLocation <- file.path(getwd(),'endoStudyOutput')
databaseName <- 'network study implementers database name'
cdmDatabaseSchema <- 'Cdm database'
cohortDatabaseSchema <- 'read/write access database or cdm database'
cohortTable <- 'endoCohorts'


# ================================================
# RUN FINAL MODEL USING ENDO PHENOTYPE OUTCOME
# ================================================     
names <- createFinalCohorts(connectionDetails,
                         cdmDatabaseSchema=cdmDatabaseSchema,
                         cohortDatabaseSchema=cohortDatabaseSchema,
                         cohortTable=cohortTable,
                         targetId=101,
                         outcomeId=202)
mainFinalModel(model = 'ccae', # pick from models: 'ccae','optum','mdcd' or 'optum_panther'
     cohortId = 101,
     outcomeId = 202,
     connectionDetails=connectionDetails,
     outputLocation=outputLocation,
     databaseName=databaseName, 
     cdmDatabaseSchema=cdmDatabaseSchema,
     cohortDatabaseSchema=cohortDatabaseSchema, 
     cohortTable=cohortTable)

# ================================================
# DEVELOP NEW MODEL
# ================================================
# Run the code with your site specific inputs:
newMod <- developEndometriosisModel(connectionDetails,
                                      cdmDatabaseSchema=cdmDatabaseSchema,
                                      cohortDatabaseSchema=cohortDatabaseSchema,
                                      cohortTable='your cohort table',
                                      cohortId=cohortId,
                                      outcomeDatabaseSchema=cohortDatabaseSchema,
                                      outcomeTable='your cohort table',
                                      outcomeId=outcomeId,
                                      sampleSize = 100000,
                                      cdmVersion = 5)
                                      
                                      
                                      
# ================================================
# RUN OLD MODELS
# ================================================       
createCohorts <- T
newTarget1Id <- NULL
newTarget2Id <- NULL
newOutcome1Id <- NULL
newOutcome2Id <- NULL

# if you need to create the tables then run:
if(createCohorts==T){
  names <- createCohorts(connectionDetails,
                         cdmDatabaseSchema=cdmDatabaseSchema,
                         cohortDatabaseSchema=cohortDatabaseSchema,
                         cohortTable=cohortTable,
                         targetIds=1:2,
                         outcomeIds=3:4)
  
} else {
  models$targetId[models$targetId==1] <- newTarget1Id
  models$targetId[models$targetId==2] <- newTarget2Id
  models$outcometId[models$outcomeId==3] <- newOutcome1Id
  models$outcomeId[models$outcomeId==4] <- newOutcome2Id
}

# then apply each model
main(modelLocations = models$modelLocation,
     cohortIds = models$targetId,
     outcomeIds = models$outcomeId,
     connectionDetails=connectionDetails,
     outputLocation=outputLocation,
     databaseName=databaseName, 
     cdmDatabaseSchema=cdmDatabaseSchema,
     cohortDatabaseSchema=cohortDatabaseSchema, 
     cohortTable=cohortTable)

```

License
=======
  EndometriosisRiskModels is licensed under Apache License 2.0

Development
===========
  EndometriosisRiskModels is being developed in R Studio.

