#' Create custom output for this study
#'
#' @details
#' Performs empricical calibration using the negative control outcomes, and computes the calibrated
#' p-values
#'
#' @param outputFolder   The path to the output folder containing the results.
#'
#' @export
createCustomOutput <- function(outputFolder) {
  outcomeReference <- readRDS(file.path(outputFolder, "outcomeModelReference.rds"))
  analysisSummary <- read.csv(file.path(outputFolder, "Results.csv"))
  cmAnalysisListFile <- system.file("settings", "cmAnalysisList.txt", package = "NoacStudy")
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
  # Add analysis description:
  for (i in 1:length(cmAnalysisList)) {
    analysisSummary$description[analysisSummary$analysisId == cmAnalysisList[[i]]$analysisId] <- cmAnalysisList[[i]]$description
  }
  drugComparatorOutcomesListFile <- system.file("settings",
                                                "drugComparatorOutcomesList.txt",
                                                package = "NoacStudy")
  drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)

  negControlCohortIds <- unique(analysisSummary$outcomeId[analysisSummary$outcomeId > 100])

  cohortDefinitionsFile <- system.file("settings", "cohorts.csv", package = "NoacStudy")
  cohortDefinitions <- read.csv(cohortDefinitionsFile)

  drugComparatorOutcome <- drugComparatorOutcomesList[[1]]
  for (drugComparatorOutcome in drugComparatorOutcomesList) {
    # Create PS plots
    psFile <- outcomeReference[outcomeReference$targetId == drugComparatorOutcome$targetId & outcomeReference$comparatorId ==
      drugComparatorOutcome$comparatorId & outcomeReference$sharedPsFile != "", "sharedPsFile"][1]
    ps <- readRDS(psFile)
    plotName <- paste("ps_t",
                      drugComparatorOutcome$targetId,
                      "_c",
                      drugComparatorOutcome$comparatorId,
                      ".png",
                      sep = "")
    CohortMethod::plotPs(ps, fileName = file.path(outputFolder, plotName))

    for (analysisId in unique(analysisSummary$analysisId)) {
      subset <- analysisSummary[analysisSummary$analysisId == analysisId & analysisSummary$targetId ==
        drugComparatorOutcome$targetId & analysisSummary$comparatorId == drugComparatorOutcome$comparatorId, ]
      outcomeReferenceSubset <- outcomeReference[outcomeReference$analysisId == analysisId & outcomeReference$targetId ==
        drugComparatorOutcome$targetId & outcomeReference$comparatorId == drugComparatorOutcome$comparatorId, ]

      negControlSubset <- subset[analysisSummary$outcomeId %in% negControlCohortIds, ]
      negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr !=
        0, ]

      hoiSubset <- subset[!(analysisSummary$outcomeId %in% negControlCohortIds), ]
      hoiSubset <- hoiSubset[!is.na(hoiSubset$logRr) & hoiSubset$logRr != 0, ]

      # Create balance plots
      outcomeId <- hoiSubset$outcomeId[1]
      for (outcomeId in hoiSubset$outcomeId) {
        balanceFile <- outcomeReferenceSubset$covariateBalanceFile[outcomeReferenceSubset$outcomeId ==
          outcomeId]
        if (balanceFile != "") {
          balance <- readRDS(balanceFile)
          plotName <- paste("balScatter_a",
                            analysisId,
                            "_t",
                            drugComparatorOutcome$targetId,
                            "_c",
                            drugComparatorOutcome$comparatorId,
                            "_o",
                            outcomeId,
                            ".png",
                            sep = "")
          CohortMethod::plotCovariateBalanceScatterPlot(balance, fileName = file.path(outputFolder,
                                                                                      plotName))
          plotName <- paste("balTop_a",
                            analysisId,
                            "_t",
                            drugComparatorOutcome$targetId,
                            "_c",
                            drugComparatorOutcome$comparatorId,
                            "_o",
                            outcomeId,
                            ".png",
                            sep = "")
          CohortMethod::plotCovariateBalanceOfTopVariables(balance,
                                                           fileName = file.path(outputFolder,
                                                                                         plotName))
        }
      }

      # Create KM plots:
      outcomeId <- hoiSubset$outcomeId[1]
      for (outcomeId in hoiSubset$outcomeId) {
        or <- outcomeReferenceSubset[outcomeReferenceSubset$outcomeId == outcomeId, ]
        om <- readRDS(or$outcomeModelFile)
        if (om$modelType == "cox") {
          plotName <- paste("km_a",
                            analysisId,
                            "_t",
                            drugComparatorOutcome$targetId,
                            "_c",
                            drugComparatorOutcome$comparatorId,
                            "_o",
                            outcomeId,
                            ".png",
                            sep = "")
          title <- cohortDefinitions$cohortDefinitionName[cohortDefinitions$cohortDefinitionId ==
          outcomeId]
          CohortMethod::plotKaplanMeier(om,
                                        includeZero = FALSE,
                                        title = title,
                                        treatmentLabel = "Rivaroxaban",
                                        comparatorLabel = "Warfarin",
                                        fileName = file.path(outputFolder, plotName))
        }
      }

      # Create overview tables:
      table <- merge(hoiSubset, cohortDefinitions, by.x = "outcomeId", by.y = "cohortDefinitionId")
      table$treatedRate <- table$eventsTreated/(table$treatedDays/(100 * 365.25))
      table$comparatorRate <- table$eventsComparator/(table$comparatorDays/(100 * 365.25))
      table <- table[, c("cohortDefinitionName",
                         "eventsTreated",
                         "treatedRate",
                         "eventsComparator",
                         "comparatorRate",
                         "rr",
                         "ci95lb",
                         "ci95ub",
                         "p",
                         "calibratedP")]

      tableName <- paste("table_a",
                         analysisId,
                         "_t",
                         drugComparatorOutcome$targetId,
                         "_c",
                         drugComparatorOutcome$comparatorId,
                         ".csv",
                         sep = "")
      write.csv(table, file.path(outputFolder, tableName), row.names = FALSE)
    }
  }
}
