# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of Existing Stroke Risk External Valiation study
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


#' Create and summarise the target and outcome cohorts
#'
#' @details
#' This will create the risk prediciton cohorts and then count the table sizes
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseschema  The schema holding the CDM data
#' @param cohortDatabaseschema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeIds         The cohort definition ids of the outcomes
#'
#' @return
#' A summary of the cohort counts
#'
#' @export
createCohorts <- function(connectionDetails,
                          cdmDatabaseschema,
                          cohortDatabaseschema,
                          cohortTable,
                          targetId,
                          outcomeIds){

  packageName= 'Your package name ...'

  cohortDetails <- NULL
  if(!missing(outcomeIds)){
    if(missing(cohortId)){
      stop('Need cohortId if outcomeIds is entered')
    }

    cohortDetails <- data.frame(cohortName=c('targetCohort',
                                       'outcomeCohort'),
                          cohortId = c(targetId, outcomeIds))

    }

  connection <- DatabaseConnector::connect(connectionDetails)

  #checking whether cohort table exists and creating if not..
  # create the cohort table if it doesnt exist
  existTab <- toupper(cohortTable)%in%toupper(DatabaseConnector::getTableNames(connection, cohortDatabaseschema))
  if(!existTab){
    sql <- SqlRender::loadRenderTranslateSql("createTable.sql",
                                             packageName = packageName,
                                             dbms = attr(connection, "dbms"),
                                             target_database_schema = cohortDatabaseschema,
                                             target_cohort_table = cohortTable)
    DatabaseConnector::executeSql(connection, sql)
  }

  if(is.null(cohortDetails)){
  result <- PatientLevelPrediction::createCohort(connectionDetails = connectionDetails,
                                       cdmDatabaseSchema = cdmDatabaseschema,
                                       cohortDatabaseSchema = cohortDatabaseschema,
                                       cohortTable = cohortTable,
                                       package = packageName)
  } else {
    result <- PatientLevelPrediction::createCohort(cohortDetails = cohortDetails,
                                                   connectionDetails = connectionDetails,
                                                   cdmDatabaseSchema = cdmDatabaseschema,
                                                   cohortDatabaseSchema = cohortDatabaseschema,
                                                   cohortTable = cohortTable,
                                                   package = packageName)
  }

  print(result)

  return(result)
}

#' Creates the target population and outcome summary characteristics
#'
#' @details
#' This will create the patient characteristic table
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseschema  The schema holding the CDM data
#' @param cohortDatabaseschema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeId         The cohort definition id of the outcome
#' @param tempCohortTable   The name of the temporary table used to hold the cohort
#'
#' @return
#' A dataframe with the characteristics
#'
#' @export
getTable1 <- function(connectionDetails,
                      cdmDatabaseschema,
                      cohortDatabaseschema,
                      cohortTable,
                      targetId,
                      outcomeId,
                      tempCohortTable='#temp_cohort'){

  covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = T)

  plpData <- PatientLevelPrediction::getPlpData(connectionDetails,
                                     cdmDatabaseSchema = cdmDatabaseschema,
                                     cohortId = targetId, outcomeIds = outcomeId,
                                     cohortDatabaseSchema = cohortDatabaseschema,
                                     outcomeDatabaseSchema = cohortDatabaseschema,
                                     cohortTable = cohortTable,
                                     outcomeTable = cohortTable,
                                     covariateSettings=covariateSettings)

  population <- PatientLevelPrediction::createStudyPopulation(plpData = plpData,
                                                              outcomeId = outcomeId,
                                                              binary = T,
                                                              includeAllOutcomes = T,
                                                              requireTimeAtRisk = T,
                                                              minTimeAtRisk = 364,
                                                              riskWindowStart = 1,
                                                              riskWindowEnd = 365,
                                                              removeSubjectsWithPriorOutcome = T)

  table1 <- PatientLevelPrediction::getPlpTable(cdmDatabaseSchema = cdmDatabaseSchema,
                                                longTermStartDays = -9999,
                                                population=population,
                                                connectionDetails=connectionDetails,
                                                cohortTable=tempCohortTable)

  return(table1)
}

#==========================
#  Example of implementing an exisitng model in the PredictionComparison repository
#==========================

#' Applies an xisting stroke prediction model
#'
#' @details
#' This will run and evaluate  the atria stroke risk prediction model
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseschema  The schema holding the CDM data
#' @param cohortDatabaseschema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeId         The cohort definition id of the outcome
#'
#' @return
#' A list with the performance and plots
#'
#' @export
applyExistingAtriastrokeModel <- function(connectionDetails,
                                      cdmDatabaseSchema,
                                      cohortDatabaseSchema,
                                      cohortTable,
                                      targetId,
                                      outcomeId){

  writeLines('Implementing Atria stroke risk model...')
  astria <- PredictionComparison::atriaStrokeModel(connectionDetails, cdmDatabaseSchema,
                                       cohortDatabaseSchema = cohortDatabaseSchema,
                                       outcomeDatabaseSchema = cohortDatabaseSchema,
                                       cohortTable = cohortTable,
                                       outcomeTable = cohortTable,
                                       cohortId = targetId, outcomeId = outcomeId,
                                       removePriorOutcome=T)

 return(atria)
}

#==========================
#  Example of implementing a plp model exported into inst/extdata
#==========================

#' Applies an exisitng plp prediction model
#'
#' @details
#' This will run and evaluate an exisitng plpModel
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseschema  The schema holding the CDM data
#' @param cohortDatabaseschema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeId         The cohort definition id of the outcome
#'
#' @return
#' A list with the performance and plots
#'
#' @export
applyDevelopedPlpModel <- function(connectionDetails,
                                   cdmDatabaseSchema,
                                   cohortDatabaseSchema,
                                   cohortTable,
                                   targetId,
                                   outcomeId,
                                   packageName){

  plpResult <- loadPlpResult(sys.file('plp_models/existingModel', package=packageName))
  writeLines('Implementing Developed plpModel...')
  result <- externalValidatePlp(plpResult = plpResult,
                                connectionDetails=connectionDetails,
                                validationSchemaCdm=cdmDatabaseSchema,
                                validationSchemaTarget=cohortDatabaseSchema,
                                validationSchemaOutcome = cohortDatabaseSchema,
                                validationTableTarget=cohortTable,
                                validationTableOutcome = cohortTable,
                                validationIdTarget=targetId,
                                validationIdOutcome=outcomeId,
                                keepPrediction=F)

  return(result)
}

#' Checks the plp package is installed sufficiently for the network study and does other checks if needed
#'
#' @details
#' This will check that the network study dependancies work
#'
#' @param connectioDetails The connections details for connecting to the CDM
#'
#' @return
#' A number (a value other than 1 means an issue with the install)
#'
#' @export

checkInstall <- function(connectionDetails=NULL){
  result <- checkPlpInstallation(connectionDetails=connectionDetails,
                       python=F)
  return(result)
}
