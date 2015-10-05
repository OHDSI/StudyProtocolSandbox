# Copyright 2015 Observational Health Data Sciences and Informatics
#
# This file is part of CelecoxibVsNsNSAIDs
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

#' Create the analyses details
#'
#' @details
#' This function creates files specifying the analyses that will be performed.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the \code{\link[DatabaseConnector]{createConnectionDetails}}
#' function in the DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides. Note that for SQL Server, this should include
#' both the database and schema name, for example 'cdm_data.dbo'.
#' @param cdmVersion           Version of the CDM. Can be "4" or "5"
#' @param outputFolder	       Name of local folder to place results; make sure to use forward slashes (/)
#'
#' @export
createAnalysisDetails <- function(connectionDetails,
                                  cdmDatabaseSchema,
                                  outputFolder,
                                  cdmVersion) {
    conn <- DatabaseConnector::connect(connectionDetails)

    # Get all NSAIDs:
    sql <- "SELECT concept_id FROM @cdmDatabaseSchema.concept_ancestor INNER JOIN @cdmDatabaseSchema.concept ON descendant_concept_id = concept_id WHERE ancestor_concept_id = 21603933"
    sql <- SqlRender::renderSql(sql, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    nsaids <- DatabaseConnector::querySql(conn, sql)
    nsaids <- nsaids$CONCEPT_ID

    RJDBC::dbDisconnect(conn)


    # 80180 = Osteoarthritis. Note that all descendants will also be included
    dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = 1,
                                                       comparatorId = 2,
                                                       exclusionConceptIds = nsaids,
                                                       excludedCovariateConceptIds = nsaids,
                                                       indicationConceptIds = 80180,
                                                       outcomeIds = c(10:16, 100:110)) #TODO: add negative control IDs
    drugComparatorOutcomesList <- list(dcos)

    covarSettings <- PatientLevelPrediction::createCovariateSettings(useCovariateDemographics = TRUE,
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
                                                                     useCovariateRiskScoresCHADS2VASc = TRUE,
                                                                     useCovariateInteractionYear = FALSE,
                                                                     useCovariateInteractionMonth = FALSE,
                                                                     excludedCovariateConceptIds = c(),
                                                                     deleteCovariatesSmallCount = 100)

    getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutWindow = 183,
                                                                     indicationLookbackWindow = 183,
                                                                     studyStartDate = "",
                                                                     studyEndDate = "",
                                                                     excludeDrugsFromCovariates = FALSE,
                                                                     covariateSettings = covarSettings)

    fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(riskWindowStart = 0,
                                                                    riskWindowEnd = 30,
                                                                    addExposureDaysToEnd = TRUE,
                                                                    useCovariates = FALSE,
                                                                    modelType = "cox",
                                                                    stratifiedCox = FALSE)

    cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                  description = "No matching, simple outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    createPsArgs <- CohortMethod::createCreatePsArgs()  # Using only defaults

    matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)

    cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                  description = "Matching plus simple outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs(numberOfStrata = 5)

    cmAnalysis3 <- CohortMethod::createCmAnalysis(analysisId = 3,
                                                  description = "Stratification plus simple outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  stratifyByPs = TRUE,
                                                  stratifyByPsArgs = stratifyByPsArgs,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs1)

    fitOutcomeModelArgs2 <- CohortMethod::createFitOutcomeModelArgs(riskWindowStart = 0,
                                                                    riskWindowEnd = 30,
                                                                    addExposureDaysToEnd = TRUE,
                                                                    useCovariates = FALSE,
                                                                    modelType = "cox",
                                                                    stratifiedCox = TRUE)

    cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 4,
                                                  description = "Matching plus stratified outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  computeCovariateBalance = TRUE,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs2)

    fitOutcomeModelArgs3 <- CohortMethod::createFitOutcomeModelArgs(riskWindowStart = 0,
                                                                    riskWindowEnd = 30,
                                                                    addExposureDaysToEnd = TRUE,
                                                                    useCovariates = TRUE,
                                                                    modelType = "cox",
                                                                    stratifiedCox = TRUE)

    cmAnalysis5 <- CohortMethod::createCmAnalysis(analysisId = 5,
                                                  description = "Matching plus full outcome model",
                                                  getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                  createPs = TRUE,
                                                  createPsArgs = createPsArgs,
                                                  matchOnPs = TRUE,
                                                  matchOnPsArgs = matchOnPsArgs,
                                                  computeCovariateBalance = TRUE,
                                                  fitOutcomeModel = TRUE,
                                                  fitOutcomeModelArgs = fitOutcomeModelArgs3)

    cmAnalysisList <- list(cmAnalysis1, cmAnalysis2, cmAnalysis3, cmAnalysis4, cmAnalysis5)

    CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(outputFolder, "cmAnalysisList.txt"))
    CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList, file.path(outputFolder, "drugComparatorOutcomesList.txt"))
}
