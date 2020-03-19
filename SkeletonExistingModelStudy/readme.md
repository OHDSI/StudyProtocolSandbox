A Package Skeleton for Validating Prognositic Models Over OHDSI
========================================================
A skeleton package, to be used as a starting point when replicating existing models

Vignette: [Using the package skeleton for validating exisitng prediction studies](https://raw.githubusercontent.com/OHDSI/StudyProtocolSandbox/master/SkeletonExistingModelStudy/inst/doc/UsingSkeletonPackage.pdf)

Instructions To Prepare Package Outside Atlas
===================
To create the package outside of ATLAS please see [Populating the settings in the package skeleton for validating exisitng prediction studies](https://raw.githubusercontent.com/OHDSI/StudyProtocolSandbox/master/SkeletonExistingModelStudy/inst/doc/PopulatingSkeletonPackage.pdf)

Instructions To Install and Run Package From Github
===================

- Make sure you have PatientLevelPrediction installed:

```r
  # get the latest PatientLevelPrediction
  install.packages("devtools")
  devtools::install_github("OHDSI/PatientLevelPrediction")
  # check the package
  PatientLevelPrediction::checkPlpInstallation()
```

- Then install the study package:
```r
  # install the network package
  devtools::install_github("OHDSI/StudyProtocolSandbox/SkeletonExistingModelStudy")
```

- Execute the study by running the code in (extras/CodeToRun.R) but make sure to edit the settings:
```r
library(SkeletonExistingModelStudy)
# USER INPUTS
#=======================
# Specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "location with space to save big data")

# The folder where the study intermediate and result files will be written:
outputFolder <- "./SkeletonExistingModelStudyResults"

# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

oracleTempSchema <- NULL

# table name where the cohorts will be generated
cohortTable <- 'SkeletonPredictionStudyCohort'

# TAR settings
sampleSize <- NULL
riskWindowStart <- 1
startAnchor <- 'cohort start'
riskWindowEnd <- 365
endAnchor <- 'cohort start'
firstExposureOnly <- F
removeSubjectsWithPriorOutcome <- F
priorOutcomeLookback <- 99999
requireTimeAtRisk <- F
minTimeAtRisk <- 1
includeAllOutcomes <- T


#=======================

standardCovariates <- FeatureExtraction::createCovariateSettings(useDemographicsAgeGroup = T, useDemographicsGender = T)

SkeletonExistingModelStudy::execute(connectionDetails = connectionDetails,
                                    cdmDatabaseSchema = cdmDatabaseSchema,
                                    cdmDatabaseName = cdmDatabaseName,
                                    cohortDatabaseSchema = cohortDatabaseSchema,
                                    cohortTable = cohortTable,
                                    sampleSize = sampleSize,
                                    riskWindowStart = riskWindowStart,
                                    startAnchor = startAnchor,
                                    riskWindowEnd = riskWindowEnd,
                                    endAnchor = endAnchor,
                                    firstExposureOnly = firstExposureOnly,
                                    removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
                                    priorOutcomeLookback = priorOutcomeLookback,
                                    requireTimeAtRisk = requireTimeAtRisk,
                                    minTimeAtRisk = minTimeAtRisk,
                                    includeAllOutcomes = includeAllOutcomes,
                                    standardCovariates = standardCovariates,
                                    outputFolder = outputFolder,
                                    createCohorts = T,
                                    runAnalyses = T,
                                    viewShiny = T,
                                    packageResults = F,
                                    minCellCount= 5,
                                    verbosity = "INFO",
                                    cdmVersion = 5)
```
# Development status
Under development.