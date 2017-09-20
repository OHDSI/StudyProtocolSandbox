# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of AlendronateVsRaloxifene
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

#' Execute OHDSI Keppra and the Risk of Angioedema study
#'
#' @details
#' This function executes the OHDSI Keppra and the Risk of Angioedema study.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param workDatabaseSchema   Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param studyCohortTable     The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param createCohorts        Create the studyCohortTable table with the exposure and outcome cohorts?
#' @param runAnalyses          Perform the cohort method analyses?
#' @param packageResults       Package the results for sharing?
#' @param maxCores             How many parallel cores should be used? If more cores are made available
#'                             this can speed up the analyses.
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' execute(connectionDetails,
#'         cdmDatabaseSchema = "cdm_data",
#'         workDatabaseSchema = "results",
#'         studyCohortTable = "ohdsi_alendronate_raloxifene",
#'         oracleTempSchema = NULL,
#'         outputFolder = "c:/temp/study_results",
#'         maxCores = 4)
#' }
#'
#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    workDatabaseSchema = cdmDatabaseSchema,
                    studyCohortTable = "ohdsi_cancertreatments",
                    oracleTempSchema = workDatabaseSchema,
                    outputFolder,
                    createCohorts = TRUE,
                    runAnalyses = FALSE,
                    packageResults = TRUE,
                    maxCores = 4) {
  if (!file.exists(outputFolder))
    dir.create(outputFolder)

  # cmOutputFolder <- file.path(outputFolder, "cmOutput")
  #  if (!file.exists(cmOutputFolder))
  #    dir.create(cmOutputFolder)

  #connect
  conn <- DatabaseConnector::connect(connectionDetails)


  if (createCohorts) {
    writeLines("Creating  cohorts")


    createCohorts(connection = conn,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  cohortDatabaseSchema = workDatabaseSchema,
                  cohortTable = studyCohortTable,
                  oracleTempSchema = oracleTempSchema,
                  outputFolder = outputFolder)
    writeLines("")
  }

  # DBI::dbDisconnect(conn)

  if (runAnalyses) {
    writeLines("Running analyses")

    writeLines("")
  }



  if (packageResults) {
    writeLines("Packaging results in export folder for sharing")
    packageResults(connectionDetails = connectionDetails,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   outputFolder = outputFolder)
    writeLines("")
  }

  invisible(NULL)
}
