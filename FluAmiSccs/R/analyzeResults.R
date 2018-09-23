#' @export
analyzeResults <- function(cdmDatabaseSchema,
                           outputFolder)
{
  db <- gsub("\\..*", "" , cdmDatabaseSchema)
  dbOutputFolder <- file.path(outputFolder, db)
  sccsOutputFolder <- file.path(dbOutputFolder, "sccsOutput")
  sccsResultsFolder <- file.path(dbOutputFolder, "sccsResults")
  if (!file.exists(sccsResultsFolder))
    dir.create(sccsResultsFolder)

  sccsSummary <- readRDS(file.path(sccsOutputFolder, "sccsSummary.rds"))
  sccsSummary <- nejmfluami::addCohortNames(sccsSummary, "outcomeId", "outcomeName")
  sccsSummary <- nejmfluami::addCohortNames(sccsSummary, "exposureId", "exposureName")
  sccsSummary <- nejmfluami::addAnalysisDescriptions(sccsSummary)
  sccsSummary <- sccsSummary[order(sccsSummary$analysisId, sccsSummary$exposureId, sccsSummary$outcomeId), ]
  utils::write.csv(sccsSummary, file.path(sccsResultsFolder, "sccsSummary.csv"), row.names = FALSE, na = "")

  # empirical calibration
  negativeControls <- utils::read.csv(system.file("settings", "NegativeControls.csv", package = "nejmfluami"))
  negativeControlOutcomes <- negativeControls[negativeControls$type == "Outcome", ]

  cohortsToCreate <- read.csv(system.file("settings", "CohortsToCreate.csv", package = "nejmfluami"))[-1:-2, ] #drop cohort for creating nesting cohort, cold cohort
  exposureIdsAnyVisit <- cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0 & cohortsToCreate$visit == "any"] * 100
  exposureIdsIPVisit <- cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0 & cohortsToCreate$visit == "IP"]   * 100
  exposureIdsOPVisit <- cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0 & cohortsToCreate$visit == "OP"]   * 100

  for (i in list(exposureIdsAnyVisit, exposureIdsIPVisit, exposureIdsOPVisit))
  {
    for (analysisId in unique(sccsSummary$analysisId))
    {
      if (base::identical(i, exposureIdsAnyVisit))
      {
        exposureVisit <- "anyVisit"
      }
      if (base::identical(i, exposureIdsIPVisit))
      {
        exposureVisit <- "ipVisit"
      }
      if (base::identical(i, exposureIdsOPVisit))
      {
        exposureVisit <- "opVisit"
      }
      idx <- sccsSummary$analysisId == analysisId & sccsSummary$exposureId %in% i
      ncs <- sccsSummary[idx & sccsSummary$outcomeId %in% negativeControlOutcomes$conceptId, ]
      pos <- sccsSummary[idx & (!( sccsSummary$outcomeId %in% negativeControlOutcomes$conceptId)), ]

      logRrCol <- "logRr(Exposure of interest)"
      seLogRrCol <- "seLogRr(Exposure of interest)"

      theme <- ggplot2::element_text(colour = "#000000", size = 8)
      themeRA <- ggplot2::element_text(colour = "#000000", size = 8, hjust = 1)
      breaks <- c(0.5, 1, 2, 4, 6, 8, 10, 12)
      forest <- EmpiricalCalibration::plotForest(
        logRr    = sccsSummary[idx, logRrCol],
        seLogRr  = sccsSummary[idx, seLogRrCol],
        names    = sccsSummary[idx, "outcomeName"]
      )
      forest <- forest +
        ggplot2::theme(axis.text.y = themeRA, axis.text.x = theme) +
        ggplot2::geom_hline(yintercept = breaks, colour = "#AAAAAA", lty = 1, size = 0.2) +
        ggplot2::scale_y_continuous("Incidence rate ratio", trans = "log10", breaks = breaks, labels = breaks) +
        ggplot2::coord_flip(ylim = c(0.5, 12))
      ggplot2::ggsave(plot = forest, path = sccsResultsFolder, filename = paste0("forest_a", analysisId, "_", exposureVisit, ".png"))

      EmpiricalCalibration::plotCalibrationEffect(
        logRrNegatives   = ncs[, logRrCol],
        seLogRrNegatives = ncs[, seLogRrCol],
        logRrPositives   = pos[, logRrCol],
        seLogRrPositives = pos[, seLogRrCol],
        xLabel           = "Incidence rate ratio",
        showCis          = TRUE,
        fileName = file.path(sccsResultsFolder, paste0("CaliOutcomeControls_a", analysisId, "_", exposureVisit, ".png"))
      )
      null <- EmpiricalCalibration::fitMcmcNull(
        logRr   = ncs[, logRrCol],
        seLogRr = ncs[, seLogRrCol]
      )
      # EmpiricalCalibration::plotMcmcTrace(
      #   mcmcNull = null,
      #   fileName = file.path(sccsResultsFolder, paste0("mcmcTrace_a", analysisId, "_", exposureVisit, ".png"))
      # )
      p <- EmpiricalCalibration::computeTraditionalP(
        logRr   = sccsSummary[idx, logRrCol],
        seLogRr = sccsSummary[idx, seLogRrCol]
      )
      sccsSummary$p[idx] <- p
      calP <- EmpiricalCalibration::calibrateP(
        null    = null,
        logRr   = sccsSummary[idx, logRrCol],
        seLogRr = sccsSummary[idx, seLogRrCol]
      )
      sccsSummary$calP[idx] <- calP$p
      sccsSummary$calPlb95Ci[idx] <- calP$lb95ci
      sccsSummary$calPub95Ci[idx] <- calP$ub95ci
    }
  }
  utils::write.csv(sccsSummary, file.path(sccsResultsFolder, "sccsSummaryCalibrated.csv"), row.names = FALSE, na = "")

  # diagnostics
  # outcomeReference <- base::readRDS(file.path(sccsOutputFolder, "outcomeModelReference.rds"))
  # eoOfInterest <- outcomeReference[!outcomeReference$outcomeId %in% negativeControls$conceptId &
  #                                    outcomeReference$exposureId == exposureIdsAnyVisit[1] &
  #                                     outcomeReference$analysisId == 4, ]
  # sccsData <- SelfControlledCaseSeries::loadSccsData(eoOfInterest$sccsDataFolder)
  # SelfControlledCaseSeries::plotEventObservationDependence(
  #   sccsData    = sccsData,
  #   naivePeriod = 0,
  #   outcomeId   = eoOfInterest$outcomeId,
  #   fileName    = file.path(sccsResultsFolder, "ObsDep.png")
  # )
  # SelfControlledCaseSeries::plotAgeSpans(
  #   sccsData         = sccsData,
  #   naivePeriod      = 0,
  #   outcomeId        = eoOfInterest$outcomeId,
  #   firstOutcomeOnly = TRUE,
  #   fileName         = file.path(sccsResultsFolder, "AgeSpans.png")
  # )
  # SelfControlledCaseSeries::plotExposureCentered(
  #   sccsData         = sccsData,
  #   naivePeriod      = 0,
  #   outcomeId        = eoOfInterest$outcomeId,
  #   exposureId       = eoOfInterest$exposureId,
  #   firstOutcomeOnly = TRUE,
  #   fileName         = file.path(sccsResultsFolder, "ExpCenter.png")
  # )
  # SelfControlledCaseSeries::plotPerPersonData(
  #   sccsData         = sccsData,
  #   naivePeriod      = 0,
  #   outcomeId        = eoOfInterest$outcomeId,
  #   exposureId       = eoOfInterest$exposureId,
  #   firstOutcomeOnly = TRUE,
  #   fileName         = file.path(sccsResultsFolder, "PerPerson.png")
  # )
  #
  # for (analysisId in unique(sccsSummary$analysisId)) # analyses with age/season
  # {
  #   model <- base::readRDS(outcomeReference$sccsModelFile[outcomeReference$exposureId == eoOfInterest$exposureId &
  #                                                           outcomeReference$outcomeId == eoOfInterest$outcomeId &
  #                                                             outcomeReference$analysisId == analysisId])
  #   SelfControlledCaseSeries::plotAgeEffect(model, fileName = file.path(sccsResultsFolder, paste0("age_a", analysisId, ".png")))
  #   SelfControlledCaseSeries::plotSeasonality(model, fileName = file.path(sccsResultsFolder, paste0("season_a", analysisId, ".png")))
  # }
}

#' @export
addCohortNames <- function(data,
                           IdColumnName   = "cohortDefinitionId",
                           nameColumnName = "cohortName")
{
  cohortsToCreate <- read.csv(system.file("settings", "CohortsToCreate.csv", package = "nejmfluami"))[-1:-2, ] #drop cohort for creating nesting cohort, common cold cohort
  cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0] <- cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0] * 100 #TAR adjusted Ts
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
addAnalysisDescriptions <- function(object)
{
  sccsAnalysisListFile <- system.file("settings", "sccsAnalysisList.json", package = "nejmfluami")
  sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
  # Add analysis description:
  for (i in 1:length(sccsAnalysisList)) {
    object$analysisDescription[object$analysisId == sccsAnalysisList[[i]]$analysisId] <- sccsAnalysisList[[i]]$description
  }
  # Change order of columns:
  aidCol <- which(colnames(object) == "analysisId")
  if (aidCol < ncol(object) - 1) {
    object <- object[, c(1:aidCol, ncol(object) , (aidCol+1):(ncol(object)-1))]
  }
  return(object)
}
