# @file CohortMethod.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of PopEstMethodEvaluation
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

#' @export
runCohortMethod <- function(connectionDetails,
                            cdmDatabaseSchema,
                            oracleTempSchema = NULL,
                            outcomeDatabaseSchema = cdmDatabaseSchema,
                            outcomeTable = "cohort",
                            workFolder,
                            cdmVersion = "5",
                            maxCores = 4) {
    start <- Sys.time()
    injectionSummaryFile <- file.path(workFolder, "injectionSummary.rds")
    if (!file.exists(injectionSummaryFile))
        stop("Cannot find injection summary file. Please run injectSignals first.")
    injectedSignals <- readRDS(injectionSummaryFile)

    cmFolder <- file.path(workFolder, "cohortMethod")
    if (!file.exists(cmFolder))
        dir.create(cmFolder)

    cmSummaryFile <- file.path(workFolder, "cmSummary.rds")
    if (!file.exists(cmSummaryFile)) {
        exposureOutcomePairs <- injectedSignals[injectedSignals$trueEffectSize != 0, c("exposureId", "newOutcomeId")]
        colnames(exposureOutcomePairs)[colnames(exposureOutcomePairs) == "newOutcomeId"] <- "outcomeId"

        resultSum <- injectedSignals[injectedSignals$trueEffectSize != 0,]
        dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = 1124300, comparatorId = 1118084, outcomeIds = resultSum$newOutcomeId)
        drugComparatorOutcomesList <- list(dcos)

        cmAnalysisListFile <- system.file("settings", "cmAnalysisSettings.txt", package = "PopEstMethodEvaluation")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        cmResult <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                  oracleTempSchema = oracleTempSchema,
                                  exposureTable = "drug_era",
                                  outcomeDatabaseSchema = outcomeDatabaseSchema,
                                  outcomeTable = outcomeTable,
                                  outputFolder = cmFolder,
                                  cdmVersion = cdmVersion,
                                  cmAnalysisList = cmAnalysisList,
                                  drugComparatorOutcomesList = drugComparatorOutcomesList,
                                  getDbCohortMethodDataThreads = 1,
                                  createStudyPopThreads = min(3, maxCores),
                                  createPsThreads = 1,
                                  psCvThreads = min(16, maxCores),
                                  computeCovarBalThreads = min(3, maxCores),
                                  trimMatchStratifyThreads = min(10, maxCores),
                                  fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                  outcomeCvThreads = min(4, maxCores),
                                  refitPsForEveryOutcome = FALSE)
        cmSummary <- CohortMethod::summarizeAnalyses(cmResult)
        saveRDS(cmSummary, cmSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed CohortMethod analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createCohortMethodSettings <- function(fileName) {

    covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
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
                                                                useCovariateObservation = TRUE,
                                                                useCovariateObservation365d = TRUE,
                                                                useCovariateObservation30d = TRUE,
                                                                useCovariateObservationCount365d = TRUE,
                                                                useCovariateMeasurement365d = TRUE,
                                                                useCovariateMeasurement30d = TRUE,
                                                                useCovariateMeasurementCount365d = TRUE,
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
    getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 183,
                                                                     firstExposureOnly = TRUE,
                                                                     removeDuplicateSubjects = TRUE,
                                                                     studyStartDate = "",
                                                                     studyEndDate = "",
                                                                     excludeDrugsFromCovariates = TRUE,
                                                                     covariateSettings = covarSettings)

    createStudyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                        minDaysAtRisk = 1,
                                                                        riskWindowStart = 0,
                                                                        addExposureDaysToStart = FALSE,
                                                                        riskWindowEnd = 30,
                                                                        addExposureDaysToEnd = TRUE)

    fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                    modelType = "cox",
                                                                    stratified = FALSE)

    cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                  description = "No matching, simple outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    createPsArgs <- CohortMethod::createCreatePsArgs(control = Cyclops::createControl(cvType = "auto",
                                                                                      startingVariance = 0.01,
                                                                                      noiseLevel = "quiet",
                                                                                      tolerance  = 2e-07,
                                                                                      cvRepetitions = 1))

    matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)

    cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                  description = "Matching plus simple outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs(numberOfStrata = 5)

    fitOutcomeModelArgs2 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                    modelType = "cox",
                                                                    stratified = TRUE)

    cmAnalysis3 <- CohortMethod::createCmAnalysis(analysisId = 3,
                                                  description = "Stratification plus stratified outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  stratifyByPs = TRUE,
                                                  stratifyByPsArgs = stratifyByPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs2)

    cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 4,
                                                  description = "Matching plus stratified outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs2)

    fitOutcomeModelArgs3 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = TRUE,
                                                                    modelType = "cox",
                                                                    stratified = TRUE,
                                                                    control = Cyclops::createControl(cvType = "auto",
                                                                                                     startingVariance = 0.1,
                                                                                                     selectorType = "byPid",
                                                                                                     cvRepetitions = 1,
                                                                                                     tolerance = 2e-07,
                                                                                                     noiseLevel = "quiet"))

    cmAnalysis5 <- CohortMethod::createCmAnalysis(analysisId = 5,
                                                  description = "Matching plus full outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs3)

    #######################

    createStudyPopArgs2 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                         minDaysAtRisk = 1,
                                                                         riskWindowStart = 0,
                                                                         addExposureDaysToStart = FALSE,
                                                                         riskWindowEnd = 99999,
                                                                         addExposureDaysToEnd = FALSE)

    cmAnalysis6 <- CohortMethod::createCmAnalysis(analysisId = 6,
                                                  description = "No matching, simple outcome model, ITT",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs2,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    cmAnalysis7 <- CohortMethod::createCmAnalysis(analysisId = 7,
                                                  description = "Matching plus simple outcome model, ITT",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs2,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    cmAnalysis8 <- CohortMethod::createCmAnalysis(analysisId = 8,
                                                  description = "Stratification plus stratified outcome model, ITT",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs2,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  stratifyByPs = TRUE,
                                                  stratifyByPsArgs = stratifyByPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs2)

    cmAnalysis9 <- CohortMethod::createCmAnalysis(analysisId = 9,
                                                  description = "Matching plus stratified outcome model, ITT",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs2,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs2)

    cmAnalysis10 <- CohortMethod::createCmAnalysis(analysisId = 10,
                                                  description = "Matching plus full outcome model, ITT",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs2,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs3)

    cmAnalysisList <- list(cmAnalysis1, cmAnalysis2, cmAnalysis3, cmAnalysis4, cmAnalysis5, cmAnalysis6, cmAnalysis7, cmAnalysis8, cmAnalysis9, cmAnalysis10)
    if (!missing(fileName) && !is.null(fileName)){
        CohortMethod::saveCmAnalysisList(cmAnalysisList, fileName)
    }
    invisible(cmAnalysisList)
}
