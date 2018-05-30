# @file functions
#
# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of:
#  ----------------------------------------------
#  DiabetesTxPath
#  ----------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#'
#' @title
#' negativeControlAnalysis
#'
#' @author
#' Jamie Weaver
#'
#' @details
#' This function executes the DiabetesTxPath comparative cohort study across a set of negative
#' control outcomes in order to create an empirical null distribution against which the main effects
#' can be calibrated. This is a method to account for residual systematic error in the study design.
#'
#' @param connectionDetails       The connection details of the database.
#' @param cdmDatabaseSchema       The cdm database schema
#' @param resultsDatabaseSchema   The results datavase schema
negativeControlAnalysis <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    results_path,
                                    createExposureCohorts = FALSE,
                                    createNegativeControlOutcomeCohorts = TRUE,
                                    maxCores){
  if (createExposureCohorts){
      DiabetesTxPath::createExposureCohorts(
      connectionDetails     = connectionDetails,
      cdmDatabaseSchema     = cdmDatabaseSchema,
      resultsDatabaseSchema = resultsDatabaseSchema
    )
  }
  if (createNegativeControlOutcomeCohorts){
      DiabetesTxPath::createNegativeControlOutcomeCohorts(
      connectionDetails     = connectionDetails,
      cdmDatabaseSchema     = cdmDatabaseSchema,
      resultsDatabaseSchema = resultsDatabaseSchema
    )
  }
  covariateSettings <- FeatureExtraction::createCovariateSettings(
    useDemographicsGender          = TRUE,
    useDemographicsAge             = TRUE,
    useDemographicsAgeGroup        = TRUE,
    useConditionOccurrenceLongTerm = TRUE,
    useDrugExposureLongTerm        = TRUE,
    useProcedureOccurrenceLongTerm = TRUE,
    excludedCovariateConceptIds    = c(1529331,1510202,1503297,43013884,40239216,40166035,1580747,19122137,44816332,45774435,
                                       1583722,40170911,1502826,1516766,44785829,43526465,45774751,1597756,19059796,1560171,
                                       1559684,1594973,1502809,1502855,1547504,1525215,253182,86009,51428,274783,139825,5856,
                                       352385,314684,400008,314683),
    addDescendantsToExclude        = TRUE
  )
  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(
    studyStartDate             = "",
    studyEndDate               = "",
    excludeDrugsFromCovariates = FALSE,
    firstExposureOnly          = TRUE,
    removeDuplicateSubjects    = TRUE,
    restrictToCommonPeriod     = FALSE,
    washoutPeriod              = 0,
    maxCohortSize              = 0,
    covariateSettings          = covariateSettings
  )
  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(
    firstExposureOnly              = FALSE, #TRUE in getDbCohortMethodData?
    restrictToCommonPeriod         = FALSE,
    washoutPeriod                  = 0,
    removeDuplicateSubjects        = FALSE, #TRUE in getDbCohortMethodData?
    removeSubjectsWithPriorOutcome = TRUE,
    priorOutcomeLookback           = 99999,
    minDaysAtRisk                  = 0,
    riskWindowStart                = 0,
    addExposureDaysToStart         = FALSE,
    riskWindowEnd                  = 0,
    addExposureDaysToEnd           = TRUE
  )
  createPsArgs <- CohortMethod::createCreatePsArgs(
    excludeCovariateIds = c(),
    includeCovariateIds = c(),
    maxCohortSizeForFitting = 250000,
    errorOnHighCorrelation = TRUE,
    stopOnError            = TRUE,
    prior                  = Cyclops::createPrior(priorType          = "laplace",
                                                  useCrossValidation = TRUE),
    control                = Cyclops::createControl(cvType           = "auto",
                                                    startingVariance = 0.01,
                                                    tolerance        = 2e-07,
                                                    cvRepetitions    = 10,
                                                    noiseLevel       = "quiet")
  )
  matchOnPsArgs <- CohortMethod::createMatchOnPsArgs(
    caliper      = 0.25,
    caliperScale = "standardized logit",
    maxRatio     = 1
  )
  fitOutcomeModelArgs <- CohortMethod::createFitOutcomeModelArgs(
    modelType           = "cox",
    stratified          = TRUE,
    useCovariates       = FALSE,
    excludeCovariateIds = c(),
    includeCovariateIds = c(),
    prior               = Cyclops::createPrior(priorType          = "laplace",
                                               useCrossValidation = TRUE),
    control             = Cyclops::createControl(cvType           = "auto",
                                                 startingVariance = 0.01,
                                                 tolerance        = 2e-07,
                                                 cvRepetitions    = 10,
                                                 noiseLevel       = "quiet")
  )
  cmAnalysis1 <- CohortMethod::createCmAnalysis(
    analysisId                    = 2,
    description                   = "Negative control analyses for DiabetesTxPath",
    targetType                    = NULL,
    comparatorType                = NULL,
    getDbCohortMethodDataArgs     = getDbCmDataArgs,
    createStudyPopArgs            = createStudyPopArgs,
    createPs                      = TRUE,
    createPsArgs                  = createPsArgs,
    trimByPs                      = FALSE,
    trimByPsArgs                  = NULL,
    trimByPsToEquipoise           = FALSE,
    trimByPsToEquipoiseArgs       = NULL,
    matchOnPs                     = TRUE,
    matchOnPsArgs                 = matchOnPsArgs,
    matchOnPsAndCovariates        = FALSE,
    matchOnPsAndCovariatesArgs    = NULL,
    stratifyByPs                  = FALSE,
    stratifyByPsArgs              = NULL,
    stratifyByPsAndCovariates     = FALSE,
    stratifyByPsAndCovariatesArgs = NULL,
    computeCovariateBalance       = TRUE,
    fitOutcomeModel               = TRUE,
    fitOutcomeModelArgs           = fitOutcomeModelArgs
  )
  cmAnalysisList <- list(cmAnalysis1)
  negativeControls <- read.csv(system.file("settings", "negativeControls.csv", package = "DiabetesTxPath"))
  negativeControlConceptIds <- negativeControls$concept_id
  cohortsToCreate <- cbind(c(1:3), read.csv(system.file("settings/CohortsToCreate.csv", package = "DiabetesTxPath"))[1:3, ])
  comparisons <- base::t(utils::combn(x = cohortsToCreate[, 1], m = 2))
  drugComparatorOutcomesList <- list()
  for (i in 1:nrow(comparisons)){
    drugComparatorOutcomesList[[i]] <- CohortMethod::createDrugComparatorOutcomes(
      targetId                    = comparisons[i, 1],
      comparatorId                = comparisons[i, 2],
      excludedCovariateConceptIds = c(),
      includedCovariateConceptIds = c(),
      outcomeIds                  = negativeControlConceptIds
    )
  }
  outputFolder <- paste(results_path,"deleteMeBeforeSharing/",sep="")
  result <- CohortMethod::runCmAnalyses(
    connectionDetails            = connectionDetails,
    cdmDatabaseSchema            = cdmDatabaseSchema,
    exposureDatabaseSchema       = resultsDatabaseSchema ,
    exposureTable                = "ohdsi_t2dpathway",
    outcomeDatabaseSchema        = resultsDatabaseSchema,
    outcomeTable                 = "ohdsi_t2dpathway_neg_controls",
    cdmVersion                   = 5,
    outputFolder                 = outputFolder,
    cmAnalysisList               = cmAnalysisList,
    drugComparatorOutcomesList   = drugComparatorOutcomesList,
    getDbCohortMethodDataThreads = 1,
    createPsThreads              = 1,
    psCvThreads                  = min(16, maxCores),
    computeCovarBalThreads       = min(3, maxCores),
    createStudyPopThreads        = min(3, maxCores),
    trimMatchStratifyThreads     = min(10, maxCores),
    fitOutcomeModelThreads       = max(1, round(maxCores/4)),
    outcomeCvThreads             = min(4, maxCores),
    refitPsForEveryOutcome       = FALSE,
    outcomeIdsOfInterest         = NULL
  )
  analysisSummary <- CohortMethod::summarizeAnalyses(result)
  write.csv(x = analysisSummary, file = paste(results_path,"negativeControlResults.csv",sep=""), row.names = FALSE)
  mainSummary <- read.csv(file = paste(results_path,"T2DStudyOutcome.csv",sep=""))
  fullSummary <- rbind(mainSummary,analysisSummary)
  # Calibrate p-values:
  newSummary <- data.frame()
  for (drugComparatorOutcome in drugComparatorOutcomesList)
  {
    for (analysisId in unique(fullSummary$analysisId))
    {
      subset <- fullSummary[fullSummary$analysisId == analysisId &
                                  fullSummary$targetId == drugComparatorOutcome$targetId &
                                  fullSummary$comparatorId == drugComparatorOutcome$comparatorId, ]

      negControlSubset <- subset[subset$outcomeId %in% negativeControlConceptIds, ]
      negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr != 0, ]
      hoiSubset <- subset[!(subset$outcomeId %in% negativeControlConceptIds), ]
      hoiSubset <- hoiSubset[!is.na(hoiSubset$logRr) & hoiSubset$logRr != 0, ]
      if (nrow(negControlSubset) > 10) {
        null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
        plotName <- paste("calEffect_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
        EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                    negControlSubset$seLogRr,
                                                    hoiSubset$logRr,
                                                    hoiSubset$seLogRr,
                                                    fileName = paste(results_path, plotName,sep=""))
        calibratedP <- EmpiricalCalibration::calibrateP(null, subset$logRr, subset$seLogRr)
        subset$calibratedP <- calibratedP$p
        subset$calibratedP_lb95ci <- calibratedP$lb95ci
        subset$calibratedP_ub95ci <- calibratedP$ub95ci
        mcmc <- attr(null, "mcmc")
        subset$null_mean <- mean(mcmc$chain[, 1])
        subset$null_sd <- 1/sqrt(mean(mcmc$chain[, 2]))
      } else {
        subset$calibratedP <- NA
        subset$calibratedP_lb95ci <- NA
        subset$calibratedP_ub95ci <- NA
        subset$null_mean <- NA
        subset$null_sd <- NA
      }
      newSummary <- rbind(newSummary, subset)
    }
  }
  newSummary$rr <- exp(newSummary$logRr)
  newSummary$seRr <- exp(newSummary$seLogRr)
  write.csv(x    = newSummary[!newSummary$outcomeId %in% negativeControlConceptIds,],
            file = paste(results_path,"calibratedSummary.csv",sep=""), row.names = FALSE)
}
