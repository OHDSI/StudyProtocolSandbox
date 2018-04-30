# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of EvaluatingCaseControl
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

runCaseTimeControlDesigns <- function(connectionDetails = connectionDetails,
                                      cdmDatabaseSchema = cdmDatabaseSchema,
                                      workDatabaseSchema = workDatabaseSchema,
                                      studyCohortTable = studyCohortTable,
                                      oracleTempSchema = oracleTempSchema,
                                      maxCores = maxCores,
                                      workFolder) {
  # Chou replication --------------------------------------------------------
  ccrApFolder <- file.path(workFolder, "ccrAp")
  if (!file.exists(ccrApFolder))
    dir.create(ccrApFolder)

  analysisListFile <- system.file("settings", "ccrAnalysisListAp.json", package = "EvaluatingCaseControl")
  analysisList <- CaseControl::loadCcAnalysisList(analysisListFile)
  eonFile <- system.file("settings", "ccrExposureOutcomeNestingAp.json", package = "EvaluatingCaseControl")
  eonList <- CaseControl::loadExposureOutcomeNestingCohortList(eonFile)
  ccrResult <- CaseCrossover::runCcrAnalyses(connectionDetails = connectionDetails,
                                             cdmDatabaseSchema = cdmDatabaseSchema,
                                             oracleTempSchema = oracleTempSchema,
                                             exposureDatabaseSchema = workDatabaseSchema,
                                             exposureTable = studyCohortTable,
                                             outcomeDatabaseSchema = workDatabaseSchema,
                                             outcomeTable = studyCohortTable,
                                             nestingCohortDatabaseSchema = workDatabaseSchema,
                                             nestingCohortTable = studyCohortTable,
                                             ccrAnalysisList = analysisList,
                                             exposureOutcomeNestingCohortList = eonList,
                                             outputFolder = ccrApFolder,
                                             getDbCaseCrossoverDataThreads = 1,
                                             selectSubjectsToIncludeThreads = min(3, maxCores),
                                             getExposureStatusThreads = min(5, maxCores),
                                             fitCaseCrossoverModelThreads = min(5, maxCores))
  ccrSummary <- CaseCrossover::summarizeCcrAnalyses(ccrResult)
  ccrSummaryFile <- file.path(workFolder, "ccrSummaryAp.rds")
  saveRDS(ccrSummary, ccrSummaryFile)

  ccrSummary <- readRDS(file.path(workFolder, "ccrSummaryAp.rds"))
  ncs <- ccrSummary[ccrSummary$exposureId != 4, ]
  EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, showCis = TRUE)

  # Crockett replication --------------------------------------------------------
  ccrIbdFolder <- file.path(workFolder, "ccrIbd")
  if (!file.exists(ccrIbdFolder))
    dir.create(ccrIbdFolder)

  analysisListFile <- system.file("settings", "ccrAnalysisListIbd.json", package = "EvaluatingCaseControl")
  analysisList <- CaseCrossover::loadCcrAnalysisList(analysisListFile)
  eonFile <- system.file("settings", "ccrExposureOutcomeNestingIbd.json", package = "EvaluatingCaseControl")
  eonList <- CaseCrossover::loadExposureOutcomeNestingCohortList(eonFile)
  ccrResult <- CaseCrossover::runCcrAnalyses(connectionDetails = connectionDetails,
                                             cdmDatabaseSchema = cdmDatabaseSchema,
                                             oracleTempSchema = oracleTempSchema,
                                             exposureDatabaseSchema = workDatabaseSchema,
                                             exposureTable = studyCohortTable,
                                             outcomeDatabaseSchema = workDatabaseSchema,
                                             outcomeTable = studyCohortTable,
                                             nestingCohortDatabaseSchema = workDatabaseSchema,
                                             nestingCohortTable = studyCohortTable,
                                             ccrAnalysisList = analysisList,
                                             exposureOutcomeNestingCohortList = eonList,
                                             outputFolder = ccrIbdFolder,
                                             getDbCaseCrossoverDataThreads = 1,
                                             selectSubjectsToIncludeThreads = min(3, maxCores),
                                             getExposureStatusThreads = min(5, maxCores),
                                             fitCaseCrossoverModelThreads = min(5, maxCores))
  ccrSummary <- CaseCrossover::summarizeCcrAnalyses(ccrResult)
  ccrSummaryFile <- file.path(workFolder, "ccrSummaryIbd.rds")
  saveRDS(ccrSummary, ccrSummaryFile)

  # model <- readRDS(ccrResult$modelFile)
  # ed <- loadCaseControlsExposure(ccrResult$exposureDataFile)
  # covs <- ff::as.ram(ed$covariates)
  # sum(covs$covariateId == 4)
  ccrSummary <- readRDS(file.path(workFolder, "ccrSummaryAp.rds"))
  ncs <- ccrSummary[ccrSummary$exposureId != 4, ]
  EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, showCis = TRUE)
}

