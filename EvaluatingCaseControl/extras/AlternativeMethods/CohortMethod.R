# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of EvaluatingCaseControl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

runCohortMethodDesigns <- function(connectionDetails = connectionDetails,
                                   cdmDatabaseSchema = cdmDatabaseSchema,
                                   workDatabaseSchema = workDatabaseSchema,
                                   studyCohortTable = studyCohortTable,
                                   oracleTempSchema = oracleTempSchema,
                                   maxCores = maxCores,
                                   workFolder) {
  # Chou replication --------------------------------------------------------
  cmApFolder <- file.path(workFolder, "cmAp")
  if (!file.exists(cmApFolder))
    dir.create(cmApFolder)

  analysisListFile <- system.file("settings", "cmAnalysisListAp.json", package = "EvaluatingCaseControl")
  analysisList <- CohortMethod::loadCmAnalysisList(analysisListFile)
  tcoFile <- system.file("settings", "cmTcosAp.json", package = "EvaluatingCaseControl")
  tcoList <- CohortMethod::loadDrugComparatorOutcomesList(tcoFile)
  cmResult <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          oracleTempSchema = oracleTempSchema,
                                          exposureDatabaseSchema = workDatabaseSchema,
                                          exposureTable = studyCohortTable,
                                          outcomeDatabaseSchema = workDatabaseSchema,
                                          outcomeTable = studyCohortTable,
                                          cmAnalysisList = analysisList,
                                          drugComparatorOutcomesList = tcoList,
                                          outputFolder = cmApFolder,
                                          refitPsForEveryOutcome = TRUE,
                                          getDbCohortMethodDataThreads = 1,
                                          createStudyPopThreads = min(3, maxCores),
                                          createPsThreads = 1,#max(3, round(maxCores/10)),
                                          psCvThreads = min(10, maxCores),
                                          computeCovarBalThreads = min(3, maxCores),
                                          trimMatchStratifyThreads = min(10, maxCores),
                                          fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                          outcomeCvThreads = min(4, maxCores))
  ccSummary <- CaseControl::summarizeCcAnalyses(ccResult)
  ccSummaryFile <- file.path(workFolder, "ccSummaryAp.rds")
  saveRDS(ccSummary, ccSummaryFile)

  # Crockett replication --------------------------------------------------------
  ccIbdFolder <- file.path(workFolder, "ccIbd")
  if (!file.exists(ccIbdFolder))
    dir.create(ccIbdFolder)

  analysisListFile <- system.file("settings", "ccAnalysisListIbd.json", package = "EvaluatingCaseControl")
  analysisList <- CaseControl::loadCcAnalysisList(analysisListFile)
  eonFile <- system.file("settings", "ccExposureOutcomeNestingIbd.json", package = "EvaluatingCaseControl")
  eonList <- CaseControl::loadExposureOutcomeNestingCohortList(eonFile)
  ccResult <- CaseControl::runCcAnalyses(connectionDetails = connectionDetails,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         oracleTempSchema = oracleTempSchema,
                                         exposureDatabaseSchema = workDatabaseSchema,
                                         exposureTable = studyCohortTable,
                                         outcomeDatabaseSchema = workDatabaseSchema,
                                         outcomeTable = studyCohortTable,
                                         nestingCohortDatabaseSchema = workDatabaseSchema,
                                         nestingCohortTable = studyCohortTable,
                                         ccAnalysisList = analysisList,
                                         exposureOutcomeNestingCohortList = eonList,
                                         outputFolder = ccIbdFolder,
                                         getDbCaseDataThreads = 1,
                                         selectControlsThreads = min(3, maxCores),
                                         getDbExposureDataThreads = 1,
                                         createCaseControlDataThreads = min(5, maxCores),
                                         fitCaseControlModelThreads = min(5, maxCores),
                                         prefetchExposureData = TRUE)
  ccSummary <- CaseControl::summarizeCcAnalyses(ccResult)
  ccSummaryFile <- file.path(workFolder, "ccSummaryIbd.rds")
  saveRDS(ccSummary, ccSummaryFile)

  # model <- readRDS(ccResult$modelFile)
  # ed <- loadCaseControlsExposure(ccResult$exposureDataFile)
  # covs <- ff::as.ram(ed$covariates)
  # sum(covs$covariateId == 4)
  # ncs <- ccSummary[ccSummary$exposureId != 4, ]
  # EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, showCis = TRUE)
}

