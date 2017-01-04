packageResults <- function(connectionDetails, cdmDatabaseSchema, outputFolder, minCellCount = 5) {
  exportFolder <- file.path(outputFolder, "export")
  if (!file.exists(exportFolder))
    dir.create(exportFolder)
  
  createMetaData(connectionDetails, cdmDatabaseSchema, exportFolder)
  cmOutputFolder <- file.path(outputFolder, "cmOutput")
  outcomeReference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(outcomeReference)
  analysisSummary <- addCohortNames(analysisSummary, "outcomeId", "outcomeName")
  analysisSummary <- addCohortNames(analysisSummary, "targetId", "targetName")
  analysisSummary <- addCohortNames(analysisSummary, "comparatorId", "comparatorName")
  analysisSummary <- addAnalysisDescriptions(analysisSummary)
  
  cohortMethodDataFolder <- outcomeReference$cohortMethodDataFolder[outcomeReference$analysisId ==
                                                                      3 & outcomeReference$outcomeId == 3]
  cohortMethodData <- CohortMethod::loadCohortMethodData(cohortMethodDataFolder)
  
  ### Write results table ###
  write.csv(analysisSummary, file.path(exportFolder, "MainResults.csv"), row.names = FALSE)
  
  ### Main attrition table ###
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 3 & outcomeReference$outcomeId == 3]
  strata <- readRDS(strataFile)
  attrition <- CohortMethod::getAttritionTable(strata)
  write.csv(attrition, file.path(exportFolder, "AttritionVarRatioMatching.csv"), row.names = FALSE)
  
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 2 & outcomeReference$outcomeId == 3]
  strata <- readRDS(strataFile)
  attrition <- CohortMethod::getAttritionTable(strata)
  write.csv(attrition, file.path(exportFolder, "Attrition1On1Matching.csv"), row.names = FALSE)
  
  ### Main propensity score plots ###
  psFileName <- outcomeReference$sharedPsFile[outcomeReference$sharedPsFile != ""][1]
  ps <- readRDS(psFileName)
  CohortMethod::plotPs(ps, fileName = file.path(exportFolder, "PsPrefScale.png"))
  CohortMethod::plotPs(ps, scale = "propensity", fileName = file.path(exportFolder, "Ps.png"))
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 3 & outcomeReference$outcomeId ==
                                              3]
  strata <- readRDS(strataFile)
  CohortMethod::plotPs(strata,
                       unfilteredData = ps,
                       fileName = file.path(exportFolder, "PsAfterVarRatioMatchingPrefScale.png"))
  CohortMethod::plotPs(strata,
                       unfilteredData = ps,
                       scale = "propensity",
                       fileName = file.path(exportFolder, "PsAfterVarRatioMatching.png"))
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 2 & outcomeReference$outcomeId ==
                                              3]
  strata <- readRDS(strataFile)
  CohortMethod::plotPs(strata,
                       unfilteredData = ps,
                       fileName = file.path(exportFolder, "PsAfter1On1MatchingPrefScale.png"))
  CohortMethod::plotPs(strata,
                       unfilteredData = ps,
                       scale = "propensity",
                       fileName = file.path(exportFolder, "PsAfter1On1Matching.png"))
  
  ### Propensity model ###
  psFileName <- outcomeReference$sharedPsFile[outcomeReference$sharedPsFile != ""][1]
  ps <- readRDS(psFileName)
  psModel <- CohortMethod::getPsModel(ps, cohortMethodData)
  write.csv(psModel, file.path(exportFolder, "PsModel.csv"), row.names = FALSE)
  
  ### Main balance tables ###
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 3 & outcomeReference$outcomeId ==
                                              3]
  strata <- readRDS(strataFile)
  balance <- CohortMethod::computeCovariateBalance(strata, cohortMethodData)
  idx <- balance$beforeMatchingSumTreated < minCellCount
  balance$beforeMatchingSumTreated[idx] <- NA
  balance$beforeMatchingMeanTreated[idx] <- NA
  idx <- balance$beforeMatchingSumComparator < minCellCount
  balance$beforeMatchingSumComparator[idx] <- NA
  balance$beforeMatchingMeanComparator[idx] <- NA
  idx <- balance$afterMatchingSumTreated < minCellCount
  balance$afterMatchingSumTreated[idx] <- NA
  balance$afterMatchingMeanTreated[idx] <- NA
  idx <- balance$afterMatchingSumComparator < minCellCount
  balance$afterMatchingSumComparator[idx] <- NA
  balance$afterMatchingMeanComparator[idx] <- NA
  write.csv(balance, file.path(exportFolder, "BalanceVarRatioMatching.csv"), row.names = FALSE)
  
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 2 & outcomeReference$outcomeId ==
                                              3]
  strata <- readRDS(strataFile)
  balance <- CohortMethod::computeCovariateBalance(strata, cohortMethodData)
  idx <- balance$beforeMatchingSumTreated < minCellCount
  balance$beforeMatchingSumTreated[idx] <- NA
  balance$beforeMatchingMeanTreated[idx] <- NA
  idx <- balance$beforeMatchingSumComparator < minCellCount
  balance$beforeMatchingSumComparator[idx] <- NA
  balance$beforeMatchingMeanComparator[idx] <- NA
  idx <- balance$afterMatchingSumTreated < minCellCount
  balance$afterMatchingSumTreated[idx] <- NA
  balance$afterMatchingMeanTreated[idx] <- NA
  idx <- balance$afterMatchingSumComparator < minCellCount
  balance$afterMatchingSumComparator[idx] <- NA
  balance$afterMatchingMeanComparator[idx] <- NA
  write.csv(balance, file.path(exportFolder, "Balance1On1Matching.csv"), row.names = FALSE)
  
  ### Removed (redunant) covariates ###
  if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
    idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId, ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
    removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE), ])
    write.csv(removedCovars, file.path(exportFolder, "RemovedCovars.csv"), row.names = FALSE)
  }
  
  ### Main Kaplan Meier plots ###
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 2 & outcomeReference$outcomeId ==
                                              3]
  strata <- readRDS(strataFile)
  CohortMethod::plotKaplanMeier(strata,
                                includeZero = FALSE,
                                fileName = file.path(exportFolder, "KaplanMeierPerProtocol.png"))
  strataFile <- outcomeReference$strataFile[outcomeReference$analysisId == 6 & outcomeReference$outcomeId ==
                                              3]
  strata <- readRDS(strataFile)
  CohortMethod::plotKaplanMeier(strata,
                                includeZero = FALSE,
                                fileName = file.path(exportFolder, "KaplanMeierIntentToTreat.png"))
  
  ### Main outcome models ###
  outcomeModelFile <- outcomeReference$outcomeModelFile[outcomeReference$analysisId == 4 & outcomeReference$outcomeId ==
                                                          3]
  outcomeModel <- readRDS(outcomeModelFile)
  if (outcomeModel$outcomeModelStatus == "OK") {
    model <- CohortMethod::getOutcomeModel(outcomeModel, cohortMethodData)
    write.csv(model, file.path(exportFolder, "OutcomeModelPerProtocol.csv"), row.names = FALSE)
  }
  
  outcomeModelFile <- outcomeReference$outcomeModelFile[outcomeReference$analysisId == 8 & outcomeReference$outcomeId ==
                                                          3]
  outcomeModel <- readRDS(outcomeModelFile)
  if (outcomeModel$outcomeModelStatus == "OK") {
    model <- CohortMethod::getOutcomeModel(outcomeModel, cohortMethodData)
    write.csv(model, file.path(exportFolder, "OutcomeModelIntentToTreat.csv"), row.names = FALSE)
  }
  
  ### Add all to zip file ###
  zipName <- file.path(exportFolder, "StudyResults.zip")
  OhdsiSharing::compressFolder(exportFolder, zipName)
  writeLines(paste("\nStudy results are ready for sharing at:", zipName))
}

