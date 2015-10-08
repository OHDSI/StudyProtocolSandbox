# Copyright 2015 Observational Health Data Sciences and Informatics
#
# This file is part of CelecoxibPredictiveModels
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

#' Create the exposure and outcome cohorts
#'
#' @details
#' This function creates the predictive outcomes for the different outcomes.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the \code{\link[DatabaseConnector]{createConnectionDetails}}
#' function in the DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides. Note that for SQL Server, this should include
#' both the database and schema name, for example 'cdm_data.dbo'.
#' @param workDatabaseSchema   Schema name where intermediate data can be stored. You will need to have write priviliges in this schema. Note that
#' for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.
#' @param studyCohortTable     The name of the table that will be created in the work database schema. This table will hold the exposure and outcome
#' cohorts used in this study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write priviliges for storing temporary tables.
#' @param cdmVersion           Version of the CDM. Can be "4" or "5"
#' @param outputFolder	       Name of local folder to place results; make sure to use forward slashes (/)
#'
#' @export
createPredictiveModels <- function(connectionDetails,
                                   cdmDatabaseSchema,
                                   workDatabaseSchema,
                                   studyCohortTable = "ohdsi_celecoxib_prediction",
                                   oracleTempSchema,
                                   cdmVersion = 5,
                                   outputFolder) {

    outcomeIds <- 10:16
    minOutcomeCount <- 25

    cohortDataFile <- file.path(outputFolder, "cohortData")
    if (file.exists(cohortDataFile)) {
        cohortData <- PatientLevelPrediction::loadCohortData(cohortDataFile)
    } else {
        writeLines("- Extracting cohorts")
        cohortData <- PatientLevelPrediction::getDbCohortData(connectionDetails,
                                                              cdmDatabaseSchema = cdmDatabaseSchema,
                                                              cohortDatabaseSchema = workDatabaseSchema,
                                                              cohortTable = studyCohortTable,
                                                              cohortIds = 1,
                                                              useCohortEndDate = FALSE,
                                                              windowPersistence = 365,
                                                              cdmVersion = cdmVersion)

        PatientLevelPrediction::saveCohortData(cohortData, cohortDataFile)
    }

    covariateDataFile <- file.path(outputFolder, "covariateData")
    if (file.exists(covariateDataFile)) {
        covariateData <- PatientLevelPrediction::loadCovariateData(covariateDataFile)
    } else {
        writeLines("- Extracting covariates")

        conn <- DatabaseConnector::connect(connectionDetails)
        sql <- "SELECT descendant_concept_id FROM @cdm_database_schema.concept_ancestor WHERE ancestor_concept_id = 1118084"
        sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema)$sql
        sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
        celecoxibDrugs <- DatabaseConnector::querySql(conn, sql)
        celecoxibDrugs <- celecoxibDrugs[,1]
        RJDBC::dbDisconnect(conn)

        covariateSettings <- PatientLevelPrediction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                                             useCovariateDemographicsGender = TRUE,
                                                                             useCovariateDemographicsRace = TRUE,
                                                                             useCovariateDemographicsEthnicity = TRUE,
                                                                             useCovariateDemographicsAge = TRUE,
                                                                             useCovariateDemographicsYear = TRUE,
                                                                             useCovariateDemographicsMonth = TRUE,
                                                                             useCovariateConditionOccurrence = TRUE,
                                                                             useCovariateConditionOccurrence365d = TRUE,
                                                                             useCovariateConditionOccurrence30d = TRUE,
                                                                             useCovariateConditionOccurrenceInpt180d = TRUE,
                                                                             useCovariateConditionEra = TRUE,
                                                                             useCovariateConditionEraEver = TRUE,
                                                                             useCovariateConditionEraOverlap = TRUE,
                                                                             useCovariateConditionGroup = TRUE,
                                                                             useCovariateConditionGroupMeddra = TRUE,
                                                                             useCovariateConditionGroupSnomed = TRUE,
                                                                             useCovariateDrugExposure = TRUE,
                                                                             useCovariateDrugExposure365d = TRUE,
                                                                             useCovariateDrugExposure30d = TRUE,
                                                                             useCovariateDrugEra = TRUE,
                                                                             useCovariateDrugEra365d = TRUE,
                                                                             useCovariateDrugEra30d = TRUE,
                                                                             useCovariateDrugEraOverlap = TRUE,
                                                                             useCovariateDrugEraEver = TRUE,
                                                                             useCovariateDrugGroup = TRUE,
                                                                             useCovariateProcedureOccurrence = TRUE,
                                                                             useCovariateProcedureOccurrence365d = TRUE,
                                                                             useCovariateProcedureOccurrence30d = TRUE,
                                                                             useCovariateProcedureGroup = TRUE,
                                                                             useCovariateObservation = TRUE,
                                                                             useCovariateObservation365d = TRUE,
                                                                             useCovariateObservation30d = TRUE,
                                                                             useCovariateObservationCount365d = TRUE,
                                                                             useCovariateMeasurement = TRUE,
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
                                                                             useCovariateRiskScoresCHADS2VASc = TRUE,
                                                                             useCovariateInteractionYear = FALSE,
                                                                             useCovariateInteractionMonth = FALSE,
                                                                             excludedCovariateConceptIds = celecoxibDrugs,
                                                                             includedCovariateConceptIds = c(),
                                                                             deleteCovariatesSmallCount = 100)

        covariateData <- PatientLevelPrediction::getDbCovariateData(connectionDetails,
                                                                    cdmDatabaseSchema = cdmDatabaseSchema,
                                                                    cohortDatabaseSchema = workDatabaseSchema,
                                                                    cohortTable = studyCohortTable,
                                                                    cohortIds = 1,
                                                                    covariateSettings = covariateSettings,
                                                                    cdmVersion = cdmVersion)

        PatientLevelPrediction::saveCovariateData(covariateData, covariateDataFile)
    }

    outcomeDataFile <- file.path(outputFolder, "outcomeData")
    if (file.exists(outcomeDataFile)) {
        outcomeData <- PatientLevelPrediction::loadOutcomeData(outcomeDataFile)
    } else {
        writeLines("- Extracting outcomes")
        outcomeData <- PatientLevelPrediction::getDbOutcomeData(connectionDetails,
                                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                                cohortDatabaseSchema = workDatabaseSchema,
                                                                cohortTable = studyCohortTable,
                                                                cohortIds = 1,
                                                                useCohortEndDate = FALSE,
                                                                windowPersistence = 365,
                                                                outcomeDatabaseSchema = workDatabaseSchema,
                                                                outcomeTable = studyCohortTable,
                                                                outcomeIds = outcomeIds,
                                                                cdmVersion = cdmVersion)

        PatientLevelPrediction::saveOutcomeData(outcomeData, outcomeDataFile)
    }

    trainCohortDataFile <- file.path(outputFolder, "trainCohortData")
    trainCovariateDataFile <- file.path(outputFolder, "trainCovariateData")
    trainOutcomeDataFile <- file.path(outputFolder, "trainOutcomeData")
    testCohortDataFile <- file.path(outputFolder, "testCohortData")
    testCovariateDataFile <- file.path(outputFolder, "testCovariateData")
    testOutcomeDataFile <- file.path(outputFolder, "testOutcomeData")
    if (file.exists(trainCohortDataFile) &&
        file.exists(trainCovariateDataFile) &&
        file.exists(trainOutcomeDataFile) &&
        file.exists(testCohortDataFile) &&
        file.exists(testCovariateDataFile) &&
        file.exists(testOutcomeDataFile)) {
        trainCohortData <- PatientLevelPrediction::loadCohortData(trainCohortDataFile)
        trainCovariateData <- PatientLevelPrediction::loadCovariateData(trainCovariateDataFile)
        trainOutcomeData <- PatientLevelPrediction::loadOutcomeData(trainOutcomeDataFile)
    } else {
        writeLines("Creating train-test split")
        parts <- PatientLevelPrediction::splitData(cohortData, covariateData, outcomeData, c(0.75, 0.25))

        PatientLevelPrediction::saveCohortData(parts[[1]]$cohortData, trainCohortDataFile)
        PatientLevelPrediction::saveCovariateData(parts[[1]]$covariateData, trainCovariateDataFile)
        PatientLevelPrediction::saveOutcomeData(parts[[1]]$outcomeData, trainOutcomeDataFile)
        PatientLevelPrediction::saveCohortData(parts[[2]]$cohortData, testCohortDataFile)
        PatientLevelPrediction::saveCovariateData(parts[[2]]$covariateData, testCovariateDataFile)
        PatientLevelPrediction::saveOutcomeData(parts[[2]]$outcomeData, testOutcomeDataFile)

        trainCohortData <- parts[[1]]$cohortData
        trainCovariateData <- parts[[1]]$covariateData
        trainOutcomeData <- parts[[1]]$outcomeData
        testCohortData <- parts[[2]]$cohortData
        testCovariateData <- parts[[2]]$covariateData
        testOutcomeData <- parts[[2]]$outcomeData

        write.csv(summary(trainCohortData)$counts, file.path(outputFolder, "trainCohortSize.csv"), row.names = FALSE)
        write.csv(addOutcomeNames(summary(trainOutcomeData)$counts), file.path(outputFolder, "trainOutcomeCounts.csv"), row.names = FALSE)
        write.csv(summary(testCohortData)$counts, file.path(outputFolder, "testCohortSize.csv"), row.names = FALSE)
        write.csv(addOutcomeNames(summary(testOutcomeData)$counts), file.path(outputFolder, "testOutcomeCounts.csv"), row.names = FALSE)
    }
    counts <- summary(trainOutcomeData)$counts
    for (outcomeId in outcomeIds){
        modelFile <- file.path(outputFolder, paste("model_o",outcomeId, ".rds", sep = ""))
        if (counts$personCount[counts$outcomeId == outcomeId] > minOutcomeCount &&
            !file.exists(modelFile)){
            writeLines(paste("- Fitting model for outcome", outcomeId))
            control = Cyclops::createControl(noiseLevel = "quiet",
                                             cvType = "auto",
                                             startingVariance = 0.1,
                                             threads = 10)
            model <- PatientLevelPrediction::fitPredictiveModel(trainCohortData,
                                                                trainCovariateData,
                                                                trainOutcomeData,
                                                                outcomeId = outcomeId,
                                                                modelType = "logistic",
                                                                control = control)
            saveRDS(model, modelFile)
        }
    }
}
