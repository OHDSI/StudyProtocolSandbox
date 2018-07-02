remove.packages("PneumoniaRiskOfPPI")

setwd("C:/Users/apple/git/ohdsi/StudyProtocolSandbox")
library(devtools)
PneumoniaRiskOfPPI::install("PneumoniaRiskOfPPI")

library(PneumoniaRiskOfPPI)

# Optional: specify where the temporary files (used by the ff package) will be created:
#options(fftempdir = "e:/FFtemp")

# Maximum number of cores to be used:
maxCores <- 4

# The folder where the study intermediate and result files will be written:
outputFolder <- "D:/PneumoniaRiskofPPI"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                                server = "",
                                                                user = "",
                                                                password = "")

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "NHIS_NSC.dbo"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "NHIS_NSC.dbo"
cohortTable <- "cohort"

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = TRUE,
        runDiagnostics = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)
traceback()
prepareForEvidenceExplorer(studyFolder = "D:/PneumoniaRiskofPPI")

launchEvidenceExplorer(studyFolder = "D:/PneumoniaRiskofPPI", blind = FALSE, launch.browser = FALSE)
