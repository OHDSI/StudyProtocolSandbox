# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonCompartiveEffectStudy
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
  covarSettings <- FeatureExtraction::createDefaultCovariateSettings(addDescendantsToExclude = TRUE)
  
  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 183,
                                                                   restrictToCommonPeriod = FALSE,
                                                                   firstExposureOnly = TRUE,
                                                                   removeDuplicateSubjects = "remove all",
                                                                   studyStartDate = "",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = FALSE,
                                                                   covariateSettings = covarSettings)
  
  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                      minDaysAtRisk = 1,
                                                                      riskWindowStart = 0,
                                                                      addExposureDaysToStart = FALSE,
                                                                      riskWindowEnd = 30,
                                                                      addExposureDaysToEnd = TRUE)
  
  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = FALSE)
  
  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                description = "No matching, simple outcome model",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  createPsArgs <- CohortMethod::createCreatePsArgs(control = Cyclops::createControl(cvType = "auto",
                                                                                    startingVariance = 0.01,
                                                                                    noiseLevel = "quiet",
                                                                                    tolerance = 2e-07,
                                                                                    cvRepetitions = 10))
  
  matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(maxRatio = 100)
  
  cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                description = "Matching plus simple outcome model",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs(numberOfStrata = 5)
  
  fitOutcomeModelArgs2 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = TRUE)
  
  cmAnalysis3 <- CohortMethod::createCmAnalysis(analysisId = 3,
                                                description = "Stratification plus stratified outcome model",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                stratifyByPs = TRUE,
                                                stratifyByPsArgs = stratifyByPsArgs,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 4,
                                                description = "Matching plus stratified outcome model",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs2)
  
  fitOutcomeModelArgs3 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                  modelType = "cox",
                                                                  stratified = FALSE,
                                                                  inversePsWeighting = TRUE)
  
  cmAnalysis5 <- CohortMethod::createCmAnalysis(analysisId = 5,
                                                description = "Inverse probability weighting",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = FALSE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs3)
  
  fitOutcomeModelArgs4 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = TRUE,
                                                                  modelType = "cox",
                                                                  stratified = TRUE,
                                                                  control = Cyclops::createControl(cvType = "auto",
                                                                                          startingVariance = 0.1,
                                                                                          selectorType = "byPid",
                                                                                          cvRepetitions = 1,
                                                                                          tolerance = 2e-07,
                                                                                          noiseLevel = "quiet"))
  
  cmAnalysis6 <- CohortMethod::createCmAnalysis(analysisId = 6,
                                                description = "Matching plus full outcome model",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs4)
  
  cmAnalysisList <- list(cmAnalysis1, cmAnalysis2, cmAnalysis3, cmAnalysis4, cmAnalysis5, cmAnalysis6)
  
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisList.json"))
}

createTcos <- function(outputFolder) {
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = "SkeletonCompartiveEffectStudy")
  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
  allControlsFile <- file.path(outputFolder, "AllControls.csv")
  allControls <- read.csv(allControlsFile)
  dcosList <- list()
  tcs <- unique(rbind(tcosOfInterest[, c("targetId", "comparatorId")],
                      allControls[, c("targetId", "comparatorId")]))
  for (i in 1:nrow(tcs)) {
    targetId <- tcs$targetId[i]
    comparatorId <- tcs$comparatorId[i]
    outcomeIds <- as.character(tcosOfInterest$outcomeIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])
    outcomeIds <- as.numeric(strsplit(outcomeIds, split = ";")[[1]])
    outcomeIds <- c(outcomeIds, allControls$outcomeId[allControls$targetId == targetId & allControls$comparatorId == comparatorId])
    excludeConceptIds <- tcosOfInterest$excludedCovariateConceptIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId]
    excludeConceptIds <- as.numeric(strsplit(excludeConceptIds, split = ";")[[1]])
    dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = targetId,
                                                       comparatorId = comparatorId,
                                                       outcomeIds = outcomeIds,
                                                       excludedCovariateConceptIds =  excludeConceptIds)
    dcosList[[length(dcosList) + 1]] <- dcos
  }
  return(dcosList)
}
