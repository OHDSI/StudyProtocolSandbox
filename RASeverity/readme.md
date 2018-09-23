RASeverity
======================

  Introduction
============
This package contains two models for RA severity.  The 90 day model predicts the chance of having severe RA (using a medication proxy) within the next 90 days (a diagnostic model effectively phenotyping severe RA) and the 730 day models predicts the chance of having severe RA (using a medication proxy) within the next 730 days (a prognostic model).


Features
========
  - This package provides two models for calculating the risk of severe RA in any cohort of patients in an OMOP CDM database
  - Users can pick the output of predicted risk or predicted class (severe RA or non-severe RA)

Technology
==========
  RASeverity is an R package.

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
devtools::install_github("OHDSI/PatientLevelPrediction")
devtools::install_github("OHDSI/StudyProtocolSandbox/RASeverity")


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

# INPUTS:
outputLocation <- file.path(getwd(),'RA severity Output')
cdmDatabaseschema <- 'CDM database schema'
cohortDatabaseschema <- 'cohort database schema'
cohortTable <- 'networkStudyTable e.g., cohort'

# apply the model to new data:
result90 <- applyRASeverity90Risk(plpData, population)
result730 <- applyRASeverity730Risk(plpData, population)

# create covariate setting for RA severity risk
covSettingRA <- createRASeverityCovariateSetting()



```

License
=======
  PredictionNetworkStudySkeleton is licensed under Apache License 2.0

Development
===========
  PredictionNetworkStudySkeleton is being developed in R Studio.

