library(UkaTkaSafetyFull)
options(fftempdir = "S:/FFTemp")
maxCores <- parallel::detectCores()
studyFolder <- "S:/StudyResults/UkaTkaSafetyFull"

# server connection:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
                                                                server = Sys.getenv("PDW_SERVER"),
                                                                user = NULL,
                                                                password = NULL,
                                                                port = Sys.getenv("PDW_PORT"))

# MDCR settings ----------------------------------------------------------------
databaseId <- "MDCR"
databaseName <- "MDCR"
databaseDescription <- "MDCR"
cdmDatabaseSchema = ""
outputFolder <- file.path(studyFolder, databaseName)
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- ""

# MDCD settings ----------------------------------------------------------------
databaseId <- "MDCD"
databaseName <- "MDCD"
databaseDescription <- "MDCD"
cdmDatabaseSchema = ""
outputFolder <- file.path(studyFolder, databaseId)
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- ""

# CCAE settings ----------------------------------------------------------------
databaseId <- "CCAE"
databaseName <- "CCAE"
databaseDescription <- "CCAE"
cdmDatabaseSchema <- "cdm_truven_ccae_v778.dbo"
outputFolder <- file.path(studyFolder, databaseId)
cohortDatabaseSchema = "scratch.dbo"
cohortTable = "uka_tka_safety_ccae"

# Optum DOD settings -----------------------------------------------------------
databaseId <- "Optum"
databaseName <- "Optum"
databaseDescription <- "Optum DOD"
cdmDatabaseSchema = "cdm_optum_extended_dod_v774.dbo"
outputFolder <- file.path(studyFolder, databaseId)
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "uka_tka_safety_optum"

# THIN settings ----------------------------------------------------------------
databaseId <- "thin"
databaseName <- "thin"
databaseDescription <- "thin"
cdmDatabaseSchema = ""
outputFolder <- file.path(studyFolder, databaseId)
cohortDatabaseSchema <- ""
cohortTable <- ""

# Pharmetrics settings ---------------------------------------------------------
databaseId <- "pmtx"
databaseName <- "pmtx"
databaseDescription <- "pmtx"
cdmDatabaseSchema = ""
outputFolder <- file.path(studyFolder, databaseId)
cohortDatabaseSchema <- ""
cohortTable <- ""

# Run --------------------------------------------------------------------------
execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = NULL,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = FALSE,
        runDiagnostics = FALSE,
        packageResults = FALSE,
        maxCores = maxCores)

resultsZipFile <- file.path(outputFolder, "exportFull", paste0("Results", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)

# meta-analysis ----------------------------------------------------------------
doMetaAnalysis(outputFolders = c(file.path(studyFolder, "CCAE"),
                                 file.path(studyFolder, "MDCR"),
                                 file.path(studyFolder, "Optum")), # execute with thin and pmtx
               maOutputFolder = file.path(studyFolder, "MetaAnalysis"),
               maxCores = maxCores)
# prepare meta analysis results for shiny --------------------------------------

# compile results for Shiny here -----------------------------------------------
compileShinyData(studyFolder = studyFolder,
                 databases = c("CCAE", "MDCR", "Optum", "thin", "pmtx"))

fullShinyDataFolder <- file.path(studyFolder, "shinyDataAll")
launchEvidenceExplorer(dataFolder = fullShinyDataFolder, blind = FALSE, launch.browser = FALSE)

# Plots and tables for manuscript ----------------------------------------------
createPlotsAndTables(studyFolder = studyFolder,
                     createTable1 = FALSE,
                     createHrTable = FALSE,
                     createForestPlot = FALSE,
                     createKmPlot = FALSE,
                     createDiagnosticsPlot = FALSE)
