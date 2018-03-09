library(DenosumabBoneMetastases)
options(fftempdir = "s:/FFtemp")

maxCores <- 32
studyFolder <- "s:/DenosumabBoneMetastases"
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv("PDW_SERVER")
port <- Sys.getenv("PDW_PORT")
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

cdmDatabaseSchema <- "cdm_optum_extended_dod_v695.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_denosumab_optum"

oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, "optum")


mailSettings <- list(from = Sys.getenv("mailAddress"),
                     to = c(Sys.getenv("mailAddress")),
                     smtp = list(host.name = "smtp.gmail.com", port = 465,
                                 user.name = Sys.getenv("mailAddress"),
                                 passwd = Sys.getenv("mailPassword"), ssl = TRUE),
                     authenticate = TRUE,
                     send = TRUE)

result <- OhdsiRTools::runAndNotify({
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
}, mailSettings = mailSettings, label = "denosumab")

createFiguresAndTables(outputFolder = outputFolder,
                       connectionDetails = connectionDetails,
                       cohortDatabaseSchema = cohortDatabaseSchema,
                       cohortTable = cohortTable,
                       oracleTempSchema = oracleTempSchema)
