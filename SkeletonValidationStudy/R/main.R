
#' Execute the validation study
#'
#' @details
#' This function will execute the sepcified parts of the study
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param databaseName         A string representing a shareable name of your databasd
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)
#' @param createCohorts        Whether to create the cohorts for the study
#' @param runValidation        Whether to run the valdiation models
#' @param packageResults       Whether to package the results (after removing sensitive details)
#' @param minCellCount         The min count for the result to be included in the package results
#' @param sampleSize           Whether to sample from the target cohort - if desired add the number to sample
#' @export
execute <- function(connectionDetails,
                    databaseName,
                    cdmDatabaseSchema,
                    cohortDatabaseSchema,
                    oracleTempSchema,
                    cohortTable,
                    outputFolder,
                    createCohorts = T,
                    runValidation = T,
                    packageResults = T,
                    minCellCount = 5,
                    sampleSize = NULL){

  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)

  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))

  if(createCohorts){
    ParallelLogger::logInfo("Creating Cohorts")
    createCohorts(connectionDetails,
                  cdmDatabaseSchema=cdmDatabaseSchema,
                  cohortDatabaseSchema=cohortDatabaseSchema,
                  cohortTable=cohortTable,
                  outputFolder = outputFolder)
  }

  if(runValidation){
    ParallelLogger::logInfo("Validating Models")
    # for each model externally validate
    analysesLocation <- system.file("plp_models",
                                    package = "SkeletonValidationStudy")
    val <- PatientLevelPrediction::evaluateMultiplePlp(analysesLocation = analysesLocation,
                                                       outputLocation = outputFolder,
                                                       connectionDetails = connectionDetails,
                                                       validationSchemaTarget = cohortDatabaseSchema,
                                                       validationSchemaOutcome = cohortDatabaseSchema,
                                                       validationSchemaCdm = cdmDatabaseSchema,
                                                       oracleTempSchema = oracleTempSchema,
                                                       databaseNames = databaseName,
                                                       validationTableTarget = cohortTable,
                                                       validationTableOutcome = cohortTable,
                                                       sampleSize = sampleSize)
  }

  # package the results: this creates a compressed file with sensitive details removed - ready to be reviewed and then
  # submitted to the network study manager

  # results saved to outputFolder/databaseName
  if (packageResults) {
    ParallelLogger::logInfo("Packaging results")
    packageResults(outputFolder = file.path(outputFolder,databaseName),
                   minCellCount = minCellCount)
  }


  invisible(NULL)

}
