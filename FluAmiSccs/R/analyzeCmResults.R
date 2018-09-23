#' @export
analyzeCmResults <- function(cdmDatabaseSchema,
                             outputFolder)
{
  db <- gsub("\\..*", "" , cdmDatabaseSchema)
  dbOutputFolder <- file.path(outputFolder, db)
  cmOutputFolder <- file.path(dbOutputFolder, "cmOutput")
  cmResultsFolder <- file.path(dbOutputFolder, "cmResults")
  if (!file.exists(cmResultsFolder))
    dir.create(cmResultsFolder)

  cmSummary <- base::readRDS(file.path(cmOutputFolder, "cmSummary.rds"))
  cmSummary <- nejmfluami::addCmCohortNames(cmSummary, "outcomeId", "outcomeName")
  cmSummary <- nejmfluami::addCmCohortNames(cmSummary, "comparatorId", "comparatorName")
  cmSummary <- nejmfluami::addCmCohortNames(cmSummary, "targetId", "targetName")
  cmSummary <- nejmfluami::addCmAnalysisDescriptions(cmSummary)
  cmSummary <- cbind(cmSummary[, c("analysisId", "analysisDescription")],
                     subset(cmSummary, select = -c(analysisId, analysisDescription)))
  fac <- sapply(cmSummary, is.factor)
  cmSummary[fac] <- lapply(cmSummary[fac], as.character)
  utils::write.csv(cmSummary, file.path(cmResultsFolder, "cmSummary.csv"), row.names = FALSE, na = "")

  negativeControls <- utils::read.csv(system.file("settings", "NegativeControls.csv", package = "nejmfluami"))
  negativeControlOutcomes <- negativeControls[negativeControls$type == "Outcome", ]
  comparisons <- unique(cmSummary[, c("targetId", "targetName", "comparatorId", "comparatorName")])
  reference <- base::readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))

  for (analysisId in unique(cmSummary$analysisId))
  {
    for (i in 1:nrow(comparisons))
    {
      idx <- cmSummary$analysisId == analysisId & cmSummary$targetId == comparisons$targetId[i] & cmSummary$comparatorId == comparisons$comparatorId[i]

      # ps plots
      psBmFile <- reference[idx, "sharedPsFile"][1]
      psBm <- base::readRDS(psBmFile)
      psBmFileName <- file.path(cmResultsFolder,
                                paste0("psBeforeMatching_a", analysisId,
                                       "_t", comparisons$targetId[i],
                                       "_c", comparisons$comparatorId[i], ".png"))
      psPlot <- CohortMethod::plotPs(
        data            = psBm,
        treatmentLabel  = comparisons$targetName[i],
        comparatorLabel = comparisons$comparatorName[i],
        fileName        = psBmFileName
      )
      psAmFile <- reference[idx, "strataFile"][1]
      psAm <- base::readRDS(psAmFile)
      psAmFileName <- file.path(cmResultsFolder,
                                paste0("psAfterMatching_a", analysisId,
                                       "_t", comparisons$targetId[i],
                                       "_c", comparisons$comparatorId[i], ".png"))
      psPlot <- CohortMethod::plotPs(
        data            = psAm,
        treatmentLabel  = comparisons$targetName[i],
        comparatorLabel = comparisons$comparatorName[i],
        fileName        = psAmFileName
      )

      # ps model
      cmDataFolder <- reference[idx, "cohortMethodDataFolder"][1]
      cmData <- CohortMethod::loadCohortMethodData(cmDataFolder)
      psModel <- CohortMethod::getPsModel(psBm, cmData)
      utils::write.csv(psModel, file.path(cmResultsFolder,
                                          paste0("psModel_a", analysisId,
                                                 "_t", comparisons$targetId[i],
                                                 "_c", comparisons$comparatorId[i], ".csv")),
                                          row.names = FALSE, na = "")

      # balance plot, table
      balFile <- reference[idx, "covariateBalanceFile"][1]
      bal <- base::readRDS(balFile)
      balFileName <- file.path(cmResultsFolder,
                               paste0("balancePlot_a", analysisId,
                                      "_t", comparisons$targetId[i],
                                      "_c", comparisons$comparatorId[i], ".png"))
      balPlot <- CohortMethod::plotCovariateBalanceScatterPlot(
        balance  = bal,
        fileName = balFileName
      )
      balTableFileName <- file.path(cmResultsFolder,
                                    paste0("balanceTable_a", analysisId,
                                           "_t", comparisons$targetId[i],
                                           "_c", comparisons$comparatorId[i], ".csv"))
      utils::write.csv(bal, balTableFileName)

      # forest plot
      logRrCol <- "logRr"
      seLogRrCol <- "seLogRr"
      theme <- ggplot2::element_text(colour = "#000000", size = 8)
      themeRA <- ggplot2::element_text(colour = "#000000", size = 8, hjust = 1)
      breaks <- c(0.5, 1, 2, 4, 6, 8, 10)
      forest <- EmpiricalCalibration::plotForest(
        logRr    = cmSummary[idx, logRrCol],
        seLogRr  = cmSummary[idx, seLogRrCol],
        names    = cmSummary[idx, "outcomeName"]
      )
      forest <- forest +
        ggplot2::theme(axis.text.y = themeRA, axis.text.x = theme) +
        ggplot2::geom_hline(yintercept = breaks, colour = "#AAAAAA", lty = 1, size = 0.2) +
        ggplot2::scale_y_continuous(name = "Rate ratio", trans = "log10", breaks = breaks, labels = breaks) +
        ggplot2::coord_flip(ylim = c(0.5, 10))
      forestFileName <- file.path(cmResultsFolder,
                                  paste0("forestPlot_a", analysisId,
                                         "_t", comparisons$targetId[i],
                                         "_c", comparisons$comparatorId[i], ".png"))
      ggplot2::ggsave(plot = forest, filename = forestFileName)

      # empirical calibiration
      ncs <- cmSummary[idx & cmSummary$outcomeId %in% negativeControlOutcomes$conceptId, ]
      pos <- cmSummary[idx & (!( cmSummary$outcomeId %in% negativeControlOutcomes$conceptId)), ]
      calibrationFileName <- file.path(cmResultsFolder,
                                       paste0("calibrationPlot_a", analysisId,
                                              "_t", comparisons$targetId[i],
                                              "_c", comparisons$comparatorId[i], ".png"))
      EmpiricalCalibration::plotCalibrationEffect(
        logRrNegatives   = ncs[, logRrCol],
        seLogRrNegatives = ncs[, seLogRrCol],
        logRrPositives   = pos[, logRrCol],
        seLogRrPositives = pos[, seLogRrCol],
        xLabel           = "Rate ratio",
        showCis          = TRUE,
        fileName         = calibrationFileName
      )

      null <- EmpiricalCalibration::fitMcmcNull(
        logRr   = ncs[, logRrCol],
        seLogRr = ncs[, seLogRrCol]
      )

      calP <- EmpiricalCalibration::calibrateP(
        null    = null,
        logRr   = cmSummary[idx, logRrCol],
        seLogRr = cmSummary[idx, seLogRrCol]
      )

      cmSummary$calP[idx] <- calP$p
      cmSummary$calPlb95Ci[idx] <- calP$lb95ci
      cmSummary$calPub95Ci[idx] <- calP$ub95ci
    }
  }
  utils::write.csv(cmSummary, file.path(cmResultsFolder, "cmSummaryCalibrated.csv"), row.names = FALSE, na = "")
}


