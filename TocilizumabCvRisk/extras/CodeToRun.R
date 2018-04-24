library(TocilizumabCvRisk)
options(fftempdir = "s:/FFtemp")

maxCores <- 32
studyFolder <- "s:/TocilizumabCvRisk"
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

cdmDatabaseSchema <- "CDM_Truven_MDCD_V635.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_tocilizumab_mdcd"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, "mdcd")

cdmDatabaseSchema <- "cdm_truven_ccae_v656.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_tocilizumab_ccae"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, "ccae")

cdmDatabaseSchema <- "cdm_truven_mdcr_v657.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_tocilizumab_mdcr"
oracleTempSchema <- NULL
outputFolder <- file.path(studyFolder, "mdcr")

cdmDatabaseSchema <- "cdm_optum_extended_ses_v655.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_tocilizumab_optum"
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
          createCohorts = TRUE,
          synthesizePositiveControls = TRUE,
          runAnalyses = TRUE,
          runDiagnostics = TRUE,
          maxCores = 30)
}, mailSettings = mailSettings, label = "Tocilizumab")

# combineAcrossDbs(folders = c("Mdcd", "Mdcr", "Optum", "Ccae"),
#                  labels = c("MDCD", "MDCR", "Optum", "CCAE"),
#                  outputFolder = "r:/Loop")
