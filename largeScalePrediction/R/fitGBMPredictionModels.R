# @file fitGBMPredictionModels.R
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

#' Creates the gradient boosting machine models for all outcomes
#'
#' @description
#' This function creates the gradient boosting machine models for all outcomes
#'
#' @details
#' The patient level prediction runPlp function is called for each outcome to train
#' a gradient boosting machine model
#'
#' @param workFolder                   The directory where the plpData and population are saved to
#'
#' @return
#' Returns TRUE when finished and saves the models  into the workFolder directory
#' in the subdirectory named gbmModels
#' @export
fitGBMPredictionModels <- function(workFolder){

    plpData <- PatientLevelPrediction::loadPlpData(file.path(workFolder, 'data'))

    outcomeIds <- plpData$metaData$call$outcomeIds
    for(oid in outcomeIds){
        tryCatch({
            population <- readRDS(file.path(workFolder, 'Populations',paste0(oid,'.rds')))
            #attr(population, "metaData")$cohortId <- plpData$metaData$call$cohortId
            #attr(population, "metaData")$outcomeId <- oid

            modelSettings <- PatientLevelPrediction::setGradientBoostingMachine(ntrees=c(50,100,250),
                                                                                max_depth = c(4,7,16),
                                                                                min_rows = c(1,20))
            trainedModel <- PatientLevelPrediction::runPlp(population,plpData,
                                                           modelSettings,
                                                           testSplit='time',
                                                           testFraction=0.25,
                                                           nfold=3,
                                                           save=NULL)

            PatientLevelPrediction::savePlpResult(trainedModel, file.path(workFolder,'models', 'gbmModels',oid))

            PatientLevelPrediction::plotPlp(trainedModel, file.path(workFolder,'models', 'gbmModels',oid))
        },error = function(e) {
            flog.info(paste0('Error for ', oid, ': ',e))
        })

    }
}

