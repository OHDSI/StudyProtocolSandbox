# @file functions
#
# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of:
#  ----------------------------------------------
#  DiabetesTxPath
#  ----------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Stanford University Center for Biomedical Informatics - Shah Lab
# @author Rohit Vashisht
#
#' @title
#' createExposureCohorts
#'
#' @author
#' Jamie Weaver
#'
#' @details
#' This function generates the 3 treatment path exposure cohorts for the DiabetesTxPath
#' comparative cohort study. They are set as bigToSulf=1, bigToDpp4=2, bigToThia=3.
#'
#' @param connectionDetails       The connection details of the database.
#' @param cdmDatabaseSchema       The cdm database schema
#' @param resultsDatabaseSchema   The results database schema
createExposureCohorts <- function(connectionDetails,
                                  cdmDatabaseSchema,
                                  resultsDatabaseSchema){
  cohortsToCreate <- cbind(c(1:3), read.csv(system.file("settings/CohortsToCreate.csv", package = "DiabetesTxPath"))[1:3, ])
  targetDatabaseSchema <- resultsDatabaseSchema
  targetCohortTable <- "ohdsi_t2dpathway"
  connection <- DatabaseConnector::connect(connectionDetails)
  sql <- "IF OBJECT_ID('@results_database_schema.@target_cohort_table', 'U') IS NOT NULL\n  DROP TABLE @results_database_schema.@target_cohort_table;\n
       CREATE TABLE @results_database_schema.@target_cohort_table (cohort_definition_id INT, subject_id BIGINT, cohort_start_date DATE, cohort_end_date DATE);"
  sql <- SqlRender::renderSql(sql                     = sql,
                              results_database_schema = resultsDatabaseSchema,
                              target_cohort_table     = targetCohortTable)$sql
  sql <- SqlRender::translateSql(sql, targetDialect   = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(connection = connection, sql = sql, progressBar = FALSE, reportOverallTime = FALSE)
  # bigToSulf
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename            = paste0(cohortsToCreate[1, 4], ".sql"),
                                           packageName            = "DiabetesTxPath",
                                           dbms                   = attr(connection, "dbms"),
                                           cdm_database_schema    = cdmDatabaseSchema,
                                           target_database_schema = targetDatabaseSchema,
                                           target_cohort_table    = targetCohortTable,
                                           target_cohort_id       = 1)
  DatabaseConnector::executeSql(connection = connection, sql = sql)
  # bigToDpp4
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename            = paste0(cohortsToCreate[2, 4], ".sql"),
                                           packageName            = "DiabetesTxPath",
                                           dbms                   = attr(connection, "dbms"),
                                           cdm_database_schema    = cdmDatabaseSchema,
                                           target_database_schema = targetDatabaseSchema,
                                           target_cohort_table    = targetCohortTable,
                                           target_cohort_id       = 2)
  DatabaseConnector::executeSql(connection = connection, sql = sql)
  # bigToThia
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename            = paste0(cohortsToCreate[3, 4], ".sql"),
                                           packageName            = "DiabetesTxPath",
                                           dbms                   = attr(connection, "dbms"),
                                           cdm_database_schema    = cdmDatabaseSchema,
                                           target_database_schema = targetDatabaseSchema,
                                           target_cohort_table    = targetCohortTable,
                                           target_cohort_id       = 3)
  DatabaseConnector::executeSql(connection = connection, sql = sql)
}
