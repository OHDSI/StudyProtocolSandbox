library(FebuxostatVsAllopurinolCVD)

# Optional: specify where the temporary files (used by the ff package) will be created:
#options(fftempdir = "s:/FFtemp")

# Maximum number of cores to be used:
maxCores <- 1

# The folder where the study intermediate and result files will be written:
outputFolder <- "D:/FebuxostatAllopurinol2"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "",
                                                                server = "",
                                                                user = "",
                                                                password = "")

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- ""

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- ""
cohortTable <- ""

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

execute(country = 'Korea',
        connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = TRUE,
        runDiagnostics = FALSE,
        packageResults = FALSE,
        maxCores = maxCores)

traceback()

prepareForEvidenceExplorer(studyFolder = "D:/FebuxostatAllopurinol")

launchEvidenceExplorer(studyFolder = "D:/FebuxostatAllopurinol", blind = FALSE, launch.browser = FALSE)
