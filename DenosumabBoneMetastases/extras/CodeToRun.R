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

cdmDatabaseSchema <- "cdm_optum_extended_dod_v654.dbo"
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
          maxCores = 30)
}, mailSettings = mailSettings, label = "denosumab")


# Some custom code to generate custom tables and figures:

mdrrFiles <- list.files(file.path(outputFolder, "diagnostics"), pattern = "mdrr.*.csv")
mdrr <- lapply(mdrrFiles, function(x) read.csv(file.path(outputFolder, "diagnostics", x)))
mdrr <- do.call(rbind, mdrr)
mdrr$file <- mdrrFiles
write.csv(mdrr, file.path(outputFolder, "diagnostics", "allMdrrs.csv"), row.names = FALSE)

conn <- connect(connectionDetails)
sql <- "SELECT MIN(cohort_start_date) FROM scratch.dbo.mschuemi_denosumab_optum WHERE cohort_definition_id = 1"
querySql(conn, sql)


fileName <-  file.path(outputFolder, paste0("simplifiedNullDistribution.png"))
EvidenceSynthesis::plotEmpiricalNulls(logRr = negControlSubset$logRr,
                                      seLogRr = negControlSubset$seLogRr,
                                      labels = rep("Optum", nrow(negControlSubset)),
                                      fileName = fileName)
