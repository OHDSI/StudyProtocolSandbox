# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of EndometriosisRiskModels study
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
#' @param cdmDatabaseSchema  The schema holding the CDM data
#' @param cohortDatabaseSchema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param targetIds          The cohort definition ids of the target populations
#' @param outcomeIds         The cohort definition ids of the outcomes
#'
#' @return
#' A summary of the cohort counts
#'
#' @export
createCohorts <- function(connectionDetails,
                          cdmDatabaseSchema,
                          cohortDatabaseSchema,
                          cohortTable,
                          targetIds=1:2,
                          outcomeIds=3:4){

  packageName= 'EndometriosisRiskModels'

  cohortDetails <- NULL
  if(missing(outcomeIds)){
    stop('Need outcomeIds')
  }

  if(missing(targetIds)){
      stop('Need targetIds')
  }

  if(length(targetIds)!=2){
    stop('Need two targetIds')
  }
  if(length(outcomeIds)!=2){
    stop('Need two outcomeIds')
  }

  if(sum(targetIds%in%outcomeIds)!=0){
    stop('outcomeId in targetId')
  }

  cohortDetails <- data.frame(cohortName=c("Women presenting in ER with abdominal pain for the first time after 1yr of observation",
                                           "Women presenting in any visit with abdominal pain for the first time after 1yr of observation",
                                           "Incident laparoscopy-confirmed endometriosis",
                                           "Incident laparoscopy-confirmed endometriosis with more strict definition"),
                              cohortId = c(targetIds, outcomeIds))

  connection <- DatabaseConnector::connect(connectionDetails)

  #checking whether cohort table exists and creating if not..
  # create the cohort table if it doesnt exist
  existTab <- toupper(cohortTable)%in%toupper(DatabaseConnector::getTableNames(connection, cohortDatabaseSchema))
  if(!existTab){
    sql <- SqlRender::loadRenderTranslateSql("createTable.sql",
                                             packageName = packageName,
                                             dbms = attr(connection, "dbms"),
                                             target_database_schema = cohortDatabaseSchema,
                                             target_cohort_table = cohortTable)
    DatabaseConnector::executeSql(connection, sql)
  }

  result <- PatientLevelPrediction::createCohort(cohortDetails = cohortDetails,
                                                 connectionDetails = connectionDetails,
                                                 cdmDatabaseSchema = cdmDatabaseSchema,
                                                 cohortDatabaseSchema = cohortDatabaseSchema,
                                                 cohortTable = cohortTable,
                                                 package = packageName)

  print(result)

  return(result)
}


#==========================
#  Implementing the 16 plp models exported into inst/extdata
#==========================

