StrokeInAfibValidationStudy
======================

  Introduction
============
  This package implements 4 models developed to predict various types of stroke in female patients diagnosed with atrial fibrilation.
  
  Users need to specify the location of their OMOP CDM as the variable 'cdmDatabaseSchema' and then specify a database ('cohortDatabaseSchema') and table ('cohortTable') where they have read/write privalidges as this is where the target and outcome cohorts will be stored.  The results will be saved into a folder named 'databaseName' in the directory specified by the input 'outputFolder'. 
  
  We are also running an existing stroke model valdiation study using the same cohorts to compare some clinically implemented stroke prediction  models across the OHDSI network.


Features
========
  - Creates the target and outcome cohorts, extracts data required by models, applies models and then calculates the model performance. 

Technology
==========
  FractionValidationStudy is an R package.

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
    # get the latest PatientLevelPrediction
  install.packages("devtools")
  devtools::install_github("OHDSI/PatientLevelPrediction")
  # check the package
  PatientLevelPrediction::checkPlpInstallation()
  
  # install the network package
  devtools::install_github('OHDSI/StudyProtocolSandbox/StrokeInAfibValidationStudy')
  
library(StrokeInAfibValidationStudy)

# add details of your database setting:
databaseName <- 'add a shareable name for the database used to develop the models'

# add the cdm database schema with the data
cdmDatabaseSchema <- 'cdm_yourdatabase.dbo'

# add the work database schema this requires read/write privileges 
cohortDatabaseSchema <- 'yourworkdatabase.dbo'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'studyAfibStrokeCohortTable'

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
StrokeInAfibValidationStudy::execute(connectionDetails = connectionDetails,
        databaseName = databaseName,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        outputFolder = outputFolder,
        createCohorts = T,
        runValidation = T,
        packageResults = T,
        minCellCount = 5)




```

License
=======
  StrokeInAfibValidationStudy is licensed under Apache License 2.0

Development
===========
  StrokeInAfibValidationStudy is being developed in R Studio.

