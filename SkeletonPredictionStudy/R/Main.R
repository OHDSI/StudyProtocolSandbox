# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonCompartiveEffectStudy
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
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the target population cohorts used in this
#'                             study.
#' @param outcomeDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param outcomeTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param createCohorts        Create the cohortTable table with the target population and outcome cohorts?
#' @param packageResults       Should results be packaged for later sharing?     
#' @param minCellCount         The minimum number of subjects contributing to a count before it can be included 
#'                             in packaged results.
#' @param packageName          The name of the package
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
#'         cohortDatabaseSchema = "study_results",
#'         cohortTable = "cohort",
#'         oracleTempSchema = NULL,
#'         outputFolder = "c:/temp/study_results")
#' }
#'
#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cohortDatabaseSchema = cdmDatabaseSchema,
                    cohortTable = "cohort",
                    outcomeDatabaseSchema = cohortDatabaseSchema,
                    outcomeTable = cohortTable,
                    oracleTempSchema = cohortDatabaseSchema,
                    outputFolder,
                    createCohorts = TRUE,
                    packageResults = TRUE,
                    minCellCount= 5,
                    packageName="SkeletonPredictionStudy") {
  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)

  OhdsiRTools::addDefaultFileLogger(file.path(outputFolder, "log.txt"))

  if (createCohorts) {
    OhdsiRTools::logInfo("Creating cohorts")
    PatientLevelPrediction::createCohort(connectionDetails = connectionDetails,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable,
                  oracleTempSchema = oracleTempSchema,
                  package = packageName)
  }
  
  OhdsiRTools::logInfo("Running predictions")
  predictionAnalysisListFile <- system.file("settings",
                                            "predictionAnalysisList.json",
                                            package = packageName)
  predictionAnalysisList <- loadPredictionAnalysisList(predictionAnalysisListFile)
  
  for(targetOutcomes in predictionAnalysisList$targetOutcomes){
    predictionAnalysisList$getPlpData$cdmDatabaseSchema <- cdmDatabaseSchema
    predictionAnalysisList$getPlpData$connectionDetails <- connectionDetails
    predictionAnalysisList$getPlpData$cohortDatabaseSchema <- cohortDatabaseSchema
    predictionAnalysisList$getPlpData$cohortDatabaseSchema <- cohortDatabaseSchema
    predictionAnalysisList$getPlpData$outcomeDatabaseSchema <- outcomeDatabaseSchema
    predictionAnalysisList$getPlpData$outcomeTable <- outcomeTable
    predictionAnalysisList$getPlpData$cohortId <- targetOutcomes$targetId
    predictionAnalysisList$getPlpData$outcomeIds <- targetOutcomes$outcomeIds
    predictionAnalysisList$getPlpData$covariateSettings <- predictionAnalysisList$covariateSettings
    plpData <- do.call(PatientLevelPrediction::getPlpData, predictionAnalysisList$getPlpData)
    
    for(outcomeId in predictionAnalysisList$getPlpData$outcomeIds){
      predictionAnalysisList$createStudyPop$plpData <- plpData
      predictionAnalysisList$createStudyPop$outcomeId <- as.double(as.character(outcomeId))
      population <- do.call(PatientLevelPrediction::createStudyPopulation, predictionAnalysisList$createStudyPop)
      
      # Run the model ---- how to name files in directory? - set analysisId using names
      predictionAnalysisList$runPlp$plpData <- plpData
      predictionAnalysisList$runPlp$population <- population
      for(modelSettings in predictionAnalysisList$modelSettings){
        predictionAnalysisList$runPlp$modelSettings <- modelSettings
        predictionAnalysisList$runPlp$saveDirectory  <- outputFolder
        population <- do.call(PatientLevelPrediction::runPlp, predictionAnalysisList$runPlp)
      }
    }
  }
  
  if (packageResults) {
    OhdsiRTools::logInfo("Packaging results")
    packageResults(mainFolder = outputFolder,
                   N = minCellCount)
  }
  
  
  invisible(NULL)
}




loadPredictionAnalysisList <- function(predictionAnalysisListFile){
  # load the json file and parse into prediction list
  json <- tryCatch({rjson::fromJSON(file=predictionAnalysisListFile)},
                   error=function(cond) {
                     stop('Issue with json file...')
                   })
  
  modelSettings <- list()
  length(modelSettings) <-  length(json$patientLevelPredictionAnalysisSettings$runPLPArgs$modelSettings[[1]])
  for(i in 1:length(json$patientLevelPredictionAnalysisSettings$runPLPArgs$modelSettings[[1]])){
    name <- names(json$patientLevelPredictionAnalysisSettings$runPLPArgs$modelSettings[[1]])[i]
    
    modelSettings[[i]] <- do.call(get(paste0('set',gsub('Settings','',name)), envir = environment(PatientLevelPrediction::accuracy)), 
            json$patientLevelPredictionAnalysisSettings$runPLPArgs$modelSettings[[1]][[i]]
            )
    
  }
  
  covariateSettings <- do.call(FeatureExtraction::createCovariateSettings, json$patientLevelPredictionAnalysisSettings$getDbPLPDataArgs$covariateSettings)
  
  predictionAnalysisList <- list(targetOutcomes = json$patientLevelPredictionAnalysisSettings$targetOutcomes,
                                 getPlpData = json$patientLevelPredictionAnalysisSettings$getDbPLPDataArgs,
                                 createStudyPop = json$patientLevelPredictionAnalysisSettings$createStudyPopArgs,
                                 runPlp = json$patientLevelPredictionAnalysisSettings$runPLPArgs, 
                                 modelSettings = modelSettings,
                                 covariateSettings = covariateSettings)
  
}



