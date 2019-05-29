# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonValidationStudy
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

#' Create the exposure and outcome cohorts
#'
#' @details
#' This function will create the exposure and outcome cohorts following the definitions included in
#' this package.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)
#'
#' @export
createCohorts <- function(connectionDetails,
                          cdmDatabaseSchema,
                          cohortDatabaseSchema,
                          cohortTable = "cohort",
                          oracleTempSchema,
                          outputFolder) {
  if (!file.exists(outputFolder))
    dir.create(outputFolder)

  conn <- DatabaseConnector::connect(connectionDetails)

  .createCohorts(connection = conn,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 cohortDatabaseSchema = cohortDatabaseSchema,
                 cohortTable = cohortTable,
                 oracleTempSchema = oracleTempSchema,
                 outputFolder = outputFolder)

  # Check number of subjects per cohort:
  writeLines("Counting cohorts")
  sql <- SqlRender::loadRenderTranslateSql("GetCounts.sql",
                                           "ExistingStrokeRiskExternalValidation",
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           work_database_schema = cohortDatabaseSchema,
                                           study_cohort_table = cohortTable)
  counts <- DatabaseConnector::querySql(conn, sql)
  colnames(counts) <- SqlRender::snakeCaseToCamelCase(colnames(counts))
  counts <- addCohortNames(counts)
  write.csv(counts, file.path(outputFolder, "CohortCounts.csv"), row.names = FALSE)

  DatabaseConnector::disconnect(conn)
}

addCohortNames <- function(data, IdColumnName = "cohortDefinitionId", nameColumnName = "cohortName") {
  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ExistingStrokeRiskExternalValidation")
  cohortsToCreate <- read.csv(pathToCsv)

  idToName <- data.frame(cohortId = c(cohortsToCreate$cohortId),
                         cohortName = c(as.character(cohortsToCreate$name)))
  idToName <- idToName[order(idToName$cohortId), ]
  idToName <- idToName[!duplicated(idToName$cohortId), ]
  names(idToName)[1] <- IdColumnName
  names(idToName)[2] <- nameColumnName
  data <- merge(data, idToName, all.x = TRUE)
  # Change order of columns:
  idCol <- which(colnames(data) == IdColumnName)
  if (idCol < ncol(data) - 1) {
    data <- data[, c(1:idCol, ncol(data) , (idCol+1):(ncol(data)-1))]
  }
  return(data)
}