#' @export
addCmCohortNames <- function(data,
                             IdColumnName   = "cohortDefinitionId",
                             nameColumnName = "cohortName")
{
  cohortsToCreate <- read.csv(system.file("settings", "CohortsToCreate.csv", package = "nejmfluami"))
  idToName <- data.frame(cohortId = c(cohortsToCreate$cohortId),
                         cohortName = c(as.character(cohortsToCreate$name)))
  names(idToName)[1] <- IdColumnName
  names(idToName)[2] <- nameColumnName
  data <- merge(data, idToName, all.x = TRUE)
  # Change order of columns:
  idCol <- which(colnames(data) == IdColumnName)
  if (idCol < ncol(data) - 1) {
    data <- data[, c(1:idCol, ncol(data) , (idCol+1):(ncol(data)-1))]
  }
  return(data)
}

#' @export
addCmAnalysisDescriptions <- function(object)
{
  cmAnalysisListFile <- system.file("settings", "cmAnalysisList.json", package = "nejmfluami")
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
  # Add analysis description:
  for (i in 1:length(cmAnalysisList)) {
    object$analysisDescription[object$analysisId == cmAnalysisList[[i]]$analysisId] <- cmAnalysisList[[i]]$description
  }
  # Change order of columns:
  aidCol <- which(colnames(object) == "analysisId")
  if (aidCol < ncol(object) - 1) {
    object <- object[, c(1:aidCol, ncol(object) , (aidCol+1):(ncol(object)-1))]
  }
  return(object)
}
