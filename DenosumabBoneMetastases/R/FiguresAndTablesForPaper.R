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
createFiguresAndTables <- function(outputFolder,
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
                                       reference$outcomeId == 3]
  population <- readRDS(strataFile)
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
    WHERE cohort.cohort_definition_id IN (12,13,14,15)
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
  write.csv(counts, file.path(figuresAndTablesFolder, "EventBreakout.csv"), row.names = FALSE)

  # MDRR across TCs -----------------------------------------------
  mdrrFiles <- list.files(file.path(outputFolder, "diagnostics"), pattern = "mdrr.*.csv")
  mdrr <- lapply(mdrrFiles, function(x) read.csv(file.path(outputFolder, "diagnostics", x)))
  mdrr <- do.call(rbind, mdrr)
  mdrr$file <- mdrrFiles
  write.csv(mdrr, file.path(figuresAndTablesFolder, "allMdrrs.csv"), row.names = FALSE)
  
  # Study start date -------------------------------------------
  conn <- connect(connectionDetails)
  sql <- "SELECT MIN(cohort_start_date) FROM scratch.dbo.mschuemi_denosumab_optum WHERE cohort_definition_id = 1"
  print(querySql(conn, sql))
  
  # Simplified null distribution -------------------------------------------
  negativeControls <- read.csv(system.file("settings", "NegativeControls.csv", package = "DenosumabBoneMetastases"))
  negativeControlOutcomeIds <- negativeControls$outcomeId[negativeControls$type == "Outcome"]
  
  negControlSubset <- analysisSummary[analysisSummary$targetId == 1 & 
                                        analysisSummary$comparatorId == 2 & 
                                        analysisSummary$outcomeId %in% negativeControlOutcomeIds, ]
  fileName <-  file.path(figuresAndTablesFolder, paste0("simplifiedNullDistribution.png"))
  EvidenceSynthesis::plotEmpiricalNulls(logRr = negControlSubset$logRr,
                                        seLogRr = negControlSubset$seLogRr,
                                        labels = rep("Optum", nrow(negControlSubset)),
                                        fileName = fileName)
}
