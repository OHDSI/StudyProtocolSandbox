# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of TocilizumabCvRisk
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
createAnalysesDetails <- function(workFolder) {
  covariateSettings <- FeatureExtraction::createDefaultCovariateSettings(addDescendantsToExclude = TRUE)
  
  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 0,
                                                                   firstExposureOnly = FALSE,
                                                                   removeDuplicateSubjects = TRUE,
                                                                   restrictToCommonPeriod = FALSE,
                                                                   studyStartDate = "",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = FALSE,
                                                                   covariateSettings = covariateSettings,
                                                                   maxCohortSize = 250000)
  
  studyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                 firstExposureOnly = FALSE,
                                                                 washoutPeriod = 0,
                                                                 removeDuplicateSubjects = FALSE,
                                                                 minDaysAtRisk = 0,
                                                                 riskWindowStart = 1,
                                                                 addExposureDaysToStart = FALSE,
                                                                 riskWindowEnd = round(4.9 * 365.25),
                                                                 addExposureDaysToEnd = FALSE)
  
  control <- Cyclops::createControl(noiseLevel = "silent", 
                                    cvType = "auto", 
                                    tolerance = 2e-07, 
                                    cvRepetitions = 1, 
                                    startingVariance = 0.01,
                                    seed = 123)
  
  createPsArgs1 <- CohortMethod::createCreatePsArgs(control = control)
  
  stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs()
  
  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = TRUE)
  
  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                description = "Hazards itent to treat time-at-risk",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = studyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs1,
                                                stratifyByPs = TRUE,
                                                stratifyByPsArgs = stratifyByPsArgs,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysisList <- list(cmAnalysis1)
  
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisList.json"))
}

createTcos <- function(outputFolder) {
  targetOfInterestId <- 1 # Tocilizumab
  comparatorOfInterestId <- 2 # Etanercept
  outcomeOfInterestId <- 3 # CV events
  excludedCovariateConceptIds <- c(40171288, 1151789, 2314229, 2314206)   #Tocilizumab, Etanercept, Chemotherapy administration, Intravenous infusion, for therapy
  
  allControlsFile <- file.path(outputFolder, "AllControls.csv")
  allControls <- read.csv(allControlsFile)
  controlOutcomes <- allControls[allControls$type == "Outcome", ]
  dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = targetOfInterestId,
                                                     comparatorId = comparatorOfInterestId,
                                                     outcomeIds = c(outcomeOfInterestId, controlOutcomes$outcomeId),
                                                     excludedCovariateConceptIds = excludedCovariateConceptIds) 
  dcosList <- list(dcos)
  controlExposures <- allControls[allControls$type == "Exposure", ]
  for (i in 1:nrow(controlExposures)) {
    dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = controlExposures$targetId[i],
                                                       comparatorId = controlExposures$comparatorId[i],
                                                       outcomeIds = controlExposures$outcomeId[i],
                                                       excludedCovariateConceptIds = c(controlExposures$targetId[i],
                                                                                       controlExposures$comparatorId[i])) 
    dcosList[[length(dcosList) + 1]] <- dcos
  }
  return(dcosList)
}
