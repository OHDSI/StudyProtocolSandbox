#' Perform empirical calibration
#'
#' @details
#' Performs empricical calibration using the negative control outcomes, and computes
#' the calibrated p-values
#'
#' @param outputFolder  The path to the output folder containing the results.
#'
#' @export
doEmpiricalCalibration <- function(outputFolder) {
  outcomeReference <- readRDS(file.path(outputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(outcomeReference)
  cmAnalysisListFile <- system.file("settings", "cmAnalysisList.txt", package = "Rivaroxaban")
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
  # Add analysis description:
  for (i in 1:length(cmAnalysisList)) {
    analysisSummary$description[analysisSummary$analysisId == cmAnalysisList[[i]]$analysisId] <- cmAnalysisList[[i]]$description
  }
  drugComparatorOutcomesListFile <- system.file("settings", "drugComparatorOutcomesList.txt", package = "Rivaroxaban")
  drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
  
  negControlCohortIds <- unique(analysisSummary$outcomeId[analysisSummary$outcomeId > 100])
  
  newSummary <- data.frame()
  # Calibrate p-values:
  drugComparatorOutcome <- drugComparatorOutcomesList[[1]]
  for (drugComparatorOutcome in drugComparatorOutcomesList) {
    for (analysisId in unique(analysisSummary$analysisId)) {
      subset <- analysisSummary[analysisSummary$analysisId == analysisId & 
                                  analysisSummary$targetId == drugComparatorOutcome$targetId &
                                  analysisSummary$comparatorId == drugComparatorOutcome$comparatorId, ]
      
      negControlSubset <- subset[analysisSummary$outcomeId %in% negControlCohortIds, ]
      negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr != 0, ]
      
      hoiSubset <- subset[!(analysisSummary$outcomeId %in% negControlCohortIds), ]
      hoiSubset <- hoiSubset[!is.na(hoiSubset$logRr) & hoiSubset$logRr != 0, ]
      
      if (nrow(negControlSubset) > 10) {
        null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
        
        plotName <- paste("calEffectNoHois_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
        EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr, 
                                                    negControlSubset$seLogRr,
                                                    fileName = file.path(outputFolder, plotName))
        
        
        plotName <- paste("calEffect_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
        EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr, 
                                                    negControlSubset$seLogRr, 
                                                    hoiSubset$logRr, 
                                                    hoiSubset$seLogRr,
                                                    fileName = file.path(outputFolder, plotName))
        
        plotName <- paste("cali_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
        EmpiricalCalibration::plotCalibration(negControlSubset$logRr, 
                                              negControlSubset$seLogRr, 
                                              fileName = file.path(outputFolder, plotName))
        
        calibratedP <- EmpiricalCalibration::calibrateP(null, subset$logRr, subset$seLogRr)
        subset$calibratedP <- calibratedP$p
        subset$calibratedP_lb95ci <- calibratedP$lb95ci
        subset$calibratedP_ub95ci <- calibratedP$ub95ci
        mcmc <- attr(null, "mcmc")
        subset$null_mean <- mean(mcmc$chain[, 1])
        subset$null_sd <- 1/sqrt(mean(mcmc$chain[, 2]))
      } else {
        subset$calibratedP <- NA
        subset$calibratedP_lb95ci <- NA
        subset$calibratedP_ub95ci <- NA
        subset$null_mean <- NA
        subset$null_sd <- NA
      }
      newSummary <- rbind(newSummary, subset)
    }
  }
  write.csv(newSummary, file.path(outputFolder, "Results.csv"), row.names = FALSE)
}