#' Create the analyses details
#'
#' @details
#' This function creates files specifying the analyses that will be performed.
#'
#' @param workFolder        Name of local folder to place results; make sure to use forward slashes
#'                            (/)
#'
#' @export
createCohortMethodAnalysesDetails <- function(workFolder) {

  # Chou replication --------------------------------------------------------

  covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                              useCovariateConditionOccurrence = TRUE,
                                                              useCovariateConditionOccurrenceLongTerm = TRUE,
                                                              useCovariateConditionOccurrenceShortTerm = TRUE,
                                                              useCovariateConditionOccurrenceInptMediumTerm = TRUE,
                                                              useCovariateConditionEra = TRUE,
                                                              useCovariateConditionEraEver = TRUE,
                                                              useCovariateConditionEraOverlap = TRUE,
                                                              useCovariateConditionGroup = TRUE,
                                                              useCovariateDrugExposure = TRUE,
                                                              useCovariateDrugExposureLongTerm = TRUE,
                                                              useCovariateDrugExposureShortTerm = TRUE,
                                                              useCovariateDrugEra = TRUE,
                                                              useCovariateDrugEraLongTerm = TRUE,
                                                              useCovariateDrugEraShortTerm = TRUE,
                                                              useCovariateDrugEraEver = TRUE,
                                                              useCovariateDrugEraOverlap = TRUE,
                                                              useCovariateDrugGroup = TRUE,
                                                              useCovariateProcedureOccurrence = TRUE,
                                                              useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                              useCovariateProcedureOccurrenceShortTerm = TRUE,
                                                              useCovariateProcedureGroup = TRUE,
                                                              useCovariateObservation = TRUE,
                                                              useCovariateObservationLongTerm = TRUE,
                                                              useCovariateObservationShortTerm = TRUE,
                                                              useCovariateObservationCountLongTerm = TRUE,
                                                              useCovariateMeasurementLongTerm = TRUE,
                                                              useCovariateMeasurementShortTerm = TRUE,
                                                              useCovariateMeasurementCountLongTerm = TRUE,
                                                              useCovariateMeasurementBelow = TRUE,
                                                              useCovariateMeasurementAbove = TRUE,
                                                              useCovariateConceptCounts = TRUE,
                                                              useCovariateRiskScores = TRUE,
                                                              useCovariateRiskScoresCharlson = TRUE,
                                                              useCovariateRiskScoresDCSI = TRUE,
                                                              useCovariateRiskScoresCHADS2 = TRUE,
                                                              useCovariateInteractionYear = FALSE,
                                                              useCovariateInteractionMonth = FALSE,
                                                              excludedCovariateConceptIds = c(),
                                                              deleteCovariatesSmallCount = 100)
  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 365,
                                                                   firstExposureOnly = TRUE,
                                                                   removeDuplicateSubjects = TRUE,
                                                                   studyStartDate = "",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = TRUE,
                                                                   covariateSettings = covarSettings)

  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                      minDaysAtRisk = 1,
                                                                      riskWindowStart = 0,
                                                                      addExposureDaysToStart = FALSE,
                                                                      riskWindowEnd = 0,
                                                                      addExposureDaysToEnd = TRUE)

  createPsArgs <- CohortMethod::createCreatePsArgs(control = Cyclops::createControl(cvType = "auto",
                                                                                    startingVariance = 0.01,
                                                                                    noiseLevel = "quiet",
                                                                                    tolerance  = 2e-07,
                                                                                    cvRepetitions = 1))

  matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)

  fitOutcomeModelArgs <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                 modelType = "cox",
                                                                 stratified = TRUE)

  cmAnalysis <- CohortMethod::createCmAnalysis(analysisId = 1,
                                               description = "Matching plus simple outcome model",
                                               getDbCohortMethodDataArgs = getDbCmDataArgs,
                                               createStudyPopArgs = createStudyPopArgs,
                                               createPs = TRUE,
                                               createPsArgs = createPsArgs,
                                               matchOnPs = TRUE,
                                               matchOnPsArgs = matchOnPsArgs,
                                               fitOutcomeModel = TRUE,
                                               fitOutcomeModelArgs = fitOutcomeModelArgs)

  cmAnalysisList <- list(cmAnalysis)
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisListAp.json"))

  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "EvaluatingCaseControl")
  negativeControls <- read.csv(pathToCsv)
  negativeControls <- negativeControls[negativeControls$outcomeName == "Acute pancreatitis", ]
  tcosAp <- list()
  for (i in 1:nrow(negativeControls)) {
    tco <- CohortMethod::createDrugComparatorOutcomes(targetId = negativeControls$targetId[i],
                                                      comparatorId = negativeControls$comparatorId[i],
                                                      outcomeId = 2)
    tcosAp[[length(tcosAp) + 1]] <- tco
  }
  CohortMethod::saveDrugComparatorOutcomesList(tcosAp, file.path(workFolder, "cmTcosAp.json"))


  # Crockett replication ----------------------------------------------------

  covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                              useCovariateConditionOccurrence = TRUE,
                                                              useCovariateConditionOccurrenceLongTerm = TRUE,
                                                              useCovariateConditionOccurrenceShortTerm = TRUE,
                                                              useCovariateConditionOccurrenceInptMediumTerm = TRUE,
                                                              useCovariateConditionEra = TRUE,
                                                              useCovariateConditionEraEver = TRUE,
                                                              useCovariateConditionEraOverlap = TRUE,
                                                              useCovariateConditionGroup = TRUE,
                                                              useCovariateDrugExposure = TRUE,
                                                              useCovariateDrugExposureLongTerm = TRUE,
                                                              useCovariateDrugExposureShortTerm = TRUE,
                                                              useCovariateDrugEra = TRUE,
                                                              useCovariateDrugEraLongTerm = TRUE,
                                                              useCovariateDrugEraShortTerm = TRUE,
                                                              useCovariateDrugEraEver = TRUE,
                                                              useCovariateDrugEraOverlap = TRUE,
                                                              useCovariateDrugGroup = TRUE,
                                                              useCovariateProcedureOccurrence = TRUE,
                                                              useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                              useCovariateProcedureOccurrenceShortTerm = TRUE,
                                                              useCovariateProcedureGroup = TRUE,
                                                              useCovariateObservation = TRUE,
                                                              useCovariateObservationLongTerm = TRUE,
                                                              useCovariateObservationShortTerm = TRUE,
                                                              useCovariateObservationCountLongTerm = TRUE,
                                                              useCovariateMeasurementLongTerm = TRUE,
                                                              useCovariateMeasurementShortTerm = TRUE,
                                                              useCovariateMeasurementCountLongTerm = TRUE,
                                                              useCovariateMeasurementBelow = TRUE,
                                                              useCovariateMeasurementAbove = TRUE,
                                                              useCovariateConceptCounts = TRUE,
                                                              useCovariateRiskScores = TRUE,
                                                              useCovariateRiskScoresCharlson = TRUE,
                                                              useCovariateRiskScoresDCSI = TRUE,
                                                              useCovariateRiskScoresCHADS2 = TRUE,
                                                              useCovariateInteractionYear = FALSE,
                                                              useCovariateInteractionMonth = FALSE,
                                                              excludedCovariateConceptIds = c(),
                                                              deleteCovariatesSmallCount = 100)
  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 365,
                                                                   firstExposureOnly = TRUE,
                                                                   removeDuplicateSubjects = TRUE,
                                                                   studyStartDate = "",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = TRUE,
                                                                   covariateSettings = covarSettings)

  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                      minDaysAtRisk = 1,
                                                                      riskWindowStart = 0,
                                                                      addExposureDaysToStart = FALSE,
                                                                      riskWindowEnd = 365,
                                                                      addExposureDaysToEnd = FALSE)

  createPsArgs <- CohortMethod::createCreatePsArgs(control = Cyclops::createControl(cvType = "auto",
                                                                                    startingVariance = 0.01,
                                                                                    noiseLevel = "quiet",
                                                                                    tolerance  = 2e-07,
                                                                                    cvRepetitions = 1))

  matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)

  fitOutcomeModelArgs <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                 modelType = "cox",
                                                                 stratified = TRUE)

  cmAnalysis <- CohortMethod::createCmAnalysis(analysisId = 1,
                                               description = "Matching plus simple outcome model",
                                               getDbCohortMethodDataArgs = getDbCmDataArgs,
                                               createStudyPopArgs = createStudyPopArgs,
                                               createPs = TRUE,
                                               createPsArgs = createPsArgs,
                                               matchOnPs = TRUE,
                                               matchOnPsArgs = matchOnPsArgs,
                                               fitOutcomeModel = TRUE,
                                               fitOutcomeModelArgs = fitOutcomeModelArgs)

  cmAnalysisList <- list(cmAnalysis)
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisListIbd.json"))

  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "EvaluatingCaseControl")
  negativeControls <- read.csv(pathToCsv)
  negativeControls <- negativeControls[negativeControls$outcomeName == "Inflammatory Bowel Disease", ]
  tcos <- list()
  for (i in 1:nrow(negativeControls)) {
    tco <- CohortMethod::createDrugComparatorOutcomes(targetId = negativeControls$targetId[i],
                                                      comparatorId = negativeControls$comparatorId[i],
                                                      outcomeId = 2)
    tcos[[length(tcos) + 1]] <- tco
  }
  CohortMethod::saveDrugComparatorOutcomesList(tcos, file.path(workFolder, "cmTcosIbd.json"))
}
