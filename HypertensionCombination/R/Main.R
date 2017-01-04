#' @export
execute<-function(connectionDetails,
                  cdmDatabaseSchema,
                  resultsDatabaseSchema = cdmDatabaseSchema,
                  exposureTable = "exposureTable",
                  outcomeTable = "outcomeTable",
                  oracleTempSchema = resultsDatabaseSchema,
                  cdmVersion = 5,
                  outputFolder = "output",
                  createCohorts = TRUE,
                  runAnalyses = TRUE,
                  packageResults = FALSE,
                  maxCores = 4){
  
  if (cdmVersion == 4) {
    stop("CDM version 4 not supported")
  }
  
  if (!file.exists(outputFolder))
    dir.create(outputFolder)
  
  cmOutputFolder <- file.path(outputFolder, "cmOutput")
  if (!file.exists(cmOutputFolder))
    dir.create(cmOutputFolder)
  
  if (createCohorts) {
    writeLines("Creating cohort for hypertension combination treatment")
    createCohorts(connectionDetails,
                  cdmDatabaseSchema,
                  resultsDatabaseSchema,
                  exposureTable,
                  outcomeTable)
    writeLines("")
  }
  
  if (runAnalyses) {
    writeLines("Running analyses")
    cmAnalysisListFile <- system.file("settings",
                                      "cmAnalysisList.txt",
                                      package = "HypertensionCombination")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    drugComparatorOutcomesListFile <- system.file("settings",
                                                  "drugComparatorOutcomesList.txt",
                                                  package = "HypertensionCombination")
    drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
    CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                oracleTempSchema = oracleTempSchema,
                                exposureDatabaseSchema = resultsDatabaseSchema,
                                exposureTable = exposureTable,
                                outcomeDatabaseSchema = resultsDatabaseSchema,
                                outcomeTable = outcomeTable,
                                cdmVersion = cdmVersion,
                                outputFolder = cmOutputFolder,
                                cmAnalysisList = cmAnalysisList,
                                drugComparatorOutcomesList = drugComparatorOutcomesList,
                                refitPsForEveryOutcome = FALSE,
                                getDbCohortMethodDataThreads = 1,
                                createPsThreads = 1,
                                psCvThreads = 1,
                                createStudyPopThreads = 1,
                                trimMatchStratifyThreads = 1,
                                computeCovarBalThreads = 1,
                                fitOutcomeModelThreads = 1,
                                outcomeCvThreads = 1)
    writeLines("")
  }
  
  if (packageResults) {
    writeLines("Packaging results in export folder for sharing")
    packageResults(connectionDetails = connectionDetails,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   outputFolder = outputFolder)
    writeLines("")
  }
  
  invisible(NULL)
}
