# Copyright 2017 Observational Health Data Sciences and Informatics
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

runCaseControlDesigns <- function(connectionDetails = connectionDetails,
                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                  workDatabaseSchema = workDatabaseSchema,
                                  studyCohortTable = studyCohortTable,
                                  oracleTempSchema = oracleTempSchema,
                                  maxCores = maxCores,
                                  workFolder) {
  ccApFolder <- file.path(workFolder, "ccAp")
  if (!file.exists(ccApFolder))
    dir.create(ccApFolder)

  analysisListFile <- system.file("settings", "ccAnalysisListAp.json", package = "EvaluatingCaseControl")
  analysisList <- CaseControl::loadCcAnalysisList(analysisListFile)
  eonFile <- system.file("settings", "ccExposureOutcomeNestingAp.json", package = "EvaluatingCaseControl")
  eonList <- CaseControl::loadExposureOutcomeNestingCohortList(eonFile)
  ccResult <- CaseControl::runCcAnalyses(connectionDetails = connectionDetails,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         oracleTempSchema = oracleTempSchema,
                                         exposureDatabaseSchema = workDatabaseSchema,
                                         exposureTable = studyCohortTable,
                                         outcomeDatabaseSchema = workDatabaseSchema,
                                         outcomeTable = studyCohortTable,
                                         nestingCohortDatabaseSchema = workDatabaseSchema,
                                         nestingCohortTable = studyCohortTable,
                                         ccAnalysisList = analysisList,
                                         exposureOutcomeNestingCohortList = eonList,
                                         outputFolder = ccApFolder,
                                         getDbCaseDataThreads = 1,
                                         selectControlsThreads = min(3, maxCores),
                                         getDbExposureDataThreads = 1,
                                         createCaseControlDataThreads = min(5, maxCores),
                                         fitCaseControlModelThreads = 1,#min(5, maxCores),
                                         cvThreads = min(2,maxCores),
                                         prefetchExposureData = FALSE)
  ccSummary <- CaseControl::summarizeCcAnalyses(ccResult)
  saveRDS(ccSummary, ccSummaryFile)
  # model <- readRDS(ccResult$modelFile)
  # ed <- loadCaseControlsExposure(ccResult$exposureDataFile)
  # covs <- ff::as.ram(ed$covariates)
  # sum(covs$covariateId == 4)
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
createCaseControlAnalysesDetails <- function(workFolder) {
  cdAp <- CaseControl::createGetDbCaseDataArgs(useNestingCohort = TRUE,
                                               useObservationEndAsNestingEndDate = TRUE,
                                               getVisits = FALSE)

  ccAp <- CaseControl::createSelectControlsArgs(firstOutcomeOnly = TRUE,
                                                washoutPeriod = 365,
                                                controlsPerCase = 1,
                                                matchOnAge = TRUE,
                                                ageCaliper = 1,
                                                matchOnGender = TRUE,
                                                matchOnProvider = FALSE,
                                                matchOnVisitDate = FALSE,
                                                matchOnTimeInCohort = TRUE,
                                                daysInCohortCaliper = 365,
                                                removedUnmatchedCases = TRUE)

  pathToCsv <- system.file("settings", "Icd9Covariates.csv", package = "EvaluatingCaseControl")
  icd9CovariateDefs <- read.csv(pathToCsv)
  icd9CovariateSettings <- createIcd9CovariateSettings(icd9CovariateDefs)

  pathToCsv <- system.file("settings", "AtcCovariates.csv", package = "EvaluatingCaseControl")
  atcCovariateDefs <- read.csv(pathToCsv)
  atcCovariateSettings <- createAtcCovariateSettings(atcCovariateDefs)

  defaultCovariateSettings = FeatureExtraction::createCovariateSettings(
    useCovariateRiskScores = TRUE,
    useCovariateRiskScoresDCSI = TRUE,
    windowEndDays = 1
  )

  edAp <-  CaseControl::createGetDbExposureDataArgs(covariateSettings = list(icd9CovariateSettings,
                                                                             atcCovariateSettings,
                                                                             defaultCovariateSettings))

  ccdAp <- CaseControl::createCreateCaseControlDataArgs(firstExposureOnly = FALSE,
                                                        riskWindowStart = 0,
                                                        riskWindowEnd = 0)

  mAp <-  CaseControl::createFitCaseControlModelArgs(useCovariates = TRUE,
                                                     prior = Cyclops::createPrior("normal", 10000))

  ccAnalysisAp <- CaseControl::createCcAnalysis(analysisId = 1,
                                                description = "Chou replication for AP",
                                                getDbCaseDataArgs = cdAp,
                                                selectControlsArgs = ccAp,
                                                getDbExposureDataArgs = edAp,
                                                createCaseControlDataArgs = ccdAp,
                                                fitCaseControlModelArgs = mAp)

  ccAnalysisListAp <- list(ccAnalysisAp)
  CaseControl::saveCcAnalysisList(ccAnalysisListAp, file.path(workFolder, "ccAnalysisListAp.json"))
  x <- jsonlite::toJSON(ccAnalysisListAp, pretty = TRUE, force = TRUE,
                   null = "null", auto_unbox = TRUE)


  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "EvaluatingCaseControl")
  negativeControls <- read.csv(pathToCsv)

  eon <- CaseControl::createExposureOutcomeNestingCohort(exposureId = 4, outcomeId = 2, nestingCohortId = 1)
  eonsAp <- list(eon)
  for (i in 1:nrow(negativeControls)) {
    eon <- CaseControl::createExposureOutcomeNestingCohort(exposureId = negativeControls$targetId[i],
                                                           outcomeId = 2,
                                                           nestingCohortId = negativeControls$nestingId[i])
    eonsAp[[length(eonsAp) + 1]] <- eon
  }
  CaseControl::saveExposureOutcomeNestingCohortList(eonsAp, file.path(workFolder, "ccExposureOutcomeNestingAp.json"))
}
