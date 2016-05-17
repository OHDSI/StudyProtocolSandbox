#' @title
#' Execute the novel oral anticoagulant study
#'
#' @description
#' This function executes the novel oral anticoagulant study.
#'
#' @return
#' Nothing.  All intermediate files, models and reports are in `outputFolder`.
#'
#' @param connectionDetails              An object of type \code{connectionDetails} as created using
#'                                       the \code{\link[DatabaseConnector]{createConnectionDetails}}
#'                                       function in the DatabaseConnector package.
#' @param cdmDatabaseSchema              Schema name where your patient-level data in OMOP CDM format
#'                                       resides. Note that for SQL Server, this should include both
#'                                       the database and schema name, for example 'cdm_data.dbo'.
#' @param workDatabaseSchema             Schema name where intermediate data can be stored. You will
#'                                       need to have write priviliges in this schema. Note that for
#'                                       SQL Server, this should include both the database and schema
#'                                       name, for example 'cdm_data.dbo'.
#' @param studyCohortTable               The name of the table that will be created in the work
#'                                       database schema. This table will hold the exposure and outcome
#'                                       cohorts used in this study.
#' @param studyCohortDefinitionTable     The table in the work database schema containing the
#'                                       definitions of the cohorts.
#' @param oracleTempSchema               Should be used in Oracle to specify a schema where the user
#'                                       has write priviliges for storing temporary tables.
#' @param cdmVersion                     Version of the CDM. Can be "4" or "5"
#' @param outputFolder                   Name of local folder to place results; make sure to use
#'                                       forward slashes (/)
#'
#' @param targetDrug                     Select which target drugs to run: `Rivaroxaban`, `Dabigatran`
#'                                       or both
#' @param analysisDesign                 Select which analysis designs to run: `main` or `all`
#'
#' @param createCohorts                  Create cohort tables from database (TRUE) or use previously
#'                                       saved cohort information (FALSE)
#' @param runAnalyses                    Run propensity score and outcome model fitting (TRUE) or use
#'                                       previously saved models (FALSE)
#' @param packageResults       Package the results for sharing?
#' @param maxCores             How many parallel cores should be used? If more cores are made available
#'                             this can speed up the analyses.
# #' @param empiricalCalibration           Perform empirical calibration of outcome models (TRUE/FALSE)
# #' @param packageResultsForSharing       Package all intermediate files and models in `outputFolder` to
# #'                                       share (TRUE/FALSE)
# #' @param createCustomOutput             Create custom output in `outputFolder`
# #' @param generateReport                 Generate results report in `outputFolder`
# #'
# #' @param getDbCohortMethodDataThreads   The number of parallel threads to use for building the
# #'                                       cohortMethod data objects.
# #' @param createPsThreads                The number of parallel threads to use for fitting the
# #'                                       propensity models.
# #' @param psCvThreads                    The number of parallel threads to use for the cross-
# #'                                       validation when estimating the hyperparameter for the
# #'                                       propensity model. Note that the total number of CV threads at
# #'                                       one time could be `createPsThreads * psCvThreads`.
# #' @param computeCovarBalThreads         The number of parallel threads to use for computing the
# #'                                       covariate balance.
# #' @param trimMatchStratifyThreads       The number of parallel threads to use for trimming, matching
# #'                                       and stratifying.
# #' @param fitOutcomeModelThreads         The number of parallel threads to use for fitting the outcome
# #'                                       models.
# #' @param outcomeCvThreads               The number of parallel threads to use for the cross-
# #'                                       validation when estimating the hyperparameter for the outcome
# #'                                       model. Note that the total number of CV threads at one time
# #'                                       could be `fitOutcomeModelThreads * outcomeCvThreads`.
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' execute(connectionDetails,
#'         cdmDatabaseSchema = "mdcr_v5",
#'         workDatabaseSchema = "ohdsi",
#'         outputFolder = "~/study_results",
#'	       maxCores = 4)
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
                    drugTarget = c("Rivaroxaban", "Dabigatran"),
                    analysisDesign = "main",
                    createCohorts = TRUE,
                    runAnalyses = TRUE,                   
                    packageResults = TRUE,
                    maxCores = 4) {

  if (cdmVersion == 4) {
    stop("CDM version 4 not supported")
  }

  analysisDesign <- tolower(analysisDesign)
  if (!analysisDesign %in% c("main", "all")) {
    stop("Invalid analysis design specification")
  }

  drugTarget <- tolower(drugTarget)
  if (any(!(drugTarget %in% c("rivaroxaban", "dabigatran")))) {
    stop("Invalid target drug specification")
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
    writeLines("")
  }

  if (runAnalyses) {
    writeLines("Running analyses")

    cmAnalysisListFile <- system.file("settings", "cmAnalysisList.txt", package = "NoacStudy")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    if (analysisDesign == "main") {
        filter <- list()
        matchId <- c(1,7) # TODO Describe which these are
        newListId <- 1
        for (i in 1:length(cmAnalysisList)) {
            if (cmAnalysisList[[i]]$analysisId %in% matchId) {
                filter[[newListId]] <- cmAnalysisList[[i]]
                newListId <- newListId + 1
            }
        }
        cmAnalysisList <- filter
    }

    drugComparatorOutcomesListFile <- system.file("settings",
                                                  "drugComparatorOutcomesList.txt",
                                                  package = "NoacStudy")
    drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
    excludeTargetId <- c()
    if (!("rivaroxaban" %in% drugTarget)) {
        excludeTargetId <- c(excludeTargetId, 1) # Rivaroxaban
    }
    if (!("dabigatran" %in% drugTarget)) {
        excludeTargetId <- c(excludeTargetId, 3) # Dabigatran
    }
    if (length(excludeTargetId) > 0) {
        filter <- list()
        newListId <- 1
        for (i in 1:length(drugComparatorOutcomesList)) {
            if (!(drugComparatorOutcomesList[[i]]$targetId %in% excludeTargetId)) {
                filter[[newListId]] <- drugComparatorOutcomesList[[i]]
                newListId <- newListId + 1
            }
        }
        drugComparatorOutcomesList <- filter
    }

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
                                createStudyPopThreads = max(3, maxCores),
                                createPsThreads = 1,
                                psCvThreads = min(16, maxCores),
                                computeCovarBalThreads = min(3, maxCores),
                                trimMatchStratifyThreads = min(10, maxCores),
                                fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                outcomeCvThreads = min(4, maxCores),
                                refitPsForEveryOutcome = FALSE)
    writeLines("")
  }
  
  if (packageResults) {
    writeLines("Packaging results in export folder for sharing")
    packageResults(connectionDetails = connectionDetails,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   outputFolder = outputFolder)
    writeLines("")  
  }

#   if (empiricalCalibration) {
#     writeLines("Performing empirical calibration")
#     doEmpiricalCalibration(outputFolder = outputFolder)
#   }
# 
#   if (createCustomOutput) {
#     writeLines("Creating custom output")
#     createCustomOutput(outputFolder = outputFolder)
#   }
# 
#   if (generateReport) {
#     writeLines("Generating report")
#     generateReport(outputFolder = outputFolder)
#   }

  invisible(NULL)
}
