library(EvaluatingCaseControl)
options(fftempdir = "S:/fftemp")


pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_ccae_V568.dbo"
oracleTempSchema <- NULL
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "mschuemie_case_control_ap_ccae"
port <- 17001
workFolder <- "S:/Temp/EvaluatingCaseControl_ccae"
maxCores <- 30


connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

ccSummary <- readRDS(file.path(workFolder, "ccSummaryIbd.rds"))
ncs <- ccSummary[ccSummary$exposureId != 5, ]
EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, xLabel = "Odds ratio", fileName = file.path(workFolder, "plots", "ncsIbd.png"))

ccSummary <- readRDS(file.path(workFolder, "ccSummaryAp.rds"))
ncs <- ccSummary[ccSummary$exposureId != 4, ]
EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, xLabel = "Odds ratio", fileName = file.path(workFolder, "plots", "ncsAp.png"))

ccrSummary <- readRDS(file.path(workFolder, "ccrSummaryIbd.rds"))
ncs <- ccrSummary[ccrSummary$exposureId != 5, ]
EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, xLabel = "Odds ratio", fileName = file.path(workFolder, "plots", "ncsIbdCaseTimeControl.png"))

ccrSummary <- readRDS(file.path(workFolder, "ccrSummaryAp.rds"))
ncs <- ccrSummary[ccrSummary$exposureId != 4, ]
EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, xLabel = "Odds ratio", fileName = file.path(workFolder, "plots", "ncsApCaseTimeControl.png"))



# Comparing populations ---------------------------------------------------



# Ibd
covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                            useCovariateConditionOccurrence = TRUE,
                                                            useCovariateConditionOccurrenceLongTerm = TRUE,
                                                            useCovariateConditionOccurrenceShortTerm = FALSE,
                                                            useCovariateConditionOccurrenceInptMediumTerm = FALSE,
                                                            useCovariateConditionEra = FALSE,
                                                            useCovariateConditionEraEver = FALSE,
                                                            useCovariateConditionEraOverlap = FALSE,
                                                            useCovariateConditionGroup = FALSE,
                                                            useCovariateDrugExposure = FALSE,
                                                            useCovariateDrugExposureLongTerm = FALSE,
                                                            useCovariateDrugExposureShortTerm = FALSE,
                                                            useCovariateDrugEra = TRUE,
                                                            useCovariateDrugEraLongTerm = TRUE,
                                                            useCovariateDrugEraShortTerm = FALSE,
                                                            useCovariateDrugEraEver = FALSE,
                                                            useCovariateDrugEraOverlap = FALSE,
                                                            useCovariateDrugGroup = TRUE,
                                                            useCovariateProcedureOccurrence = TRUE,
                                                            useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                            useCovariateProcedureOccurrenceShortTerm = FALSE,
                                                            useCovariateProcedureGroup = TRUE,
                                                            useCovariateObservation = TRUE,
                                                            useCovariateObservationLongTerm = TRUE,
                                                            useCovariateObservationShortTerm = FALSE,
                                                            useCovariateObservationCountLongTerm = FALSE,
                                                            useCovariateMeasurementLongTerm = TRUE,
                                                            useCovariateMeasurementShortTerm = FALSE,
                                                            useCovariateMeasurementCountLongTerm = FALSE,
                                                            useCovariateMeasurementBelow = TRUE,
                                                            useCovariateMeasurementAbove = TRUE,
                                                            useCovariateConceptCounts = TRUE,
                                                            useCovariateRiskScores = TRUE,
                                                            useCovariateRiskScoresCharlson = TRUE,
                                                            useCovariateRiskScoresDCSI = TRUE,
                                                            useCovariateRiskScoresCHADS2 = TRUE,
                                                            useCovariateInteractionYear = FALSE,
                                                            useCovariateInteractionMonth = FALSE,
                                                            windowEndDays = 365,
                                                            longTermDays = 365+265,
                                                            mediumTermDays = 265+180,
                                                            shortTermDays = 365+30,
                                                            excludedCovariateConceptIds = c(),
                                                            deleteCovariatesSmallCount = 100)
ccFile <- file.path(workFolder, "ccIbd", "caseControls_cd1_cc1_o3.rds")
cc <- readRDS(ccFile)
stratumIds <- unique(cc$stratumId)
sampledStratumIds <- sample(stratumIds, 10000, replace = FALSE)
ccSampled <- cc[cc$stratumId %in% sampledStratumIds, ]
ed <- CaseControl::getDbExposureData(caseControls = ccSampled,
                                     connectionDetails = connectionDetails,
                                     oracleTempSchema = oracleTempSchema,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     exposureDatabaseSchema = cdmDatabaseSchema,
                                     exposureTable = "drug_era",
                                     exposureIds = -1,
                                     covariateSettings = covarSettings)
