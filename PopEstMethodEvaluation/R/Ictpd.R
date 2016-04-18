# @file Ictpd.R
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
runIctpd <- function(connectionDetails,
                     cdmDatabaseSchema,
                     oracleTempSchema = NULL,
                     outcomeDatabaseSchema = cdmDatabaseSchema,
                     outcomeTable = "cohort",
                     workFolder,
                     cdmVersion = "5") {
    start <- Sys.time()
    injectionSummaryFile <- file.path(workFolder, "injectionSummary.rds")
    if (!file.exists(injectionSummaryFile))
        stop("Cannot find injection summary file. Please run injectSignals first.")
    injectedSignals <- readRDS(injectionSummaryFile)

    ictpdFolder <- file.path(workFolder, "ICTemporalPatternDiscovery")
    if (!file.exists(ictpdFolder))
        dir.create(ictpdFolder)

    ictpdSummaryFile <- file.path(workFolder, "ictpdSummary.rds")
    if (!file.exists(ictpdSummaryFile)) {
        eoList <- list()
        for (i in 1:nrow(injectedSignals)) {
            if (injectedSignals$trueEffectSize[i] != 0) {
                eoList[[length(eoList)+1]] <- IcTemporalPatternDiscovery::createExposureOutcome(exposureId = injectedSignals$exposureId[i],
                                                                                                outcomeId = injectedSignals$newOutcomeId[i])
            }
        }
        ictpdAnalysisListFile <- system.file("settings", "ictpdAnalysisSettings.txt", package = "PopEstMethodEvaluation")
        ictpdAnalysisList <- IcTemporalPatternDiscovery::loadIctpdAnalysisList(ictpdAnalysisListFile)
        ictpResult <- IcTemporalPatternDiscovery::runIctpdAnalyses(connectionDetails = connectionDetails,
                                                                   cdmDatabaseSchema = cdmDatabaseSchema,
                                                                   oracleTempSchema = oracleTempSchema,
                                                                   exposureTable = "drug_era",
                                                                   outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                                   outcomeTable = outcomeTable,
                                                                   ictpdAnalysisList = ictpdAnalysisList,
                                                                   exposureOutcomeList = eoList,
                                                                   cdmVersion = cdmVersion,
                                                                   outputFolder = ictpdFolder,
                                                                   getDbIctpdDataThreads = 1,
                                                                   calculateStatisticsIcThreads = 1)
        sccSummary <- SelfControlledCohort::summarizeAnalyses(sccResult)
        saveRDS(sccSummary, sccSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed SelfControlledCohort analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createIctpdSettings <- function(fileName) {

    getDbIctpdDataArgs1 <- IcTemporalPatternDiscovery::createGetDbIctpdDataArgs(censor = TRUE)
    getDbIctpdDataArgs2 <- IcTemporalPatternDiscovery::createGetDbIctpdDataArgs(censor = FALSE)
    calculateStatisticsIcArgs <- IcTemporalPatternDiscovery::createCalculateStatisticsIcArgs()
    analysis1 <- IcTemporalPatternDiscovery::createIctpdAnalysis(analysisId = 1,
                                                                 description = "Using censoring",
                                                                 getDbIctpdDataArgs = getDbIctpdDataArgs1,
                                                                 calculateStatisticsIcArgs = calculateStatisticsIcArgs)
    analysis2 <- IcTemporalPatternDiscovery::createIctpdAnalysis(analysisId = 2,
                                                                 description = "No censoring",
                                                                 getDbIctpdDataArgs = getDbIctpdDataArgs2,
                                                                 calculateStatisticsIcArgs = calculateStatisticsIcArgs)
    ictpdAnalysisList <- list(analysis1, analysis2)

    if (!missing(fileName) && !is.null(fileName)){
        IcTemporalPatternDiscovery::saveIctpdAnalysisList(ictpdAnalysisList, fileName)
    }
    invisible(ictpdAnalysisList)
}
