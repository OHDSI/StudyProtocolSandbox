library(SkeletonCompartiveEffectStudy)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "s:/FFtemp")

# Maximum number of cores to be used:
maxCores <- 32

# The folder where the study intermediate and result files will be written:
outputFolder <- "s:/SkeletonCompartiveEffectStudy"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
                                                                server = Sys.getenv("PDW_SERVER"),
                                                                user = NULL,
                                                                password = NULL,
                                                                port = Sys.getenv("PDW_PORT"))

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "cdm_optum_extended_dod_v695.dbo"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_denosumab_optum"

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL


execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        createCohorts = FALSE,
        synthesizePositiveControls = TRUE,
        runAnalyses = TRUE,
        runDiagnostics = TRUE,
        maxCores = maxCores)

createFiguresAndTables(outputFolder = outputFolder,
                       connectionDetails = connectionDetails,
                       cohortDatabaseSchema = cohortDatabaseSchema,
                       cohortTable = cohortTable,
                       oracleTempSchema = oracleTempSchema)
