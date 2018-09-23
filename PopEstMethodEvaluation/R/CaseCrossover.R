# @file CaseCrossover.R
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
runCaseCrossover <- function(connectionDetails,
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
        stop("The CaseCrossover package does not support CDM version 4")
    start <- Sys.time()

    ccrFolder <- file.path(workFolder, "caseCrossover")
    if (!file.exists(ccrFolder))
        dir.create(ccrFolder)

    ccrSummaryFile <- file.path(workFolder, "ccrSummary.rds")
    if (!file.exists(ccrSummaryFile)) {
        allControls <- read.csv(file.path(workFolder , "allControls.csv"))
        allControls <- unique(allControls[, c("targetId", "outcomeId", "nestingId")])
        eonList <- list()
        for (i in 1:nrow(allControls)) {
            eonList[[length(eonList)+1]] <- CaseCrossover::createExposureOutcomeNestingCohort(exposureId = allControls$targetId[i],
                                                                                            outcomeId = allControls$outcomeId[i],
                                                                                            nestingCohortId = allControls$nestingId[i])
        }
        ccrAnalysisListFile <- system.file("settings", "ccrAnalysisSettings.txt", package = "PopEstMethodEvaluation")
        ccrAnalysisList <- CaseCrossover::loadCcrAnalysisList(ccrAnalysisListFile)
        ccrResult <- CaseCrossover::runCcrAnalyses(connectionDetails = connectionDetails,
                                                   cdmDatabaseSchema = cdmDatabaseSchema,
                                                   oracleTempSchema = oracleTempSchema,
                                                   exposureTable = "drug_era",
                                                   outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                   outcomeTable = outcomeTable,
                                                   nestingCohortDatabaseSchema = nestingCohortDatabaseSchema,
                                                   nestingCohortTable = nestingCohortTable,
                                                   ccrAnalysisList = ccrAnalysisList,
                                                   exposureOutcomeNestingCohortList = eonList,
                                                   outputFolder = ccrFolder,
                                                   getDbCaseCrossoverDataThreads = 1,
                                                   selectSubjectsToIncludeThreads = min(5, maxCores),
                                                   getExposureStatusThreads = min(5, maxCores),
                                                   fitCaseCrossoverModelThreads = min(5, maxCores))
        ccrSummary <- CaseCrossover::summarizeCcrAnalyses(ccrResult)
        saveRDS(ccrSummary, ccrSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed case-crossover analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createCaseCrossoverSettings <- function(fileName) {
    getDbCaseCrossoverDataArgs1 <- CaseCrossover::createGetDbCaseCrossoverDataArgs(useNestingCohort = FALSE)

    selectSubjectsToIncludeArgs1 <- CaseCrossover::createSelectSubjectsToIncludeArgs(firstOutcomeOnly = FALSE,
                                                                                     washoutPeriod = 180)

    getExposureStatusArgs1 <- CaseCrossover::createGetExposureStatusArgs(firstExposureOnly = FALSE,
                                                                         riskWindowStart = 0,
                                                                         riskWindowEnd = 0,
                                                                         controlWindowOffsets = -30)

    ccrAnalysis1 <- CaseCrossover::createCcrAnalysis(analysisId = 1,
                                                     description = "Simple case-crossover",
                                                     getDbCaseCrossoverDataArgs = getDbCaseCrossoverDataArgs1,
                                                     selectSubjectsToIncludeArgs = selectSubjectsToIncludeArgs1,
                                                     getExposureStatusArgs = getExposureStatusArgs1)

    getDbCaseCrossoverDataArgs2 <- CaseCrossover::createGetDbCaseCrossoverDataArgs(useNestingCohort = TRUE,
                                                                                   getTimeControlData = TRUE)

    ccrAnalysis2 <- CaseCrossover::createCcrAnalysis(analysisId = 2,
                                                     description = "Nested case-crossover",
                                                     getDbCaseCrossoverDataArgs = getDbCaseCrossoverDataArgs2,
                                                     selectSubjectsToIncludeArgs = selectSubjectsToIncludeArgs1,
                                                     getExposureStatusArgs = getExposureStatusArgs1)

    matchingCriteria1 <- CaseCrossover::createMatchingCriteria(matchOnAge = TRUE,
                                                               ageCaliper = 2,
                                                               matchOnGender = TRUE)

    selectSubjectsToIncludeArgs2 <- CaseCrossover::createSelectSubjectsToIncludeArgs(firstOutcomeOnly = FALSE,
                                                                                     washoutPeriod = 180,
                                                                                     matchingCriteria = matchingCriteria1)

    ccrAnalysis3 <- CaseCrossover::createCcrAnalysis(analysisId = 3,
                                                     description = "Nested case-time-control, matching on age and gender",
                                                     getDbCaseCrossoverDataArgs = getDbCaseCrossoverDataArgs2,
                                                     selectSubjectsToIncludeArgs = selectSubjectsToIncludeArgs2,
                                                     getExposureStatusArgs = getExposureStatusArgs1)

    matchingCriteria2 <- CaseCrossover::createMatchingCriteria(matchOnAge = TRUE,
                                                               ageCaliper = 2,
                                                               matchOnGender = TRUE,
                                                               matchOnVisitDate = TRUE)

    selectSubjectsToIncludeArgs3 <- CaseCrossover::createSelectSubjectsToIncludeArgs(firstOutcomeOnly = FALSE,
                                                                                     washoutPeriod = 180,
                                                                                     matchingCriteria = matchingCriteria2)

    ccrAnalysisList <- list(ccrAnalysis1, ccrAnalysis2, ccrAnalysis3)

    if (!missing(fileName) && !is.null(fileName)){
        CaseCrossover::saveCcrAnalysisList(ccrAnalysisList, fileName)
    }
    invisible(ccrAnalysisList)
}
