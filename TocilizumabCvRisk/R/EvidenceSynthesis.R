# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of TocilizumabCvRisk
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

combineAcrossDbs <- function(folders, labels, outputFolder) {
  #devtools::install_github("ohdsi/EvidenceSynthesis")
  negativeControls <- read.csv(system.file("settings", "NegativeControls.csv", package = "TocilizumabCvRisk"))
  targetOfInterestId <- 1 # Tocilizumab
  comparatorOfInterestId <- 2 # Etanercept
  outcomeOfInterestId <- 3 # MACE
  primaryAnalysisId <- 1 # ITT
  
  preparedPsPlots <- list()
  balances <- list()
  mdrrs <- data.frame()
  allNcOutcomes <- data.frame()
  allNcExposures <- data.frame()
  for (i in 1:length(folders)) {
    omReference <- readRDS(file.path(folders[i], "cmOutput", "outcomeModelReference.rds"))   
    analysisSummary <- CohortMethod::summarizeAnalyses(omReference)
    idx <- omReference$analysisId == primaryAnalysisId & 
      omReference$targetId == targetOfInterestId &
      omReference$comparatorId == comparatorOfInterestId &
      omReference$outcomeId == outcomeOfInterestId
    ps <- readRDS(omReference$sharedPsFile[idx])
    strataPop <- readRDS(omReference$strataFile[idx])   
    cmData <- CohortMethod::loadCohortMethodData(omReference$cohortMethodDataFolder[idx])
    
    preparedPsPlots[[i]] <- EvidenceSynthesis::preparePsPlot(ps)
    # balances[[i]] <- CohortMethod::computeCovariateBalance(strataPop, cmData)
    mdrr <- CohortMethod::computeMdrr(population = strataPop,
                                      alpha = 0.05,
                                      power = 0.8,
                                      twoSided = TRUE,
                                      modelType = "cox")
    mdrr$label <- labels[i]
    mdrrs <- rbind(mdrrs, mdrr)
    
    ncOutcomes <- analysisSummary[analysisSummary$outcomeId %in% negativeControls$outcomeId[negativeControls$type == "Outcome"], ]
    ncOutcomes$label <- labels[i]
    allNcOutcomes <- rbind(allNcOutcomes, ncOutcomes)
    
    ncExposures <- analysisSummary[analysisSummary$targetId %in% negativeControls$targetId[negativeControls$type == "Exposure"] &
                                     analysisSummary$outcomeId == outcomeOfInterestId, ]
    ncExposures$label <- labels[i]
    allNcExposures <- rbind(allNcExposures, ncExposures)
  }
  for (analysisId in unique(ncOutcomes$analysisId)) {
    idx <- allNcOutcomes$analysisId == analysisId
    fileName = file.path(outputFolder, paste0("bias_outcome_controls_a", analysisId, ".png"))
    EvidenceSynthesis::plotEmpiricalNulls(logRr = allNcOutcomes$logRr[idx],
                                          seLogRr = allNcOutcomes$seLogRr[idx],
                                          labels = allNcOutcomes$label[idx],
                                          showCis = TRUE,
                                          fileName = fileName)
    idx <- allNcExposures$analysisId == analysisId
    # saveRDS(allNcExposures[idx, ], file.path(outputFolder, "ncs.rds"))
    fileName = file.path(outputFolder, paste0("bias_exposure_controls_a", analysisId, ".png"))
    EvidenceSynthesis::plotEmpiricalNulls(logRr = allNcExposures$logRr[idx],
                                          seLogRr = allNcExposures$seLogRr[idx],
                                          labels = allNcExposures$label[idx],
                                          showCis = TRUE,
                                          fileName = fileName)
  }
  
  # saveRDS(balances, file.path(outputFolder, "balances.rds"))
  # balances <- readRDS(file.path(outputFolder, "balances.rds"))
  fileName = file.path(outputFolder, "balance.png")
  EvidenceSynthesis::plotCovariateBalances(balances = balances,
                                           labels = labels,
                                           beforeLabel = "Before stratification",
                                           afterLabel = "After stratification",
                                           threshold = 0.1,
                                           fileName = fileName)
  
  saveRDS(preparedPsPlots, file.path(outputFolder, "pss.rds"))
  preparedPsPlots <- readRDS(file.path(outputFolder, "pss.rds"))
  fileName = file.path(outputFolder, "ps.png")
  EvidenceSynthesis::plotPreparedPs(preparedPsPlots = preparedPsPlots,
                                    labels = labels,
                                    treatmentLabel = "Tocilizumab",
                                    comparatorLabel = "Etanercept",
                                    fileName = fileName)
  
  fileName = file.path(outputFolder, "mdrr.csv")
  write.csv(mdrrs, fileName, row.names = FALSE)
}