#' @title
#' Execute the novel oral anticoagulant study
#'
#' @details
#' This function executes the novel oral anticoagulant study.
#'
#' @return
#' TODO
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param workDatabaseSchema   Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param studyCohortTable     The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param cdmVersion           Version of the CDM. Can be "4" or "5"
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)
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
#'         workDatabaseSchema = "results",
#'         oracleTempSchema = NULL,
#'         outputFolder = "c:/temp/study_results",
#'         cdmVersion = "5")
#'
#' }
#'
#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    workDatabaseSchema = cdmDatabaseSchema,
                    studyCohortTable = "cohort_noac",
                    studyCohortDefinitionTable = "cohort_definition_noac",
                    oracleTempSchema = NULL,
                    cdmVersion = 5,
                    outputFolder,
                    createCohorts = TRUE,
                    runAnalyses = TRUE,
                    empiricalCalibration = TRUE,
                    packageResultsForSharing = TRUE,
                    createCustomOutput = TRUE,
                    generateReport = TRUE) {
  
  if (cdmVersion == 4) {
    stop("CDM version 4 not supported")
  }
  
  if (!file.exists(outputFolder))
    dir.create(outputFolder)
  
  if (createCohorts) {
    writeLines("Creating exposure and outcome cohorts")
    createCohorts(connectionDetails,
                  cdmDatabaseSchema,
                  workDatabaseSchema,
                  studyCohortTable,
                  studyCohortDefinitionTable,
                  oracleTempSchema,
                  cdmVersion,
                  outputFolder)
  }
  
  if (runAnalyses) {
    writeLines("Running analyses")
    cmAnalysisListFile <- system.file("settings", "cmAnalysisList.txt", package = "NoacStudy")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    drugComparatorOutcomesListFile <- system.file("settings", "drugComparatorOutcomesList.txt", package = "NoacStudy")
    drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
    CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                exposureDatabaseSchema = workDatabaseSchema,
                                exposureTable = studyCohortTable,
                                outcomeDatabaseSchema = workDatabaseSchema,
                                outcomeTable = studyCohortTable,
                                outputFolder = outputFolder,
                                cmAnalysisList = cmAnalysisList,
                                cdmVersion = cdmVersion,
                                drugComparatorOutcomesList = drugComparatorOutcomesList,
                                getDbCohortMethodDataThreads = 1,
                                createPsThreads = 1,
                                psCvThreads = 30,
                                computeCovarBalThreads = 5,
                                trimMatchStratifyThreads = 10,
                                fitOutcomeModelThreads = 5,
                                outcomeCvThreads = 10)
    # TODO: exposure multi-threading parameters
  }
  
  if (empiricalCalibration) {
    writeLines("Performing empirical calibration")
    doEmpiricalCalibration(outputFolder = outputFolder)
  }
  
  if (createCustomOutput) {
    writeLines("Creating custom output")
    createCustomOutput(outputFolder = outputFolder)
  }
  
  if (generateReport) {
    writeLines("Generating report")
    generateReport(outputFolder = outputFolder)
  }

}