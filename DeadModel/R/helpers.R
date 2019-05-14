# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of Dead Risk Model
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

#==========================
#  Validate death model in plpData with death outcome
#==========================
#' Validate death plp prediction model
#'
#' @details
#' This will run and evaluate an exisitng death plpModel
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseschema  The schema holding the CDM data
#' @param cohortDatabaseschema The schema holding the cohort table
#' @param oracleTempSchema  The temp schema for oracle (default is NULL)
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeId         The cohort definition id of the outcome
#'
#' @return
#' A list with the performance and plots
#'
#' @export
validateDeadModel <- function(connectionDetails,
                                   cdmDatabaseSchema,
                                   cohortDatabaseSchema,
                                   oracleTempSchema = NULL,
                                   cohortTable,
                                   targetId,
                                   outcomeId,
                                   packageName='DeadModel'){

  plpResult <- PatientLevelPrediction::loadPlpResult(system.file('plp_models', package=packageName))
  writeLines('Implementing DEAD model...')
  result <- PatientLevelPrediction::externalValidatePlp(plpResult = plpResult,
                                                        oracleTempSchema = oracleTempSchema,
                                connectionDetails=connectionDetails,
                                validationSchemaCdm=cdmDatabaseSchema,
                                validationSchemaTarget=cohortDatabaseSchema,
                                validationSchemaOutcome = cohortDatabaseSchema,
                                validationTableTarget=cohortTable,
                                validationTableOutcome = cohortTable,
                                validationIdTarget=targetId,
                                validationIdOutcome=outcomeId,
                                keepPrediction=T)
  return(result)
}



#==========================
#  Create death risk covariate
#==========================
#' Create set and get function for a custom covariate corresponding to death risk
#'
#' @details
#' This will create custom covariate functions in your enviroment for creating
#' the risk of being dead
#'
#' @param covariateConstructionName  This is used to create the custom covariate function names
#' @param analysisId                 The analysis id for the custom covariate
#' @param eniviron                   The environment to add the custom covariate functions
#'
#' @return
#' The names of the two functions added to the environment
#'
#' @export
createDeadCovariate <- function(covariateConstructionName = 'DeadRiskCov',
                                   analysisId = 967,
                                   eniviron){

  plpResult <- PatientLevelPrediction::loadPlpResult(system.file('plp_models', package='DeadModel'))

  result <- PatientLevelPrediction::createLrSql(models = plpResult$model,
                                      modelNames = 'DEAD model risk score',
                                      covariateConstructionName = covariateConstructionName,
                                      analysisId = analysisId, e=eniviron )

  names=c(paste0('create',covariateConstructionName,'CovariateSettings'),
  paste0('get',covariateConstructionName,'CovariateSettings'))

  return(names)

}


#==========================
#  Predict risk of death in new population
#==========================

#' Applies death risk model to new cohort
#'
#' @details
#' This will return a predicted risk of being dead at the cohort_start_date for each subject_id in the cohort
#'
#' @param connectionDetails The connection details to connect to a database
#' @param cdmDatabaseSchema  The common data model schema
#' @param cohortDatabaseSchema  The database schema containing the cohort you wish to apply the death risk prediction to
#' @param oracleTempSchema  The temp schema for oracle (default is NULL)
#' @param cohortTable   The table containing the cohort you want to apply the death risk model to
#' @param cohortId   The cohort_definition_id defining the cohort you wish to apply the death risk model to
#'
#' @return
#' A dataframe with each subjectId and cohortStartDate in the cohort with the predicted death risk as the column 'value'
#'
#' @export
applyDeadModel <- function(connectionDetails,
                              cdmDatabaseSchema,
                              cohortDatabaseSchema,
                              oracleTempSchema = NULL,
                              cohortTable,
                              cohortId){

  plpResult <- PatientLevelPrediction::loadPlpResult(system.file('plp_models', package='DeadModel'))

  # get similar plpData
  newData <- PatientLevelPrediction::similarPlpData(plpModel = plpResult,
                                                    newOracleTempSchema = oracleTempSchema,
                                                    createCohorts = F,
                                                    newConnectionDetails = connectionDetails,
                                                    newCdmDatabaseSchema = cdmDatabaseSchema,
                                                    newCohortDatabaseSchema = cohortDatabaseSchema,
                                                    newCohortTable = cohortTable,
                                                    newCohortId = cohortId,
                                                    newOutcomeDatabaseSchema = cohortDatabaseSchema,
                                                    newOutcomeTable = cohortTable,
                                                    newOutcomeId = -999, sample = NULL,
                                                    createPopulation = F
                                                    )
  # apply Model
  result <- PatientLevelPrediction::applyModel(population = newData$cohorts,
                                     plpData = newData,
                                     plpModel = plpResult$model,
                                     calculatePerformance = F)

  return(result$prediction)
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
  result <- PatientLevelPrediction::checkPlpInstallation(connectionDetails=connectionDetails,
                       python=F)
  return(result)
}


flog.warn <- OhdsiRTools::logWarn





#' View DEAD prediction model in shiny app
#'
#' @details
#' This will open a shiny app to explore the DEAD model
#'
#'
#' @return
#' NULL
#'
#' @export
viewDeadShiny <- function(packageName='DeadModel'){

  plpResult <- PatientLevelPrediction::loadPlpResult(system.file('plp_models', package=packageName))
  PatientLevelPrediction::viewPlp(plpResult)

}

#' View DEAD prediction model coefficients
#'
#' @details
#' This will show a table with the covaraite name and coefficient value
#'
#'
#' @return
#' NULL
#'
#' @export
viewDeadCoefficients <- function(packageName='DeadModel'){

  plpResult <- PatientLevelPrediction::loadPlpResult(system.file('plp_models', package=packageName))

  covs <- plpResult$covariateSummary[!is.na(plpResult$covariateSummary$covariateValue),]
  covs <- covs[covs$covariateValue!=0,]
  covs <- covs[order(-abs(covs$covariateValue)),]

  result <- covs[,c('covariateName','covariateValue')]
  View(result)
}
