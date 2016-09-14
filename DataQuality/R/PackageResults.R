# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of KeppraAngioedema
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

#' Package the results for sharing with OHDSI researchers
#'
#' @details
#' This function packages the results.
#'
#' @param connectionDetails   An object of type \code{connectionDetails} as created using the
#'                            \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                            DatabaseConnector package.
#' @param cdmDatabaseSchema   Schema name where your patient-level data in OMOP CDM format resides.
#'                            Note that for SQL Server, this should include both the database and
#'                            schema name, for example 'cdm_data.dbo'.
#' @param workFolder        Name of local folder to place results; make sure to use forward slashes subfolder export will be created there
#'                            (/)
#'
#' @export
packageResults <- function(connectionDetails, cdmDatabaseSchema, workFolder, dbName=cdmDatabaseSchema) {
  
  #create export subfolder in workFolder
    exportFolder <- file.path(workFolder, "export")
    if (!file.exists(exportFolder)) 
      dir.create(exportFolder)

    #actual components to be extracted
    
    #optionaly may be included
    #createMetaData(connectionDetails, cdmDatabaseSchema, exportFolder)

    
    ### Add all to zip file ###
    zipName <- file.path(exportFolder, paste0(dbName,"-StudyResults.zip"))
    OhdsiSharing::compressFolder(exportFolder, zipName)
    writeLines(paste("\nStudy results are ready for sharing at:", zipName))
}




#' Create metadata file
#'
#' @details
#' Creates a file containing metadata about the source data (taken from the cdm_source table) and R
#' package versions.
#'
#' @param connectionDetails   An object of type \code{connectionDetails} as created using the
#'                            \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                            DatabaseConnector package.
#' @param cdmDatabaseSchema   Schema name where your patient-level data in OMOP CDM format resides.
#'                            Note that for SQL Server, this should include both the database and
#'                            schema name, for example 'cdm_data.dbo'.
#' @param exportFolder        The name of the folder where the metadata file should be created.
#'
#' @export
createMetaData <- function(connectionDetails, cdmDatabaseSchema, exportFolder) {
    conn <- DatabaseConnector::connect(connectionDetails)
    sql <- "SELECT * FROM @cdm_database_schema.cdm_source"
    sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    cdmSource <- DatabaseConnector::querySql(conn, sql)
    RJDBC::dbDisconnect(conn)
    lines <- paste(names(cdmSource), cdmSource[1, ], sep = ": ")
    lines <- c(lines, paste("OhdsiRTools version", packageVersion("OhdsiRTools"), sep = ": "))
    lines <- c(lines, paste("SqlRender version", packageVersion("SqlRender"), sep = ": "))
    lines <- c(lines,
               paste("DatabaseConnector version", packageVersion("DatabaseConnector"), sep = ": "))
    lines <- c(lines, paste("Cyclops version", packageVersion("Cyclops"), sep = ": "))
    lines <- c(lines,
               paste("FeatureExtraction version", packageVersion("FeatureExtraction"), sep = ": "))
    lines <- c(lines, paste("CohortMethod version", packageVersion("CohortMethod"), sep = ": "))
    lines <- c(lines, paste("OhdsiSharing version", packageVersion("OhdsiSharing"), sep = ": "))
    lines <- c(lines,
               paste("KeppraAngioedema version", packageVersion("KeppraAngioedema"), sep = ": "))
    write(lines, file.path(exportFolder, "MetaData.txt"))
    invisible(NULL)
}

