# Copyright 2016 Observational Health Data Sciences and Informatics
#
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

