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
#' This function generates figures and tables for the paper. Requires the study to be executed first.
#'
#' @param outputFolder         Name of local folder where the results were generated; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cohortDatabaseSchema   Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable     The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#'
#' @export
createFiguresAndTablesForPaper <- function(outputFolder,
                                           connectionDetails,
                                           cohortDatabaseSchema,
                                           cohortTable,
                                           oracleTempSchema = NULL) {
  packageName <- "DenosumabBoneMetastases"
  cmOutputFolder <- file.path(outputFolder, "cmOutput")
  figuresAndTablesFolder <- file.path(outputFolder, "figuresAndTables")
  if (!file.exists(figuresAndTablesFolder))
    dir.create(figuresAndTablesFolder)
  
  
  reference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(reference)
  # Estimates (calibrated and uncalibrated) -------------------------------------------
  allControlsFile <- file.path(outputFolder, "AllControls.csv")
  allControls <- read.csv(allControlsFile)
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = packageName)
  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
  tcsOfInterest <- unique(tcosOfInterest[, c("targetId", "comparatorId")])
  calResults <- data.frame()
  for (i in 1:nrow(tcsOfInterest)) {
    targetId <- tcsOfInterest$targetId[i]
    comparatorId <- tcsOfInterest$comparatorId[i]
    targetLabel <- tcosOfInterest$targetName[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId][1]
    comparatorLabel <- tcosOfInterest$comparatorName[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId][1]
    outcomeIds <- as.character(tcosOfInterest$outcomeIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])
    outcomeIds <- as.numeric(strsplit(outcomeIds, split = ";")[[1]])
    outcomeNames <- as.character(tcosOfInterest$OutcomeNames[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])
    outcomeNames <- strsplit(outcomeNames, split = ";")[[1]]
    
    for (analysisId in unique(reference$analysisId)) {
      controlSubset <- allControls[allControls$targetId == targetId & allControls$comparatorId == comparatorId, ]
      controlSubset <- merge(controlSubset[, c("targetId", "comparatorId", "outcomeId", "oldOutcomeId", "targetEffectSize")], 
                             analysisSummary[analysisSummary$analysisId == analysisId, ])
      negControlSubset <- controlSubset[controlSubset$targetEffectSize == 1, ]
      validNcs <- sum(!is.na(negControlSubset$seLogRr))
      if (validNcs >= 5) {
        null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
      } else {
        null <- NULL
      }
      validPcs <- sum(!is.na(controlSubset$seLogRr))
      if (validPcs >= 10) {
        model <- EmpiricalCalibration::fitSystematicErrorModel(controlSubset$logRr, controlSubset$seLogRr, log(controlSubset$targetEffectSize), estimateCovarianceMatrix = FALSE)
      } else {
        model <- NULL
      }
      for (o in 1:length(outcomeIds)) {
        outcomeId <- outcomeIds[o]
        outcomeLabel <- outcomeNames[o]
        rowIdx <- analysisSummary$targetId == targetId &
          analysisSummary$comparatorId == comparatorId &
          analysisSummary$analysisId == analysisId &
          analysisSummary$outcomeId == outcomeId
        row <- analysisSummary[rowIdx, ]
        row$targetLabel <- targetLabel
        row$comparatorLabel <- comparatorLabel
        row$outcomeLabel <- outcomeLabel
        if (!is.null(null)) {
          fileName <-  file.path(figuresAndTablesFolder, paste0("pCal_a",analysisId,"_t",targetId,"_c",comparatorId, "_o", outcomeId, ".png"))
          EmpiricalCalibration::plotCalibrationEffect(logRrNegatives = negControlSubset$logRr,
                                                      seLogRrNegatives = negControlSubset$seLogRr,
                                                      logRrPositives = row$logRr,
                                                      seLogRrPositives = row$seLogRr,
                                                      null = null,
                                                      showCis = TRUE,
                                                      fileName = fileName)
          calP <- EmpiricalCalibration::calibrateP(null = null,
                                                   logRr = row$logRr,
                                                   seLogRr = row$seLogRr)
          row$calP <- calP$p
          row$calPlb95Ci <- calP$lb95ci
          row$calPub95Ci <- calP$ub95ci
        } else {
          row$calP <- NA
          row$calPlb95Ci <- NA
          row$calPub95Ci <- NA 
        }
        if (!is.null(model)) {
          calCi <- EmpiricalCalibration::calibrateConfidenceInterval(model = model,
                                                                     logRr = row$logRr,
                                                                     seLogRr = row$seLogRr)
          row$calRr <- exp(calCi$logRr)
          row$calLb95Ci <- exp(calCi$logLb95Rr)
          row$calUb95Ci <- exp(calCi$logUb95Rr)
          row$calLogRr <- calCi$logRr
          row$calSeLogRr <- calCi$seLogRr
        } else {
          row$calRr <- NA
          row$calLb95Ci <- NA
          row$calUb95Ci <- NA
          row$calLogRr <- NA
          row$calSeLogRr <- NA
        }
        calResults <- rbind(calResults, row)
      }
    }
  }
  fileName <-  file.path(figuresAndTablesFolder, "caliEstimates.csv")
  write.csv(calResults, fileName, row.names = FALSE)
  
  #calResults <- read.csv(fileName)
  formatEstimate <- function(rr, lb95ci, ub95ci) {
    sprintf("%.2f (%.2f-%.2f)", rr, lb95ci, ub95ci)
  }
  calResults$'HR (95% CI)' <- formatEstimate(calResults$rr, calResults$ci95lb, calResults$ci95ub)
  calResults$'Cal. HR (95% CI)' <- formatEstimate(calResults$calRr, calResults$calLb95Ci, calResults$calUb95Ci)
  for (analysisId in unique(calResults$analysisId)) {
    for (outcomeLabel in unique(calResults$outcomeLabel)) {
      table <- calResults[calResults$outcomeLabel == outcomeLabel & calResults$analysisId == analysisId, ]
      ordered <- data.frame(targetId = c(1,7,9,11,13,3,15,17,5,19),2,
                            description = c("All (prostate cancer)",
                                            "-\t No other malignant diseases",
                                            "-\t  No osteonecrosis or osteomyelitis of the jaw",
                                            "-\t  No prior bisphosphonates",
                                            "-\t  Prior hormonal therapy",
                                            "All (breast cancer)",
                                            "-\t  No other malignant diseases",
                                            "-\t  No prior bisphosphonates",
                                            "All (advanced cancer or multiple myeloma)",
                                            "-\t  No prior bisphosphonates"))
      table[match(table$targetId, ordered$targetId), ] <- table
      table$description <- ordered$description
      table <- data.frame('Inclusion criteria' = table$description,
                          'HR (95% CI)' = table$'HR (95% CI)',
                          'Cal. HR (95% CI)' = table$'Cal. HR (95% CI)')
      fileName <-  file.path(figuresAndTablesFolder, paste0("HRs_", outcomeLabel, "_a", analysisId, ".csv"))
      write.csv(table, fileName, row.names = FALSE)
    }
  }
  
  # Kaplan Meier plots --------------------------------------------------------------------
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = packageName)
  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
  tcsOfInterest <- unique(tcosOfInterest[, c("targetId", "comparatorId")])
  for (i in 1:nrow(tcsOfInterest)) {
    targetId <- tcsOfInterest$targetId[i]
    comparatorId <- tcsOfInterest$comparatorId[i]
    targetLabel <- tcosOfInterest$targetName[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId][1]
    comparatorLabel <- tcosOfInterest$comparatorName[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId][1]
    outcomeIds <- as.character(tcosOfInterest$outcomeIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])
    outcomeIds <- as.numeric(strsplit(outcomeIds, split = ";")[[1]])
    outcomeNames <- as.character(tcosOfInterest$OutcomeNames[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])
    outcomeNames <- strsplit(outcomeNames, split = ";")[[1]]
    
    for (analysisId in unique(reference$analysisId)) {
      for (o in 1:length(outcomeIds)) {
        outcomeId <- outcomeIds[o]
        outcomeLabel <- outcomeNames[o]
        rowIdx <- reference$targetId == targetId &
          reference$comparatorId == comparatorId &
          reference$analysisId == analysisId &
          reference$outcomeId == outcomeId
        strataPop <- readRDS(reference$strataFile[rowIdx])
        fileName <-  file.path(figuresAndTablesFolder, paste0("KM_a",analysisId,"_t",targetId,"_c",comparatorId, "_o", outcomeId, ".png"))
        CohortMethod::plotKaplanMeier(population = strataPop,
                                      treatmentLabel = targetLabel,
                                      comparatorLabel = comparatorLabel,
                                      fileName = fileName)
        
        # cmData <- CohortMethod::loadCohortMethodData(reference$cohortMethodDataFolder[rowIdx])
        # studyPop <- CohortMethod::createStudyPopulation(cohortMethodData = cmData,
        #                                                 outcomeId = outcomeId,
        #                                                 removeDuplicateSubjects = "keep first",
        #                                                 removeSubjectsWithPriorOutcome = FALSE,
        #                                                 riskWindowStart = 0,
        #                                                 riskWindowEnd = round(34 * 30.5),
        #                                                 addExposureDaysToEnd = FALSE)
        # population <- cmData$cohorts
        # population <- population[order(population$subjectId, as.Date(population$cohortStartDate)), ]
        # idx <- duplicated(population[, c("subjectId")])
        # x <- population[idx, ]
        # population <- population[!idx, ]
        # metaData$attrition <- rbind(metaData$attrition,
        #                             getCounts(population, paste("Restricting duplicate subjects to first cohort")))
      }
    }
  }
        
}


