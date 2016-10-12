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
workFolder <- "s:/temp/Yuxi"

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port,
                                                                extraSettings = extraSettings)
connection <- DatabaseConnector::connect(connectionDetails)

sql <- loadRenderTranslateSql("coxibVsNonselVsGiBleed.sql",
                              packageName = "PropensityScoreEvaluation",
                              dbms = dbms,
                              cdmDatabaseSchema = cdmDatabaseSchema,
                              resultsDatabaseSchema = resultsDatabaseSchema)
DatabaseConnector::executeSql(connection, sql)

# Check number of subjects per cohort:
sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @resultsDatabaseSchema.coxibVsNonselVsGiBleed GROUP BY cohort_definition_id"
sql <- SqlRender::renderSql(sql, resultsDatabaseSchema = resultsDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
DatabaseConnector::querySql(connection, sql)

# Get all NSAIDs:
sql <- "SELECT concept_id FROM @cdmDatabaseSchema.concept_ancestor INNER JOIN @cdmDatabaseSchema.concept ON descendant_concept_id = concept_id WHERE ancestor_concept_id = 21603933"
sql <- SqlRender::renderSql(sql, cdmDatabaseSchema = cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
nsaids <- DatabaseConnector::querySql(connection, sql)
nsaids <- nsaids$CONCEPT_ID

dbDisconnect(connection)


covariateSettings1 = createHdpsCovariateSettings(useCovariateCohortIdIs1 = FALSE,
                                             useCovariateDemographics = TRUE, 
                                             useCovariateDemographicsGender = TRUE,
                                             useCovariateDemographicsRace = TRUE,
                                             useCovariateDemographicsEthnicity = TRUE,
                                             useCovariateDemographicsAge = TRUE, 
                                             useCovariateDemographicsYear = TRUE,
                                             useCovariateDemographicsMonth = TRUE,
                                             useCovariateConditionOccurrence = TRUE,
                                             useCovariate3DigitIcd9Inpatient180d = TRUE,
                                             useCovariate3DigitIcd9Inpatient180dMedF = TRUE,
                                             useCovariate3DigitIcd9Inpatient180d75F = TRUE,
                                             useCovariate3DigitIcd9Ambulatory180d = TRUE,
                                             useCovariate3DigitIcd9Ambulatory180dMedF = TRUE,
                                             useCovariate3DigitIcd9Ambulatory180d75F = TRUE,
                                             useCovariateDrugExposure = TRUE,
                                             useCovariateIngredientExposure180d = TRUE,
                                             useCovariateIngredientExposure180dMedF = TRUE,
                                             useCovariateIngredientExposure180d75F = TRUE,
                                             useCovariateProcedureOccurrence = TRUE,
                                             useCovariateProcedureOccurrenceInpatient180d = TRUE,
                                             useCovariateProcedureOccurrenceInpatient180dMedF = TRUE,
                                             useCovariateProcedureOccurrenceInpatient180d75F = TRUE,
                                             useCovariateProcedureOccurrenceAmbulatory180d = TRUE,
                                             useCovariateProcedureOccurrenceAmbulatory180dMedF = TRUE,
                                             useCovariateProcedureOccurrenceAmbulatory180d75F = TRUE,
                                             excludedCovariateConceptIds = nsaids, 
                                             includedCovariateConceptIds = c(),
                                             deleteCovariatesSmallCount = 5)

covariateSettings2 <- createCovariateSettings(useCovariateDemographics = TRUE,
                                              useCovariateDemographicsAge = TRUE,
                                              useCovariateDemographicsGender = TRUE,
                                              useCovariateDemographicsRace = TRUE,
                                              useCovariateDemographicsEthnicity = TRUE,
                                              useCovariateDemographicsYear = TRUE,
                                              useCovariateDemographicsMonth = TRUE,
                                              useCovariateConditionOccurrence = TRUE,
                                              useCovariateConditionOccurrence365d = TRUE,
                                              useCovariateConditionOccurrence30d = TRUE,
                                              useCovariateConditionOccurrenceInpt180d = TRUE,
                                              useCovariateConditionEra = TRUE,
                                              useCovariateConditionEraEver = TRUE,
                                              useCovariateConditionEraOverlap = TRUE,
                                              useCovariateConditionGroup = TRUE,
                                              useCovariateDrugExposure = TRUE,
                                              useCovariateDrugExposure365d = TRUE,
                                              useCovariateDrugExposure30d = TRUE,
                                              useCovariateDrugEra = TRUE,
                                              useCovariateDrugEra365d = TRUE,
                                              useCovariateDrugEra30d = TRUE,
                                              useCovariateDrugEraEver = TRUE,
                                              useCovariateDrugEraOverlap = TRUE,
                                              useCovariateDrugGroup = TRUE,
                                              useCovariateProcedureOccurrence = TRUE,
                                              useCovariateProcedureOccurrence365d = TRUE,
                                              useCovariateProcedureOccurrence30d = TRUE,
                                              useCovariateProcedureGroup = TRUE,
                                              useCovariateObservation = FALSE,
                                              useCovariateObservation365d = FALSE,
                                              useCovariateObservation30d = FALSE,
                                              useCovariateObservationCount365d = FALSE,
                                              useCovariateMeasurement365d = FALSE,
                                              useCovariateMeasurement30d = FALSE,
                                              useCovariateMeasurementCount365d = FALSE,
                                              useCovariateMeasurementBelow = FALSE,
                                              useCovariateMeasurementAbove = FALSE,
                                              useCovariateConceptCounts = FALSE,
                                              useCovariateRiskScores = FALSE,
                                              useCovariateRiskScoresCharlson = FALSE,
                                              useCovariateRiskScoresDCSI = FALSE,
                                              useCovariateRiskScoresCHADS2 = FALSE,
                                              useCovariateInteractionYear = FALSE,
                                              useCovariateInteractionMonth = FALSE,
                                              excludedCovariateConceptIds = nsaids,
                                              includedCovariateConceptIds = c(),
                                              deleteCovariatesSmallCount = 5)

cohortMethodData1 <- getDbCohortMethodData(connectionDetails = connectionDetails,
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          oracleTempSchema = resultsDatabaseSchema,
                                          targetId = 1,
                                          comparatorId = 2,
                                          outcomeIds = 3,
                                          studyStartDate = "",
                                          studyEndDate = "",
                                          exposureDatabaseSchema = resultsDatabaseSchema,
                                          exposureTable = "coxibVsNonselVsGiBleed",
                                          outcomeDatabaseSchema = resultsDatabaseSchema,
                                          outcomeTable = "coxibVsNonselVsGiBleed",
                                          cdmVersion = cdmVersion,
                                          excludeDrugsFromCovariates = FALSE,
                                          firstExposureOnly = TRUE,
                                          removeDuplicateSubjects = TRUE,
                                          washoutPeriod = 180,
                                          covariateSettings = covariateSettings1)

saveCohortMethodData(cohortMethodData = cohortMethodData1, file = file.path(workFolder, "cmData1"))

cohortMethodData2 <- getDbCohortMethodData(connectionDetails = connectionDetails,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           oracleTempSchema = resultsDatabaseSchema,
                                           targetId = 1,
                                           comparatorId = 2,
                                           outcomeIds = 3,
                                           studyStartDate = "",
                                           studyEndDate = "",
                                           exposureDatabaseSchema = resultsDatabaseSchema,
                                           exposureTable = "coxibVsNonselVsGiBleed",
                                           outcomeDatabaseSchema = resultsDatabaseSchema,
                                           outcomeTable = "coxibVsNonselVsGiBleed",
                                           cdmVersion = cdmVersion,
                                           excludeDrugsFromCovariates = FALSE,
                                           firstExposureOnly = TRUE,
                                           removeDuplicateSubjects = TRUE,
                                           washoutPeriod = 180,
                                           covariateSettings = covariateSettings2)

saveCohortMethodData(cohortMethodData = cohortMethodData2, file = file.path(workFolder, "cmData2"))

options("fffinalizer" = "delete")

simulationStudy1 <- runSimulationStudy(cohortMethodData1, hdpsFeatures = TRUE)
simulationStudy2 <- runSimulationStudy(cohortMethodData2, hdpsFeatures = FALSE)