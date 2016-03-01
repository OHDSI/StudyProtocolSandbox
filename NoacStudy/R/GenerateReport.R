generateReport <- function(outputFolder) {
  intro <- "This reports describes the results from a comparative effectiveness study comparing new users of rivaroxaban to new users of warfarin. The study was restricted to those people with a prior diagnose of diabetes. Propensity scores were generated using large scale regression, and one-on-one matching was performed. Effect sizes were estimated using a univariate Cox regression, conditioned on the matched sets. A set of negative control outcomes was included to estimate residual bias and calibrate p-values."
  outcomeReference <- readRDS(file.path(outputFolder, "outcomeModelReference.rds"))
  results <- read.csv(file.path(outputFolder, "Results.csv"))
  cohortDefinitionsFile <- system.file("settings", "cohorts.csv", package = "NoacStudy")
  cohortDefinitions <- read.csv(cohortDefinitionsFile)
  analysisId <- 7
  targetId <- 5
  comparatorId <- 6
  negControlCohortIds <- unique(results$outcomeId[results$outcomeId > 100])

  # cmData <- CohortMethod::loadCohortMethodData(outcomeReferenceSubset$cohortMethodDataFolder[1])
  outcomeReferenceSubset <- outcomeReference[outcomeReference$analysisId == analysisId & outcomeReference$targetId ==
    targetId & outcomeReference$comparatorId == comparatorId, ]
  omData <- readRDS(outcomeReferenceSubset$outcomeModelFile[outcomeReferenceSubset$outcomeId == 14])
  resultsSubset <- results[results$analysisId == analysisId & results$targetId == targetId & results$comparatorId ==
    comparatorId, ]
  negControlSubset <- resultsSubset[resultsSubset$outcomeId %in% negControlCohortIds, ]
  negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr != 0, ]
  hoiSubset <- resultsSubset[!(resultsSubset$outcomeId %in% negControlCohortIds), ]
  # hoiSubset <- hoiSubset[!is.na(hoiSubset$logRr) & hoiSubset$logRr != 0, ]

  # Generate report document
  report <- ReporteRs::docx()
  report <- ReporteRs::addParagraph(report, value = intro)

  report <- ReporteRs::addTitle(report, "Model diagnostics", level = 1)

  # Propensity scores
  report <- ReporteRs::addTitle(report, "Propensity score distribution", level = 2)
  psFile <- outcomeReferenceSubset$sharedPsFile[1]
  ps <- readRDS(psFile)
  plot <- CohortMethod::plotPs(ps, scale = "propensity", type = "histogram")
  report <- ReporteRs::addPlot(report, fun = print, x = plot)

  paragraph <- "Propensity score distribution plot. This plot shows the propensity score distribution."
  report <- ReporteRs::addParagraph(report, value = paragraph)

  auc <- CohortMethod::computePsAuc(ps)
  paragraph <- paste("Propensity model Area Under the receiver operator Curve (AUC) =", auc)
  report <- ReporteRs::addParagraph(report, value = paragraph)

  # Covariate balance
  report <- ReporteRs::addTitle(report, "Covariate balance", level = 2)
  balanceFile <- outcomeReferenceSubset$covariateBalanceFile[outcomeReferenceSubset$outcomeId == 14]
  balance <- readRDS(balanceFile)

  plot <- CohortMethod::plotCovariateBalanceScatterPlot(balance)
  report <- ReporteRs::addPlot(report, fun = print, x = plot)
  paragraph <- "Balance scatter plot. This plot shows the standardized difference before and after matching for all covariates used in the propensity score model."
  report <- ReporteRs::addParagraph(report, value = paragraph)


  plot <- CohortMethod::plotCovariateBalanceOfTopVariables(balance)
  report <- ReporteRs::addPlot(report, fun = print, x = plot)
  paragraph <- "Balance plot for top covariates. This plot shows the standardized difference before and after matching for those covariates with the largest difference before matching (top) and after matching (bottom). A negative difference means the value in the treated group was lower than in the comparator group."
  report <- ReporteRs::addParagraph(report, value = paragraph)

  # Empirical calibration
  report <- ReporteRs::addTitle(report, "Emprical calibration", level = 2)
  null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
  mcmc <- attr(null, "mcmc")
  lb95Mean <- quantile(mcmc$chain[, 1], 0.025)
  ub95Mean <- quantile(mcmc$chain[, 1], 0.975)
  lb95Precision <- quantile(mcmc$chain[, 2], 0.025)
  ub95Precision <- quantile(mcmc$chain[, 2], 0.975)
  output <- data.frame(Variable = c("Mean", "Precision"),
                       Estimate = c(null[1], null[2]),
                       lb95 = c(lb95Mean, lb95Precision),
                       ub95 = c(ub95Mean, ub95Precision))
  colnames(output) <- c("Variable", "Estimate", "lower .95", "upper .95")
  report <- ReporteRs::addFlexTable(report, ReporteRs::FlexTable(output))
  paragraph <- "Bias distribution estimates. This table shows the estimated parameters of the bias distribution."
  report <- ReporteRs::addParagraph(report, value = paragraph)


  plot <- EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                      negControlSubset$seLogRr)
  report <- ReporteRs::addPlot(report, fun = print, x = plot)
  paragraph <- "Calibration effect plot. Blue dots represent the negative controls used in this study. The dashed line indicates the boundary below which p < 0.05 using traditional p-value computation. The orange area indicated the area where p < 0.05 using calibrated p-value computation."
  report <- ReporteRs::addParagraph(report, value = paragraph)


  plot <- EmpiricalCalibration::plotCalibration(negControlSubset$logRr, negControlSubset$seLogRr)
  report <- ReporteRs::addPlot(report, fun = print, x = plot)
  paragraph <- "Calibration plot. This plot shows the fraction of negative controls with p-values below alpha, for every level of alpha. Ideally, the plots should follow the diagonal. This plot has been generated using leave-one-out: when computing the calibrated p-value for a negative control, the bias distribution was fitted using all other negative controls."
  report <- ReporteRs::addParagraph(report, value = paragraph)


  # Manually selected characteristics
  report <- ReporteRs::addTitle(report, "Manually selected baseline characteristics", level = 2)
  countVars <- c(10:30,
                 8507,
                 8532,
                 36703451251,
                 35205243251,
                 37604050251,
                 35205189251,
                 321052251,
                 4029305251,
                 198124251,
                 37219804251,
                 35909501251,
                 438112251,
                 439777251,
                 21601784554,
                 21601782554,
                 21601664554,
                 21601744554,
                 1326303504,
                 21601461554,
                 21601855554,
                 21600081554,
                 21600095554,
                 21603638554,
                 21604709551,
                 21600714553,
                 21600722552,
                 21600735554,
                 1503297504,
                 21600749554)
  meanVars <- c(1100, 1102, 1103)
  treatedBefore <- omData$counts$notPriorCount[omData$counts$treatment == 1]
  treatedAfter <- omData$counts$matchedTrimmedCount[omData$counts$treatment == 1]
  comparatorBefore <- omData$counts$notPriorCount[omData$counts$treatment == 0]
  comparatorAfter <- omData$counts$matchedTrimmedCount[omData$counts$treatment == 0]

  countBal <- balance[balance$covariateId %in% countVars, ]
  countBal <- countBal[order(countBal$covariateId), ]
  countBal$shortName <- as.character(countBal$covariateName)
  x <- regexpr("-[A-Z]", countBal$covariateName)
  countBal$shortName[x >= 0] <- substr(countBal$covariateName[x >= 0], x[x >= 0] + 1, 9999)
  countBal$countTreatedBefore <- paste(countBal$beforeMatchingSumTreated,
                                       " (",
                                       round(countBal$beforeMatchingMeanTreated *
    100, 1), ")", sep = "")
  countBal$countComparatorBefore <- paste(countBal$beforeMatchingsumComparator,
                                          " (",
                                          round(countBal$beforeMatchingMeanComparator *
    100, 1), ")", sep = "")
  countBal$beforeMatchingStdDiff <- round(countBal$beforeMatchingStdDiff, 2)
  countBal$countTreatedAfter <- paste(countBal$afterMatchingSumTreated,
                                      " (",
                                      round(countBal$afterMatchingMeanTreated *
    100, 1), ")", sep = "")
  countBal$countComparatorAfter <- paste(countBal$afterMatchingSumComparator,
                                         " (",
                                         round(countBal$afterMatchingMeanComparator *
    100, 1), ")", sep = "")
  countBal$afterMatchingStdDiff <- round(countBal$afterMatchingStdDiff, 2)
  countBal <- countBal[, c("shortName",
                           "countTreatedBefore",
                           "countComparatorBefore",
                           "beforeMatchingStdDiff",
                           "countTreatedAfter",
                           "countComparatorAfter",
                           "afterMatchingStdDiff")]
  colnames(countBal) <- c("Baseline characteristic",
                          paste("Riva - before (N=", treatedBefore, sep = ""),
                          paste("Warf - before (N=", comparatorBefore, sep = ""),
                          "Std Diff - before",
                          paste("Riva - after (N=", treatedAfter, sep = ""),
                          paste("Warf - after (N=", comparatorAfter, sep = ""),
                          "std Diff - after")
  report <- ReporteRs::addFlexTable(report, ReporteRs::FlexTable(countBal))
  paragraph <- "Manually selected baseline characteristics. This table shows for a set of manually selected characteristics the number (and percentage) of people for which the covariate applies. Covariate status was evaluated on and all time prior to the index date."
  report <- ReporteRs::addParagraph(report, value = paragraph)

  meanBal <- balance[balance$covariateId %in% meanVars, ]
  meanBal$shortName <- sub(", using conditions all time on or prior to cohort index",
                           "",
                           meanBal$covariateName)
  meanBal$meanTreatedBefore <- round(meanBal$beforeMatchingMeanTreated, 1)
  meanBal$meanComparatorBefore <- round(meanBal$beforeMatchingMeanComparator, 1)
  meanBal$beforeMatchingStdDiff <- round(meanBal$beforeMatchingStdDiff, 2)
  meanBal$meanTreatedAfter <- round(meanBal$afterMatchingMeanTreated, 1)
  meanBal$meanComparatorAfter <- round(meanBal$afterMatchingMeanComparator, 1)
  meanBal$afterMatchingStdDiff <- round(meanBal$afterMatchingStdDiff, 2)
  meanBal <- meanBal[, c("shortName",
                         "meanTreatedBefore",
                         "meanComparatorBefore",
                         "beforeMatchingStdDiff",
                         "meanTreatedAfter",
                         "meanComparatorAfter",
                         "afterMatchingStdDiff")]
  colnames(meanBal) <- c("Baseline characteristic",
                         paste("Riva - before (N=", treatedBefore, sep = ""),
                         paste("Warf - before (N=", comparatorBefore, sep = ""),
                         "Std Diff - before",
                         paste("Riva - after (N=", treatedAfter, sep = ""),
                         paste("Warf - after (N=", comparatorAfter, sep = ""),
                         "std Diff - after")
  report <- ReporteRs::addFlexTable(report, ReporteRs::FlexTable(meanBal))
  paragraph <- "Manually selected baseline characteristics. This table shows for a set of manually selected characteristics the mean value."
  report <- ReporteRs::addParagraph(report, value = paragraph)


  # Results
  report <- ReporteRs::addPageBreak(report)
  report <- ReporteRs::addTitle(report, "Results", level = 1)

  # Overview table
  report <- ReporteRs::addTitle(report, "Overview", level = 2)
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
  ignore <- table$eventsTreated < 10 | table$eventsComparator < 10
  colnames(table) <- c("Outcome",
                       "Riva - # events",
                       "Riva - Rate",
                       "Warf - # events",
                       "Warf - Rate",
                       "HR",
                       "95% LB",
                       "95% UB",
                       "P",
                       "Calibrated P")
  table <- sapply(table, function(x) {
    if (is.numeric(x))
      round(x, 2) else as.character(x)
  })
  table[ignore, 6:10] <- ""
  report <- ReporteRs::addFlexTable(report, ReporteRs::FlexTable(table))
  paragraph <- "Results overview tabe. Rate is per 100 patient years. HR is the fully adjusted hazard ratio."
  report <- ReporteRs::addParagraph(report, value = paragraph)

  # Empirical calibration
  report <- ReporteRs::addTitle(report, "Empirical calibration", level = 2)
  plot <- EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                      negControlSubset$seLogRr,
                                                      hoiSubset$logRr,
                                                      hoiSubset$seLogRr)
  report <- ReporteRs::addPlot(report, fun = print, x = plot)
  paragraph <- "Calibration effect plot. Blue dots represent the negative controls used in this study. The dashed line indicates the boundary below which p < 0.05 using traditional p-value computation. The orange area indicated the area where p < 0.05 using calibrated p-value computation. Yellow diamonds indicate the various outcomes of interest in this study."
  report <- ReporteRs::addParagraph(report, value = paragraph)

  report <- ReporteRs::addTitle(report, "Kaplan - Meier plots", level = 2)
  outcomeId <- hoiSubset$outcomeId[1]
  for (outcomeId in hoiSubset$outcomeId) {
    or <- outcomeReferenceSubset[outcomeReferenceSubset$outcomeId == outcomeId, ]
    om <- readRDS(or$outcomeModelFile)
    title <- cohortDefinitions$cohortDefinitionName[cohortDefinitions$cohortDefinitionId == outcomeId]
    plot <- CohortMethod::plotKaplanMeier(om,
                                          includeZero = FALSE,
                                          title = title,
                                          treatmentLabel = "Rivaroxaban",
                                          comparatorLabel = "Warfarin")
    report <- ReporteRs::addPlot(report, fun = print, x = plot)
    paragraph <- "Kaplan-Meier plot. Shaded areas indicate the 95% confidence interval. Note that this plot does not take into account conditioning on the matched sets, as done when fitting the Cox model."
    report <- ReporteRs::addParagraph(report, value = paragraph)
  }

  ReporteRs::writeDoc(report, file = file.path(outputFolder, "Report.docx"))
}
