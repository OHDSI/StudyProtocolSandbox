packageResults <- function(connectionDetails, cdmDatabaseSchema, cmOutputFolder, exportFolder, minCellCount = 5) {
  #createMetaData(connectionDetails, cdmDatabaseSchema, exportFolder)
  
  outcomeReference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(outcomeReference)
  analysisSummary <- addCohortNames(analysisSummary, "outcomeId", "outcomeName")
  analysisSummary <- addCohortNames(analysisSummary, "targetId", "targetName")
  analysisSummary <- addCohortNames(analysisSummary, "comparatorId", "comparatorName")
  analysisSummary <- addAnalysisDescriptions(analysisSummary)
  
  cohortMethodDataFolder <- outcomeReference$cohortMethodDataFolder
  cohortMethodData<-list()
  for(i in 1:length(cohortMethodDataFolder)){
    cohortMethodData[[i]] <- CohortMethod::loadCohortMethodData(cohortMethodDataFolder[i])
  }
  
  ### Write results table ###
  write.csv(analysisSummary, file.path(exportFolder, "MainResults.csv"), row.names = FALSE)
  
  ### Main attrition table ###
  strataFile <- outcomeReference$strataFile
  for(i in 1:length(strataFile)){
    strata <- readRDS(strataFile[i])
    attrition <- CohortMethod::getAttritionTable(strata)
    idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
    write.csv(attrition, file.path(exportFolder, paste0("AttritionTable",idx,".csv")), row.names = FALSE)
    
  }
  
  ### Main propensity score plots ###
  psFileName <- outcomeReference$sharedPsFile[outcomeReference$sharedPsFile != ""]
  ps<-list()
  for(i in 1:length(psFileName)){
    ps[[i]] <- readRDS(psFileName[i])
    idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
    CohortMethod::plotPs(ps[[i]], scale = "preference", fileName = file.path(exportFolder, paste0("PsPrefScale",idx,".png")))
    CohortMethod::plotPs(ps[[i]], scale = "propensity", fileName = file.path(exportFolder, paste0("Ps",idx,".png")))
  }
  
  strataFile <- outcomeReference$strataFile
  for(i in 1:length(strataFile)){
    strata <- readRDS(strataFile[i])
    idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
    CohortMethod::plotPs(strata,
                         unfilteredData = ps[[i]],
                         scale = "preference",
                         fileName = file.path(exportFolder, paste0("PsAfterVarRatioMatchingPrefScale",idx,".png")))
    CohortMethod::plotPs(strata,
                         unfilteredData = ps[[i]],
                         scale = "propensity",
                         fileName = file.path(exportFolder, paste0("PsAfterVarRatioMatching",idx,".png")))
    
  }
  
  ### Propensity model ###
  psFileName <- outcomeReference$sharedPsFile[outcomeReference$sharedPsFile != ""]
  for(i in 1:length(psFileName)){
    ps <- readRDS(psFileName[i])
    psModel <- CohortMethod::getPsModel(ps, cohortMethodData[[i]])
    idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
    write.csv(psModel, file.path(exportFolder, paste0("PsModel",idx,".csv")), row.names = FALSE)
  }
  
  ### Main balance tables ###
  strataFile <- outcomeReference$strataFile
  for(i in 1:length(strataFile)){
    strata <- readRDS(strataFile[i])
    balance <- CohortMethod::computeCovariateBalance(strata, cohortMethodData[[i]])
    if(length(idx <- balance$beforeMatchingSumTreated < minCellCount)>0){
		balance$beforeMatchingSumTreated[idx] <- NA
		balance$beforeMatchingMeanTreated[idx] <- NA
	}
	if(length(idx <- balance$beforeMatchingSumComparator < minCellCount)>0){
		balance$beforeMatchingSumComparator[idx] <- NA
		balance$beforeMatchingMeanComparator[idx] <- NA
    }
    if(length(idx <- balance$afterMatchingSumTreated < minCellCount)>0){
		balance$afterMatchingSumTreated[idx] <- NA
		balance$afterMatchingMeanTreated[idx] <- NA
    }
    if(length(idx <- balance$afterMatchingSumComparator < minCellCount)>0){
		balance$afterMatchingSumComparator[idx] <- NA
		balance$afterMatchingMeanComparator[idx] <- NA
    }
    idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
    write.csv(balance, file.path(exportFolder, paste0("Balance",idx,".csv")), row.names = FALSE)
    
  }
  
  ### Removed (redunant) covariates ###
  for(i in 1:length(cohortMethodData)){
    
        try(
            if (!is.null(cohortMethodData[[i]]$metaData$deletedCovariateIds)) {
          idx <- is.na(ffbase::ffmatch(cohortMethodData[[i]]$covariateRef$covariateId, ff::as.ff(cohortMethodData[[i]]$metaData$deletedCovariateIds)))
          removedCovars <- ff::as.ram(cohortMethodData[[i]]$covariateRef[ffbase::ffwhich(idx, idx == FALSE), ])
          idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
          write.csv(removedCovars, file.path(exportFolder, paste0("RemovedCovars",idx,".csv")), row.names = FALSE)
          
        }
        )
  }
  
  ### Main Kaplan Meier plots ###
  strataFile <- outcomeReference$strataFile
  for(i in 1:length(strataFile)){
    strata <- readRDS(strataFile[i])
    idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
    CohortMethod::plotKaplanMeier(strata,
                                  includeZero = FALSE,
                                  fileName = file.path(exportFolder, paste0("KaplanMeier",idx,".png")))
    
    
  }
  
  ### Main outcome models ###
  outcomeModelFile <- outcomeReference$outcomeModelFile
  for(i in 1:length(outcomeModelFile)){
    outcomeModel <- readRDS(outcomeModelFile[i])
    if (outcomeModel$outcomeModelStatus == "OK" && outcomeModel$outcomeModelCoefficients !=0) {
        try({
            model <- CohortMethod::getOutcomeModel(outcomeModel, cohortMethodData[[i]])
            idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
            write.csv(model, file.path(exportFolder, paste0("OutcomeModel",idx,".csv")), row.names = FALSE)
        })
    }
  }
#  }
  
  ### create Tables and Figures
#  HypertensionCombination::createTableAndFigures(exportFolder, cmOutputFolder)
  
  ### Add all to zip file ###
#  zipName <- file.path(exportFolder, "StudyResults.zip")
#  OhdsiSharing::compressFolder(exportFolder, zipName)
#  writeLines(paste("\nStudy results are ready for sharing at:", zipName))
  writeLines(paste("\nStudy results are ready for sharing at:", exportFolder))
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
  return(object)}