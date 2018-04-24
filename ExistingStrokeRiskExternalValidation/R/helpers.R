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
#' @param outcomeId         The cohort definition id of the outcome
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
                          outcomeId){

  connection <- DatabaseConnector::connect(connectionDetails)

  #checking whether cohort table exists and creating if not..
  # create the cohort table if it doesnt exist
  existTab <- toupper(cohortTable)%in%toupper(DatabaseConnector::getTableNames(connection, cohortDatabaseschema))
  if(!existTab){
    sql <- SqlRender::loadRenderTranslateSql("createTable.sql",
                                             packageName = "ExistingStrokeRiskExternalValidation",
                                             dbms = attr(connection, "dbms"),
                                             target_database_schema = cohortDatabaseschema,
                                             target_cohort_table = cohortTable)
    DatabaseConnector::executeSql(connection, sql)
  }

  writeLines(paste0('Creating target cohort with id ', targetId))
  sql <- SqlRender::loadRenderTranslateSql('targetCohort.sql',
                                    packageName = 'ExistingStrokeRiskExternalValidation',
                                    dbms =  attr(connection, "dbms"),
                                    vocabulary_database_schema = cdmDatabaseschema,
                                    cdm_database_schema=cdmDatabaseschema,
                                    target_database_schema=cohortDatabaseschema,
                                    target_cohort_table=cohortTable,
                                    target_cohort_id=targetId)
  DatabaseConnector::executeSql(connection, sql)

  writeLines(paste0('Creating outcome cohort with id ', outcomeId))
  sql <- SqlRender::loadRenderTranslateSql('outcomeCohort.sql',
                                           packageName = 'ExistingStrokeRiskExternalValidation',
                                           dbms =  attr(connection, "dbms"),
                                           vocabulary_database_schema = cdmDatabaseschema,
                                           cdm_database_schema=cdmDatabaseschema,
                                           target_database_schema=cohortDatabaseschema,
                                           target_cohort_table=cohortTable,
                                           target_cohort_id=outcomeId)
  DatabaseConnector::executeSql(connection, sql)

  writeLines(paste0('Exracting cohort counts...'))
  sql <- "select cohort_definition_id, count(*) N from @cohortDatabaseschema.@cohortTable
  where cohort_definition_id in (@targetId, @outcomeId) group by cohort_definition_id"

  sql <- SqlRender::renderSql(sql, cohortDatabaseschema=cohortDatabaseschema,
                       cohortTable=cohortTable, targetId=targetId,outcomeId=outcomeId)$sql
  sql <- SqlRender::translateSql(sql,targetDialect =  attr(connection, "dbms"))$sql
  result <- DatabaseConnector::querySql(connection, sql)

  result <- merge(data.frame(COHORT_DEFINITION_ID=c(targetId,outcomeId),
             NAMES = c('Females newly diagnosed with atrial fibrilation aged 35-95',
                       'Stroke')), result)
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

  covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = T,
                                                                  useDemographicsAge = T,
                                                                  useDemographicsAgeGroup = T,
                                                                  useConditionEraAnyTimePrior = T,
                                                                  useConditionGroupEraAnyTimePrior = T,
                                                                  useDrugEraAnyTimePrior = T,
                                                                  useDrugGroupEraAnyTimePrior = T)

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

  table1 <- PatientLevelPrediction::getPlpTable(plpData, population, connectionDetails,
                                    cohortTable=tempCohortTable)

  return(table1)
}

#' Applies the five existing stroke prediction models
#'
#' @details
#' This will run and evaluate five existing stroke risk prediction models
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
applyExistingstrokeModels <- function(connectionDetails,
                                      cdmDatabaseSchema,
                                      cohortDatabaseSchema,
                                      cohortTable,
                                      targetId,
                                      outcomeId){

  writeLines('Implementing Astria stroke risk model...')
  astria <- PredictionComparison::atriaStrokeModel(connectionDetails, cdmDatabaseSchema,
                                       cohortDatabaseSchema = cohortDatabaseSchema,
                                       outcomeDatabaseSchema = cohortDatabaseSchema,
                                       cohortTable = cohortTable,
                                       outcomeTable = cohortTable,
                                       cohortId = targetId, outcomeId = outcomeId,
                                       removePriorOutcome=T)

  writeLines('Implementing Qstroke stroke risk model...')
  qstroke <- PredictionComparison::qstrokeModel(connectionDetails, cdmDatabaseSchema,
                                                 cohortDatabaseSchema = cohortDatabaseSchema,
                                                 outcomeDatabaseSchema = cohortDatabaseSchema,
                                                 cohortTable = cohortTable,
                                                 outcomeTable = cohortTable,
                                                 cohortId = targetId, outcomeId = outcomeId,
                                                 removePriorOutcome=T)

  writeLines('Implementing Framington stroke risk model...')
  framington <- PredictionComparison::framinghamModel(connectionDetails, cdmDatabaseSchema,
                                              cohortDatabaseSchema = cohortDatabaseSchema,
                                              outcomeDatabaseSchema = cohortDatabaseSchema,
                                              cohortTable = cohortTable,
                                              outcomeTable = cohortTable,
                                              cohortId = targetId, outcomeId = outcomeId,
                                              removePriorOutcome=T)

  writeLines('Implementing chads2 stroke risk model...')
  chads2 <- PredictionComparison::chads2Model(connectionDetails, cdmDatabaseSchema,
                                              cohortDatabaseSchema = cohortDatabaseSchema,
                                              outcomeDatabaseSchema = cohortDatabaseSchema,
                                              cohortTable = cohortTable,
                                              outcomeTable = cohortTable,
                                              cohortId = targetId, outcomeId = outcomeId,
                                              removePriorOutcome=T)

  writeLines('Implementing chads2vas stroke risk model...')
  chads2vas <- PredictionComparison::chads2vasModel(connectionDetails, cdmDatabaseSchema,
                                              cohortDatabaseSchema = cohortDatabaseSchema,
                                              outcomeDatabaseSchema = cohortDatabaseSchema,
                                              cohortTable = cohortTable,
                                              outcomeTable = cohortTable,
                                              cohortId = targetId, outcomeId = outcomeId,
                                              removePriorOutcome=T)

# format the results... [TODO...]
  results <- list(astria=astria,
                  qstroke=qstroke,
                  framington=framington,
                  chads2=chads2,
                  chads2vas=chads2vas)

 return(results)
}


