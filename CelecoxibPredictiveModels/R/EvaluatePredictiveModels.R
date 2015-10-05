# Copyright 2015 Observational Health Data Sciences and Informatics
#
# This file is part of CelecoxibPredictiveModels
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

#' Compute evaluation metrics for the predictive models
#'
#' @details
#' This function computes the AUC and plots the ROC and calibration plots per predictive model.
#'
#' @param outputFolder	       Name of local folder to place results; make sure to use forward slashes (/)
#'
#' @export
evaluatePredictiveModels <- function(outputFolder) {

    outcomeIds <- 10:16

    testCohortDataFile <- file.path(outputFolder, "testCohortData")
    testCovariateDataFile <- file.path(outputFolder, "testCovariateData")
    testOutcomeDataFile <- file.path(outputFolder, "testOutcomeData")
    testCohortData <- PatientLevelPrediction::loadCohortData(testCohortDataFile)
    testCovariateData <- PatientLevelPrediction::loadCovariateData(testCovariateDataFile)
    testOutcomeData <- PatientLevelPrediction::loadOutcomeData(testOutcomeDataFile)

    for (outcomeId in outcomeIds){
        modelFile <- file.path(outputFolder, paste("model_o",outcomeId, ".rds", sep = ""))
        model <- readRDS(modelFile)

        predictionsFile <- file.path(outputFolder, paste("predictions_o",outcomeId, ".rds", sep = ""))
        if (file.exists(predictionsFile)){
            predictions <- readRDS(predictionsFile)
        } else {
            predictions <- PatientLevelPrediction::predictProbabilities(model, testCohortData, testCovariateData)
            saveRDS(predictions, predictionsFile)
        }

        aucFile <- file.path(outputFolder, paste("auc_o",outcomeId, ".csv", sep = ""))
        if (!file.exists(aucFile)){
            auc <- PatientLevelPrediction::computeAuc(predictions, testOutcomeData)
            write.csv(auc, aucFile, row.names = FALSE)
        }

        rocFile <- file.path(outputFolder, paste("roc_o",outcomeId, ".png", sep = ""))
        if (!file.exists(rocFile)){
            PatientLevelPrediction::plotRoc(predictions, testOutcomeData, fileName = rocFile)
        }

        calibrationFile <- file.path(outputFolder, paste("calibration_o",outcomeId, ".png", sep = ""))
        if (!file.exists(calibrationFile)){
            PatientLevelPrediction::plotCalibration(predictions, testOutcomeData, numberOfStrata = 10, fileName = calibrationFile)
        }
    }
}
