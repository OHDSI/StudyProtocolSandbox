# @file InjectSignals.R
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
injectSignals <- function(connectionDetails,
                          cdmDatabaseSchema,
                          oracleTempSchema = NULL,
                          outcomeDatabaseSchema = cdmDatabaseSchema,
                          outcomeTable = "cohort",
                          workFolder,
                          maxCores = 1) {
    injectionFolder <- file.path(workFolder, "SignalInjection")
    if (!file.exists(injectionFolder))
        dir.create(injectionFolder)

    injectionSummaryFile <- file.path(workFolder, "injectionSummary.rds")
    if (!file.exists(injectionSummaryFile)) {
        ohdsiNegativeControls <- readRDS(system.file("ohdsiNegativeControls.rds", package = "MethodEvaluation"))
        exposureOutcomePairs <- data.frame(exposureId = ohdsiNegativeControls$targetId,
                                           outcomeId = ohdsiNegativeControls$outcomeId)
        exposureOutcomePairs <- unique(exposureOutcomePairs)
        #
        # connection <- DatabaseConnector::connect(connectionDetails)
        # sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @resultsDatabaseSchema.@outcomeTable GROUP BY cohort_definition_id"
        # sql <- SqlRender::renderSql(sql, resultsDatabaseSchema = outcomeDatabaseSchema, outcomeTable = outcomeTable)$sql
        # sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
        # print(DatabaseConnector::querySql(connection, sql))
        # dbDisconnect(connection)

        prior = Cyclops::createPrior("laplace", exclude = 0, useCrossValidation = TRUE)

        control = Cyclops::createControl(cvType = "auto",
                                         startingVariance = 0.01,
                                         noiseLevel = "quiet",
                                         cvRepetitions = 1,
                                         threads = min(c(10, maxCores)))

        covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsAgeGroup = TRUE,
                                                                        useDemographicsGender = TRUE,
                                                                        useDemographicsIndexYear = TRUE,
                                                                        useDemographicsIndexMonth = TRUE,
                                                                        useConditionGroupEraLongTerm = TRUE,
                                                                        useDrugGroupEraLongTerm = TRUE,
                                                                        useProcedureOccurrenceLongTerm = TRUE,
                                                                        useMeasurementLongTerm = TRUE,
                                                                        useObservationLongTerm = TRUE,
                                                                        useCharlsonIndex = TRUE,
                                                                        useDcsi = TRUE,
                                                                        useChads2Vasc = TRUE,
                                                                        longTermStartDays = 365,
                                                                        endDays = 0)

        result <- MethodEvaluation::injectSignals(connectionDetails,
                                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                                  oracleTempSchema = oracleTempSchema,
                                                  exposureDatabaseSchema = cdmDatabaseSchema,
                                                  exposureTable = "drug_era",
                                                  outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                  outcomeTable = outcomeTable,
                                                  outputDatabaseSchema = outcomeDatabaseSchema,
                                                  outputTable = outcomeTable,
                                                  createOutputTable = FALSE,
                                                  outputIdOffset = 10000,
                                                  exposureOutcomePairs = exposureOutcomePairs,
                                                  firstExposureOnly = FALSE,
                                                  firstOutcomeOnly = TRUE,
                                                  removePeopleWithPriorOutcomes = TRUE,
                                                  modelType = "survival",
                                                  washoutPeriod = 365,
                                                  riskWindowStart = 0,
                                                  riskWindowEnd = 0,
                                                  addExposureDaysToEnd = TRUE,
                                                  effectSizes = c(1.5, 2, 4),
                                                  precision = 0.01,
                                                  prior = prior,
                                                  control = control,
                                                  maxSubjectsForModel = 250000,
                                                  minOutcomeCountForModel = 100,
                                                  minOutcomeCountForInjection = 25,
                                                  workFolder = injectionFolder,
                                                  modelThreads = max(1, round(maxCores/8)),
                                                  generationThreads = min(6, maxCores),
                                                  covariateSettings = covariateSettings)
        saveRDS(result, injectionSummaryFile)
    }
    ohdsiNegativeControls <- readRDS(system.file("ohdsiNegativeControls.rds", package = "MethodEvaluation"))
    injectedSignals <- readRDS(injectionSummaryFile)
    injectedSignals$targetId <- injectedSignals$exposureId
    injectedSignals <- merge(injectedSignals, ohdsiNegativeControls)
    injectedSignals <- injectedSignals[injectedSignals$trueEffectSize != 0, ]
    injectedSignals$outcomeName <- paste0(injectedSignals$outcomeName, ", RR=", injectedSignals$targetEffectSize)
    injectedSignals$oldOutcomeId <- injectedSignals$outcomeId
    injectedSignals$outcomeId <- injectedSignals$newOutcomeId
    ohdsiNegativeControls$targetEffectSize <- 1
    ohdsiNegativeControls$trueEffectSize <- 1
    ohdsiNegativeControls$trueEffectSizeFirstExposure <- 1
    ohdsiNegativeControls$oldOutcomeId <- ohdsiNegativeControls$outcomeId
    allControls <- rbind(ohdsiNegativeControls, injectedSignals[, names(ohdsiNegativeControls)])
    exposureOutcomes <- data.frame()
    exposureOutcomes <- rbind(exposureOutcomes, data.frame(exposureId = allControls$targetId,
                                                           outcomeId = allControls$outcomeId))
    exposureOutcomes <- rbind(exposureOutcomes, data.frame(exposureId = allControls$comparatorId,
                                                           outcomeId = allControls$outcomeId))
    exposureOutcomes <- unique(exposureOutcomes)
    mdrr <- MethodEvaluation::computeMdrr(connectionDetails = connectionDetails,
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          oracleTempSchema = oracleTempSchema,
                                          exposureOutcomePairs = exposureOutcomes,
                                          exposureDatabaseSchema = cdmDatabaseSchema,
                                          exposureTable = "drug_era",
                                          outcomeDatabaseSchema = outcomeDatabaseSchema,
                                          outcomeTable = outcomeTable,
                                          cdmVersion = cdmVersion)
    allControls <- merge(allControls, data.frame(targetId = mdrr$exposureId,
                                                 outcomeId = mdrr$outcomeId,
                                                 mdrrTarget = mdrr$mdrr))
    allControls <- merge(allControls,
                         data.frame(comparatorId = mdrr$exposureId,
                                    outcomeId = mdrr$outcomeId,
                                    mdrrComparator = mdrr$mdrr),
                         all.x = TRUE)
    write.csv(allControls, file.path(workFolder, "allControls.csv"), row.names = FALSE)
}
