# @file generateLearningCurve.R
#
# This file is part of the learnig curve package
#
# Copyright 2018 Observational Health Data Sciences and Informatics
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

#' generateLearningCurve
#'
#' generateLearningCurve generates learning curves for all target data in the
#' work folder.
#'
#' @param workFolder the folder containing the data and populations
#'
#' @export
#'
#' @examples
#' # register a parallel backend
#' PatientLevelPrediction::registerParallelBackend()
#'
#' # generate the learning curves
#' generateLearningCurve(workFolder)
#'
#' # de-register parallel backend by registering a sequential backend
#' PatientLevelPrediction::registerSequentialBackend()
generateLearningCurve <- function(workFolder){

  plpData <- PatientLevelPrediction::loadPlpData(file.path(workFolder, 'data'))

  outcomeIds <- plpData$metaData$call$outcomeIds
  learningCurveList <- vector(mode = "list", length = length(outcomeIds))

  for (i in seq_along(outcomeIds)) {
    tryCatch({
      population <- readRDS(file.path(workFolder, 'Populations',paste0(outcomeIds[i],'.rds')))

      modelSettings <- PatientLevelPrediction::setLassoLogisticRegression()

      trainFraction <- seq(0.01, 0.8, 0.01)
      learningCurve <-
        PatientLevelPrediction::createLearningCurvePar(
          population,
          plpData,
          modelSettings,
          testSplit = 'person',
          testFraction = 0.2,
          trainFractions = trainFraction,
          nfold = 3,
          timeStamp = FALSE,
          splitSeed = 1000
        )
      learningCurveList[[i]] <- learningCurve
      print(PatientLevelPrediction::plotLearningCurve(learningCurve))

    },error = function(e) {
      flog.info(paste0('Error for ', outcomeIds[i], ': ',e))
    })
  }

  return(learningCurveList)
}