createMetaData <- function(connectionDetails, cdmDatabaseSchema, exportFolder) {
  conn <- DatabaseConnector::connect(connectionDetails)
  sql <- "SELECT * FROM @cdm_database_schema.cdm_source"
  sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  cdmSource <- DatabaseConnector::querySql(conn, sql)
  RJDBC::dbDisconnect(conn)
  lines <- paste(names(cdmSource), cdmSource[1, ], sep = ": ")
  lines <- c(lines, paste("OhdsiRTools version", packageVersion("OhdsiRTools"), sep = ": "))
  lines <- c(lines, paste("SqlRender version", packageVersion("SqlRender"), sep = ": "))
  lines <- c(lines,
             paste("DatabaseConnector version", packageVersion("DatabaseConnector"), sep = ": "))
  lines <- c(lines, paste("Cyclops version", packageVersion("Cyclops"), sep = ": "))
  lines <- c(lines,
             paste("FeatureExtraction version", packageVersion("FeatureExtraction"), sep = ": "))
  lines <- c(lines, paste("CohortMethod version", packageVersion("CohortMethod"), sep = ": "))
  lines <- c(lines, paste("OhdsiSharing version", packageVersion("OhdsiSharing"), sep = ": "))
  lines <- c(lines,
             paste("KeppraAngioedema version", packageVersion("KeppraAngioedema"), sep = ": "))
  write(lines, file.path(exportFolder, "MetaData.txt"))
  invisible(NULL)
}

addAnalysisDescriptions <- function(object) {
  cmAnalysisListFile <- system.file("settings", "cmAnalysisList.txt", package = "HypertensionCombination")
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