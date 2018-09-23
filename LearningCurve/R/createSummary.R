# @file createSummary.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of LargeScalePrediction package
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

#' Get the summary details for the directory
#'
#' @description
#' This function creates a csv summarising all the model results
#'
#' @details
#' Searching through the directory to extract the model evaluation for each model
#'
#' @param workFolder   The directory where the plpData and population are saved to
#'
#' @return
#' Returns TRUE when finished and saves the summary csv into the workFolder directory names
#' summary.csv
#' @export
createSummary <- function(workFolder) {
  # find all the models
  locations <- list.dirs(workFolder, full.names = FALSE)[grep("/model$", list.dirs(workFolder))]
  locations <- gsub("/model", "", locations)

  # for each outcome extract the testEvaluationStatistics and trainEvaluationStatistics from the
  # evaluation folder

  getDetails <- function(location) {
    result <- PatientLevelPrediction::loadPlpResult(location)
    trainRes <- result$performanceEvaluation$evaluationStatistics[result$performanceEvaluation$evaluationStatistics[, "Eval"] == "train", "Value"]
    if (sum(names(trainRes) %in% c("AUC.auc_lb95ci")) < 1)
      trainRes$AUC.auc_lb95ci <- NULL
    if (sum(names(trainRes) %in% c("AUC.auc_lb95ci.1")) < 1)
      trainRes$AUC.auc_lb95ci.1 <- NULL
    names(trainRes) <- paste0("train_", names(trainRes))
    testRes <- result$performanceEvaluation$evaluationStatistics[result$performanceEvaluation$evaluationStatistics[, "Eval"] == "test", "Value"]
    if (sum(names(testRes) %in% c("AUC.auc_lb95ci")) < 1)
      testRes$AUC.auc_lb95ci <- NULL
    if (sum(names(testRes) %in% c("AUC.auc_lb95ci.1")) < 1)
      testRes$AUC.auc_lb95ci.1 <- NULL
    names(testRes) <- paste0("test_", names(testRes))

    result <- c(model = result$inputSetting$modelSettings$model,
                outcomeId = result$inputSetting$populationSettings$outcomeId,
                trainRes,
                testRes)

    return(result)
  }


  completeSummary <- t(sapply(file.path(workFolder, locations), getDetails))
  outcomes <- system.file("settings", "OutcomesOfInterest.csv", package = "LargeScalePrediction")
  outcomes <- read.csv(outcomes)
  completeSummary <- merge(outcomes,
                           completeSummary,
                           by.x = "cohortDefinitionId",
                           by.y = "outcomeId")

  write.csv(completeSummary, file.path(workFolder, "summary.csv"))

  return(TRUE)
}
