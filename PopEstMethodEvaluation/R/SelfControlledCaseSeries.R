# @file SelfControlledCaseSeries.R
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
runSelfControlledCaseSeries <- function(connectionDetails,
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

    sccsFolder <- file.path(workFolder, "selfControlledCaseSeries")
    if (!file.exists(sccsFolder))
        dir.create(sccsFolder)

    sccsSummaryFile <- file.path(workFolder, "sccsSummary.rds")
    if (!file.exists(sccsSummaryFile)) {
        exposureOutcomePairs <- injectedSignals[injectedSignals$trueEffectSize != 0, c("exposureId", "newOutcomeId")]
        colnames(exposureOutcomePairs)[colnames(exposureOutcomePairs) == "newOutcomeId"] <- "outcomeId"

        analysisIds <- 1:5
        result <- data.frame(exposureId = rep(exposureOutcomePairs$exposureId, length(analysisIds)),
                             outcomeId = rep(exposureOutcomePairs$outcomeId, length(analysisIds)),
                             analysisId = rep(analysisIds, each = nrow(exposureOutcomePairs)))
        result$logRr <- NA
        result$seLogRr <- NA
        result$description <- NA

        sccsDataFile <- file.path(sccsFolder, "sccsData")
        if (file.exists(sccsFolder)) {
            sccsData <- SelfControlledCaseSeries::loadSccsData(sccsDataFile)
        } else {
            sccsData <- SelfControlledCaseSeries::getDbSccsData(connectionDetails = connectionDetails,
                                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                                oracleTempSchema = oracleTempSchema,
                                                                exposureTable = "drug_era",
                                                                outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                                outcomeTable = outcomeTable,
                                                                outcomeIds = result$outcomeId,
                                                                cdmVersion = cdmVersion)

            SelfControlledCaseSeries::saveSccsData(sccsData, sccsDataFile)
        }

        for (i in 1:nrow(exposureOutcomePairs)) {
            # i <- 1
            exposureId <- exposureOutcomePairs$exposureId[i]
            outcomeId <- exposureOutcomePairs$outcomeId[i]
            writeLines(paste0("Running analyses for exposure ", exposureId, " and outcome ", outcomeId))


            ### Analysis 1: simplest SCCS ###
            analysisFolder <- file.path(sccsFolder, "Analysis_1")
            if (!file.exists(analysisFolder))
                dir.create(analysisFolder)
            sccsEraDataFile <- file.path(analysisFolder, paste0("sccsEraData_e", exposureId, "_o",outcomeId))
            if (file.exists(sccsEraDataFile)) {
                sccsEraData <- SelfControlledCaseSeries::loadSccsEraData(sccsEraDataFile)
            } else {
                covariateSettings = SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                                      includeCovariateIds = exposureId,
                                                                                      start = 0,
                                                                                      end = 0,
                                                                                      addExposedDaysToEnd = TRUE)
                sccsEraData <- SelfControlledCaseSeries::createSccsEraData(sccsData = sccsData,
                                                                           outcomeId = outcomeId,
                                                                           naivePeriod = 180,
                                                                           firstOutcomeOnly = FALSE,
                                                                           covariateSettings = covariateSettings)
                SelfControlledCaseSeries::saveSccsEraData(sccsEraData, sccsEraDataFile)
            }
            outcomeModelFile <- file.path(analysisFolder, paste0("outcomeModel_e", exposureId, "_o",outcomeId, ".rds"))
            if (file.exists(outcomeModelFile)) {
                outcomeModel <- readRDS(outcomeModelFile)
            } else {
                outcomeModel <- SelfControlledCaseSeries::fitSccsModel(sccsEraData, control = Cyclops::createControl(threads = 2))
                saveRDS(outcomeModel, outcomeModelFile)
            }
            idx <- result$exposureId == exposureId & result$outcomeId == outcomeId & result$analysisId == 1
            result$logRr[idx] <- outcomeModel$estimates$logRr[1]
            result$seLogRr[idx] <- outcomeModel$estimates$seLogRr[1]
            result$description[idx] <- "Simple SCCS"

            ### Analysis 2: adding pre-exposure window ###
            analysisFolder <- file.path(sccsFolder, "Analysis_2")
            if (!file.exists(analysisFolder))
                dir.create(analysisFolder)
            sccsEraDataFile <- file.path(analysisFolder, paste0("sccsEraData_e", exposureId, "_o",outcomeId))
            if (file.exists(sccsEraDataFile)) {
                sccsEraData <- SelfControlledCaseSeries::loadSccsEraData(sccsEraDataFile)
            } else {
                covariateSettings = SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                                      includeCovariateIds = exposureId,
                                                                                      start = 0,
                                                                                      end = 0,
                                                                                      addExposedDaysToEnd = TRUE)
                covarPreExposure = SelfControlledCaseSeries::createCovariateSettings(label = "Pre-exposure",
                                                                                     includeCovariateIds = exposureId,
                                                                                     start = -60,
                                                                                     end = -1,
                                                                                     splitPoints = c(-30))
                sccsEraData <- SelfControlledCaseSeries::createSccsEraData(sccsData = sccsData,
                                                                           outcomeId = outcomeId,
                                                                           naivePeriod = 180,
                                                                           firstOutcomeOnly = FALSE,
                                                                           covariateSettings = list(covariateSettings,covarPreExposure))
                SelfControlledCaseSeries::saveSccsEraData(sccsEraData, sccsEraDataFile)
            }
            outcomeModelFile <- file.path(analysisFolder, paste0("outcomeModel_e", exposureId, "_o",outcomeId, ".rds"))
            if (file.exists(outcomeModelFile)) {
                outcomeModel <- readRDS(outcomeModelFile)
            } else {
                outcomeModel <- SelfControlledCaseSeries::fitSccsModel(sccsEraData, control = Cyclops::createControl(threads = 6))
                saveRDS(outcomeModel, outcomeModelFile)
            }
            idx <- result$exposureId == exposureId & result$outcomeId == outcomeId & result$analysisId == 2
            result$logRr[idx] <- outcomeModel$estimates$logRr[1]
            result$seLogRr[idx] <- outcomeModel$estimates$seLogRr[1]
            result$description[idx] <- "Using pre-exposure window"

            ### Analysis 3: Adding age and seasonality ###
            analysisFolder <- file.path(sccsFolder, "Analysis_3")
            if (!file.exists(analysisFolder))
                dir.create(analysisFolder)
            sccsEraDataFile <- file.path(analysisFolder, paste0("sccsEraData_e", exposureId, "_o",outcomeId))
            if (file.exists(sccsEraDataFile)) {
                sccsEraData <- SelfControlledCaseSeries::loadSccsEraData(sccsEraDataFile)
            } else {
                covariateSettings = SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                                      includeCovariateIds = exposureId,
                                                                                      start = 0,
                                                                                      end = 0,
                                                                                      addExposedDaysToEnd = TRUE)
                ageSettings <- SelfControlledCaseSeries::createAgeSettings(includeAge = TRUE, ageKnots = 5)
                seasonalitySettings <- SelfControlledCaseSeries::createSeasonalitySettings(includeSeasonality = TRUE, seasonKnots = 5)
                sccsEraData <- SelfControlledCaseSeries::createSccsEraData(sccsData = sccsData,
                                                                           outcomeId = outcomeId,
                                                                           naivePeriod = 180,
                                                                           firstOutcomeOnly = FALSE,
                                                                           covariateSettings = covariateSettings,
                                                                           ageSettings = ageSettings,
                                                                           seasonalitySettings = seasonalitySettings)
                SelfControlledCaseSeries::saveSccsEraData(sccsEraData, sccsEraDataFile)
            }
            outcomeModelFile <- file.path(analysisFolder, paste0("outcomeModel_e", exposureId, "_o",outcomeId, ".rds"))
            if (file.exists(outcomeModelFile)) {
                outcomeModel <- readRDS(outcomeModelFile)
            } else {
                outcomeModel <- SelfControlledCaseSeries::fitSccsModel(sccsEraData, control = Cyclops::createControl(threads = 16))
                saveRDS(outcomeModel, outcomeModelFile)
            }
            idx <- result$exposureId == exposureId & result$outcomeId == outcomeId & result$analysisId == 3
            result$logRr[idx] <- outcomeModel$estimates$logRr[9]
            result$seLogRr[idx] <- outcomeModel$estimates$seLogRr[9]
            result$description[idx] <- "Using age and season"

            ### Analysis 4: Adding event-dependent observation ###
            if (outcomeId != 1066 && outcomeId != 1068 && outcomeId != 1069 && !(outcomeId %in% 1116:1119) && outcomeId < 1125) {
                analysisFolder <- file.path(sccsFolder, "Analysis_4")
                if (!file.exists(analysisFolder))
                    dir.create(analysisFolder)
                sccsEraDataFile <- file.path(analysisFolder, paste0("sccsEraData_e", exposureId, "_o",outcomeId))
                if (file.exists(sccsEraDataFile)) {
                    sccsEraData <- SelfControlledCaseSeries::loadSccsEraData(sccsEraDataFile)
                } else {
                    covariateSettings = SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                                          includeCovariateIds = exposureId,
                                                                                          start = 0,
                                                                                          end = 0,
                                                                                          addExposedDaysToEnd = TRUE)
                    sccsEraData <- SelfControlledCaseSeries::createSccsEraData(sccsData = sccsData,
                                                                               outcomeId = outcomeId,
                                                                               naivePeriod = 180,
                                                                               firstOutcomeOnly = FALSE,
                                                                               covariateSettings = covariateSettings,
                                                                               eventDependentObservation = TRUE)
                    SelfControlledCaseSeries::saveSccsEraData(sccsEraData, sccsEraDataFile)
                }
                outcomeModelFile <- file.path(analysisFolder, paste0("outcomeModel_e", exposureId, "_o",outcomeId, ".rds"))
                if (file.exists(outcomeModelFile)) {
                    outcomeModel <- readRDS(outcomeModelFile)
                } else {
                    outcomeModel <- SelfControlledCaseSeries::fitSccsModel(sccsEraData, control = Cyclops::createControl(threads = 16))
                    saveRDS(outcomeModel, outcomeModelFile)
                }
                idx <- result$exposureId == exposureId & result$outcomeId == outcomeId & result$analysisId == 4
                result$logRr[idx] <- outcomeModel$estimates$logRr[1]
                result$seLogRr[idx] <- outcomeModel$estimates$seLogRr[1]
                result$description[idx] <- "Using event-dependent observation"
            }
            ### Analysis 5: MSCCS ###
            analysisFolder <- file.path(sccsFolder, "Analysis_5")
            if (!file.exists(analysisFolder))
                dir.create(analysisFolder)
            sccsEraDataFile <- file.path(analysisFolder, paste0("sccsEraData_e", exposureId, "_o",outcomeId))
            if (file.exists(sccsEraDataFile)) {
                sccsEraData <- SelfControlledCaseSeries::loadSccsEraData(sccsEraDataFile)
            } else {
                covariateSettings = SelfControlledCaseSeries::createCovariateSettings(label = "Exposure of interest",
                                                                                      includeCovariateIds = exposureId,
                                                                                      start = 0,
                                                                                      end = 0,
                                                                                      addExposedDaysToEnd = TRUE)
                covarAllDrugs = SelfControlledCaseSeries::createCovariateSettings(label = "All other exposures",
                                                                                  excludeCovariateIds = exposureId,
                                                                                  stratifyById = TRUE,
                                                                                  start = 1,
                                                                                  end = 0,
                                                                                  addExposedDaysToEnd = TRUE,
                                                                                  allowRegularization = TRUE)
                sccsEraData <- SelfControlledCaseSeries::createSccsEraData(sccsData = sccsData,
                                                                           outcomeId = outcomeId,
                                                                           naivePeriod = 180,
                                                                           firstOutcomeOnly = FALSE,
                                                                           covariateSettings = list(covariateSettings, covarAllDrugs))
                SelfControlledCaseSeries::saveSccsEraData(sccsEraData, sccsEraDataFile)
            }
            outcomeModelFile <- file.path(analysisFolder, paste0("outcomeModel_e", exposureId, "_o",outcomeId, ".rds"))
            if (file.exists(outcomeModelFile)) {
                outcomeModel <- readRDS(outcomeModelFile)
            } else {
                prior = Cyclops::createPrior("laplace", useCrossValidation = TRUE)
                control = Cyclops::createControl(cvType = "auto",
                                                 selectorType = "byPid",
                                                 startingVariance = 0.01,
                                                 noiseLevel = "quiet",
                                                 tolerance = 2e-07,
                                                 threads = 16)
                outcomeModel <- SelfControlledCaseSeries::fitSccsModel(sccsEraData, prior = prior, control = control)
                saveRDS(outcomeModel, outcomeModelFile)
            }
            idx <- result$exposureId == exposureId & result$outcomeId == outcomeId & result$analysisId == 5
            result$logRr[idx] <- outcomeModel$estimates$logRr[outcomeModel$estimates$originalCovariateId == exposureId]
            result$seLogRr[idx] <- outcomeModel$estimates$seLogRr[outcomeModel$estimates$originalCovariateId == exposureId]
            result$description[idx] <- "MSCCS"
        }
        saveRDS(result, sccsSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed SCCS analyses in", signif(delta, 3), attr(delta, "units")))
}