#' Generate diagnostics
#'
#' @details
#' This function generates figures and tables for the paper. Requires the study to be executed first.
#'
#' @param outputFolder         Name of local folder where the results were generated; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cohortDatabaseSchema   Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable     The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#'
#' @export
createFiguresAndTablesForProtocol <- function(outputFolder,
                                   connectionDetails,
                                   cohortDatabaseSchema,
                                   cohortTable,
                                   oracleTempSchema = oracleTempSchema) {
  cmOutputFolder <- file.path(outputFolder, "cmOutput")
  figuresAndTablesFolder <- file.path(outputFolder, "figuresAndTables")
  if (!file.exists(figuresAndTablesFolder))
    dir.create(figuresAndTablesFolder)
  
  
  reference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
  analysisSummary <- CohortMethod::summarizeAnalyses(reference)
  
  
  # Break up outcomes into components --------------------------------------------------------------
  conn <- DatabaseConnector::connect(connectionDetails)
  strataFile <- reference$strataFile[reference$analysisId == 1 &
                                       reference$targetId == 1 &
                                       reference$comparatorId == 2 &
                                       reference$outcomeId == 21]
  popPc <- readRDS(strataFile)
  strataFile <- reference$strataFile[reference$analysisId == 1 &
                                       reference$targetId == 3 &
                                       reference$comparatorId == 4 &
                                       reference$outcomeId == 21]
  popBc <- readRDS(strataFile)
  strataFile <- reference$strataFile[reference$analysisId == 1 &
                                       reference$targetId == 5 &
                                       reference$comparatorId == 6 &
                                       reference$outcomeId == 21]
  popOther <- readRDS(strataFile)
  population <- rbind(popPc, popBc, popOther)
  population <- population[population$outcomeCount > 0, ]
  population$cohortStartDate <- population$cohortStartDate + population$daysToEvent
  population <- population[, c("subjectId", "cohortStartDate", "treatment")]
  colnames(population) <- SqlRender::camelCaseToSnakeCase(colnames(population))
  DatabaseConnector::insertTable(connection = conn,
                                 tableName = "#temp",
                                 data = population,
                                 dropTableIfExists = TRUE,
                                 createTable = TRUE,
                                 tempTable = TRUE,
                                 oracleTempSchema = oracleTempSchema)
  sql <- "SELECT dedupe.cohort_definition_id,
    treatment,
    COUNT(*) AS event_count
  FROM (SELECT MAX(cohort.cohort_definition_id) AS cohort_definition_id,
      treatment,
      cohort.cohort_start_date,
      cohort.subject_id
    FROM #temp temp
    INNER JOIN @cohort_database_schema.@cohort_table cohort
    ON temp.subject_id = cohort.subject_id
    AND temp.cohort_start_date = cohort.cohort_start_date
    WHERE cohort.cohort_definition_id IN (22,23,24,25)
    GROUP BY treatment,
      cohort.cohort_start_date,
      cohort.subject_id
  ) dedupe
  GROUP BY dedupe.cohort_definition_id,
    treatment;"
  sql <- SqlRender::renderSql(sql = sql,
                              cohort_database_schema = cohortDatabaseSchema,
                              cohort_table = cohortTable)$sql
  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms, oracleTempSchema = oracleTempSchema)$sql
  counts <- DatabaseConnector::querySql(conn, sql)
  colnames(counts) <- SqlRender::snakeCaseToCamelCase(colnames(counts))
  counts <- addCohortNames(counts)
  counts <- aggregate(eventCount ~ cohortName, counts, sum)
  write.csv(counts, file.path(figuresAndTablesFolder, "EventBreakout.csv"), row.names = FALSE)
  
  # MDRR across TCs -----------------------------------------------
  mdrrFiles <- list.files(file.path(outputFolder, "diagnostics"), pattern = "mdrr.*.csv")
  outcomeIds <- as.integer(gsub(".csv", "", gsub("^.*_o", "", mdrrFiles)))
  for (outcomeId in unique(outcomeIds)) {
    mdrr <- lapply(mdrrFiles[outcomeIds == outcomeId], function(x) read.csv(file.path(outputFolder, "diagnostics", x)))
    mdrr <- do.call(rbind, mdrr)
    mdrr$file <- mdrrFiles[outcomeIds == outcomeId]
    mdrr$targetId <- as.integer(gsub("_.*$", "", gsub("mdrr_a1_t", "", mdrr$file)))
    ordered <- data.frame(targetId = c(1,7,9,11,13,3,15,17,5,19),2,
                          description = c("All (prostate cancer)",
                                          "-\t No other malignant diseases",
                                          "-\t  No osteonecrosis or osteomyelitis of the jaw",
                                          "-\t  No prior bisphosphonates",
                                          "-\t  Prior hormonal therapy",
                                          "All (breast cancer)",
                                          "-\t  No other malignant diseases",
                                          "-\t  No prior bisphosphonates",
                                          "All (advanced cancer or multiple myeloma)",
                                          "-\t  No prior bisphosphonates"))
    mdrr[match(mdrr$targetId, ordered$targetId), ] <- mdrr
    mdrr$description <- ordered$description
    mdrr$mdrr <- 1/mdrr$mdrr
    mdrr <- mdrr[, c("description", "targetPersons", "comparatorPersons", "totalOutcomes", "mdrr")]
    fileName <- file.path(figuresAndTablesFolder, paste0("allMdrrs_o", outcomeId, ".csv"))
    write.csv(mdrr, fileName, row.names = FALSE)
  }
  
  # Study start date -------------------------------------------
  conn <- connect(connectionDetails)
  sql <- "SELECT MIN(cohort_start_date), cohort_definition_id FROM scratch.dbo.mschuemi_denosumab_optum WHERE cohort_definition_id IN (1, 3, 5) GROUP BY cohort_definition_id"
  print(querySql(conn, sql))
  
  # Simplified null distribution -------------------------------------------
  negativeControls <- read.csv(system.file("settings", "NegativeControls.csv", package = "DenosumabBoneMetastases"))
  negativeControlOutcomeIds <- negativeControls$outcomeId[negativeControls$type == "Outcome"]
  
  negControlSubset <- analysisSummary[analysisSummary$targetId %in% c(1,3,5) & 
                                        analysisSummary$comparatorId %in% c(2,4,6) & 
                                        analysisSummary$outcomeId %in% negativeControlOutcomeIds, ]
  negControlSubset$label <- "Prostate cancer"
  negControlSubset$label[negControlSubset$targetId == 3] <- "Breast cancer"
  negControlSubset$label[negControlSubset$targetId == 5] <- "Advanced cancer"
  fileName <-  file.path(figuresAndTablesFolder, paste0("simplifiedNullDistribution.png"))
  EvidenceSynthesis::plotEmpiricalNulls(logRr = negControlSubset$logRr,
                                        seLogRr = negControlSubset$seLogRr,
                                        labels = negControlSubset$label,
                                        fileName = fileName)
  
  # PS distributions --------------------------------------------------------------
  psFile <- reference$sharedPsFile[reference$analysisId == 1 &
                                     reference$targetId == 1 &
                                     reference$comparatorId == 2 &
                                     reference$outcomeId == 21]
  ps <- readRDS(psFile)
  psPc <- EvidenceSynthesis::preparePsPlot(ps)
  psFile <- reference$sharedPsFile[reference$analysisId == 1 &
                                     reference$targetId == 3 &
                                     reference$comparatorId == 4 &
                                     reference$outcomeId == 21]
  ps <- readRDS(psFile)
  psBc <- EvidenceSynthesis::preparePsPlot(ps)
  psFile <- reference$sharedPsFile[reference$analysisId == 1 &
                                     reference$targetId == 5 &
                                     reference$comparatorId == 6 &
                                     reference$outcomeId == 21]
  ps <- readRDS(psFile)
  psOther <- EvidenceSynthesis::preparePsPlot(ps)
  ps <- list(psPc, psBc, psOther)
  fileName <-  file.path(figuresAndTablesFolder, paste0("ps.png"))
  EvidenceSynthesis::plotPreparedPs(preparedPsPlots = ps, 
                                    labels = c("Prostate cancer", "Breast cancer", "Advanced cancer"), 
                                    treatmentLabel = "Denosumab",
                                    comparatorLabel = "Zoledronic acid",
                                    fileName = fileName)
  
  # Balance --------------------------------------------------------------
  cmDataFile <- reference$cohortMethodDataFolder[reference$analysisId == 1 &
                                                   reference$targetId == 1 &
                                                   reference$comparatorId == 2 &
                                                   reference$outcomeId == 21]
  strataFile <- reference$strataFile[reference$analysisId == 1 &
                                       reference$targetId == 1 &
                                       reference$comparatorId == 2 &
                                       reference$outcomeId == 21]
  cmData <- CohortMethod::loadCohortMethodData(cmDataFile)
  strata <- readRDS(strataFile)
  balPc <- CohortMethod::computeCovariateBalance(strata, cmData)
  
  cmDataFile <- reference$cohortMethodDataFolder[reference$analysisId == 1 &
                                                   reference$targetId == 3 &
                                                   reference$comparatorId == 4 &
                                                   reference$outcomeId == 21]
  strataFile <- reference$strataFile[reference$analysisId == 1 &
                                       reference$targetId == 3 &
                                       reference$comparatorId == 4 &
                                       reference$outcomeId == 21]
  cmData <- CohortMethod::loadCohortMethodData(cmDataFile)
  strata <- readRDS(strataFile)
  balBc <- CohortMethod::computeCovariateBalance(strata, cmData)
  cmDataFile <- reference$cohortMethodDataFolder[reference$analysisId == 1 &
                                                   reference$targetId == 5 &
                                                   reference$comparatorId == 6 &
                                                   reference$outcomeId == 21]
  strataFile <- reference$strataFile[reference$analysisId == 1 &
                                       reference$targetId == 5 &
                                       reference$comparatorId == 6 &
                                       reference$outcomeId == 21]
  cmData <- CohortMethod::loadCohortMethodData(cmDataFile)
  strata <- readRDS(strataFile)
  balOther <- CohortMethod::computeCovariateBalance(strata, cmData)
  bal <- list(balPc, balBc, balOther)
  fileName <-  file.path(figuresAndTablesFolder, paste0("balance.png"))
  EvidenceSynthesis::plotCovariateBalances(balances = bal,
                                           labels = c("Prostate cancer", "Breast cancer", "Adv. cancer"), 
                                           beforeLabel = "Before straticiation",
                                           afterLabel = "After stratification",
                                           fileName = fileName)
  fileName <- system.file("settings", "Table1Specs.csv", package = "DenosumabBoneMetastases")
  table1Specs <- read.csv(fileName)
  table1 <- CohortMethod::createCmTable1(balance = balPc, 
                                         specifications = table1Specs, 
                                         beforeLabel = "Before stratification",
                                         afterLabel = "After stratification",
                                         targetLabel = "Deno-sumab",
                                         comparatorLabel = "Zole-dronic acid",
                                         percentDigits = 0)
  write.csv(table1, file.path(figuresAndTablesFolder, "Table1_PC.csv"), row.names = FALSE)
  table1 <- CohortMethod::createCmTable1(balance = balBc, 
                                         specifications = table1Specs, 
                                         beforeLabel = "Before stratification",
                                         afterLabel = "After stratification",
                                         targetLabel = "Deno-sumab",
                                         comparatorLabel = "Zole-dronic acid",
                                         percentDigits = 0)
  write.csv(table1, file.path(figuresAndTablesFolder, "Table1_BC.csv"), row.names = FALSE)
  table1 <- CohortMethod::createCmTable1(balance = balOther, 
                                         specifications = table1Specs, 
                                         beforeLabel = "Before stratification",
                                         afterLabel = "After stratification",
                                         targetLabel = "Deno-sumab",
                                         comparatorLabel = "Zole-dronic acid",
                                         percentDigits = 0)
  write.csv(table1, file.path(figuresAndTablesFolder, "Table1_Other.csv"), row.names = FALSE)
}
