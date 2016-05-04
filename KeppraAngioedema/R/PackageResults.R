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

#' Package the results for sharing with OHDSI researchers
#'
#' @details
#' This function packages the results.
#'
#' @param outputFolder   Name of local folder to place results; make sure to use forward slashes (/)
#'
#' @export
packageResults <- function(outputFolder) {
  exportFolder <- file.path(outputFolder, "export")

  if (!file.exists(exportFolder))
    dir.create(exportFolder)

  outcomeReference <- readRDS(file.path(outputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(outcomeReference)

  ### Write main results table ###
  write.csv(analysisSummary, file.path(exportFolder, "Results.csv"), row.names = FALSE)

  ### Main propensity score plot ###
  psFileName <- outcomeReference$sharedPsFile[outcomeReference$sharedPsFile != ""][1]
  ps <- readRDS(psFileName)
  CohortMethod::plotPs(ps, fileName = file.path(exportFolder, "PS_pref_scale.png"))
  CohortMethod::plotPs(ps, scale = "propensity", fileName = file.path(exportFolder, "PS.png"))

  ### Two covariate balance plots ###
  balFileName <- outcomeReference$covariateBalanceFile[outcomeReference$outcomeId == 3 & outcomeReference$analysisId == 3]
  balance <- readRDS(balFileName)
  CohortMethod::plotCovariateBalanceScatterPlot(balance, fileName = file.path(exportFolder,
                                                                              "Balance_scatterplot.png"))
  CohortMethod::plotCovariateBalanceOfTopVariables(balance, fileName = file.path(exportFolder,
                                                                                 "Balance_topVars.png"))

  ### Add all to zip file ###
  zipName <- file.path(exportFolder, "StudyResults.zip")
  OhdsiSharing::compressFolder(exportFolder, zipName)
  writeLines(paste("\nStudy results are ready for sharing at:", zipName))
}