#' Package the results for sharing with OHDSI researchers
#'
#' @details
#' This function packages the results.
#'
#' @param results           The result of running applyExistingstrokeModels()
#' @param table1            The result of running getTable1()
#' @param saveFolder        Name of the folder where results are saved to
#' @param dbName            Name of the databased used to validate the models
#' @param modelComp         whether to include comparisons between the model performances
#'
#' @export
packageResults <- function(results, table1=NULL, saveFolder,dbName, modelComp=T) {
  if(missing(results)){
    stop('Need to enter results')
  }
  if(missing(saveFolder)){
    stop('Need to enter saveFolder')
  }
  if(missing(dbName)){
    stop('Need to enter dbName')
  }

  #create export subfolder in workFolder
  exportFolder <- file.path(saveFolder, "export")
  if (!file.exists(exportFolder))
    dir.create(exportFolder, recursive = T)

  ### Add all to zip file ###
  zipName <- file.path(exportFolder, paste0(dbName,"-StudyResults.zip"))

  # remove inputSettings and prediction from results
  for(i in 1:length(results)){
    result <- results[[i]]
    namei <- names(results)[i]
    saveRDS(result, file.path(saveFolder,namei))

    PatientLevelPrediction::plotSparseRoc(result$performanceEvaluation,
                                    file.path(exportFolder,paste0(namei,'_plots',
                                                                  'sparseROC.pdf')),
                                    type = 'validation')
    PatientLevelPrediction::plotSparseCalibration(result$performanceEvaluation,
                                                   file.path(exportFolder,paste0(namei,'_plots',
                                                                                 'sparseCalibration.pdf')),
                                                   type = 'validation')
    PatientLevelPrediction::plotSparseCalibration2(result$performanceEvaluation,
                                          file.path(exportFolder,paste0(namei,'_plots',
                                                                        'sparseCalibrationConventional.pdf')),
                                          type = 'validation')
    write.csv(result$performanceEvaluation$evaluationStatistics,
              file.path(exportFolder,paste0(namei,'_performance.csv')), row.names=F)

  }

  if(modelComp==T){
    idi <- PredictionComparison::multipleIDI(results)
    write.csv(idi, file.path(exportFolder,'idi.csv'))
    write.csv(names(results), file.path(exportFolder,'idi_names.csv'))
  }

  if(!is.null(table1))
    write.csv(table1,file.path(exportFolder,'table1.csv'))


  OhdsiSharing::compressFolder(exportFolder, zipName)
  writeLines(paste("\nStudy results are ready for sharing at:", zipName))
}



#' Submit the study results to the study coordinating center
#'
#' @details
#' This will upload the file \code{StudyResults.zip} to the study coordinating center using Amazon S3.
#' This requires an active internet connection.
#'
#' @param exportFolder   The path to the folder containing the \code{StudyResults.zip} file.
#' @param dbName         Database name used in the zipName
#' @param key            The key string as provided by the study coordinator
#' @param secret         The secret string as provided by the study coordinator
#'
#' @return
#' TRUE if the upload was successful.
#'
#' @export
submitResults <- function(exportFolder,dbName, key, secret) {
  zipName <- file.path(exportFolder, paste0(dbName,"-StudyResults.zip"))
  if (!file.exists(zipName)) {
    stop(paste("Cannot find file", zipName))
  }
  writeLines(paste0("Uploading file '", zipName, "' to study coordinating center"))
  result <- OhdsiSharing::putS3File(file = zipName,
                                    bucket = "ohdsi-study-plp",
                                    key = key,
                                    secret = secret,
                                    region = "us-east-1")
  if (result) {
    writeLines("Upload complete")
  } else {
    writeLines("Upload failed. Please contact the study coordinator")
  }
  invisible(result)
}
