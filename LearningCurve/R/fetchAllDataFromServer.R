# @file fetchAllDataFromServer.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of LargeScalePrediction package
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

#' Creates the cohorts needed for the abalysis and the gets the patient level prediction data from the server
#' @description
#' This function creates the 'at risk' and 'outcome' cohorts using files saved in the package to the
#'  workDatabaseSchema database in the studyCohortTable table and then extracts the plpData
#'  using these cohorts.
#'
#' @details
#' This function creates the 'at risk' and 'outcome' cohorts using files saved in the package to the
#'  workDatabaseSchema database in the studyCohortTable table and then extracts the plpData
#'  using these cohorts.
#'
#' @param connectionDetails            An R object of type\cr\code{connectionDetails} created using the
#'                                     function \code{createConnectionDetails} in the
#'                                     \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema            The name of the database schema that contains the OMOP CDM
#'                                     instance.  Requires read permissions to this database. On SQL
#'                                     Server, this should specifiy both the database and the schema,
#'                                     so for example 'cdm_instance.dbo'.
#' @param oracleTempSchema             For Oracle only: the name of the database schema where you want
#'                                     all temporary tables to be managed. Requires create/insert
#'                                     permissions to this database.
#' @param workDatabaseSchema           The name of the database schema that is the location where the
#'                                     cohort data used to define the study cohorts is available
#' @param studyCohortTable             The tablename that contains the study cohorts.
#' @param workFolder                   The directory where the results will be saved to
#'
#' @return
#' Returns TRUE when finished
#' @export
fetchAllDataFromServer <- function(connectionDetails = connectionDetails,
                                   cdmDatabaseSchema = cdmDatabaseSchema,
                                   oracleTempSchema = oracleTempSchema,
                                   workDatabaseSchema = workDatabaseSchema,
                                   studyCohortTable = studyCohortTable,
                                   workFolder = workFolder,
                                   verbosity=INFO){
    #checking inputs:
    #TODO

    flog.seperator()
    flog.info('Starting data extraction')
    flog.seperator()
    # create the cohort table if it doest exist
    flog.info('Connecting to database')
    conn <- ftry(DatabaseConnector::connect(connectionDetails),
                 error = stop, finally = flog.info('Connected')
    )
    flog.info('Checking work cohort table exists')

    exists <- studyCohortTable%in%DatabaseConnector::getTableNames(conn, workDatabaseSchema)

    if(!exists){
        flog.info('Creating work cohort table')
        sql <- "create table @target_database_schema.@target_cohort_table(cohort_definition_id bigint, subject_id bigint, cohort_start_date datetime, cohort_end_date datetime)"
        sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
        sql <- SqlRender::renderSql(sql,
                                    target_database_schema=workDatabaseSchema,
                                    target_cohort_table=studyCohortTable)$sql
        ftry(DatabaseConnector::executeSql(conn,sql),
             error = stop, finally = flog.info('Cohort table created'))
    }

    # insert the at risk cohort:
    flog.info('Inserting risk cohort into cohort table')
    target_cohort_id <- 109
    sql <- SqlRender::loadRenderTranslateSql('t2dm_narrow.sql',
                                             "LearningCurve",
                                             dbms = connectionDetails$dbms,
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             target_database_schema = workDatabaseSchema,
                                             target_cohort_table = studyCohortTable,
                                             target_cohort_id = target_cohort_id)

    DatabaseConnector::executeSql(conn, sql, progressBar = TRUE, reportOverallTime = FALSE)

    # insert all the outcome cohorts
    outcomes <- system.file("settings", "OutcomesOfInterest.csv", package = "LearningCurve")
    outcomes <- read.csv(outcomes)
    nrOutcomes <- nrow(outcomes)
    flog.info(paste0('Inserting ',nrOutcomes,' outcomes into cohort table'))

    for(i in 1:nrOutcomes){
        flog.info(paste0('Inserting ', outcomes$name[i],' (',i,'/',nrOutcomes,')'))
        sql <- SqlRender::loadRenderTranslateSql(paste0(outcomes[i,2],'.sql'),
                                                 "LearningCurve",
                                                 dbms = connectionDetails$dbms,
                                                 oracleTempSchema = oracleTempSchema,
                                                 cdm_database_schema = cdmDatabaseSchema,
                                                 target_database_schema = workDatabaseSchema,
                                                 target_cohort_table = studyCohortTable,
                                                 target_cohort_id = outcomes[i,1])
        DatabaseConnector::executeSql(conn, sql, progressBar = TRUE, reportOverallTime = FALSE)
    }

    # load the covariateSettings
    pathToSettings <- system.file("settings", "covariateSettings.R", package = "LearningCurve")
    source(pathToSettings)

    # get the plpData
    flog.info('Extracting plpData')
    plpData <- PatientLevelPrediction::getPlpData(connectionDetails = connectionDetails,
                                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                                  oracleTempSchema = oracleTempSchema,
                                                  cohortId = target_cohort_id, #need to create this
                                                  outcomeIds = outcomes[,1],
                                                  cohortDatabaseSchema = workDatabaseSchema,
                                                  cohortTable = studyCohortTable,
                                                  outcomeDatabaseSchema = workDatabaseSchema,
                                                  outcomeTable = studyCohortTable,
                                                  cdmVersion = "5",
                                                  washoutPeriod = 365,
                                                  covariateSettings = covSettings)

    # save the plpData
    flog.info('Saving plpData')
    if(!dir.exists(file.path(workFolder,'data'))){dir.create(file.path(workFolder,'data'))}
    PatientLevelPrediction::savePlpData(plpData, file=file.path(workFolder,'data'))
    flog.info('Done.')

    return(TRUE)
}
