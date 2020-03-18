# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonPredictionStudy
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
#' This function executes the SkeletonPredictionStudy Study.
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
#' @param sampleSize           How many patients to sample from the target population                             
#' @param riskWindowStart      The start of the risk window (in days) relative to the startAnchor.                           
#' @param startAnchor          The anchor point for the start of the risk window. Can be "cohort start" or "cohort end".
#' @param riskWindowEnd        The end of the risk window (in days) relative to the endAnchor parameter
#' @param endAnchor            The anchor point for the end of the risk window. Can be "cohort start" or "cohort end".
#' @param firstExposureOnly    Should only the first exposure per subject be included? Note that this is typically done in the createStudyPopulation function,
#' @param removeSubjectsWithPriorOutcome Remove subjects that have the outcome prior to the risk window start?
#' @param priorOutcomeLookback How many days should we look back when identifying prior outcomes?
#' @param requireTimeAtRisk    Should subject without time at risk be removed?
#' @param minTimeAtRisk        The minimum number of days at risk required to be included
#' @param includeAllOutcomes   (binary) indicating whether to include people with outcomes who are not observed for the whole at risk period
#' @param standardCovariates   Use this to add standard covariates such as age/gender
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param createCohorts        Create the cohortTable table with the target population and outcome cohorts?
#' @param runAnalyses          Run the model development
#' @param packageResults       Should results be packaged for later sharing?     
#' @param minCellCount         The minimum number of subjects contributing to a count before it can be included 
#'                             in packaged results.
#' @param verbosity            Sets the level of the verbosity. If the log level is at or higher in priority than the logger threshold, a message will print. The levels are:
#'                                         \itemize{
#'                                         \item{DEBUG}{Highest verbosity showing all debug statements}
#'                                         \item{TRACE}{Showing information about start and end of steps}
#'                                         \item{INFO}{Show informative information (Default)}
#'                                         \item{WARN}{Show warning messages}
#'                                         \item{ERROR}{Show error messages}
#'                                         \item{FATAL}{Be silent except for fatal errors}
#'                                         }                              
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
#'         outcomeId = 1,
#'         oracleTempSchema = NULL,
#'         riskWindowStart = 1,
#'         startAnchor = 'cohort start',
#'         riskWindowEnd = 365,
#'         endAnchor = 'cohort start',
#'         standardCovariates = FeatureExtraction::createCovariateSettings(useDemographicsAgeGroup = T, useDemographicsGender = T),
#'         customCovariates = 'customAtlasCovariates',
#'         outputFolder = "c:/temp/study_results", 
#'         createCohorts = T,
#'         runAnalyses = T,
#'         packageResults = F,
#'         minCellCount = 10,
#'         verbosity = "INFO",
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
                    sampleSize = NULL,
                    riskWindowStart = 1,
                    startAnchor = 'cohort start',
                    riskWindowEnd = 365,
                    endAnchor = 'cohort start',
                    firstExposureOnly = F,
                    removeSubjectsWithPriorOutcome = F,
                    priorOutcomeLookback = 99999,
                    requireTimeAtRisk = F,
                    minTimeAtRisk = 1,
                    includeAllOutcomes = T,
                    standardCovariates,
                    outputFolder,
                    createCohorts = F,
                    runAnalyses = F,
                    packageResults = F,
					          minCellCount = 10,
                    verbosity = "INFO",
                    cdmVersion = 5) {
  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)
  
  OhdsiRTools::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
  
  if (createCohorts) {
    OhdsiRTools::logInfo("Creating cohorts")
    createCohorts(connectionDetails = connectionDetails,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable,
                  oracleTempSchema = oracleTempSchema,
                  outputFolder = outputFolder,
                  cohortVariableSetting = customCovariates) 
  }
  
  if(runAnalyses){
    
    #getData
    plpData <- getData(connectionDetails = connectionDetails,
                          cdmDatabaseSchema = cdmDatabaseSchema,
                          cdmDatabaseName = cdmDatabaseName,
                          cohortDatabaseSchema = cohortDatabaseSchema,
                          cohortTable = cohortTable,
                          oracleTempSchema = oracleTempSchema,
                          standardCovariates = standardCovariates,
                          firstExposureOnly = firstExposureOnly,
                          sampleSize = sampleSize,
                          cdmVersion = cdmVersion)
    
    #create pop
    population <- PatientLevelPrediction::createStudyPopulation(plpData = plpData, 
                                                                outcomeId = 2,
                                                                riskWindowStart = riskWindowStart,
                                                                startAnchor = startAnchor,
                                                                riskWindowEnd = riskWindowEnd,
                                                                endAnchor = endAnchor,
                                                                firstExposureOnly = firstExposureOnly,
                                                                removeSubjectsWithPriorOutcome = removeSubjectsWithPriorOutcome,
                                                                priorOutcomeLookback = priorOutcomeLookback,
                                                                requireTimeAtRisk = requireTimeAtRisk,
                                                                minTimeAtRisk = minTimeAtRisk,
                                                                includeAllOutcomes = includeAllOutcomes)
    

    # apply the model:
    plpModel <- list(model = getModel(),
                     analysisId = 'ExistingModel',
                     hyperParamSearch = NULL,
                     index = NULL,
                     trainCVAuc = NULL,
                     modelSettings = list(model = 'score', modelParameters = NULL),
                     metaData = NULL,
                     populationSettings = NULL,
                     trainingTime = NULL,
                     varImp = NULL,
                     dense = T,
                     cohortId = 1,
                     outcomeId = 2,
                     covariateMap = NULL,
                     predict = predictExisting
    )
    class(plpModel) <- 'plpModel'
    result <- PatientLevelPrediction::applyModel(population = population,
                                                 plpData = plpData,
                                                 plpModel = plpModel)
    
    result$inputSetting$database <- databaseName
    result$executionSummary  <- list()
    result$model <- plpModel
    result$analysisRef <- list()
    result$covariateSummary <- PatientLevelPrediction:::covariateSummary(plpData = plpData, population = population)
    
    if(!dir.exists(file.path(outputFolder,cdmDatabaseName))){
      dir.create(file.path(outputFolder,cdmDatabaseName))
    }
    saveRDS(result, file.path(outputFolder,cdmDatabaseName,'validationResults.rds'))
    
  }
  
  # [TODO] add create shiny app
  
  
  if (packageResults) {
    OhdsiRTools::logInfo("Packaging results")
    packageResults(outputFolder = outputFolder,
                   minCellCount = minCellCount)
  }
   
  invisible(NULL)
}




