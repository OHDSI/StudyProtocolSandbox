# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of FebuxostatVsAllopurinolCVD
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

createAnalysesDetails <- function(workFolder) {
  covarSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = TRUE,
                                                                     useDemographicsAge = FALSE, 
                                                                     useDemographicsAgeGroup = TRUE,
                                                                     useDemographicsRace = FALSE, 
                                                                     useDemographicsEthnicity = TRUE,
                                                                     useDemographicsIndexYear = TRUE, 
                                                                     useDemographicsIndexMonth = TRUE,
                                                                     useDemographicsPriorObservationTime = FALSE,
                                                                     useDemographicsPostObservationTime = FALSE,
                                                                     useDemographicsTimeInCohort = FALSE,
                                                                     useDemographicsIndexYearMonth = FALSE,
                                                                     useConditionOccurrenceAnyTimePrior = TRUE,
                                                                     useConditionOccurrenceLongTerm = TRUE,
                                                                     useConditionOccurrenceMediumTerm = FALSE,
                                                                     useConditionOccurrenceShortTerm = FALSE,
                                                                     useConditionEraAnyTimePrior = FALSE, 
                                                                     useConditionEraLongTerm = FALSE,
                                                                     useConditionEraMediumTerm = FALSE, 
                                                                     useConditionEraShortTerm = FALSE,
                                                                     useConditionEraOverlapping = FALSE, 
                                                                     useConditionEraStartLongTerm = FALSE,
                                                                     useConditionEraStartMediumTerm = FALSE,
                                                                     useConditionEraStartShortTerm = FALSE,
                                                                     useConditionGroupEraAnyTimePrior = FALSE,
                                                                     useConditionGroupEraLongTerm = FALSE,
                                                                     useConditionGroupEraMediumTerm = FALSE,
                                                                     useConditionGroupEraShortTerm = FALSE,
                                                                     useConditionGroupEraOverlapping = FALSE,
                                                                     useConditionGroupEraStartLongTerm = FALSE,
                                                                     useConditionGroupEraStartMediumTerm = FALSE,
                                                                     useConditionGroupEraStartShortTerm = FALSE,
                                                                     useDrugExposureAnyTimePrior = FALSE, 
                                                                     useDrugExposureLongTerm = FALSE,
                                                                     useDrugExposureMediumTerm = FALSE, 
                                                                     useDrugExposureShortTerm = FALSE,
                                                                     useDrugEraAnyTimePrior = FALSE, 
                                                                     useDrugEraLongTerm = FALSE,
                                                                     useDrugEraMediumTerm = FALSE, 
                                                                     useDrugEraShortTerm = FALSE,
                                                                     useDrugEraOverlapping = FALSE, 
                                                                     useDrugEraStartLongTerm = FALSE,
                                                                     useDrugEraStartMediumTerm = FALSE, 
                                                                     useDrugEraStartShortTerm = FALSE,
                                                                     useDrugGroupEraAnyTimePrior = FALSE, 
                                                                     useDrugGroupEraLongTerm = FALSE,
                                                                     useDrugGroupEraMediumTerm = FALSE, 
                                                                     useDrugGroupEraShortTerm = FALSE,
                                                                     useDrugGroupEraOverlapping = FALSE, 
                                                                     useDrugGroupEraStartLongTerm = FALSE,
                                                                     useDrugGroupEraStartMediumTerm = FALSE,
                                                                     useDrugGroupEraStartShortTerm = FALSE,
                                                                     useProcedureOccurrenceAnyTimePrior = FALSE,
                                                                     useProcedureOccurrenceLongTerm = FALSE,
                                                                     useProcedureOccurrenceMediumTerm = FALSE,
                                                                     useProcedureOccurrenceShortTerm = FALSE,
                                                                     useDeviceExposureAnyTimePrior = FALSE, 
                                                                     useDeviceExposureLongTerm = FALSE,
                                                                     useDeviceExposureMediumTerm = FALSE, 
                                                                     useDeviceExposureShortTerm = FALSE,
                                                                     useMeasurementAnyTimePrior = FALSE, 
                                                                     useMeasurementLongTerm = FALSE,
                                                                     useMeasurementMediumTerm = FALSE, 
                                                                     useMeasurementShortTerm = FALSE,
                                                                     useMeasurementValueAnyTimePrior = FALSE,
                                                                     useMeasurementValueLongTerm = FALSE,
                                                                     useMeasurementValueMediumTerm = FALSE,
                                                                     useMeasurementValueShortTerm = FALSE,
                                                                     useMeasurementRangeGroupAnyTimePrior = FALSE,
                                                                     useMeasurementRangeGroupLongTerm = FALSE,
                                                                     useMeasurementRangeGroupMediumTerm = FALSE,
                                                                     useMeasurementRangeGroupShortTerm = FALSE,
                                                                     useObservationAnyTimePrior = FALSE, 
                                                                     useObservationLongTerm = FALSE,
                                                                     useObservationMediumTerm = FALSE, 
                                                                     useObservationShortTerm = FALSE,
                                                                     useCharlsonIndex = FALSE, 
                                                                     useDcsi = FALSE, 
                                                                     useChads2 = FALSE,
                                                                     useChads2Vasc = FALSE, 
                                                                     useDistinctConditionCountLongTerm = FALSE,
                                                                     useDistinctConditionCountMediumTerm = FALSE,
                                                                     useDistinctConditionCountShortTerm = FALSE,
                                                                     useDistinctIngredientCountLongTerm = FALSE,
                                                                     useDistinctIngredientCountMediumTerm = FALSE,
                                                                     useDistinctIngredientCountShortTerm = FALSE,
                                                                     useDistinctProcedureCountLongTerm = FALSE,
                                                                     useDistinctProcedureCountMediumTerm = FALSE,
                                                                     useDistinctProcedureCountShortTerm = FALSE,
                                                                     useDistinctMeasurementCountLongTerm = FALSE,
                                                                     useDistinctMeasurementCountMediumTerm = FALSE,
                                                                     useDistinctMeasurementCountShortTerm = FALSE,
                                                                     useDistinctObservationCountLongTerm = FALSE,
                                                                     useDistinctObservationCountMediumTerm = FALSE,
                                                                     useDistinctObservationCountShortTerm = FALSE,
                                                                     useVisitCountLongTerm = FALSE, 
                                                                     useVisitCountMediumTerm = FALSE,
                                                                     useVisitCountShortTerm = FALSE, 
                                                                     useVisitConceptCountLongTerm = FALSE,
                                                                     useVisitConceptCountMediumTerm = FALSE,
                                                                     useVisitConceptCountShortTerm = FALSE, 
                                                                     longTermStartDays = -365,
                                                                     mediumTermStartDays = -180, 
                                                                     shortTermStartDays = -30, 
                                                                     endDays = 0,
                                                                     includedCovariateConceptIds = c(), 
                                                                     addDescendantsToInclude = FALSE,
                                                                     excludedCovariateConceptIds = c(), 
                                                                     addDescendantsToExclude = TRUE,
                                                                     includedCovariateIds = c())				

  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 7,
                                                                   restrictToCommonPeriod = FALSE,
                                                                   firstExposureOnly = FALSE,
                                                                   removeDuplicateSubjects = FALSE,
                                                                   studyStartDate = "20120211",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = FALSE,
                                                                   covariateSettings = covarSettings)
  
  createStudyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 1,
                                                                       riskWindowStart = 1,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 30,
                                                                       addExposureDaysToEnd = TRUE)
  
  createStudyPopArgs2 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 1,
                                                                       riskWindowStart = 1,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 9999,
                                                                       addExposureDaysToEnd = FALSE)
  
  createStudyPopArgs3 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 1095,
                                                                       riskWindowStart = 1,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 30,
                                                                       addExposureDaysToEnd = TRUE)
  
  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = FALSE)
  
  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                description = "No matching On Treatment",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                description = "No matching ITT",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs2,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysis3 <- CohortMethod::createCmAnalysis(analysisId = 3,
                                                description = "No matching with minDaysAtRisk more than 3yr",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs3,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  createPsArgs <- CohortMethod::createCreatePsArgs(control = Cyclops::createControl(cvType = "auto",
                                                                                    startingVariance = 0.01,
                                                                                    noiseLevel = "quiet",
                                                                                    tolerance = 2e-07,
                                                                                    cvRepetitions = 10))
  
  matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs(maxRatio = 4)
  
  fitOutcomeModelArgs2 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = TRUE)
  
  cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 4,
                                                description = "One-on-one matching on Treatment",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  cmAnalysis5 <- CohortMethod::createCmAnalysis(analysisId = 5,
                                                description = "One-on-one matching ITT",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs2,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  cmAnalysis6 <- CohortMethod::createCmAnalysis(analysisId = 6,
                                                description = "One-on-one matching with minDaysAtRisk more than 3yr",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs3,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  matchOnPsArgs2 <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)
  
  cmAnalysis7 <- CohortMethod::createCmAnalysis(analysisId = 7,
                                                description = "Variable ratio matching on Treatmet",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs2,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  cmAnalysis8 <- CohortMethod::createCmAnalysis(analysisId = 8,
                                                description = "Variable ratio matching ITT",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs2,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs2,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  cmAnalysis9 <- CohortMethod::createCmAnalysis(analysisId = 9,
                                                description = "Variable ratio matching with minDaysAtRisk more than 3yr",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs3,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs2,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  
  stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs(numberOfStrata = 10)
  
  cmAnalysis10 <- CohortMethod::createCmAnalysis(analysisId = 10,
                                                 description = "Stratification on Treatment",
                                                 getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                 createStudyPopArgs = createStudyPopArgs1,
                                                 createPs = TRUE,
                                                 createPsArgs = createPsArgs,
                                                 stratifyByPs = TRUE,
                                                 stratifyByPsArgs = stratifyByPsArgs,
                                                 fitOutcomeModel = TRUE,
                                                 fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  cmAnalysis11 <- CohortMethod::createCmAnalysis(analysisId = 11,
                                                 description = "Stratification ITT",
                                                 getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                 createStudyPopArgs = createStudyPopArgs2,
                                                 createPs = TRUE,
                                                 createPsArgs = createPsArgs,
                                                 stratifyByPs = TRUE,
                                                 stratifyByPsArgs = stratifyByPsArgs,
                                                 fitOutcomeModel = TRUE,
                                                 fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  cmAnalysis12 <- CohortMethod::createCmAnalysis(analysisId = 12,
                                                 description = "Stratification with minDaysAtRisk more than 3y",
                                                 getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                 createStudyPopArgs = createStudyPopArgs3,
                                                 createPs = TRUE,
                                                 createPsArgs = createPsArgs,
                                                 stratifyByPs = TRUE,
                                                 stratifyByPsArgs = stratifyByPsArgs,
                                                 fitOutcomeModel = TRUE,
                                                 fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  
  
  cmAnalysisList <- list(cmAnalysis1, cmAnalysis2, cmAnalysis3, cmAnalysis4,cmAnalysis5, cmAnalysis6,
                         cmAnalysis7, cmAnalysis8, cmAnalysis9, cmAnalysis10, cmAnalysis11, cmAnalysis12)
  
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisListKorea.json"))
}