.createCohorts <- function(connection,
                           cdmDatabaseSchema,
                           vocabularyDatabaseSchema = cdmDatabaseSchema,
                           cohortDatabaseSchema,
                           cohortTable,
                           oracleTempSchema,
                           outputFolder) {

  # Create study cohort table structure:
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "CreateCohortTable.sql",
                                           packageName = "ExistingStrokeRiskExternalValidation",
                                           dbms = attr(connection, "dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable)
  DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)



  # Instantiate cohorts:
  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ExistingStrokeRiskExternalValidation")
  cohortsToCreate <- read.csv(pathToCsv)
  for (i in 1:nrow(cohortsToCreate)) {
    writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = paste0(cohortsToCreate$name[i], ".sql"),
                                             packageName = "ExistingStrokeRiskExternalValidation",
                                             dbms = attr(connection, "dbms"),
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             vocabulary_database_schema = vocabularyDatabaseSchema,

                                             target_database_schema = cohortDatabaseSchema,
                                             target_cohort_table = cohortTable,
                                             target_cohort_id = cohortsToCreate$cohortId[i])
    DatabaseConnector::executeSql(connection, sql)
  }
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
                      cdmDatabaseSchema,
                      cohortDatabaseSchema,
                      cohortTable,
                      targetId,
                      outcomeId,
                      tempCohortTable='#temp_cohort'){

  covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = T)

  plpData <- PatientLevelPrediction::getPlpData(connectionDetails,
                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                cohortId = targetId, outcomeIds = outcomeId,
                                                cohortDatabaseSchema = cohortDatabaseSchema,
                                                outcomeDatabaseSchema = cohortDatabaseSchema,
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


#' Package the results for sharing with OHDSI researchers
#'
#' @details
#' This function packages the results.
#'
#' @param outputFolder        Name of folder containing the study analysis results
#' @param dbName              A shareable name for the database used in this study
#' @param minCellCount        The minimum number of subjects contributing to a count before it can be included in the results.
#'
#' @export
packageResults <- function(outputFolder, dbName,
                           minCellCount = 5) {
  if(missing(outputFolder)){
    stop('Missing outputFolder...')
  }

  #create export subfolder in workFolder
  exportFolder <- file.path(outputFolder, dbName)
  dir.create(exportFolder, recursive = T)

  # move the summary
  if(file.exists(file.path(outputFolder,'resultSummary.csv'))){
    summary <- read.csv(file.path(outputFolder,'resultSummary.csv'))
    write.csv(summary, file.path(exportFolder,'resultSummary.csv'))
  }

  # for each analysis copy the requested files...
  folders <- list.dirs(path = outputFolder, recursive = F, full.names = F)
  folders <- folders[grep('Analysis_', folders)]

  for(folder in folders){
    #copy all plots across
    if (!file.exists(file.path(exportFolder,folder))){
      dir.create(file.path(exportFolder,folder), recursive = T)
    }

    # loads analysis results
    if(dir.exists(file.path(outputFolder,folder, 'plpResult'))){
      plpResult <- PatientLevelPrediction::loadPlpResult(file.path(outputFolder,folder, 'plpResult'))

      if(minCellCount!=0){
        PatientLevelPrediction::transportPlp(plpResult,
                                             outputFolder=file.path(exportFolder,folder, 'plpResult'),
                                             n=minCellCount,
                                             includeEvaluationStatistics=T,
                                             includeThresholdSummary=T,
                                             includeDemographicSummary=T,
                                             includeCalibrationSummary =T,
                                             includePredictionDistribution=T,
                                             includeCovariateSummary=T)
      } else {
        PatientLevelPrediction::transportPlp(plpResult,outputFolder=file.path(exportFolder,folder, 'plpResult'),
                                             n=NULL,
                                             includeEvaluationStatistics=T,
                                             includeThresholdSummary=T,
                                             includeDemographicSummary=T,
                                             includeCalibrationSummary =T,
                                             includePredictionDistribution=T,
                                             includeCovariateSummary=T)
      }
    }
  }


  ### Add all to zip file ###
  zipName <- paste0(exportFolder, '.zip')
  OhdsiSharing::compressFolder(exportFolder, zipName)
  # delete temp folder
  unlink(exportFolder, recursive = T)

  writeLines(paste("\nStudy results are compressed and ready for sharing at:", zipName))
  return(zipName)
}

#' Submit the study results to the study coordinating center
#'
#' @details
#' This will upload the file \code{StudyResults.zip} to the study coordinating center using Amazon S3.
#' This requires an active internet connection.
#'
#' @param exportFolder   The path to the folder containing the \code{export.zip} file.
#' @param key            The key string as provided by the study coordinator
#' @param secret         The secret string as provided by the study coordinator
#'
#' @return
#' TRUE if the upload was successful.
#'
#' @export
submitResults <- function(exportFolder,dbName, key, secret) {
  if (!file.exists(exportFolder)) {
    stop(paste("Cannot find zipped folder", exportFolder))
  }
  PatientLevelPrediction::submitResults(exportFolder = exportFolder,
                                        key =  key, secret = secret)

}


#' View the coefficients of the models in this study and the concept ids used to define them
#'
#'
#' @details
#' This will print the models and return a data.frame with the models
#'
#'
#' @return
#' A data.frame of the models
#'
#' @export
viewModels <- function(){
  conceptSets <- system.file("extdata", "existingStrokeModels_concepts.csv", package = "PredictionComparison")
  conceptSets <- read.csv(conceptSets)

  existingBleedModels <- system.file("extdata", "existingStrokeModels_modelTable.csv", package = "PredictionComparison")
  existingBleedModels <- read.csv(existingBleedModels)

  modelNames <- system.file("extdata", "existingStrokeModels_models.csv", package = "PredictionComparison")
  modelNames <- read.csv(modelNames)


  models <- merge(modelNames,merge(existingBleedModels[,c('modelId','modelCovariateId','Name','Time','coefficientValue')],
                                   conceptSets[,c('modelCovariateId','ConceptId','AnalysisId')]))
  models <- models[,c('name','Name','Time','coefficientValue','ConceptId','AnalysisId')]
  colnames(models)[1:2] <- c('Model','Covariate')
  models[,1] <- as.character(models[,1])
  models[,2] <- as.character(models[,2])
  models <- rbind(models, c('Chads2','FeatureExtraction covariate','',0,0,0))
  models <- rbind(models, c('Chads2Vas','FeatureExtraction covariate','',0,0,0))

  View(models)
  return(models)
}
