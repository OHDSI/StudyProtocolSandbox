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
#' createNegativeControlOutcomeCohorts
#'
#' @author
#' Jamie Weaver
#'
#' @details
#' This function generates negative control outcome cohorts for the DiabetesTxPath comparative cohort
#' study
#'
#' @param connectionDetails       The connection details of the database.
#' @param cdmDatabaseSchema       The cdm database schema
#' @param resultsDatabaseSchema   The results database schema
createNegativeControlOutcomeCohorts <- function(connectionDetails,
                                                cdmDatabaseSchema,
                                                resultsDatabaseSchema){
  negativeControls <- read.csv(system.file("settings", "negativeControls.csv", package = "DiabetesTxPath"))
  negativeControlConceptIds <- base::noquote(paste(negativeControls$concept_id, collapse = ","))
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename                  = "createNegativeControlOutcomeCohorts.sql",
                                           packageName                  = "DiabetesTxPath",
                                           dbms                         = attr(connection, "dbms"),
                                           results_database_schema      = resultsDatabaseSchema,
                                           cdm_database_schema          = cdmDatabaseSchema,
                                           negative_control_concept_ids = negativeControlConceptIds)
  DatabaseConnector::executeSql(connection = connection,sql = sql)
}
