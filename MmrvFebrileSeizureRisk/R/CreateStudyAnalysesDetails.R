# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of MmrvFebrileSeizureRisk
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
#' @param connectionDetails   An object of type \code{connectionDetails} as created using the
#'                            \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                            DatabaseConnector package.
#' @param cdmDatabaseSchema   Schema name where your patient-level data in OMOP CDM format resides.
#'                            Note that for SQL Server, this should include both the database and
#'                            schema name, for example 'cdm_data.dbo'.
#' @param workFolder        Name of local folder to place results; make sure to use forward slashes
#'                            (/)
#'
#' @export
createAnalysesDetails <- function(connectionDetails, cdmDatabaseSchema, workFolder) {

  # Almost verbatim from ATLAS

  targetCohortId <- 99321
  comparatorCohortId <- 99322 # make comparatorCohortList <- c(X, Y, Z)
  outcomeList <- c(99323, 100791, 100792, 100793, 100794, 100795)

  # Default Prior & Control settings ----
  defaultPrior <- Cyclops::createPrior("laplace",
                                       exclude = c(0),
                                       useCrossValidation = TRUE)

  defaultControl <- Cyclops::createControl(cvType = "auto",
                                           startingVariance = 0.01,
                                           noiseLevel = "quiet",
                                           tolerance  = 2e-07,
                                           cvRepetitions = 10,
                                           threads = 1,
                                           seed = 123)

  # Get all  Concept IDs for exclusion ----

  excludedConcepts <- c()

  # Get all  Concept IDs for inclusion ----

  includedConcepts <- c()


  # Get all  Concept IDs for exclusion in the outcome model ----

  omExcludedConcepts <- c()

  # Get all  Concept IDs for inclusion exclusion in the outcome model ----

  omIncludedConcepts <- c()


  # Get all Adjudicated negative controls for MMRV Concept IDs for empirical calibration ----
  sql <- paste("select distinct I.concept_id FROM
               (
               select concept_id from @cdm_database_schema.CONCEPT where concept_id in (4132093,4148204,257011,257007,317009,4288734,75860,254761,374375,4080305,444207,24969,433701,4226263,255848,4170143,4283893,138455,4122115,440921,314754)and invalid_reason is null

               ) I
               ")
  sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  connection <- DatabaseConnector::connect(connectionDetails)
  negativeControlConcepts <- DatabaseConnector::querySql(connection, sql)
  negativeControlConcepts <- negativeControlConcepts$CONCEPT_ID


  # Create drug comparator and outcome arguments by combining target + comparitor + outcome + negative controls ----
  dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = targetCohortId,
                                                     comparatorId = comparatorCohortId,
                                                     excludedCovariateConceptIds = excludedConcepts,
                                                     includedCovariateConceptIds = includedConcepts,
                                                     outcomeIds = c(outcomeList, negativeControlConcepts))

  drugComparatorOutcomesList <- list(dcos)


  # HAVE NOT UPDATED ANYTHING PAST HERE

  # Define which types of covariates must be constructed ----
  covariateSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                                  useCovariateDemographicsGender = TRUE,
                                                                  useCovariateDemographicsRace = FALSE,
                                                                  useCovariateDemographicsEthnicity = FALSE,
                                                                  useCovariateDemographicsAge = TRUE,
                                                                  useCovariateDemographicsYear = TRUE,
                                                                  useCovariateDemographicsMonth = TRUE,
                                                                  useCovariateConditionOccurrence = TRUE,
                                                                  useCovariateConditionOccurrenceLongTerm = TRUE,
                                                                  useCovariateConditionOccurrenceShortTerm = TRUE,
                                                                  useCovariateConditionOccurrenceInptMediumTerm = FALSE,
                                                                  useCovariateConditionEra = FALSE,
                                                                  useCovariateConditionEraEver = FALSE,
                                                                  useCovariateConditionEraOverlap = FALSE,
                                                                  useCovariateConditionGroup = TRUE,
                                                                  useCovariateConditionGroupMeddra = FALSE,
                                                                  useCovariateConditionGroupSnomed = TRUE,
                                                                  useCovariateDrugExposure = FALSE,
                                                                  useCovariateDrugExposureLongTerm = FALSE,
                                                                  useCovariateDrugExposureShortTerm = FALSE,
                                                                  useCovariateDrugEra = TRUE,
                                                                  useCovariateDrugEraLongTerm = TRUE,
                                                                  useCovariateDrugEraShortTerm = FALSE,
                                                                  useCovariateDrugEraOverlap = FALSE,
                                                                  useCovariateDrugEraEver = FALSE,
                                                                  useCovariateDrugGroup = TRUE,
                                                                  useCovariateProcedureOccurrence = TRUE,
                                                                  useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                                  useCovariateProcedureOccurrenceShortTerm = FALSE,
                                                                  useCovariateProcedureGroup = FALSE,
                                                                  useCovariateObservation = FALSE,
                                                                  useCovariateObservationLongTerm = FALSE,
                                                                  useCovariateObservationShortTerm = FALSE,
                                                                  useCovariateObservationCountLongTerm = FALSE,
                                                                  useCovariateMeasurement = TRUE,
                                                                  useCovariateMeasurementLongTerm = TRUE,
                                                                  useCovariateMeasurementShortTerm = FALSE,
                                                                  useCovariateMeasurementCountLongTerm = TRUE,
                                                                  useCovariateMeasurementBelow = FALSE,
                                                                  useCovariateMeasurementAbove = FALSE,
                                                                  useCovariateConceptCounts = TRUE,
                                                                  useCovariateRiskScores = TRUE,
                                                                  useCovariateRiskScoresCharlson = TRUE,
                                                                  useCovariateRiskScoresDCSI = FALSE,
                                                                  useCovariateRiskScoresCHADS2 = FALSE,
                                                                  useCovariateRiskScoresCHADS2VASc = FALSE,
                                                                  useCovariateInteractionYear = FALSE,
                                                                  useCovariateInteractionMonth = FALSE,
                                                                  deleteCovariatesSmallCount = 100,
                                                                  addDescendantsToExclude = TRUE)

  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 365,
                                                                   firstExposureOnly = FALSE,
                                                                   removeDuplicateSubjects = TRUE,
                                                                   studyStartDate = "",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = FALSE,
                                                                   covariateSettings = covariateSettings)

  createStudyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                       firstExposureOnly = FALSE,
                                                                       washoutPeriod = 365,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 90,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 9999,
                                                                       addExposureDaysToEnd = FALSE)

  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = TRUE,
                                                                  includeCovariateIds = omIncludedConcepts,
                                                                  excludeCovariateIds = omExcludedConcepts,
                                                                  prior = defaultPrior,
                                                                  control = defaultControl)

  createPsArgs1 <- CohortMethod::createCreatePsArgs(control = defaultControl) # Using only defaults
  trimByPsArgs1 <- CohortMethod::createTrimByPsArgs() # Using only defaults
  trimByPsToEquipoiseArgs1 <- CohortMethod::createTrimByPsToEquipoiseArgs(bounds = c(0.1, 0.9))
  matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs() # Using only defaults
  stratifyByPsArgs1 <- CohortMethod::createStratifyByPsArgs(numberOfStrata = 5)

  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                description = "Main analysis: ITT",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs1,
                                                trimByPs = FALSE,
                                                trimByPsArgs = trimByPsArgs1,
                                                trimByPsToEquipoise = TRUE,
                                                trimByPsToEquipoiseArgs = trimByPsToEquipoiseArgs1,
                                                matchOnPs = FALSE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                stratifyByPs = TRUE,
                                                stratifyByPsArgs = stratifyByPsArgs1,
                                                computeCovariateBalance = FALSE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  createStudyPopArgs2 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                       firstExposureOnly = FALSE,
                                                                       washoutPeriod = 365,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 90,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 0,
                                                                       addExposureDaysToEnd = TRUE)

  cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                description = "Sensitivity analysis: Per-protocol",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs2,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs1,
                                                trimByPs = FALSE,
                                                trimByPsArgs = trimByPsArgs1,
                                                trimByPsToEquipoise = TRUE,
                                                trimByPsToEquipoiseArgs = trimByPsToEquipoiseArgs1,
                                                matchOnPs = FALSE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                stratifyByPs = TRUE,
                                                stratifyByPsArgs = stratifyByPsArgs1,
                                                computeCovariateBalance = FALSE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysisList <- list(cmAnalysis1, cmAnalysis2)

  # Save settings to package ------------------------------------------------
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisList.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList, file.path(workFolder, "drugComparatorOutcomesList.txt"))
}