#' Create the analyses details
#'
#' @details
#' This function creates files specifying the analyses that will be performed.
#'
#' @param workFolder        Name of local folder to place results; make sure to use forward slashes
#'                            (/)
#'
#' @export
createCaseTimeControlAnalysesDetails <- function(workFolder) {

  # Chou replication --------------------------------------------------------
  cdAp <- CaseCrossover::createGetDbCaseCrossoverDataArgs(getTimeControlData = TRUE)

  matchingCriteria <- CaseCrossover::createMatchingCriteria(controlsPerCase = 1,
                                                            matchOnAge = TRUE,
                                                            ageCaliper = 1,
                                                            matchOnGender = TRUE)

  ccAp <- CaseCrossover::createSelectSubjectsToIncludeArgs(firstOutcomeOnly = TRUE,
                                                           washoutPeriod = 365,
                                                           matchingCriteria = matchingCriteria)

  getExposureStatusArgs <- CaseCrossover::createGetExposureStatusArgs(firstExposureOnly = FALSE,
                                                                      riskWindowStart = 0,
                                                                      riskWindowEnd = 0,
                                                                      controlWindowOffsets = -30)

  ccrAnalysisAp <- CaseCrossover::createCcrAnalysis(analysisId = 1,
                                                    description = "Case-time-control",
                                                    getDbCaseCrossoverDataArgs = cdAp,
                                                    selectSubjectsToIncludeArgs = ccAp,
                                                    getExposureStatusArgs = getExposureStatusArgs)

  ccrAnalysisListAp <- list(ccrAnalysisAp)
  CaseCrossover::saveCcrAnalysisList(ccrAnalysisListAp, file.path(workFolder, "ccrAnalysisListAp.json"))

  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "EvaluatingCaseControl")
  negativeControls <- read.csv(pathToCsv)
  negativeControls <- negativeControls[negativeControls$outcomeName == "Acute pancreatitis", ]
  eon <- CaseCrossover::createExposureOutcomeNestingCohort(exposureId = 4, outcomeId = 2)
  eonsAp <- list(eon)
  for (i in 1:nrow(negativeControls)) {
    eon <- CaseCrossover::createExposureOutcomeNestingCohort(exposureId = negativeControls$targetId[i],
                                                             outcomeId = 2)
    eonsAp[[length(eonsAp) + 1]] <- eon
  }
  CaseCrossover::saveExposureOutcomeNestingCohortList(eonsAp, file.path(workFolder, "ccrExposureOutcomeNestingAp.json"))


  # Crockett replication ----------------------------------------------------

  cdIbd <- CaseCrossover::createGetDbCaseCrossoverDataArgs(getTimeControlData = TRUE)

  matchingCriteria <- CaseCrossover::createMatchingCriteria(controlsPerCase = 1,
                                                            matchOnAge = TRUE,
                                                            ageCaliper = 1,
                                                            matchOnGender = TRUE)

  ccIbd <- CaseCrossover::createSelectSubjectsToIncludeArgs(firstOutcomeOnly = TRUE,
                                                            washoutPeriod = 730,
                                                            matchingCriteria = matchingCriteria)

  getExposureStatusArgs <- CaseCrossover::createGetExposureStatusArgs(firstExposureOnly = FALSE,
                                                                      riskWindowStart = -365,
                                                                      riskWindowEnd = 0,
                                                                      controlWindowOffsets = -365)

  ccrAnalysisIbd <- CaseCrossover::createCcrAnalysis(analysisId = 1,
                                                     description = "Case-time-control",
                                                     getDbCaseCrossoverDataArgs = cdIbd,
                                                     selectSubjectsToIncludeArgs = ccIbd,
                                                     getExposureStatusArgs = getExposureStatusArgs)

  ccrAnalysisListIbd <- list(ccrAnalysisIbd)
  CaseCrossover::saveCcrAnalysisList(ccrAnalysisListIbd, file.path(workFolder, "ccrAnalysisListIbd.json"))

  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "EvaluatingCaseControl")
  negativeControls <- read.csv(pathToCsv)
  negativeControls <- negativeControls[negativeControls$outcomeName == "Acute pancreatitis", ]
  eon <- CaseCrossover::createExposureOutcomeNestingCohort(exposureId = 5, outcomeId = 3)
  eonsIbd <- list(eon)
  for (i in 1:nrow(negativeControls)) {
    eon <- CaseCrossover::createExposureOutcomeNestingCohort(exposureId = negativeControls$targetId[i],
                                                             outcomeId = 3)
    eonsIbd[[length(eonsIbd) + 1]] <- eon
  }
  CaseCrossover::saveExposureOutcomeNestingCohortList(eonsIbd, file.path(workFolder, "ccrExposureOutcomeNestingIbd.json"))
}
