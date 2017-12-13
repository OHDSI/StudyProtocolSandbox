# @file CohortMethod.R
#
# Copyright 2017 Observational Health Data Sciences and Informatics
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

    cmFolder <- file.path(workFolder, "cohortMethod")
    if (!file.exists(cmFolder))
        dir.create(cmFolder)

    cmSummaryFile <- file.path(workFolder, "cmSummary.rds")
    if (!file.exists(cmSummaryFile)) {
        allControls <- read.csv(file.path(workFolder , "allControls.csv"))

        tcs <- unique(allControls[, c("targetId", "comparatorId")])
        tcosList <- list()
        for (i in 1:nrow(tcs)) {
            outcomeIds <- allControls$outcomeId[allControls$targetId == tcs$targetId[i] &
                                                    allControls$comparatorId == tcs$comparatorId[i] &
                                                    !is.na(allControls$mdrrComparator)]
            if (length(outcomeIds) != 0) {
                tcos <- CohortMethod::createDrugComparatorOutcomes(targetId = tcs$targetId[i],
                                                                   comparatorId = tcs$comparatorId[i],
                                                                   outcomeIds = outcomeIds)
                tcosList[[length(tcosList)+1]] <- tcos
            }
        }
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
                                                drugComparatorOutcomesList = tcosList,
                                                getDbCohortMethodDataThreads = min(3, maxCores),
                                                createStudyPopThreads = min(3, maxCores),
                                                createPsThreads = min(3, maxCores),
                                                psCvThreads = min(10, floor(maxCores/3)),
                                                computeCovarBalThreads = min(3, maxCores),
                                                trimMatchStratifyThreads = min(10, maxCores),
                                                fitOutcomeModelThreads = min(max(1, floor(maxCores/8)), 4),
                                                outcomeCvThreads = min(10, maxCores),
                                                refitPsForEveryOutcome = FALSE)

        cmSummary <- CohortMethod::summarizeAnalyses(cmResult)
        # write.csv(cmSummary, file.path(workFolder, "cmSummary.csv"), row.names = FALSE)
        saveRDS(cmSummary, cmSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed CohortMethod analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createCohortMethodSettings <- function(fileName) {
    covariateSettings <- FeatureExtraction::createDefaultCovariateSettings()

    getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 365,
                                                                     firstExposureOnly = TRUE,
                                                                     removeDuplicateSubjects = TRUE,
                                                                     studyStartDate = "",
                                                                     studyEndDate = "",
                                                                     excludeDrugsFromCovariates = TRUE,
                                                                     maxCohortSize = 250000,
                                                                     covariateSettings = covariateSettings)

    createStudyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                         minDaysAtRisk = 1,
                                                                         riskWindowStart = 0,
                                                                         addExposureDaysToStart = FALSE,
                                                                         riskWindowEnd = 0,
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

    createPsArgs <- CohortMethod::createCreatePsArgs(errorOnHighCorrelation = TRUE,
                                                     stopOnError = FALSE,
                                                     maxCohortSizeForFitting = 150000,
                                                     control = Cyclops::createControl(cvType = "auto",
                                                                                      startingVariance = 0.01,
                                                                                      noiseLevel = "quiet",
                                                                                      tolerance  = 2e-07,
                                                                                      cvRepetitions = 1))

    matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs(maxRatio = 1)

    cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                  description = "Matching plus simple outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs1,
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

    matchOnPsArgs2 <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)

    cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 4,
                                                  description = "Matching plus stratified outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createStudyPopArgs = createStudyPopArgs1,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs2,
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
                                                  matchOnPsArgs = matchOnPsArgs2,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs3)

    cmAnalysisList <- list(cmAnalysis1, cmAnalysis2, cmAnalysis3, cmAnalysis4, cmAnalysis5)
    if (!missing(fileName) && !is.null(fileName)){
        CohortMethod::saveCmAnalysisList(cmAnalysisList, fileName)
    }
    invisible(cmAnalysisList)
}
