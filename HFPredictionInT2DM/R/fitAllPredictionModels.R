# @file fitAllPredictionModels.R
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

#' Creates the models for each classifier for all outcomes
#'
#' @description
#' This function creates the models for each classifier for all outcomes
#'
#' @details
#' The patient level prediction runPlp function is called for each outcome to train
#' each classifier
#'
#' @param workFolder                   The directory where the plpData and population are saved to
#'
#' @return
#' Returns TRUE when finished and saves the models into the workFolder directory
#' in the subdirectory named models
#' @export
fitAllPredictionModels <- function(workFolder,
                                   verbosity=INFO){

    flog.seperator()
    flog.info('Fitting models')
    flog.seperator()

    # add log starting lasso regularised logistic regression
    flog.info('Fitting lasso regularised logistic regression')
    fitLassoPredictionModels(file.path(workFolder))

    # add log starting gbm model
    flog.info('Fitting GBM ')
    fitGBMPredictionModels(file.path(workFolder))

    # add log starting random forest
    flog.info('Fitting random forest ')
    fitRFPredictionModels(file.path(workFolder))

    # add log starting naive bayes
    flog.info('Fitting naive bayes ')
    fitNaiveBayesPredictionModels(file.path(workFolder))

    # add log starting knn
    flog.info('Fitting KNN ')
    fitKNNPredictionModels(file.path(workFolder))

    return(TRUE)

}

