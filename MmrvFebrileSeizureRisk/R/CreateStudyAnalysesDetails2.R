# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of DenosumabBoneMetastases
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
  covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = TRUE,
                                                                  useDemographicsAgeGroup = TRUE,
                                                                  useDemographicsIndexYear = TRUE,
                                                                  useDemographicsIndexMonth = TRUE,
                                                                  useConditionGroupEraLongTerm = TRUE,
                                                                  useConditionGroupEraShortTerm = TRUE,
                                                                  useDrugGroupEraLongTerm = TRUE,
                                                                  useDrugGroupEraShortTerm = TRUE,
                                                                  useCharlsonIndex = TRUE,
                                                                  addDescendantsToExclude = TRUE)
  
  getDbCohortMethodDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(restrictToCommonPeriod = TRUE,
                                                                             washoutPeriod = 365,
                                                                             excludeDrugsFromCovariates = FALSE,
                                                                             covariateSettings = covariateSettings)
  
  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(removeDuplicateSubjects = "keep first",
                                                                      removeSubjectsWithPriorOutcome = FALSE,
                                                                      riskWindowStart = 0,
                                                                      riskWindowEnd = round(34 * 30.5),
                                                                      addExposureDaysToEnd = FALSE)
  
  control <- Cyclops::createControl(noiseLevel = "quiet", 
                                    cvType = "auto", 
                                    tolerance = 2e-07, 
                                    cvRepetitions = 10, 
                                    startingVariance = 0.01,
                                    seed = 123)
  createPsArgs <- CohortMethod::createCreatePsArgs(control = control)
  
  stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs()
  
  fitOutcomeModelArgs <- CohortMethod::createFitOutcomeModelArgs(modelType = "cox",
                                                                 stratified = TRUE,
                                                                 useCovariates = FALSE)
  
  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                description = "ITT",
                                                getDbCohortMethodDataArgs = getDbCohortMethodDataArgs,
                                                createStudyPopArgs = createStudyPopArgs,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                stratifyByPs = TRUE,
                                                stratifyByPsArgs = stratifyByPsArgs,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs)
  
  cmAnalysisList <- list(cmAnalysis1)
  
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(workFolder, "cmAnalysisList.json"))
}

createTcos <- function(outputFolder) {
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = "DenosumabBoneMetastases")
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