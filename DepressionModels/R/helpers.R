# @file helpers.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of externalValidation
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

#' extractData
#'
#' @description
#' Extracts the plpData required for plpModel being validated using the same settings as the model
#' @details
#' The function runs various sql scripts to create the target population and outcome populations and then
#' extracts the data from the database and creates the data objects required to run the model and evaluate it
#' @param connectionDetails            An R object of type\cr\code{connectionDetails} created using the
#'                                     function \code{createConnectionDetails} in the
#'                                     \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema            The name of the database schema that contains the OMOP CDM
#'                                     instance.  Requires read permissions to this database. On SQL
#'                                     Server, this should specifiy both the database and the schema,
#'                                     so for example 'cdm_instance.dbo'.
#' @param targetDatabaseSchema         The name of the database schema that is the location where the
#'                                     cohort data used to define the at risk cohort will be written.
#'                                     Requires read/write permissions to this database.
#' @param targetCohortTable            The tablename that will contain the at risk cohort and outcome.
#'                                     The table has format of COHORT table: cohort_concept_id, SUBJECT_ID,
#'                                     COHORT_START_DATE, COHORT_END_DATE.
#' @param targetCohortId               A unique identifier to define the at risk cohort.
#' @param outcomeCohortIds             Cohort_definition_ids used to define the outcomes.
#' @return
#' A list containing the plpData and population
#' @export
extractData <- function(connectionDetails,
                        cdmDatabaseSchema, targetDatabaseSchema,
                        targetCohortTable = 'extValCohort',
                        targetCohortId=1, outcomeCohortIds = 2:22,
                        outputDir= file.path(getwd(),'depressionModels')
                        ) {
  # run the target and outcome sql files in the package to create the population tables

  if(length(outcomeCohortIds)!=21)
    stop('OutocmeCohortId vector much contain 21 ids')

  if(!dir.exists(outputDir))
    dir.create(outputDir)


  conn <- DatabaseConnector::connect(connectionDetails)

  # create the cohort table if it doesnt exist
  existTab <- targetCohortTable%in%DatabaseConnector::getTableNames(conn, targetDatabaseSchema)
    if(!existTab){
    sql <- SqlRender::loadRenderTranslateSql("createTable.sql",
                                             packageName = "DepressionModels",
                                             dbms = attr(conn, "dbms"),
                                             cdm_database_schema = cdmDatabaseSchema,
                                             target_database_schema = targetDatabaseSchema,
                                             target_cohort_table = targetCohortTable,
                                             target_cohort_id=targetCohortId)
    DatabaseConnector::executeSql(conn, sql)
  }


  # TTD
  writeLines(paste0("Creating target population"))
  sql <- SqlRender::loadRenderTranslateSql("PTD.sql",
                                           packageName = "DepressionModels",
                                           dbms = attr(conn, "dbms"),
                                           cdm_database_schema = cdmDatabaseSchema,
                                           target_database_schema = targetDatabaseSchema,
                                           target_cohort_table = targetCohortTable,
                                           target_cohort_id=targetCohortId)
  DatabaseConnector::executeSql(conn, sql)

  # load the outcomes:
  outcomes <- system.file("settings", "outcomes.csv", package = "DepressionModels")
  outcomes <- read.csv(outcomes)

  for(i in 1:length(outcomes)){
    writeLines(paste0("Creating cohort for ", outcomes[i]))
    sql <- SqlRender::loadRenderTranslateSql(paste0(outcomes[i],".sql"),
                                             packageName = "DepressionModels",
                                             dbms = attr(conn, "dbms"),
                                             cdm_database_schema = cdmDatabaseSchema,
                                             target_database_schema = targetDatabaseSchema,
                                             target_cohort_table = targetCohortTable,
                                             target_cohort_id=outcomeCohortId[i])
    DatabaseConnector::executeSql(conn, sql)
  }

  # extract data based on plpModel info
  model <- PatientLevelPrediction::loadPlpModel(file.path(system.file('models',package="DepressionModels"), 'OPTUM Stroke'))
  modelDetails <- as.list(model$metaData$call)
  modelDetails[[1]] <- NULL
  modelDetails$cohortId <- targetCohortId
  modelDetails$outcomeIds <- outcomeCohortIds
  modelDetails$connectionDetails <- connectionDetails
  modelDetails$cdmDatabaseSchema <- cdmDatabaseSchema
  modelDetails$cohortDatabaseSchema <- targetDatabaseSchema
  modelDetails$cohortTable <- targetCohortTable
  modelDetails$outcomeDatabaseSchema <- targetDatabaseSchema
  modelDetails$outcomeTable <- targetCohortTable
  #cdmVersion - currently just support 5?

  plpData <- do.call(PatientLevelPrediction::getPlpData, modelDetails)

  # save the outcome cohort details:
  write.csv(data.frame(cohortId=c(targetCohortId, outcomeCohortIds), names=c('PTD', outcomes)),
            file.path(outputDir, 'cohortIds.csv'), row.names = F)


  # return plpData
  return(plpData)
}


#' applyModels
#'
#' @description
#' This function applied the models contained in the package to the new data and evaluates the models
#' @details
#' The function runs applyPlp() from the patientLevelPrediction package on various models to validate the models
#' on the new data
#' @param plpData                          An object of type \code{plpData} - the patient level prediction
#'                                         data extracted from the CDM.
#' @param population                       The population created using createStudyPopulation() who will be used to develop the model
#' @param outputDir                        The path to the directory where the results will be saved
#' @return
#' Nothing is returned but the validation will be saved within the outputDir
#' @export
applyModel <- function(plpData, outcomeCohortId, outputDir){

  # get all models in the model location folder:
  outcomeList <- read.csv(file.path(outputDir, 'cohortIds.csv'), row.names = F)

  if(sum(outcomeList$cohortId==outcomeCohortId)==0)
    stop('outcomeCohortId invalid')
  oid <- outcomeList$names[outcomeList$cohortId==outcomeCohortId]


  for(database in c('CCAE','MDCD','MDCR','OPTUM')){
    modelLoc <- system.file("models", paste0(database,'_', oid), package = "DepressionModels")
    model <- PatientLevelPrediction::loadPlpModel(modelLoc)

    # create population based on plpModel info
    popDetails <- as.list(model$populationSettings)
    popDetails$cohortId <- plpData$metaData$targetCohortId
    popDetails$outcomeId <- outcomeCohortId
    popDetails$plpData <- plpData
    population <- do.call(PatientLevelPrediction::createStudyPopulation, popDetails)


    # perform the external validation
    result <- PatientLevelPrediction::applyModel(population,plpData,plpModel=model)
    result$performance$developDatabase <- model$metaData$call$cdmDatabaseSchema
    result$performance$validationDatabase <- plpData$metaData$call$cdmDatabaseSchema

    # get the key details
    sumRes <- unlist(result$performance$evaluationStatistics)

    # get id:
    id <- strsplit(modelLocs[i], '/')[[1]][length(strsplit(modelLocs[i], '/')[[1]])]

    sumRes <- c(developDatabase=id,
                validationDatabase=plpData$metaData$call$cdmDatabaseSchema,
                sumRes)

    # save the results
    if(!dir.exists(outputDir))
      dir.create(outputDir)
    saveRDS(result$performance, file.path(outputDir, paste0('model', database,'_',outcomeCohortId,'.rds')))
    write.table(t(sumRes), file.path(outputDir, 'summary.txt'),
                append=file.exists(file.path(outputDir, 'summary.txt')),
                col.names = !file.exists(file.path(outputDir, 'summary.txt')))
  }

}
