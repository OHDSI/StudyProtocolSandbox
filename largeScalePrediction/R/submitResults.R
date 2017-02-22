# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of Large-Scale Patient-Level Prediction Study
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

#' Package the results for sharing with OHDSI researchers
#'
#' @details
#' This function packages the results.
#'
#' @param workFolder        Name of local folder to place results
#' @param dbName            Database name used in the zipName
#' @param N                 The minimum count size for summary data to be exported for data sensitivity
#' @param localFolder       Name of the folder where sensitive data gets moved
#'
#' @export
packageResults <- function(workFolder, dbName, N=NULL, localFolder=NULL) {

    #create export subfolder in workFolder
    exportFolder <- file.path(workFolder, "export")
    if (!file.exists(exportFolder))
        dir.create(exportFolder)

    ### Add all to zip file ###
    zipName <- file.path(exportFolder, paste0(dbName,"-StudyResults.zip"))
    resultsFolder <- paste0(workFolder,"/models");
    if (file.exists(file.path(workFolder, 'summary.csv'))) {
        file.copy(file.path(workFolder, 'summary.csv'), resultsFolder)
    }

    #remove the connection details
    removeSensitive(workFolder, N=N, localFolder=localFolder )

    OhdsiSharing::compressFolder(resultsFolder, zipName)
    writeLines(paste("\nStudy results are ready for sharing at:", zipName))
}


#' Remove any sensitive details before submitting results
#'
#' @details
#' This function removes any passwords/usernames in the connectionDetails
#'
#' @param workFolder        Name of results folder
#' @param N                 The minimum count size for summary data to be exported
#' @param localFolder       Name of the folder where senitive data gets moved
#'
#' @export
removeSensitive <- function(workFolder, N=NULL, localFolder=NULL) {

    if(is.null(localFolder))
        localFolder <- file.path(workFolder,'sensitive_excludes')
    if(!dir.exists(localFolder))
        dir.create(localFolder)

    writeLines('removing the connection sensitive details from plpData...')
    plpMetaData <- readRDS(file.path(workFolder, 'data','metaData.rds'))
    plpMetaData$call$connectionDetails <- NULL
    saveRDS(plpMetaData, file=file.path(workFolder, 'data','metaData.rds'))

    writeLines('removing the model sensitive details from plpModel...')
    plpModels <- dir(file.path(workFolder, 'models'))
    for(mod in plpModels){
        models <- dir(file.path(workFolder, 'models', mod))
        for(model in models){
            fileName <- model
            if(file.exists(file.path(workFolder, 'models', mod, fileName,'model/metaData.rds'))){
                plpMetaData <- readRDS(file.path(workFolder, 'models', mod, fileName,'model/metaData.rds'))
                plpMetaData$call$connectionDetails <- NULL
                saveRDS(plpMetaData, file=file.path(workFolder, 'models', mod, fileName,'model/metaData.rds'))
            }

            # remove the predictions and add to a localFolder..
            if(file.exists(file.path(workFolder, 'models', mod,fileName,'prediction.rds'))){
                if(localFolder==workFolder)
                    warning('The sensitive files are being moved into the workFolder
                            loction, edit localFolder to a new location')
                writeLines(paste0('Moving prediction.rds to ', localFolder))
                if(!dir.exists(file.path(localFolder, 'models_sensitive', mod,fileName)))
                    dir.create(file.path(localFolder, 'models_sensitive', mod,fileName), recursive = T)
                file.copy(file.path(workFolder, 'models', mod,fileName,'prediction.rds'),
                          file.path(localFolder,'models_sensitive', mod,fileName,'prediction.rds' ),
                          copy.date=T)
                file.remove(file.path(workFolder, 'models', mod,fileName,'prediction.rds'))
            }

            if(!is.null(N)){

                # remove less than N counts from demographicSummary
                if(file.exists(file.path(workFolder, 'models', mod,fileName,'performanceEvaluation.rds '))){
                    writeLines(paste0('Moving demographicSummary entried less than ',N,' to ', localFolder))
                    perfEval <- readRDS(file.path(workFolder, 'models', mod,fileName,'performanceEvaluation.rds'))
                    removed <-  perfEval$demographicSummary[perfEval$demographicSummary$PersonCountAtRisk< N,]
                    if(!dir.exists(file.path(localFolder, 'models_sensitive', mod,fileName)))
                        dir.create(file.path(localFolder, 'models_sensitive', mod,fileName), recursive = T)
                    saveRDS(removed, file=file.path(localFolder, 'models_sensitive', mod,fileName,'demographics_removed.rds'))
                    perfEval$demographicSummary <- perfEval$demographicSummary[perfEval$demographicSummary$PersonCountAtRisk>=N,]
                    saveRDS(perfEval, file=file.path(workFolder, 'models', mod,fileName,'performanceEvaluation.rds'))
                }

                # remove less than N counts from demographicSummary
                if(file.exists(file.path(workFolder, 'models', mod,fileName,'covariateSummary.rds '))){
                    writeLines(paste0('Moving covariateSummary entried less than ',N,' to ', localFolder))
                    covSum <- readRDS(file.path(workFolder, 'models', mod,fileName,'covariateSummary.rds'))
                    removed <-  covSum[covSum$CovariateCount< N,]
                    if(!dir.exists(file.path(localFolder, 'models_sensitive', mod,fileName)))
                        dir.create(file.path(localFolder, 'models_sensitive', mod,fileName), recursive = T)
                    saveRDS(removed, file=file.path(localFolder, 'models_sensitive', mod,fileName,'covariateSummary_removed.rds'))
                    covSum$CovariateCount[is.na(covSum$CovariateCount)] <- -1
                    covSum[covSum$CovariateCount < N,-(1:5)] <- NA
                    saveRDS(covSum, file=file.path(workFolder, 'models', mod,fileName,'covariateSummary.rds'))
                }

            }

        }
    }
}