CaseControl::saveCaseControlsExposure(caseControlsExposure = ed, file.path(workFolder, "Ed_ibd"))
ed <- CaseControl::loadCaseControlsExposure(file.path(workFolder, "Ed_ibd"))
population <- ed$caseControls
population$treatment <- population$isCase
ed$cohorts <- population
bal <- CohortMethod::computeCovariateBalance(population, ed)
saveRDS(bal, file.path(workFolder, "Bal_ibd.rds"))
bal <- readRDS(file.path(workFolder, "Bal_ibd.rds"))
bal <- bal[order(-abs(bal$afterMatchingStdDiff)), ]
table <- data.frame(std = bal$afterMatchingStdDiff,
                    name = bal$covariateName)
table <- table[1:25, ]
table$name <- gsub("^.*:", "", table$name)
table$name <- gsub("^.*-", "", table$name)
write.csv(table, file.path(workFolder, "plots", "Std_Ibd.csv"), row.names = FALSE)

# Ap
covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                            useCovariateConditionOccurrence = TRUE,
                                                            useCovariateConditionOccurrenceLongTerm = TRUE,
                                                            useCovariateConditionOccurrenceShortTerm = FALSE,
                                                            useCovariateConditionOccurrenceInptMediumTerm = FALSE,
                                                            useCovariateConditionEra = FALSE,
                                                            useCovariateConditionEraEver = FALSE,
                                                            useCovariateConditionEraOverlap = FALSE,
                                                            useCovariateConditionGroup = FALSE,
                                                            useCovariateDrugExposure = FALSE,
                                                            useCovariateDrugExposureLongTerm = FALSE,
                                                            useCovariateDrugExposureShortTerm = FALSE,
                                                            useCovariateDrugEra = TRUE,
                                                            useCovariateDrugEraLongTerm = TRUE,
                                                            useCovariateDrugEraShortTerm = FALSE,
                                                            useCovariateDrugEraEver = FALSE,
                                                            useCovariateDrugEraOverlap = FALSE,
                                                            useCovariateDrugGroup = TRUE,
                                                            useCovariateProcedureOccurrence = TRUE,
                                                            useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                            useCovariateProcedureOccurrenceShortTerm = FALSE,
                                                            useCovariateProcedureGroup = TRUE,
                                                            useCovariateObservation = TRUE,
                                                            useCovariateObservationLongTerm = TRUE,
                                                            useCovariateObservationShortTerm = FALSE,
                                                            useCovariateObservationCountLongTerm = FALSE,
                                                            useCovariateMeasurementLongTerm = TRUE,
                                                            useCovariateMeasurementShortTerm = FALSE,
                                                            useCovariateMeasurementCountLongTerm = FALSE,
                                                            useCovariateMeasurementBelow = TRUE,
                                                            useCovariateMeasurementAbove = TRUE,
                                                            useCovariateConceptCounts = TRUE,
                                                            useCovariateRiskScores = TRUE,
                                                            useCovariateRiskScoresCharlson = TRUE,
                                                            useCovariateRiskScoresDCSI = TRUE,
                                                            useCovariateRiskScoresCHADS2 = TRUE,
                                                            useCovariateInteractionYear = FALSE,
                                                            useCovariateInteractionMonth = FALSE,
                                                            windowEndDays = 7,
                                                            longTermDays = 7+265,
                                                            mediumTermDays = 7+180,
                                                            shortTermDays = 7+30,
                                                            excludedCovariateConceptIds = c(),
                                                            deleteCovariatesSmallCount = 100)
ccFile <- file.path(workFolder, "ccAp", "caseControls_cd1_n1_cc1_o2.rds")
cc <- readRDS(ccFile)
stratumIds <- unique(cc$stratumId)
#sampledStratumIds <- sample(stratumIds, 10000, replace = FALSE)
sampledStratumIds <- stratumIds
ccSampled <- cc[cc$stratumId %in% sampledStratumIds, ]
ed <- CaseControl::getDbExposureData(caseControls = ccSampled,
                                     connectionDetails = connectionDetails,
                                     oracleTempSchema = oracleTempSchema,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     exposureDatabaseSchema = cdmDatabaseSchema,
                                     exposureTable = "drug_era",
                                     exposureIds = -1,
                                     covariateSettings = covarSettings)
CaseControl::saveCaseControlsExposure(caseControlsExposure = ed, file.path(workFolder, "Ed_ap"))
ed <- CaseControl::loadCaseControlsExposure(file.path(workFolder, "Ed_ap"))
population <- ed$caseControls
population$treatment <- population$isCase
ed$cohorts <- population
bal <- CohortMethod::computeCovariateBalance(population, ed)
saveRDS(bal, file.path(workFolder, "Bal_ap.rds"))
bal <- readRDS(file.path(workFolder, "Bal_ap.rds"))
bal <- bal[order(-abs(bal$afterMatchingStdDiff)), ]
table <- data.frame(std = bal$afterMatchingStdDiff,
                    name = bal$covariateName)
table <- table[1:25, ]
table$name <- gsub("^.*:", "", table$name)
table$name <- gsub("^.*-", "", table$name)
write.csv(table, file.path(workFolder, "plots", "Std_Ap.csv"), row.names = FALSE)
