# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of DiabetesTxPath
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
#
# @author Stanford University Center for Biomedical Informatics - Nigam Shah Lab
# @author Rohit Vashisht
#
#' @title
#' buildCohort
#'
#' @author
#' Rohit Vashisht
#'
#
#' Create the exposure and outcome cohorts
#'
#' @details
#' This function creates all the required outcome cohorts for T2D study. The outcome cohort
#' represents a) HbA1c <= 7%, b) HbA1c <= 8%, c) MI, d) KD and e) ED.
#'
#' @param connectionDetails       An object of type \code{connectionDetails} as created using the
#'                                \code{\link[DatabaseConnector]{createConnectionDetails}} function in
#'                                the DatabaseConnector package.
#' @param cdmDatabaseSchema       Schema name where your patient-level data in OMOP CDM format resides.
#'                                Note that for SQL Server, this should include both the database and
#'                                schema name, for example 'cdm_data.dbo'.
#' @param resultsDatabaseSchema   Schema name where intermediate data can be stored. You will need to
#'                                have write priviliges in this schema. Note that for SQL Server, this
#'                                should include both the database and schema name, for example
#'                                'cdm_data.dbo'.
buildOutComeCohort <- function(connectionDetails,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema){
  #Cohorts for the outCome of interest. Please note the outcome IDs for each outCome.
  outComeOne <- c("HbA1c7Good.sql")  #cohortId = 4
  outComeTwo <- c("HbA1c8Moderate.sql") #cohortId = 5
  outComeThree <- c("myocardialInfraction.sql")  #cohortId = 6
  outComeFour <- c("kidneyDisorder.sql")  #cohortId = 7
  outComeFive <- c("eyeDisorder.sql")  #cohortId = 8
  targetDatabaseSchema <- resultsDatabaseSchema
  targetCohortTable <- "ohdsi_t2dpathway_outcomes"
  conn <- DatabaseConnector::connect(connectionDetails)
  sql <- "IF OBJECT_ID('@results_database_schema.@target_cohort_table', 'U') IS NOT NULL\n  DROP TABLE @results_database_schema.@target_cohort_table;\n
       CREATE TABLE @results_database_schema.@target_cohort_table (cohort_definition_id INT, subject_id BIGINT, cohort_start_date DATE, cohort_end_date DATE);"
  sql <- SqlRender::renderSql(sql                     = sql,
                              results_database_schema = resultsDatabaseSchema,
                              target_cohort_table     = targetCohortTable)$sql
  sql <- SqlRender::translateSql(sql, targetDialect   = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(connection = conn, sql = sql, progressBar = FALSE, reportOverallTime = FALSE)



  #outComeOne - outComeId = 4, outComeName <- HbA1c7Good
  sql <- readSql(system.file(paste("sql/sql_server/", outComeOne, sep = ""),
                               package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 4)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  #outComeTwo, outComeId = 5, outComeName <- HbA1c8Moderate
  sql <- readSql(system.file(paste("sql/sql_server/", outComeTwo, sep = ""),
                               package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 5)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  #OutcomeThree, outComeId = 6, outComeName = MI
  sql <- readSql(system.file(paste("sql/sql_server/", outComeThree, sep = ""),
                               package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 6)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  #outComeFour, outComeId = 7, outComeName = KD
  sql <- readSql(system.file(paste("sql/sql_server/", outComeFour, sep = ""),
                               package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 7)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  #outComeFive, outComeId = 8, outComeName = ED
  sql <- readSql(system.file(paste("sql/sql_server/", outComeFive, sep = ""),
                               package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = targetDatabaseSchema,
                                target_cohort_table = targetCohortTable,
                                target_cohort_id = 8)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
  #Negative Controls
  negativeControls <- read.csv(system.file("settings", "negativeControls.csv", package = "DiabetesTxPath"))
  negativeControlConceptIds <- base::noquote(paste(negativeControls$concept_id, collapse = ","))
  sql <- readSql(system.file(paste("sql/sql_server/createNegativeControlOutcomeCohorts.sql", sep = ""),
                             package = "DiabetesTxPath"))
  sql <- SqlRender::renderSql(sql,
                              cdm_database_schema = cdmDatabaseSchema,
                              results_database_schema = resultsDatabaseSchema,
                              negative_control_concept_ids = negativeControlConceptIds)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)
}
