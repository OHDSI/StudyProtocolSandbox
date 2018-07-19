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

#' Run CohortMethod analyses
#'
#' @details
#' This function runs CohortMethod.
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
#' @param maxCores             How many parallel cores should be used? If more cores are made available
#'                             this can speed up the analyses.
#'
#' @export
runCmAnalyses <- function(outputFolder,
                          connectionDetails,
                          cdmDatabaseSchema,
                          cohortDatabaseSchema,
                          cohortTable,
                          oracleTempSchema,
                          maxCores) {
  cmOutputFolder <- file.path(outputFolder, "cmOutput")
  if (!file.exists(cmOutputFolder))
    dir.create(cmOutputFolder)
  cmAnalysisListFile <- system.file("settings",
                                    "cmAnalysisList.json",
                                    package = "DenosumabBoneMetastases")
  
  # First: load data -----------------------------------------------------------------------
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
  dcosList <- createTcos(outputFolder = outputFolder)
  for (i in 1:length(cmAnalysisList)) {
    cmAnalysisList[[i]]$createPs <- FALSE
    cmAnalysisList[[i]]$stratifyByPs <- FALSE
    cmAnalysisList[[i]]$fitOutcomeModel <- FALSE
  }
  results <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         exposureDatabaseSchema = cohortDatabaseSchema,
                                         exposureTable = cohortTable,
                                         outcomeDatabaseSchema = cohortDatabaseSchema,
                                         outcomeTable = cohortTable,
                                         outputFolder = cmOutputFolder,
                                         oracleTempSchema = oracleTempSchema,
                                         cmAnalysisList = cmAnalysisList,
                                         drugComparatorOutcomesList = dcosList,
                                         getDbCohortMethodDataThreads = min(3, maxCores),
                                         createStudyPopThreads = min(3, maxCores),
                                         createPsThreads = max(1, round(maxCores/10)),
                                         psCvThreads = min(10, maxCores),
                                         computeCovarBalThreads = min(3, maxCores),
                                         trimMatchStratifyThreads = min(10, maxCores),
                                         fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                         outcomeCvThreads = min(4, maxCores),
                                         refitPsForEveryOutcome = FALSE)
  unlink(unique(results$studyPopFile))
  unlink(unique(results$psFile))
  
  
  # Then: Fix cohort end dates -------------------------------------------------------------
  results <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
  exposure <- getEras(connectionDetails = connectionDetails, 
                      oracleTempSchema = oracleTempSchema, 
                      cdmDatabaseSchema = cdmDatabaseSchema, 
                      cohortDatabaseSchema = cohortDatabaseSchema, 
                      cohortTable = cohortTable)
  cmDataFolders <- unique(results$cohortMethodDataFolder)
  for (cmDataFolder in cmDataFolders) {
    fileName <- file.path(cmDataFolder, "cohorts.rds")
    backupFileName <- paste0(fileName, ".bak")
    if (file.exists(backupFileName)) {
      cohorts <- readRDS(backupFileName)
    } else { 
      cohorts <- readRDS(fileName)
      saveRDS(cohorts, backupFileName)
    }
    OhdsiRTools::logInfo("Fixing cohort end dates in ", fileName)
    cohorts <- merge(cohorts, exposure[, c("subjectId", "cohortStartDate", "treatment", "eraEndDate")])  
    cohorts$daysToCohortEnd <- as.integer(cohorts$eraEndDate - cohorts$cohortStartDate)
    cohorts$daysToCohortEnd[cohorts$daysToCohortEnd > cohorts$daysToObsEnd] <- cohorts$daysToObsEnd[cohorts$daysToCohortEnd > cohorts$daysToObsEnd]
    cohorts$eraEndDate <- NULL
    saveRDS(cohorts, fileName)
  }
  
  # Last: Run cohort method in full --------------------------------------------------------
  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
  dcosList <- createTcos(outputFolder = outputFolder)
  results <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         exposureDatabaseSchema = cohortDatabaseSchema,
                                         exposureTable = cohortTable,
                                         outcomeDatabaseSchema = cohortDatabaseSchema,
                                         outcomeTable = cohortTable,
                                         outputFolder = cmOutputFolder,
                                         oracleTempSchema = oracleTempSchema,
                                         cmAnalysisList = cmAnalysisList,
                                         drugComparatorOutcomesList = dcosList,
                                         getDbCohortMethodDataThreads = min(3, maxCores),
                                         createStudyPopThreads = min(3, maxCores),
                                         createPsThreads = max(1, round(maxCores/10)),
                                         psCvThreads = min(10, maxCores),
                                         computeCovarBalThreads = min(3, maxCores),
                                         trimMatchStratifyThreads = min(10, maxCores),
                                         fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                         outcomeCvThreads = min(4, maxCores),
                                         refitPsForEveryOutcome = FALSE)
}


