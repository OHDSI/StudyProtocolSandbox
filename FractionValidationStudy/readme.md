FractionValidationStudy
======================

  Introduction
============
  This package implements 2 models developed to predict hip fracture in new users of bisphosphonates.
  
  Users need to specify the location of their OMOP CDM as the variable 'cdmDatabaseSchema' and then specify a database ('cohortDatabaseSchema') and table ('cohortTable') where they have read/write privalidges as this is where the target and outcome cohorts will be stored.  The results will be saved into a folder named 'databaseName' in the directory specified by the input 'outputFolder'. 


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
library(FractionValidationStudy)
library(PatientLevelPrediction)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "s:/FFtemp")

# The folder where the study intermediate and result files will be written:
outputFolder <- "s:/FractionValidationStudy"

# Details for connecting to the server:
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv("server")
port <- Sys.getenv("port")

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# debug(execute)
FractionValidationStudy::execute(connectionDetails = connectionDetails,
                                 databaseName = 'your database name',
                                 cdmDatabaseSchema = "CDM_yourdatabase",
                                 cohortDatabaseSchema = "workdatabase.dbo",
                                 cohortTable = "fractioncohortval",
                                 outputFolder = outputFolder,
                                 createCohorts = T,
                                 runValidations = T,
                                 packageResults = T,
                                 minCellCount = 5)




```

License
=======
  FractionValidationStudy is licensed under Apache License 2.0

Development
===========
  FractionValidationStudy is being developed in R Studio.

