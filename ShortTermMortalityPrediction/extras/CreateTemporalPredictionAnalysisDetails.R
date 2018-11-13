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

createTemporalAnalysesDetails <- function(workFolder) {
  
  window_period_days = 14
  day_interval=2
  initial_start_day=-14
  
  #startDays = seq(from=initial_start_day,length.out=abs(initial_start_day)/day_interval, by = day_interval)
  startDays = c(-99999,-60,-30, seq(from=initial_start_day,length.out=abs(initial_start_day)/day_interval, by = day_interval))
  #endDays = seq(from=initial_start_day+day_interval-1,length.out=(abs(initial_start_day)/day_interval),by = day_interval)
  endDays = c(-61,-31,-15, seq(from=initial_start_day,length.out=abs(initial_start_day)/day_interval, by = day_interval)+1)
  endDays[length(endDays)]<-0
  
  # 1) ADD MODELS you want
  temporalModelSettingList<-list(PatientLevelPrediction::setCIReNN(units=c(64), recurrentDropout=c(0.3),lr =c(1e-4), decay=c(1e-5), 
                                                                   outcomeWeight = c(1.0),
                                                                   batchSize = c(200), 
                                                                   epochs = c(100),
                                                                   earlyStoppingMinDelta = c(1e-03), earlyStoppingPatience = c(5),
                                                                   useVae =T, vaeDataSamplingProportion = 1.0, vaeValidationSplit = 0.2,
                                                                   vaeBatchSize = 100L, vaeLatentDim = 256, vaeIntermediateDim = 1024L,
                                                                   vaeEpoch = 100L, vaeEpislonStd = 1.0, seed = NULL)
  )
  
  # 2) ADD POPULATIONS you want

  temporalPopulation<-PatientLevelPrediction::createStudyPopulationSettings(riskWindowStart = 1, 
                                        riskWindowEnd = 14,
                                        requireTimeAtRisk = T, 
                                        minTimeAtRisk = 1, 
                                        includeAllOutcomes = T)
  
  temporalPopulationSettingList <- list(temporalPopulation)
  
  # 3) ADD COVARIATES settings you want
  temporalCovariateSettings <- FeatureExtraction::createTemporalCovariateSettings(useDemographicsGender = FALSE,
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
                                                                                  useConditionOccurrence = TRUE,
                                                                                  useConditionEraStart = FALSE,
                                                                                  useConditionEraOverlap = FALSE, 
                                                                                  useConditionEraGroupStart = FALSE,
                                                                                  useConditionEraGroupOverlap = FALSE, 
                                                                                  useDrugExposure = TRUE,
                                                                                  useDrugEraStart = FALSE, 
                                                                                  useDrugEraOverlap = FALSE,
                                                                                  useDrugEraGroupStart = FALSE, 
                                                                                  useDrugEraGroupOverlap = FALSE,
                                                                                  useProcedureOccurrence = TRUE, 
                                                                                  useDeviceExposure = TRUE,
                                                                                  useMeasurement = TRUE, 
                                                                                  useMeasurementValue = TRUE,
                                                                                  useMeasurementRangeGroup = TRUE, 
                                                                                  useObservation = TRUE,
                                                                                  useCharlsonIndex = FALSE, 
                                                                                  useDcsi = FALSE, 
                                                                                  useChads2 = FALSE,
                                                                                  useChads2Vasc = FALSE, 
                                                                                  useDistinctConditionCount = FALSE,
                                                                                  useDistinctIngredientCount = FALSE, 
                                                                                  useDistinctProcedureCount = FALSE,
                                                                                  useDistinctMeasurementCount = FALSE, 
                                                                                  useDistinctObservationCount = FALSE,
                                                                                  useVisitCount = FALSE, 
                                                                                  useVisitConceptCount = FALSE,
                                                                                  temporalStartDays = startDays, 
                                                                                  temporalEndDays = endDays,
                                                                                  includedCovariateConceptIds = c(), 
                                                                                  addDescendantsToInclude = FALSE,
                                                                                  excludedCovariateConceptIds = c(), 
                                                                                  addDescendantsToExclude = FALSE,
                                                                                  includedCovariateIds = c())
  temporalCovariateSettingList <- list(temporalCovariateSettings) 
  
  # ADD COHORTS
  cohortIds <- c(872)  # add all your Target cohorts here
  outcomeIds <- c(20)   # add all your outcome cohorts here
  
  
  # this will then generate and save the json specification for the analysis
  saveTemporalPredictionAnalysisList(workFolder=workFolder,
                                     cohortIds,
                                     outcomeIds,
                                     cohortSettingCsv =file.path(workFolder, 'CohortsToCreate.csv'), 
                                     temporalCovariateSettingList,
                                     temporalPopulationSettingList,
                                     temporalModelSettingList,
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


saveTemporalPredictionAnalysisList<-function (workFolder = "inst/settings", cohortIds, outcomeIds, 
          cohortSettingCsv = file.path(workFolder, "CohortsToCreate.csv"), 
          covariateSettingList, populationSettingList, modelSettingList, 
          maxSampleSize = NULL, washoutPeriod = 0, minCovariateFraction = 0, 
          normalizeData = T, testSplit = "person", testFraction = 0.25, 
          splitSeed = 1, nfold = 3, verbosity = "INFO") 
{
  json <- list()
  json$targetIds <- cohortIds
  json$outcomeIds <- outcomeIds
  cohortsToCreate <- read.csv(cohortSettingCsv)
  json$cohortDefinitions <- apply(cohortsToCreate[, c("cohortId", 
                                                      "name")], 1, function(x) list(id = x[1], name = x[2]))
  json$getPlpDataArgs <- list(maxSampleSize = maxSampleSize, 
                              washoutPeriod = washoutPeriod)
  json$runPlpArgs <- list(minCovariateFraction = minCovariateFraction, 
                          normalizeData = normalizeData, testSplit = testSplit, 
                          testFraction = testFraction, splitSeed = splitSeed, nfold = nfold, 
                          verbosity = verbosity)
  json$covariateSettings <- covariateSettingList
  json$populationSettings <- populationSettingList
  json$modelSettings <- list()
  if (class(modelSettingList) == "list") {
    length(json$modelSettings) <- length(modelSettingList)
    for (k in 1:length(modelSettingList)) {
      modSet <- list()
      if (modelSettingList[[k]]$model %in% c("fitLassoLogisticRegression", 
                                             "fitKNN", "fitNaiveBayes")) {
        modSet[[1]] <- modelSettingList[[k]]$param
      }
      else {
        if (class(modelSettingList[[k]]$param) == "data.frame") {
          modelSettingList[[k]]$param <- split(modelSettingList[[k]]$param, 
                                               factor(1:nrow(modelSettingList[[k]]$param)))
        }
        params <- lapply(1:ncol(modelSettingList[[k]]$param[[1]]), 
                         function(i) unique(unlist(lapply(modelSettingList[[k]]$param, 
                                                          function(x) x[[i]]))))
        names(params) <- colnames(modelSettingList[[k]]$param[[1]])
        if (params$seed == "NULL") {
          params$seed <- NULL
        }
        modSet[[1]] <- params
      }
      names(modSet) <- paste0(gsub("fit", "", modelSettingList[[k]]$model), 
                              "Settings")
      json$modelSettings[[k]] <- modSet
    }
  }
  else {
    length(json$modelSettings) <- 1
    modSet <- list()
    if (modelSettingList$model %in% c("fitLassoLogisticRegression", 
                                      "fitKNN", "fitNaiveBayes")) {
      modSet[[1]] <- modelSettingList$param
    }
    else {
      if (class(modelSettingList$param) == "data.frame") {
        modelSettingList$param <- split(modelSettingList$param, 
                                        factor(1:nrow(modelSettingList$param)))
      }
      params <- lapply(1:ncol(modelSettingList$param[[1]]), 
                       function(i) unique(unlist(lapply(modelSettingList$param, 
                                                        function(x) x[[i]]))))
      names(params) <- colnames(modelSettingList$param[[1]])
      if (params$seed == "NULL") {
        params$seed <- NULL
      }
      modSet[[1]] <- params
    }
    names(modSet) <- paste0(gsub("fit", "", modelSettingList$model), 
                            "Settings")
    json$modelSettings[[1]] <- modSet
  }
  OhdsiRTools::saveSettingsToJson(json, file = file.path(workFolder, 
                                                         "temporalPredictionAnalysisList.json"))
  return(file.path(workFolder, "temporalPredictionAnalysisList.json"))
}