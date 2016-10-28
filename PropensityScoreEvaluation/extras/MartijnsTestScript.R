# Install packages
# install.packages("devtools")
# library(devtools)
# install_github("ohdsi/OhdsiRTools")
# install_github("ohdsi/SqlRender")
# install_github("ohdsi/DatabaseConnector")
# install_github("ohdsi/Cyclops", ref="HDPS")
# install_github("ohdsi/FeatureExtraction")
# install_github("ohdsi/CohortMethod", ref = "hdps_clean")
library(SqlRender)
library(DatabaseConnector)
library(CohortMethod)
library(PropensityScoreEvaluation)
options('fftempdir' = 's:/fftemp')

dbms <- "pdw"
user <- NULL
pw <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "cdm_truven_mdcd_v446.dbo"
resultsDatabaseSchema <- "scratch.dbo"
port <- 17001
cdmVersion <- "5"
extraSettings <- NULL
file = "inst/sql/sql_server/coxibVsNonselVsGiBleed.sql"
workFolder <- "s:/temp/Yuxi"

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port,
                                                                extraSettings = extraSettings)
hdpsCovariates = TRUE

connection <- DatabaseConnector::connect(connectionDetails)

sql <- "SELECT concept_id FROM @cdmDatabaseSchema.concept_ancestor INNER JOIN @cdmDatabaseSchema.concept ON descendant_concept_id = concept_id WHERE ancestor_concept_id = 21603933"
sql <- SqlRender::renderSql(sql, cdmDatabaseSchema = cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
nsaids <- DatabaseConnector::querySql(connection, sql)
nsaids <- nsaids$CONCEPT_ID

dbDisconnect(connection)


cohortMethodData <- createCohortMethodData(connectionDetails = connectionDetails,
                                           file = file,
                                           exposureTable = "coxibVsNonselVsGiBleed",
                                           outcomeTable = "coxibVsNonselVsGiBleed",
                                           cdmVersion = cdmVersion,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           hdpsCovariates = hdpsCovariates,
                                           excludedCovariateConceptIds = nsaids)


saveCohortMethodData(cohortMethodData = cohortMethodData, file = file.path(workFolder, "cmData_hdps"))

# cohortMethodData <- loadCohortMethodData(file.path(workFolder, "cmData_hdps"))

studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
                                  outcomeId = 3,
                                  firstExposureOnly = FALSE,
                                  washoutPeriod = 0,
                                  removeDuplicateSubjects = FALSE,
                                  removeSubjectsWithPriorOutcome = TRUE,
                                  minDaysAtRisk = 1,
                                  riskWindowStart = 0,
                                  addExposureDaysToStart = FALSE,
                                  riskWindowEnd = 30,
                                  addExposureDaysToEnd = TRUE)

simulationProfile <- createCMDSimulationProfile(cohortMethodData, studyPop, threads = 30)

# Default runs is n = 10; can be changed
# Currently matching 1-1 on propensity score (strata = matchOnPs(ps))

# Vanilla parameters: no unmeasured confounding, no replacing observed effect size, no replacing outcome prevalence
hdpsCovariates <- TRUE
simulationStudy <- runSimulationStudy(simulationProfile, studyPop, hdpsFeatures = hdpsCovariates)

saveRDS(simulationStudy, "s:/temp/simulationStudy.rds")