#' Get the cohorts from atlas inserted into the package
#'
#' @details
#' This function inserts the cohorts specified in the prediction analysis list
#' into the study package.
#' 
#' @param baseUrl       The connection to the atlas webAPI e.g., http://api.ohdsi.org:80/WebAPI
#' @param packageDirectory   (Default is working directory) The directory of the of the package containing the predictionAnalysisList.json when predictionAnalysisListFile is missing
#' @param predictionAnalysisListFile   (optional) The json extracted from atlas.  If not
#'                                      entered then it searches in inst/settings for predictionAnalysisList.json
#'                                      
#' @examples
#' \dontrun{
#' library(SkeletonPredictionStudy)
#' createStudyFiles(baseUrl='http://api.ohdsi.org:80/WebAPI')
#' }
#'
#' @export
createStudyFiles <-function(baseUrl, packageDirectory, predictionAnalysisListFile){
  if(missing(packageDirectory)){packageDirectory <- getwd()}
  if(missing(predictionAnalysisListFile)){
    predictionAnalysisListFile <- file.path(packageDirectory,
                                            'inst/settings/predictionAnalysisList.json')
  }
  json <- tryCatch({rjson::fromJSON(file=predictionAnalysisListFile)},
                   error=function(cond) {
                     stop('Issue with json file...')
                   })
  
  
  getCohortInfo <- function(x){
    return(c(cohortName=x$name, cohortId =x$id, drescription= x$description))
  }
  
  cohortTable <- do.call(rbind, lapply(json$cohortDefinitions, getCohortInfo))
  cohortTable <- as.data.frame(cohortTable)
  if(!dir.exists(file.path(packageDirectory,'inst/extdata'))){
    dir.create(file.path(packageDirectory,'inst/extdata'), recursive = T)
  }
  write.csv(cohortTable, file = file.path(packageDirectory,
                                          'inst/extdata/cohort_details.csv'),
            row.names = F) #save to package 
  for(j in 1:nrow(cohortTable)){
    # now extract and json and sql from atlas 
    OhdsiRTools::insertCohortDefinitionInPackage(definitionId = cohortTable$cohortId[j], 
                                                 name = cohortTable$cohortName[j], 
                                                 baseUrl = baseUrl)
  }
}


packageResults <- function(mainFolder, 
         includePlots = T,
         includeThresholdSummary =T,
         includeDemographicSummary = T,
         includeCalibrationSummary = T,
         includePredictionDistribution =T,
         includeCovariateSummary = T,
         removeLessThanN = T,
         N = 5
) {
  if(missing(mainFolder)){
    stop('Missing mainFolder...')
  }
  
  # for each analysis copy the requested files...
  folders <- list.dirs(path = mainFolder, recursive = F, full.names = F)
  
  #create export subfolder in workFolder
  exportFolder <- file.path(mainFolder, "export")

  for(folder in folders){
  #copy all plots across
    if (!file.exists(file.path(exportFolder,folder))){
      dir.create(file.path(exportFolder,folder), recursive = T)
    }

  if(includePlots){ file.copy(file.path(mainFolder,folder, 'plots'), 
            file.path(exportFolder,folder), recursive=TRUE)}
 
  # depends on devel or eval...
  plpResult <- PatientLevelPrediction::loadPlpResult(file.path(mainFolder,folder, 'plpResult'))
  
  if(removeLessThanN){
    PatientLevelPrediction::transportPlp(plpResult,outputFolder=file.path(exportFolder,folder, 'plpResult'), 
                 n=N,includeEvaluationStatistics=T,
                 includeThresholdSummary=includeThresholdSummary, 
                 includeDemographicSummary=includeDemographicSummary,
                 includeCalibrationSummary =includeCalibrationSummary, 
                 includePredictionDistribution=includePredictionDistribution,
                 includeCovariateSummary=includeCovariateSummary)
  } else {
    PatientLevelPrediction::transportPlp(plpResult,outputFolder=file.path(exportFolder,folder, 'plpResult'), 
                 n=NULL,includeEvaluationStatistics=T,
                 includeThresholdSummary=includeThresholdSummary, 
                 includeDemographicSummary=includeDemographicSummary,
                 includeCalibrationSummary =includeCalibrationSummary, 
                 includePredictionDistribution=includePredictionDistribution,
                 includeCovariateSummary=includeCovariateSummary)
  }
  }
  
  
  ### Add all to zip file ###
  zipName <- paste0(mainFolder, '.zip')
  OhdsiSharing::compressFolder(exportFolder, zipName)
  # delete temp folder
  unlink(exportFolder, recursive = T)
  
  writeLines(paste("\nStudy results are compressed and ready for sharing at:", zipName))
  return(zipName)
}