library(FebuxostatVsAllopurinolCVD)

# Optional: specify where the temporary files (used by the ff package) will be created:
#options(fftempdir = "s:/FFtemp")

# Maximum number of cores to be used:
maxCores <- 1

# The folder where the study intermediate and result files will be written:
outputFolder <- "D:/FebuxostatAllopurinol2"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                                server = "128.1.99.53",
                                                                user = "chandryou",
                                                                password = "dbtmdcks12#")

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "NHIS_NSC.dbo"

cohortTable <- "cohort"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "Chan_NHID_CVD.dbo"
cohortTable <- "FebuxostatAllopurinol"

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

prepareForEvidenceExplorer(studyFolder = "D:/FebuxostatAllopurinol2")

launchEvidenceExplorer(studyFolder = "D:/FebuxostatAllopurinol2", blind = FALSE, launch.browser = FALSE)
