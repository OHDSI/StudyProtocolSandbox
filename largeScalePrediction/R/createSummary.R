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
#' @param workFolder                   The directory where the plpData and population are saved to
#'
#' @return
#' Returns TRUE when finished and saves the summary csv  into the workFolder directory
#' names summary.csv
#' @export
createSummary <- function(workFolder){
    # find all the models
    locations <- list.dirs(workFolder)[grep('evaluation', list.dirs(workFolder))]

    # for each outcome extract the testEvaluationStatistics and trainEvaluationStatistics
    # from the evaluation folder

    getDetails<- function(location){
        sepVals <- strsplit(location,'/')[[1]]
        result <- c(model = sepVals[length(sepVals)-3],
                    outcomeId = sepVals[length(sepVals)-2],
                    analysisId = as.double(sepVals[length(sepVals)-1]))

        test <- read.csv(file.path(location,"testEvaluationStatistics.csv"))
        colnames(test)[-1] <- paste0(colnames(test[-1]), 'Test')
        train <- read.csv(file.path(location,"trainEvaluationStatistics.csv"))
        colnames(train)[-1] <- paste0(colnames(train[-1]), 'Train')
        result <- unlist(c(result, test[-1], train[-1]))

        return(result)
    }


    completeSummary <- t(sapply(locations, getDetails))
    outcomes <- system.file("settings", "OutcomesOfInterest.csv", package = "LargeScalePrediction")
    outcomes <- read.csv(outcomes)
    completeSummary <- merge(outcomes, completeSummary, by.x='cohortDefinitionId',
                             by.y='outcomeId')

    write.csv(completeSummary, file.path(workFolder, 'summary.csv'))


    return(TRUE)
}
