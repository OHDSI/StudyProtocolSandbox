# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of ShortTermMortalityPrediction
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

#' Execute the Study
#'
#' @details
#' This function executes the ShortTermMortalityPrediction Study.
#' 
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cdmDatabaseName      Shareable name of the database 
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the target population cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param createCohorts        Create the cohortTable table with the target population and outcome cohorts?
#' @param runAnalyses          Run the model development
#' @param createValidationPackage  Create a package for sharing the models 
#' @param packageResults       Should results be packaged for later sharing?     
#' @param minCellCount         The minimum number of subjects contributing to a count before it can be included 
#'                             in packaged results.
#' @param cdmVersion           The version of the common data model                             
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
#'         cdmDatabaseName = 'shareable name of the database'
#'         cohortDatabaseSchema = "study_results",
#'         cohortTable = "cohort",
#'         oracleTempSchema = NULL,
#'         outputFolder = "c:/temp/study_results", 
#'         createCohorts = T,
#'         runAnalyses = T,
#'         createValidationPackage = T,
#'         packageResults = F,
#'         minCellCount = 5,
#'         cdmVersion = 5)
#' }
#'
#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cdmDatabaseName = 'friendly database name',
                    cohortDatabaseSchema = cdmDatabaseSchema,
                    cohortTable = "cohort",
                    oracleTempSchema = cohortDatabaseSchema,
                    outputFolder,
                    createCohorts = TRUE,
                    runAnalyses = T,
                    createValidationPackage = TRUE,
                    packageResults = TRUE,
                    minCellCount= 5,
                    cdmVersion = 5) {
  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)

  if (createCohorts) {
    OhdsiRTools::logInfo("Creating cohorts")
    createCohorts(connectionDetails = connectionDetails,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable,
                  oracleTempSchema = oracleTempSchema,
                  outputFolder = outputFolder)
  }
  
  if(runAnalyses){
  OhdsiRTools::logInfo("Running predictions")
  predictionAnalysisListFile <- system.file("settings",
                                            "predictionAnalysisList.json",
                                            package = "ShortTermMortalityPrediction")
  predictionAnalysisList <- PatientLevelPrediction::loadPredictionAnalysisList(predictionAnalysisListFile)
  predictionAnalysisList$connectionDetails = connectionDetails
  predictionAnalysisList$cdmDatabaseSchema = cdmDatabaseSchema
  predictionAnalysisList$cdmDatabaseName = cdmDatabaseName
  predictionAnalysisList$oracleTempSchema = oracleTempSchema
  predictionAnalysisList$cohortDatabaseSchema = cohortDatabaseSchema
  predictionAnalysisList$cohortTable = cohortTable
  predictionAnalysisList$outcomeDatabaseSchema = cohortDatabaseSchema
  predictionAnalysisList$outcomeTable = cohortTable
  predictionAnalysisList$cdmVersion = cdmVersion
  predictionAnalysisList$outputFolder = outputFolder
  
  result <- do.call(PatientLevelPrediction::runPlpAnalyses, predictionAnalysisList)
  }
  
  if (packageResults) {
    OhdsiRTools::logInfo("Packaging results")
    packageResults(outputFolder = outputFolder,
                   minCellCount = minCellCount)
  }
  
  if(createValidationPackage){
    predictionAnalysisListFile <- system.file("settings",
                "predictionAnalysisList.json",
                package = "ShortTermMortalityPrediction")
    jsonSettings <-  tryCatch({rjson::fromJSON(file=predictionAnalysisListFile)},
                                        error=function(cond) {
                                          stop('Issue with json file...')
                                        })
    jsonSettings$skeletonType <- 'SimpleValidationStudy'
    jsonSettings$packageName <- paste0(jsonSettings$packageName,'Validation')
    
    createValidationPackage(modelFolder = outputFolder, 
                            outputFolder = file.path(outputFolder, jsonSettings$packageName),
                            minCellCount = minCellCount,
                            databaseName = cdmDatabaseName,
                            jsonSettings = jsonSettings )
  }
  
  
  invisible(NULL)
}