getEras <- function(connectionDetails, oracleTempSchema, cdmDatabaseSchema, cohortDatabaseSchema, cohortTable) {
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = "DenosumabBoneMetastases")
  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)
  cohortIds <- unique(c(tcosOfInterest$targetId, tcosOfInterest$comparatorId))
  connection <- DatabaseConnector::connect(connectionDetails)
  
  # Get denosumab exposures of T and C -------------------------------
  sql <- "SELECT DISTINCT subject_id,
  cohort_start_date,
  drug_exposure_start_date,
  DATEADD(DAY, days_supply, drug_exposure_start_date) AS drug_exposure_end_date
  FROM @cohort_database_schema.@cohort_table cohort
  INNER JOIN @cdm_database_schema.drug_exposure
  ON person_id = subject_id
  AND drug_exposure_start_date >= cohort_start_date
  WHERE drug_concept_id IN (SELECT descendant_concept_id FROM @cdm_database_schema.concept_ancestor WHERE ancestor_concept_id = 40222444)
  AND cohort_definition_id IN (@cohort_ids);"
  sql <- SqlRender::renderSql(sql = sql, 
                              cdm_database_schema = cdmDatabaseSchema,
                              cohort_database_schema = cohortDatabaseSchema,
                              cohort_table = cohortTable,
                              cohort_ids = cohortIds)$sql
  sql <- SqlRender::translateSql(sql = sql,
                                 targetDialect = connectionDetails$dbms,
                                 oracleTempSchema = oracleTempSchema)$sql
  exposureDenosumab <- DatabaseConnector::querySql(connection, sql)
  colnames(exposureDenosumab) <- SqlRender::snakeCaseToCamelCase(colnames(exposureDenosumab))
  
  # Get zoledronic acid exposures of T and C -------------------------------
  sql <- "SELECT DISTINCT subject_id,
  cohort_start_date,
  drug_exposure_start_date,
  DATEADD(DAY, days_supply, drug_exposure_start_date) AS drug_exposure_end_date
  FROM @cohort_database_schema.@cohort_table cohort
  INNER JOIN @cdm_database_schema.drug_exposure
  ON person_id = subject_id
  AND drug_exposure_start_date >= cohort_start_date
  WHERE drug_concept_id IN (SELECT descendant_concept_id FROM @cdm_database_schema.concept_ancestor WHERE ancestor_concept_id = 1524674)
  AND cohort_definition_id IN (@cohort_ids)
  
  UNION ALL
  
  SELECT DISTINCT subject_id,
  cohort_start_date,
  procedure_date AS drug_exposure_start_date,
  procedure_date AS drug_exposure_end_date
  FROM @cohort_database_schema.@cohort_table cohort
  INNER JOIN @cdm_database_schema.procedure_occurrence
  ON person_id = subject_id
  AND procedure_date >= cohort_start_date
  WHERE procedure_source_concept_id IN (2718650,2720787,2718649,44786564,44786608)
  AND cohort_definition_id IN (@cohort_ids);"
  sql <- SqlRender::renderSql(sql = sql, 
                              cdm_database_schema = cdmDatabaseSchema,
                              cohort_database_schema = cohortDatabaseSchema,
                              cohort_table = cohortTable,
                              cohort_ids = cohortIds)$sql
  sql <- SqlRender::translateSql(sql = sql,
                                 targetDialect = connectionDetails$dbms,
                                 oracleTempSchema = oracleTempSchema)$sql
  exposureZoledronicAcid <- DatabaseConnector::querySql(connection, sql)
  colnames(exposureZoledronicAcid) <- SqlRender::snakeCaseToCamelCase(colnames(exposureZoledronicAcid))
  
  DatabaseConnector::disconnect(connection)
  
  createEras <- function(exposure, gap = 60, append = 30) {
    exposure <- exposure[order(exposure$subjectId, 
                               exposure$cohortStartDate, 
                               exposure$drugExposureStartDate), ]
    n  <- nrow(exposure)
    idx <- exposure$subjectId[1:(n-1)] == exposure$subjectId[2:n] &
      exposure$cohortStartDate[1:(n-1)] == exposure$cohortStartDate[2:n] &
      (exposure$drugExposureStartDate[1:(n-1)] - exposure$drugExposureStartDate[2:n]>= -gap)
    idx <- which(idx)
    exposure$eraEndDate <- as.Date(NA)
    exposure$eraEndDate[idx] <- exposure$drugExposureStartDate[idx+1]
    head(exposure)
    while(length(idx) > 0) {
      idx <- exposure$subjectId[1:(n-1)] == exposure$subjectId[2:n] &
        exposure$cohortStartDate[1:(n-1)] == exposure$cohortStartDate[2:n] &
        (exposure$drugExposureStartDate[1:(n-1)] - exposure$drugExposureStartDate[2:n]>= -gap) &
        !is.na(exposure$eraEndDate[2:n]) &
        (is.na(exposure$eraEndDate[1:(n-1)]) | exposure$eraEndDate[2:n] > exposure$eraEndDate[1:(n-1)])
      idx <- which(idx)
      exposure$eraEndDate[idx] <- exposure$eraEndDate[idx+1]
    }
    exposure$eraEndDate[is.na(exposure$eraEndDate)] <- exposure$drugExposureStartDate[is.na(exposure$eraEndDate)]
    exposure$eraEndDate <- exposure$eraEndDate + append
    return(exposure)
  }
  
  exposureDenosumab <- createEras(exposureDenosumab)
  exposureZoledronicAcid <- createEras(exposureZoledronicAcid)
  exposureDenosumab$treatment <- 1
  exposureZoledronicAcid$treatment <- 0
  exposure <- rbind(exposureDenosumab, exposureZoledronicAcid)
  exposure <- exposure[exposure$cohortStartDate == exposure$drugExposureStartDate, ]
  exposure <- exposure[, c("subjectId", "cohortStartDate", "treatment", "eraEndDate")]
  exposure <- exposure[order(exposure$subjectId, 
                             exposure$cohortStartDate, 
                             exposure$treatment), ]
  dup <- duplicated(exposure[, c("subjectId", "cohortStartDate", "treatment")])
  exposure <- exposure[!dup, ]
  return(exposure)
}