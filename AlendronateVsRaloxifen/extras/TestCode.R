library(AlendronateVsRaloxifen)
options(fftempdir = "s:/FFtemp")

dbms <- "pdw"
user <- NULL
pw <- NULL
server <- "JRDUSAPSCTL01"
port <- 17001
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)
cdmDatabaseSchema <- "CDM_Truven_MDCD_V446.dbo"
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "ohdsi_alendronate_raloxifen_mdcd"
oracleTempSchema <- NULL
cdmVersion <- "5"
outputFolder <- "S:/temp/AlendronateVsRaloxifenMdcd"

cdmDatabaseSchema <- "cdm_truven_ccae_v441.dbo"
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "ohdsi_alendronate_raloxifen_ccae"
oracleTempSchema <- NULL
cdmVersion <- "5"
outputFolder <- "S:/temp/AlendronateVsRaloxifenCcae"

cdmDatabaseSchema <- "cdm_truven_mdcr_v445.dbo"
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "ohdsi_alendronate_raloxifen_mdcr"
oracleTempSchema <- NULL
cdmVersion <- "5"
outputFolder <- "S:/temp/AlendronateVsRaloxifenMdcr"

cdmDatabaseSchema <- "cdm_optum_extended_ses_v458.dbo"
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "ohdsi_alendronate_raloxifen_optum"
oracleTempSchema <- NULL
cdmVersion <- "5"
outputFolder <- "S:/temp/AlendronateVsRaloxifenOptum"

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

assessFeasibility(connectionDetails = connectionDetails,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  workDatabaseSchema = workDatabaseSchema,
                  studyCohortTable = studyCohortTable,
                  oracleTempSchema = oracleTempSchema,
                  cdmVersion = cdmVersion,
                  outputFolder = outputFolder,
                  createCohorts = FALSE,
                  getCounts = TRUE)