#' Applies the exisitng plp prediction models
#'
#' @details
#' This will run and evaluate an exisitng plpModels
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseSchema  The schema holding the CDM data
#' @param cohortDatabaseSchema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeId         The cohort definition id of the outcome
#' @param packageName       The name of the package
#' @param modelLocation     The model location in the package
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
                                   packageName='EndometriosisRiskModels',
                                   modelLocation = 'ccae_T6814_O6815'){

  plpResult <- loadPlpResult(system.file(file.path('plp_models/existingModel', modelLocation),
                                      package=packageName))
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


#' Train a endometriosis model using your data
#'
#' @details
#' This will create a new model using the same settings
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseSchema  The schema holding the CDM data
#' @param cohortDatabaseSchema The schema holding the cohort table
#' @param cohortTable         The name of the cohort table
#' @param cohortId          The cohort definition id of the target population
#' @param outcomeDatabaseSchema The schema holding the outcome table
#' @param outcomeTable         The name of the outcome table
#' @param outcomeId         The cohort definition id of the outcome
#' @param sampleSize        The sample of the target population to use
#' @param cdmVersion        The version of the cdm
#' @return
#' A list containing plpData and a plpResult object containing the model, prediction, evaluation summary and input settings
#'
#' @export
developEndometriosisModel <- function(connectionDetails,
                                      cdmDatabaseSchema,
                                      cohortDatabaseSchema,
                                      cohortTable,
                                      cohortId,
                                      outcomeDatabaseSchema,
                                      outcomeTable,
                                      outcomeId,
                                      sampleSize = 500000,
                                      cdmVersion = 5
                                      ){

  # Define which types of covariates must be constructed ----
  covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = TRUE,
                                                                  useDemographicsAge = FALSE,
                                                                  useDemographicsAgeGroup = TRUE,
                                                                  useDemographicsRace = FALSE,
                                                                  useDemographicsEthnicity = FALSE,
                                                                  useDemographicsIndexYear = FALSE,
                                                                  useDemographicsIndexMonth = FALSE,
                                                                  useDemographicsPriorObservationTime = FALSE,
                                                                  useDemographicsPostObservationTime = FALSE,
                                                                  useDemographicsTimeInCohort = FALSE,
                                                                  useDemographicsIndexYearMonth = FALSE,
                                                                  useConditionOccurrenceAnyTimePrior = FALSE,
                                                                  useConditionOccurrenceLongTerm = FALSE,
                                                                  useConditionOccurrenceMediumTerm = FALSE,
                                                                  useConditionOccurrenceShortTerm = TRUE,
                                                                  useConditionOccurrenceInpatientAnyTimePrior = FALSE,
                                                                  useConditionOccurrenceInpatientLongTerm = FALSE,
                                                                  useConditionOccurrenceInpatientMediumTerm = FALSE,
                                                                  useConditionOccurrenceInpatientShortTerm = FALSE,
                                                                  useConditionEraAnyTimePrior = TRUE,
                                                                  useConditionEraLongTerm = FALSE,
                                                                  useConditionEraMediumTerm = FALSE,
                                                                  useConditionEraShortTerm = FALSE,
                                                                  useConditionEraOverlapping = FALSE,
                                                                  useConditionEraStartLongTerm = FALSE,
                                                                  useConditionEraStartMediumTerm = FALSE,
                                                                  useConditionEraStartShortTerm = FALSE,
                                                                  useConditionGroupEraAnyTimePrior = FALSE,
                                                                  useConditionGroupEraLongTerm = FALSE,
                                                                  useConditionGroupEraMediumTerm = FALSE,
                                                                  useConditionGroupEraShortTerm = FALSE,
                                                                  useConditionGroupEraOverlapping = FALSE,
                                                                  useConditionGroupEraStartLongTerm = FALSE,
                                                                  useConditionGroupEraStartMediumTerm = FALSE,
                                                                  useConditionGroupEraStartShortTerm = FALSE,
                                                                  useDrugExposureAnyTimePrior = FALSE,
                                                                  useDrugExposureLongTerm = FALSE,
                                                                  useDrugExposureMediumTerm = FALSE,
                                                                  useDrugExposureShortTerm = TRUE,
                                                                  useDrugEraAnyTimePrior = TRUE,
                                                                  useDrugEraLongTerm = FALSE,
                                                                  useDrugEraMediumTerm = FALSE,
                                                                  useDrugEraShortTerm = FALSE,
                                                                  useDrugEraOverlapping = FALSE,
                                                                  useDrugEraStartLongTerm = FALSE,
                                                                  useDrugEraStartMediumTerm = FALSE,
                                                                  useDrugEraStartShortTerm = FALSE,
                                                                  useDrugGroupEraAnyTimePrior = FALSE,
                                                                  useDrugGroupEraLongTerm = FALSE,
                                                                  useDrugGroupEraMediumTerm = FALSE,
                                                                  useDrugGroupEraShortTerm = FALSE,
                                                                  useDrugGroupEraOverlapping = FALSE,
                                                                  useDrugGroupEraStartLongTerm = FALSE,
                                                                  useDrugGroupEraStartMediumTerm = FALSE,
                                                                  useDrugGroupEraStartShortTerm = FALSE,
                                                                  useProcedureOccurrenceAnyTimePrior = FALSE,
                                                                  useProcedureOccurrenceLongTerm = FALSE,
                                                                  useProcedureOccurrenceMediumTerm = FALSE,
                                                                  useProcedureOccurrenceShortTerm = TRUE,
                                                                  useDeviceExposureAnyTimePrior = FALSE,
                                                                  useDeviceExposureLongTerm = FALSE,
                                                                  useDeviceExposureMediumTerm = FALSE,
                                                                  useDeviceExposureShortTerm = FALSE,
                                                                  useMeasurementAnyTimePrior = FALSE,
                                                                  useMeasurementLongTerm = FALSE,
                                                                  useMeasurementMediumTerm = FALSE,
                                                                  useMeasurementShortTerm = TRUE,
                                                                  useMeasurementValueAnyTimePrior = FALSE,
                                                                  useMeasurementValueLongTerm = FALSE,
                                                                  useMeasurementValueMediumTerm = FALSE,
                                                                  useMeasurementValueShortTerm = FALSE,
                                                                  useMeasurementRangeGroupAnyTimePrior = FALSE,
                                                                  useMeasurementRangeGroupLongTerm = FALSE,
                                                                  useMeasurementRangeGroupMediumTerm = FALSE,
                                                                  useMeasurementRangeGroupShortTerm = FALSE,
                                                                  useObservationAnyTimePrior = FALSE,
                                                                  useObservationLongTerm = FALSE,
                                                                  useObservationMediumTerm = FALSE,
                                                                  useObservationShortTerm = FALSE,
                                                                  useCharlsonIndex = TRUE,
                                                                  useDcsi = FALSE,
                                                                  useChads2 = FALSE,
                                                                  useChads2Vasc = FALSE,
                                                                  useDistinctConditionCountLongTerm = FALSE,
                                                                  useDistinctConditionCountMediumTerm = FALSE,
                                                                  useDistinctConditionCountShortTerm = FALSE,
                                                                  useDistinctIngredientCountLongTerm = FALSE,
                                                                  useDistinctIngredientCountMediumTerm = FALSE,
                                                                  useDistinctIngredientCountShortTerm = FALSE,
                                                                  useDistinctProcedureCountLongTerm = FALSE,
                                                                  useDistinctProcedureCountMediumTerm = FALSE,
                                                                  useDistinctProcedureCountShortTerm = FALSE,
                                                                  useDistinctMeasurementCountLongTerm = FALSE,
                                                                  useDistinctMeasurementCountMediumTerm = FALSE,
                                                                  useDistinctMeasurementCountShortTerm = FALSE,
                                                                  useVisitCountLongTerm = T,
                                                                  useVisitCountMediumTerm = FALSE,
                                                                  useVisitCountShortTerm = T,
                                                                  longTermStartDays = -365,
                                                                  mediumTermStartDays = -180,
                                                                  shortTermStartDays = -30,
                                                                  endDays = 0,
                                                                  includedCovariateIds = c())
  plpData <- PatientLevelPrediction::getPlpData(connectionDetails = connectionDetails,
                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                cohortId = cohortId,
                                                outcomeIds = outcomeId,
                                                studyStartDate = "",
                                                studyEndDate = "",
                                                cohortDatabaseSchema = cohortDatabaseSchema,
                                                cohortTable = cohortTable,
                                                outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                outcomeTable = outcomeTable,
                                                cdmVersion = cdmVersion,
                                                firstExposureOnly = TRUE,
                                                washoutPeriod = 365,
                                                sampleSize = sampleSize,
                                                covariateSettings = covariateSettings)

   # Create study population ----
    population <- PatientLevelPrediction::createStudyPopulation(plpData = plpData,
                                                                outcomeId = outcomeId,
                                                                binary = TRUE,
                                                                includeAllOutcomes = TRUE,
                                                                firstExposureOnly = TRUE,
                                                                washoutPeriod = 365,
                                                                removeSubjectsWithPriorOutcome = TRUE,
                                                                priorOutcomeLookback = 99999,
                                                                requireTimeAtRisk = T, # edited this
                                                                minTimeAtRisk = 365*3, # edited this
                                                                riskWindowStart = 1,
                                                                addExposureDaysToStart = FALSE,
                                                                riskWindowEnd = 99999,
                                                                addExposureDaysToEnd = FALSE)

    # Create the model settings ----
    modelSettings <- PatientLevelPrediction::setLassoLogisticRegression()

    # Run the model ----
    results <- PatientLevelPrediction::runPlp(population = population,
                                              plpData = plpData,
                                              modelSettings = modelSettings,
                                              testSplit = 'person',
                                              testFraction = 0.25,
                                              nfold = 3)

    return(list(plpData = plpData,
                plpResult = results))
}
