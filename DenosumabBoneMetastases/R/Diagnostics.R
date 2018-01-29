# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of DenosumabBoneMetastases
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

#' Generate diagnostics
#'
#' @details
#' This function generates analyses diagnostics. Requires the study to be executed first.
#'

#' @param outputFolder         Name of local folder where the results were generated; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#'
#' @export
generateDiagnostics <- function(outputFolder) {
  cmOutputFolder <- file.path(outputFolder, "cmOutput")
  diagnosticsFolder <- file.path(outputFolder, "diagnostics")
  if (!file.exists(diagnosticsFolder))
    dir.create(diagnosticsFolder)
  
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = "DenosumabBoneMetastases")
  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
  
  reference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(reference)
  analysisSummary <- addCohortNames(analysisSummary, "targetId", "targetName")
  analysisSummary <- addCohortNames(analysisSummary, "comparatorId", "comparatorName")
  analysisSummary <- addCohortNames(analysisSummary, "outcomeId", "outcomeName")
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(system.file("settings", "cmAnalysisList.json", package = "DenosumabBoneMetastases"))
  for (i in 1:length(cmAnalysisList)) {
    analysisSummary$description[analysisSummary$analysisId == cmAnalysisList[[i]]$analysisId] <-  cmAnalysisList[[i]]$description
  }
  negativeControls <- read.csv(system.file("settings", "NegativeControls.csv", package = "DenosumabBoneMetastases"))
  negativeControlOutcomeIds <- negativeControls$outcomeId[negativeControls$type == "Outcome"]
  tcsOfInterest <- unique(tcosOfInterest[, c("targetId", "comparatorId")])
  for (i in 1:nrow(tcsOfInterest)) {
    targetId <- tcsOfInterest$targetId[i]
    comparatorId <- tcsOfInterest$comparatorId[i]
    outcomeIds <- tcosOfInterest$outcomeId[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId]
    for (analysisId in unique(reference$analysisId)) {
      # Outcome controls
      label <- "OutcomeControls"
      negControlSubset <- analysisSummary[analysisSummary$analysisId == analysisId &
                                            analysisSummary$targetId == targetId &
                                            analysisSummary$comparatorId == comparatorId &
                                            analysisSummary$outcomeId %in% negativeControlOutcomeIds, ]
      
      validNcs <- sum(!is.na(negControlSubset$seLogRr))
      if (validNcs >= 5) {
        null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
        
        fileName <-  file.path(diagnosticsFolder, paste0("nullDistribution_a",analysisId,"_t",targetId,"_c",comparatorId,"_", label, ".png"))
        EmpiricalCalibration::plotCalibrationEffect(logRrNegatives = negControlSubset$logRr,
                                                    seLogRrNegatives = negControlSubset$seLogRr,
                                                    null = null,
                                                    showCis = TRUE,
                                                    title = label,
                                                    fileName = fileName)
        
      }
      for (outcomeId in outcomeIds) {
        # Compute MDRR
        strataFile <- reference$strataFile[reference$analysisId == analysisId &
                                             reference$targetId == targetId &
                                             reference$comparatorId == comparatorId &
                                             reference$outcomeId == outcomeId]
        population <- readRDS(strataFile)
        mdrr <- CohortMethod::computeMdrr(population, alpha = 0.05, power = 0.8, twoSided = TRUE, modelType = "cox")
        fileName <-  file.path(diagnosticsFolder, paste0("mdrr_a",analysisId,"_t",targetId,"_c",comparatorId, "_o", outcomeId, ".csv"))
        write.csv(mdrr, fileName, row.names = FALSE)
        fileName <-  file.path(diagnosticsFolder, paste0("attrition_a",analysisId,"_t",targetId,"_c",comparatorId, "_o", outcomeId, ".png"))
        CohortMethod::drawAttritionDiagram(population, treatmentLabel = "Denosumab", comparatorLabel = "Zoledronic acid", fileName = fileName)
        fileName <-  file.path(diagnosticsFolder, paste0("type1Error_a",analysisId,"_t",targetId,"_c",comparatorId, "_o", outcomeId,"_", label, ".png"))
        EmpiricalCalibration::plotExpectedType1Error(seLogRrPositives = mdrr$se,
                                                     null = null,
                                                     showCis = TRUE,
                                                     title = label,
                                                     fileName = fileName)
      }
      exampleRef <- reference[reference$analysisId == analysisId &
                                reference$targetId == targetId &
                                reference$comparatorId == comparatorId &
                                reference$outcomeId == outcomeIds[1], ]
      
      ps <- readRDS(exampleRef$sharedPsFile)
      fileName <-  file.path(diagnosticsFolder, paste0("psBeforeStratification_a",analysisId,"_t",targetId,"_c",comparatorId,".png"))
      psPlot <- CohortMethod::plotPs(data = ps,
                                     treatmentLabel = "Denosumab",
                                     comparatorLabel = "Zoledronic acid",
                                     fileName = fileName)
      
      psAfterMatching <- readRDS(exampleRef$strataFile)
      fileName <-  file.path(diagnosticsFolder, paste0("psAfterStratification_a",analysisId,"_t",targetId,"_c",comparatorId,".png"))
      psPlot <- CohortMethod::plotPs(data = psAfterMatching,
                                     treatmentLabel = "Denosumab",
                                     comparatorLabel = "Zoledronic acid",
                                     fileName = fileName)
      
      fileName = file.path(diagnosticsFolder, paste("followupDist_a",analysisId,"_t",targetId,"_c",comparatorId, ".png",sep=""))
      CohortMethod::plotFollowUpDistribution(psAfterMatching, 
                                             targetLabel = "Denosumab",
                                             comparatorLabel = "Zoledronic acid",
                                             fileName = fileName)
      
      cmdata <- CohortMethod::loadCohortMethodData(exampleRef$cohortMethodDataFolder)
      balance <- CohortMethod::computeCovariateBalance(psAfterMatching, cmdata)
      
      fileName = file.path(diagnosticsFolder, paste("balanceScatter_a",analysisId,"_t",targetId,"_c",comparatorId,".png",sep=""))
      balanceScatterPlot <- CohortMethod::plotCovariateBalanceScatterPlot(balance = balance,
                                                                          beforeLabel = "Before stratification",
                                                                          afterLabel = "After stratification",
                                                                          fileName = fileName)
      
      fileName = file.path(diagnosticsFolder, paste("balanceTop_a",analysisId,"_t",targetId,"_c",comparatorId,".png",sep=""))
      balanceTopPlot <- CohortMethod::plotCovariateBalanceOfTopVariables(balance = balance,
                                                                         beforeLabel = "Before stratification",
                                                                         afterLabel = "After stratification",
                                                                         fileName = fileName)
    }
  }
}
