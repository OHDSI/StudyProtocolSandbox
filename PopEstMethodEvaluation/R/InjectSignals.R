# @file InjectSignals.R
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
injectSignals <- function(connectionDetails,
                          cdmDatabaseSchema,
                          oracleTempSchema = NULL,
                          outcomeDatabaseSchema = cdmDatabaseSchema,
                          outcomeTable = "cohort",
                          workFolder,
                          cdmVersion = "5",
                          createBaselineCohorts = TRUE) {
    injectionFolder <- file.path(workFolder, "SignalInjection")
    if (!file.exists(injectionFolder))
        dir.create(injectionFolder)

    injectionSummaryFile <- file.path(workFolder, "injectionSummary.rds")
    if (!file.exists(injectionSummaryFile)) {
        if (createBaselineCohorts) {
            connection <- DatabaseConnector::connect(connectionDetails)

            sql <- loadRenderTranslateSql("CreateNegativeControlOutcomes",
                                          packageName = "MethodEvaluation",
                                          dbms = connectionDetails$dbms,
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          resultsDatabaseSchema = outcomeDatabaseSchema,
                                          outcomeTable = outcomeTable)
            if (cdmVersion == "4"){
                sql <- gsub("cohort_definition_id", "cohort_concept_id", sql)
                sql <- gsub("visit_concept_id", "place_of_service_concept_id", sql)
            }

            DatabaseConnector::executeSql(connection, sql)

            # Check number of subjects per cohort:
            sql <- "SELECT cohort_concept_id, COUNT(*) AS count FROM @resultsDatabaseSchema.@outcomeTable GROUP BY cohort_concept_id"
            sql <- SqlRender::renderSql(sql, resultsDatabaseSchema = outcomeDatabaseSchema, outcomeTable = outcomeTable)$sql
            sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
            if (cdmVersion != "4"){
                sql <- gsub("cohort_definition_id", "cohort_concept_id", sql)
            }
            print(DatabaseConnector::querySql(connection, sql))
            dbDisconnect(connection)
        }
        #Diclofenac and all negative control outcomes:
        exposureOutcomePairs <- data.frame(exposureId = 1124300,
                                           outcomeId = c(24609, 29735, 73754, 80004, 134718, 139099, 141932, 192367, 193739, 194997, 197236, 199074, 255573, 257007, 313459, 314658, 316084, 319843, 321596, 374366, 375292, 380094, 433753, 433811, 436665, 436676, 436940, 437784, 438134, 440358, 440374, 443617, 443800, 4084966, 4288310))

        prior = Cyclops::createPrior("laplace", exclude = 0, useCrossValidation = TRUE)

        control = Cyclops::createControl(cvType = "auto",
                                         startingVariance = 0.001,
                                         noiseLevel = "quiet",
                                         tolerance = 2e-07,
                                         threads = 10)

        result <- MethodEvaluation::injectSignals(connectionDetails,
                                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                                  oracleTempSchema = oracleTempSchema,
                                                  exposureDatabaseSchema = cdmDatabaseSchema,
                                                  exposureTable = "drug_era",
                                                  outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                  outcomeTable = outcomeTable,
                                                  exposureOutcomePairs = exposureOutcomePairs,
                                                  createOutputTable = FALSE,
                                                  firstExposureOnly = FALSE,
                                                  firstOutcomeOnly = FALSE,
                                                  modelType = "poisson",
                                                  prior = prior,
                                                  control = control,
                                                  riskWindowStart = 0,
                                                  riskWindowEnd = 0,
                                                  addExposureDaysToEnd = TRUE,
                                                  effectSizes = c(1, 1.25, 1.5, 2, 4),
                                                  workFolder = injectionFolder,
                                                  cdmVersion = cdmVersion)
        saveRDS(result, injectionSummaryFile)
    }
}
