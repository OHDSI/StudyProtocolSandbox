# @file CaseControl.R
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
runCaseControl <- function(connectionDetails,
                           cdmDatabaseSchema,
                           oracleTempSchema = NULL,
                           outcomeDatabaseSchema = cdmDatabaseSchema,
                           outcomeTable = "cohort",
                           nestingCohortDatabaseSchema = cdmDatabaseSchema,
                           nestingCohortTable = "condition_era",
                           workFolder,
                           cdmVersion = "5",
                           maxCores = 4) {
    if (cdmVersion == '4')
        stop("The CaseControl package does not support CDM version 4")
    start <- Sys.time()

    ccFolder <- file.path(workFolder, "caseControl")
    if (!file.exists(ccFolder))
        dir.create(ccFolder)

    ccSummaryFile <- file.path(workFolder, "ccSummary.rds")
    if (!file.exists(ccSummaryFile)) {
        allControls <- read.csv(file.path(workFolder , "allControls.csv"))
        allControls <- unique(allControls[, c("targetId", "outcomeId", "nestingId")])
        eonList <- list()
        for (i in 1:nrow(allControls)) {
            eonList[[length(eonList)+1]] <- CaseControl::createExposureOutcomeNestingCohort(exposureId = allControls$targetId[i],
                                                                                            outcomeId = allControls$outcomeId[i],
                                                                                            nestingCohortId = allControls$nestingId[i])
        }
        ccAnalysisListFile <- system.file("settings", "ccAnalysisSettings.txt", package = "PopEstMethodEvaluation")
        ccAnalysisList <- CaseControl::loadCcAnalysisList(ccAnalysisListFile)
        ccResult <- CaseControl::runCcAnalyses(connectionDetails = connectionDetails,
                                               cdmDatabaseSchema = cdmDatabaseSchema,
                                               oracleTempSchema = oracleTempSchema,
                                               exposureTable = "drug_era",
                                               outcomeDatabaseSchema = outcomeDatabaseSchema,
                                               outcomeTable = outcomeTable,
                                               nestingCohortDatabaseSchema = nestingCohortDatabaseSchema,
                                               nestingCohortTable = nestingCohortTable,
                                               ccAnalysisList = ccAnalysisList,
                                               exposureOutcomeNestingCohortList = eonList,
                                               outputFolder = ccFolder,
                                               getDbCaseDataThreads = 1,
                                               selectControlsThreads = min(3, maxCores),
                                               getDbExposureDataThreads = min(3, maxCores),
                                               createCaseControlDataThreads = min(5, maxCores),
                                               fitCaseControlModelThreads = min(5, maxCores),
                                               cvThreads = min(2,maxCores),
                                               prefetchExposureData = TRUE)

        ccSummary <- CaseControl::summarizeCcAnalyses(ccResult)
        saveRDS(ccSummary, ccSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed case-control analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createCaseControlSettings <- function(fileName) {

    getDbCaseDataArgs1 <- CaseControl::createGetDbCaseDataArgs(useNestingCohort = FALSE,
                                                               getVisits = FALSE)

    selectControlsArgs1 <- CaseControl::createSelectControlsArgs(firstOutcomeOnly = FALSE,
                                                                 washoutPeriod = 365,
                                                                 controlsPerCase = 2,
                                                                 matchOnAge = TRUE,
                                                                 ageCaliper = 2,
                                                                 matchOnGender = TRUE,
                                                                 matchOnProvider = FALSE,
                                                                 matchOnVisitDate = FALSE)

    getDbExposureDataArgs <-  CaseControl::createGetDbExposureDataArgs()

    createCaseControlDataArgs1 <- CaseControl::createCreateCaseControlDataArgs(firstExposureOnly = FALSE,
                                                                               riskWindowStart = 0,
                                                                               riskWindowEnd = 0)

    fitCaseControlModelArgs1 <-  CaseControl::createFitCaseControlModelArgs()

    ccAnalysis1 <- CaseControl::createCcAnalysis(analysisId = 1,
                                                 description = "Matching on age and gender, 2 controls per case",
                                                 getDbCaseDataArgs = getDbCaseDataArgs1,
                                                 selectControlsArgs = selectControlsArgs1,
                                                 getDbExposureDataArgs = getDbExposureDataArgs,
                                                 createCaseControlDataArgs = createCaseControlDataArgs1,
                                                 fitCaseControlModelArgs = fitCaseControlModelArgs1)

    selectControlsArgs2 <- CaseControl::createSelectControlsArgs(firstOutcomeOnly = FALSE,
                                                                 washoutPeriod = 365,
                                                                 controlsPerCase = 10,
                                                                 matchOnAge = TRUE,
                                                                 ageCaliper = 2,
                                                                 matchOnGender = TRUE,
                                                                 matchOnProvider = FALSE,
                                                                 matchOnVisitDate = FALSE)

    ccAnalysis2 <- CaseControl::createCcAnalysis(analysisId = 2,
                                                 description = "Matching on age and gender, 10 controls per case",
                                                 getDbCaseDataArgs = getDbCaseDataArgs1,
                                                 selectControlsArgs = selectControlsArgs2,
                                                 getDbExposureDataArgs = getDbExposureDataArgs,
                                                 createCaseControlDataArgs = createCaseControlDataArgs1,
                                                 fitCaseControlModelArgs = fitCaseControlModelArgs1)

    getDbCaseDataArgs2 <- CaseControl::createGetDbCaseDataArgs(useNestingCohort = TRUE,
                                                               getVisits = FALSE)

    # covariateSettings <- FeatureExtraction::createCovariateSettings(useCovariateRiskScores = TRUE,
    #                                                                 useCovariateRiskScoresCharlson = TRUE,
    #                                                                 useCovariateRiskScoresDCSI = TRUE,
    #                                                                 useCovariateRiskScoresCHADS2 = TRUE)
    #
    # getDbExposureDataArgs2 <-  CaseControl::createGetDbExposureDataArgs(covariateSettings = covariateSettings)

    ccAnalysis3 <- CaseControl::createCcAnalysis(analysisId = 3,
                                                 description = "Matching on age and gender, nesting in indication, 2 controls per case",
                                                 getDbCaseDataArgs = getDbCaseDataArgs2,
                                                 selectControlsArgs = selectControlsArgs1,
                                                 getDbExposureDataArgs = getDbExposureDataArgs,
                                                 createCaseControlDataArgs = createCaseControlDataArgs1,
                                                 fitCaseControlModelArgs = fitCaseControlModelArgs1)

    ccAnalysis4 <- CaseControl::createCcAnalysis(analysisId = 4,
                                                 description = "Matching on age and gender, nesting in indication, 10 controls per case",
                                                 getDbCaseDataArgs = getDbCaseDataArgs2,
                                                 selectControlsArgs = selectControlsArgs2,
                                                 getDbExposureDataArgs = getDbExposureDataArgs,
                                                 createCaseControlDataArgs = createCaseControlDataArgs1,
                                                 fitCaseControlModelArgs = fitCaseControlModelArgs1)

    # fitCaseControlModelArgs2 <-  CaseControl::createFitCaseControlModelArgs(useCovariates = TRUE,
    #                                                                         prior = Cyclops::createPrior("none"))
    #
    # ccAnalysis5 <- CaseControl::createCcAnalysis(analysisId = 5,
    #                                              description = "Matching on age and gender, nesting in indication, 2 controls per case, using covars",
    #                                              getDbCaseDataArgs = getDbCaseDataArgs2,
    #                                              selectControlsArgs = selectControlsArgs1,
    #                                              getDbExposureDataArgs = getDbExposureDataArgs2,
    #                                              createCaseControlDataArgs = createCaseControlDataArgs1,
    #                                              fitCaseControlModelArgs = fitCaseControlModelArgs2)
    #
    # ccAnalysis6 <- CaseControl::createCcAnalysis(analysisId = 6,
    #                                              description = "Matching on age and gender, nesting in indication, 10 controls per case, using covars",
    #                                              getDbCaseDataArgs = getDbCaseDataArgs2,
    #                                              selectControlsArgs = selectControlsArgs2,
    #                                              getDbExposureDataArgs = getDbExposureDataArgs2,
    #                                              createCaseControlDataArgs = createCaseControlDataArgs1,
    #                                              fitCaseControlModelArgs = fitCaseControlModelArgs2)

    # selectControlsArgs3 <- CaseControl::createSelectControlsArgs(firstOutcomeOnly = FALSE,
    #                                                              washoutPeriod = 365,
    #                                                              controlsPerCase = 2,
    #                                                              matchOnAge = TRUE,
    #                                                              ageCaliper = 2,
    #                                                              matchOnGender = TRUE,
    #                                                              matchOnProvider = FALSE,
    #                                                              matchOnVisitDate = TRUE,
    #                                                              visitDateCaliper = 30)
    #
    # ccAnalysis7 <- CaseControl::createCcAnalysis(analysisId = 7,
    #                                              description = "Matching on age and gender, nesting in indication, match on visit, 2 controls per case",
    #                                              getDbCaseDataArgs = getDbCaseDataArgs2,
    #                                              selectControlsArgs = selectControlsArgs3,
    #                                              getDbExposureDataArgs = getDbExposureDataArgs2,
    #                                              createCaseControlDataArgs = createCaseControlDataArgs1,
    #                                              fitCaseControlModelArgs = fitCaseControlModelArgs1)

    # selectControlsArgs4 <- CaseControl::createSelectControlsArgs(firstOutcomeOnly = FALSE,
    #                                                              washoutPeriod = 365,
    #                                                              controlsPerCase = 10,
    #                                                              matchOnAge = TRUE,
    #                                                              ageCaliper = 2,
    #                                                              matchOnGender = TRUE,
    #                                                              matchOnProvider = FALSE,
    #                                                              matchOnVisitDate = TRUE,
    #                                                              visitDateCaliper = 30)
    #
    # ccAnalysis8 <- CaseControl::createCcAnalysis(analysisId = 8,
    #                                              description = "Matching on age and gender, nesting in indication, match on visit, 10 controls per case",
    #                                              getDbCaseDataArgs = getDbCaseDataArgs2,
    #                                              selectControlsArgs = selectControlsArgs4,
    #                                              getDbExposureDataArgs = getDbExposureDataArgs2,
    #                                              createCaseControlDataArgs = createCaseControlDataArgs1,
    #                                              fitCaseControlModelArgs = fitCaseControlModelArgs1)
    #
    # ccAnalysis9 <- CaseControl::createCcAnalysis(analysisId = 9,
    #                                              description = "Matching on age and gender, nesting in indication, match on visit, 2 controls per case, using covars",
    #                                              getDbCaseDataArgs = getDbCaseDataArgs2,
    #                                              selectControlsArgs = selectControlsArgs3,
    #                                              getDbExposureDataArgs = getDbExposureDataArgs2,
    #                                              createCaseControlDataArgs = createCaseControlDataArgs1,
    #                                              fitCaseControlModelArgs = fitCaseControlModelArgs2)
    #
    # ccAnalysis10 <- CaseControl::createCcAnalysis(analysisId = 10,
    #                                               description = "Matching on age and gender, nesting in indication, match on visit, 10 controls per case, using covars",
    #                                               getDbCaseDataArgs = getDbCaseDataArgs2,
    #                                               selectControlsArgs = selectControlsArgs4,
    #                                               getDbExposureDataArgs = getDbExposureDataArgs2,
    #                                               createCaseControlDataArgs = createCaseControlDataArgs1,
    #                                               fitCaseControlModelArgs = fitCaseControlModelArgs2)

    # ccAnalysisList <- list(ccAnalysis1, ccAnalysis3, ccAnalysis4, ccAnalysis5, ccAnalysis6, ccAnalysis7, ccAnalysis8, ccAnalysis9, ccAnalysis10)
    ccAnalysisList <- list(ccAnalysis1, ccAnalysis2, ccAnalysis3, ccAnalysis4)

    if (!missing(fileName) && !is.null(fileName)){
        CaseControl::saveCcAnalysisList(ccAnalysisList, fileName)
    }
    invisible(ccAnalysisList)
}
