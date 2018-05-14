library(TofaRep)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "S:/FFTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# PDW ----------------------------------------------------------------------------------------------
# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
                                                                server = Sys.getenv("PDW_SERVER"),
                                                                user = NULL,
                                                                password = NULL,
                                                                port = Sys.getenv("PDW_PORT"))
cohortDatabaseSchema <- "scratch.dbo"
oracleTempSchema <- NULL

# CCAE settings
outputFolder <- "S:/TofaRep/CCAE"
cohortTable <- "tofarep_ccae_v697"
cdmDatabaseSchema <- "cdm_truven_ccae_v697.dbo"

# MDCR settings
outputFolder <- "S:/TofaRep/MDCR"
cohortTable <- "tofarep_mdcr_v698"
cdmDatabaseSchema <- "cdm_truven_mdcr_v698.dbo"


# Postgres ---------------------------------------------------------------------------------------
# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                server = "localhost/ohdsi",
                                                                user = "postgres",
                                                                password = Sys.getenv("pwPostgres"))
cohortDatabaseSchema <- "scratch"
oracleTempSchema <- NULL

# Synpuf settings
outputFolder <- "S:/TofaRep/Synpuf"
cohortTable <- "tofarep"
cdmDatabaseSchema <- "cdm_synpuf"


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

createFiguresAndTables(outputFolder = outputFolder,
                       connectionDetails = connectionDetails,
                       cohortDatabaseSchema = cohortDatabaseSchema,
                       cohortTable = cohortTable,
                       oracleTempSchema = oracleTempSchema)
