# @file SelfControlledCaseSeries.R
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
runSelfControlledCaseSeries <- function(connectionDetails,
                                        cdmDatabaseSchema,
                                        oracleTempSchema = NULL,
                                        outcomeDatabaseSchema = cdmDatabaseSchema,
                                        outcomeTable = "cohort",
                                        workFolder,
                                        cdmVersion = "5") {
    start <- Sys.time()
    sccsFolder <- file.path(workFolder, "selfControlledCaseSeries")
    if (!file.exists(sccsFolder))
        dir.create(sccsFolder)

    sccsSummaryFile <- file.path(workFolder, "sccsSummary.rds")
    if (!file.exists(sccsSummaryFile)) {
        allControls <- read.csv(file.path(workFolder , "allControls.csv"))
        allControls <- unique(allControls[, c("targetId", "outcomeId")])
        eoList <- list()
        for (i in 1:nrow(allControls)) {
            eoList[[length(eoList)+1]] <- SelfControlledCaseSeries::createExposureOutcome(exposureId = allControls$targetId[i],
                                                                                            outcomeId = allControls$outcomeId[i])
        }
        sccsAnalysisListFile <- system.file("settings", "sccsAnalysisSettings.txt", package = "PopEstMethodEvaluation")
        sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
        sccsResult <- SelfControlledCaseSeries::runSccsAnalyses(connectionDetails = connectionDetails,
                                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                                oracleTempSchema = oracleTempSchema,
                                                                exposureTable = "drug_era",
                                                                outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                                outcomeTable = outcomeTable,
                                                                sccsAnalysisList = sccsAnalysisList,
                                                                exposureOutcomeList = eoList,
                                                                cdmVersion = cdmVersion,
                                                                outputFolder = sccsFolder,
                                                                combineDataFetchAcrossOutcomes = TRUE,
                                                                compressSccsEraDataFiles = FALSE,
                                                                getDbSccsDataThreads = 1,
                                                                createSccsEraDataThreads = 5,
                                                                fitSccsModelThreads = 6,
                                                                cvThreads = 10)

        sccsSummary <- SelfControlledCaseSeries::summarizeSccsAnalyses(sccsResult)
        saveRDS(sccsSummary, sccsSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed SCCS analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createSccsSettings <- function(fileName) {

    getDbSccsDataArgs1 <- SelfControlledCaseSeries::createGetDbSccsDataArgs(useCustomCovariates = FALSE,
                                                                            deleteCovariatesSmallCount = 100,
                                                                            studyStartDate = "",
                                                                            studyEndDate = "",
                                                                            exposureIds = c(),
                                                                            maxCasesPerOutcome = 250000)

    covarExposureOfInt <- SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                            includeCovariateIds = "exposureId",
                                                                            start = 0,
                                                                            end = 0,
                                                                            addExposedDaysToEnd = TRUE)

    createSccsEraDataArgs1 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
                                                                                    firstOutcomeOnly = FALSE,
                                                                                    covariateSettings = covarExposureOfInt)

    fitSccsModelArgs1 <- SelfControlledCaseSeries::createFitSccsModelArgs()

    sccsAnalysis1 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 1,
                                                                  description = "Simple SCCS",
                                                                  getDbSccsDataArgs = getDbSccsDataArgs1,
                                                                  createSccsEraDataArgs = createSccsEraDataArgs1,
                                                                  fitSccsModelArgs = fitSccsModelArgs1)

    covarPreExposure = SelfControlledCaseSeries::createCovariateSettings(label = "Pre-exposure",
                                                                         includeCovariateIds = "exposureId",
                                                                         start = -60,
                                                                         end = -1,
                                                                         splitPoints = c(-30))

    createSccsEraDataArgs2 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
                                                                                    firstOutcomeOnly = FALSE,
                                                                                    covariateSettings = list(covarExposureOfInt,
                                                                                                             covarPreExposure))

    sccsAnalysis2 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 2,
                                                                  description = "Using pre-exposure window",
                                                                  getDbSccsDataArgs = getDbSccsDataArgs1,
                                                                  createSccsEraDataArgs = createSccsEraDataArgs2,
                                                                  fitSccsModelArgs = fitSccsModelArgs1)

    ageSettings <- SelfControlledCaseSeries::createAgeSettings(includeAge = TRUE, ageKnots = 5)

    seasonalitySettings <- SelfControlledCaseSeries::createSeasonalitySettings(includeSeasonality = TRUE, seasonKnots = 5)

    createSccsEraDataArgs3 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
                                                                                    firstOutcomeOnly = FALSE,
                                                                                    covariateSettings = covarExposureOfInt,
                                                                                    ageSettings = ageSettings,
                                                                                    seasonalitySettings = seasonalitySettings,
                                                                                    minCasesForAgeSeason = 10000)

    sccsAnalysis3 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 3,
                                                                  description = "Using age and season",
                                                                  getDbSccsDataArgs = getDbSccsDataArgs1,
                                                                  createSccsEraDataArgs = createSccsEraDataArgs3,
                                                                  fitSccsModelArgs = fitSccsModelArgs1)

    createSccsEraDataArgs4 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
                                                                                    firstOutcomeOnly = FALSE,
                                                                                    covariateSettings = covarExposureOfInt,
                                                                                    eventDependentObservation = TRUE)

    sccsAnalysis4 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 4,
                                                                  description = "Using event-dependent observation",
                                                                  getDbSccsDataArgs = getDbSccsDataArgs1,
                                                                  createSccsEraDataArgs = createSccsEraDataArgs4,
                                                                  fitSccsModelArgs = fitSccsModelArgs1)

    covarAllDrugs = SelfControlledCaseSeries::createCovariateSettings(label = "All other exposures",
                                                                      excludeCovariateIds = "exposureId",
                                                                      stratifyById = TRUE,
                                                                      start = 1,
                                                                      end = 0,
                                                                      addExposedDaysToEnd = TRUE,
                                                                      allowRegularization = TRUE)

    createSccsEraDataArgs5 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(naivePeriod = 365,
                                                                                    firstOutcomeOnly = FALSE,
                                                                                    covariateSettings = list(covarExposureOfInt,
                                                                                                             covarAllDrugs))
    prior = Cyclops::createPrior("laplace", useCrossValidation = TRUE)
    control = Cyclops::createControl(cvType = "auto",
                                     selectorType = "byPid",
                                     startingVariance = 0.01,
                                     noiseLevel = "quiet",
                                     tolerance = 2e-07)
    fitSccsModelArgs2 <- SelfControlledCaseSeries::createFitSccsModelArgs(prior = prior, control = control)

    sccsAnalysis5 <- SelfControlledCaseSeries::createSccsAnalysis(analysisId = 5,
                                                                  description = "Using all other exposures",
                                                                  getDbSccsDataArgs = getDbSccsDataArgs1,
                                                                  createSccsEraDataArgs = createSccsEraDataArgs5,
                                                                  fitSccsModelArgs = fitSccsModelArgs2)

    sccsAnalysisList <- list(sccsAnalysis1, sccsAnalysis2, sccsAnalysis3, sccsAnalysis4, sccsAnalysis5)

    if (!missing(fileName) && !is.null(fileName)){
        SelfControlledCaseSeries::saveSccsAnalysisList(sccsAnalysisList, fileName)
    }
    invisible(sccsAnalysisList)
}
