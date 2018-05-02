library(TofaRep)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "S:/FFTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# The folder where the study intermediate and result files will be written:
outputFolder <- "S:/StudyResults/tofarep_ccae_v697"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms     = Sys.getenv("dbms"),
  server   = Sys.getenv("server"),
  port     = as.numeric(Sys.getenv("port")),
  user     = NULL,
  password = NULL
)

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "cdm_truven_ccae_v697.dbo"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "tofarep_ccae_v697"

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

tofarep::execute(connectionDetails = connectionDetails,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 cohortDatabaseSchema = cohortDatabaseSchema,
                 cohortTable = cohortTable,
                 oracleTempSchema = oracleTempSchema,
                 outputFolder = outputFolder,
                 createCohorts = FALSE,
                 synthesizePositiveControls = FALSE,
                 runAnalyses = FALSE,
                 runDiagnostics = FALSE,
                 packageResults = TRUE,
                 maxCores = maxCores)

createFiguresAndTables(outputFolder = outputFolder,
                       connectionDetails = connectionDetails,
                       cohortDatabaseSchema = cohortDatabaseSchema,
                       cohortTable = cohortTable,
                       oracleTempSchema = oracleTempSchema)
