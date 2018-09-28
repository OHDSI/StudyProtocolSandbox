# Copyright 2018 Observational Health Data Sciences and Informatics
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
#' @param workFolder        Name of local folder to place results; make sure to use forward slashes
#'                            (/)
#'
#' @export
#' 
#' 
#' 

createAnalysesDetails <- function(workFolder) {
   # 1) ADD MODELS you want
  modelSettingList <- list(PatientLevelPrediction::setAdaBoost(),
                           PatientLevelPrediction::setLassoLogisticRegression(),
                           PatientLevelPrediction::setGradientBoostingMachine(), 
                           PatientLevelPrediction::setDecisionTree(), 
                           PatientLevelPrediction::setNaiveBayes(),
                           PatientLevelPrediction::setRandomForest()
                           )
  
  # 2) ADD POPULATIONS you want
  pop1 <- PatientLevelPrediction::createStudyPopulationSettings(riskWindowStart = 1, 
                                        riskWindowEnd = 14,
                                        requireTimeAtRisk = T, 
                                        minTimeAtRisk = 1, 
                                        includeAllOutcomes = T)
  populationSettingList <- list(pop1)
  
  # 3) ADD COVARIATES settings you want
  covariateSettings1 <- FeatureExtraction::createCovariateSettings(useDemographicsGender = FALSE,
                                                                   useDemographicsAge = FALSE, 
                                                                   useDemographicsAgeGroup = FALSE,
                                                                   useDemographicsRace = FALSE, 
                                                                   useDemographicsEthnicity = FALSE,
                                                                   useDemographicsIndexYear = FALSE, 
                                                                   useDemographicsIndexMonth = FALSE,
                                                                   useDemographicsPriorObservationTime = FALSE,
                                                                   useDemographicsPostObservationTime = FALSE,
                                                                   useDemographicsTimeInCohort = FALSE,
                                                                   useDemographicsIndexYearMonth = FALSE,
                                                                   useConditionOccurrenceAnyTimePrior = TRUE,
                                                                   useConditionOccurrenceLongTerm = FALSE,
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
                                                                   useDrugExposureAnyTimePrior = TRUE, 
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
                                                                   useProcedureOccurrenceAnyTimePrior = TRUE,
                                                                   useProcedureOccurrenceLongTerm = FALSE,
                                                                   useProcedureOccurrenceMediumTerm = FALSE,
                                                                   useProcedureOccurrenceShortTerm = FALSE,
                                                                   useDeviceExposureAnyTimePrior = FALSE, 
                                                                   useDeviceExposureLongTerm = FALSE,
                                                                   useDeviceExposureMediumTerm = FALSE, 
                                                                   useDeviceExposureShortTerm = FALSE,
                                                                   useMeasurementAnyTimePrior = TRUE, 
                                                                   useMeasurementLongTerm = FALSE,
                                                                   useMeasurementMediumTerm = FALSE, 
                                                                   useMeasurementShortTerm = FALSE,
                                                                   useMeasurementValueAnyTimePrior = TRUE,
                                                                   useMeasurementValueLongTerm = FALSE,
                                                                   useMeasurementValueMediumTerm = FALSE,
                                                                   useMeasurementValueShortTerm = FALSE,
                                                                   useMeasurementRangeGroupAnyTimePrior = TRUE,
                                                                   useMeasurementRangeGroupLongTerm = FALSE,
                                                                   useMeasurementRangeGroupMediumTerm = FALSE,
                                                                   useMeasurementRangeGroupShortTerm = FALSE,
                                                                   useObservationAnyTimePrior = TRUE, 
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
                                                                   mediumTermStartDays = -180, shortTermStartDays = -30, endDays = 0,
                                                                   includedCovariateConceptIds = c(), addDescendantsToInclude = FALSE,
                                                                   excludedCovariateConceptIds = c(), addDescendantsToExclude = FALSE,
                                                                   includedCovariateIds = c())
  
  covariateSettingList <- list(covariateSettings1) 
  
  # ADD COHORTS
  cohortIds <- c(872)  # add all your Target cohorts here
  outcomeIds <- c(20)   # add all your outcome cohorts here
  
  
  # this will then generate and save the json specification for the analysis
  PatientLevelPrediction::savePredictionAnalysisList(workFolder=workFolder,
                                                     cohortIds,
                                                     outcomeIds,
                                                     cohortSettingCsv =file.path(workFolder, 'CohortsToCreate.csv'), 
                                                     covariateSettingList,
                                                     populationSettingList,
                                                     modelSettingList,
                                                     maxSampleSize= NULL,
                                                     washoutPeriod=0,
                                                     minCovariateFraction=0.001,
                                                     normalizeData=T,
                                                     testSplit='person',
                                                     testFraction=0.2,
                                                     splitSeed=1,
                                                     nfold=3,
                                                     verbosity="INFO")
  }
