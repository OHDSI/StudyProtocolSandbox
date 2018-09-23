# @file fitRFPredictionModels.R
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

#' Creates the random forest models for all outcomes
#'
#' @description
#' This function creates the random forest models for all outcomes
#'
#' @details
#' The patient level prediction runPlp function is called for each outcome to train
#' a random forest model
#'
#' @param workFolder                   The directory where the plpData and population are saved to
#'
#' @return
#' Returns TRUE when finished and saves the models  into the workFolder directory
#' in the subdirectory named rfModels
#' @export
fitRFPredictionModels <- function(workFolder){

    plpData <- PatientLevelPrediction::loadPlpData(file.path(workFolder, 'data'))

    #outcomeIds <- plpData$metaData$call$outcomeIds
    outcomes <- system.file("settings", "OutcomesOfInterest.csv", package = "LargeScalePrediction")
    outcomes <- read.csv(outcomes)
    outcomeIds <- outcomes$cohortDefinitionId

    for(oid in outcomeIds){
        tryCatch({
            population <- readRDS(file.path(workFolder, 'Populations',paste0(oid,'.rds')))

            modelSettings <- PatientLevelPrediction::setRandomForest(ntrees=c(50,500,1000),
                                                                     mtries = c(-1,50,500),
                                                                     max_depth=c(4,10,17),
                                                                     varImp=T)#c(T,F))
            trainedModel <- PatientLevelPrediction::runPlp(population,plpData,
                                                           modelSettings,
                                                           testSplit='time',
                                                           testFraction=0.25,
                                                           nfold=3,
                                                           save=NULL
            )

            PatientLevelPrediction::savePlpResult(trainedModel, file.path(workFolder,'models', 'rfModels',oid))


            PatientLevelPrediction::plotPlp(trainedModel, file.path(workFolder,'models', 'rfModels',oid))

        },error = function(e) {
            flog.info(paste0('Error for ', oid, ': ',e))
        })






    }
}

