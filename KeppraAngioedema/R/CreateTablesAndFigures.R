# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of KeppraAngioedema
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


#' Create tables and figures
#'
#' @details
#' Creates tables and figures for viewing and interpreting the results. Requires that the \code{\link{execute}} function has
#' completed first.
#'
#' @param outputFolder  The path to the output folder containing the results.
#'
#' @export
createTableAndFigures <- function(outputFolder) {
  outcomeReference <- readRDS(file.path(outputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(outcomeReference)
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(file.path(outputFolder, "cmAnalysisList.txt"))
  # Add analysis description:
  for (i in 1:length(cmAnalysisList)) {
    analysisSummary$description[analysisSummary$analysisId == cmAnalysisList[[i]]$analysisId] <- cmAnalysisList[[i]]$description
  }

  negControlCohortIds <- unique(analysisSummary$outcomeId[analysisSummary$outcomeId > 100])
  # Calibrate p-values:
  for (analysisId in unique(analysisSummary$analysisId)) {
    negControlSubset <- analysisSummary[analysisSummary$analysisId == analysisId & analysisSummary$outcomeId %in%
      negControlCohortIds, ]
    negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr !=
      0, ]
    if (nrow(negControlSubset) > 10) {
      null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
      subset <- analysisSummary[analysisSummary$analysisId == analysisId, ]
      calibratedP <- EmpiricalCalibration::calibrateP(null, subset$logRr, subset$seLogRr)
      subset$calibratedP <- calibratedP$p
      subset$calibratedP_lb95ci <- calibratedP$lb95ci
      subset$calibratedP_ub95ci <- calibratedP$ub95ci
      mcmc <- attr(null, "mcmc")
      subset$null_mean <- mean(mcmc$chain[, 1])
      subset$null_sd <- 1/sqrt(mean(mcmc$chain[, 2]))
      analysisSummary$calibratedP[analysisSummary$analysisId == analysisId] <- subset$calibratedP
      analysisSummary$calibratedP_lb95ci[analysisSummary$analysisId == analysisId] <- subset$calibratedP_lb95ci
      analysisSummary$calibratedP_ub95ci[analysisSummary$analysisId == analysisId] <- subset$calibratedP_ub95ci
      analysisSummary$null_mean[analysisSummary$analysisId == analysisId] <- subset$null_mean
      analysisSummary$null_sd[analysisSummary$analysisId == analysisId] <- subset$null_sd
    }
  }
  write.csv(analysisSummary, file.path(outputFolder, "Results.csv"), row.names = FALSE)
}
