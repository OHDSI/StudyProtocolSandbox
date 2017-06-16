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
  
    
    if (!file.exists(file.path(outputFolder)))
        dir.create(file.path(outputFolder))
    
    cmOutputFolder <- file.path(file.path(outputFolder), "cmOutput")
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
    

  
  
  ##30 analysis 1
  if (runAnalyses) {
      if (!file.exists(file.path(outputFolder, "30")))
          dir.create(file.path(outputFolder, "30"))
      
      cmOutputFolder <- file.path(file.path(outputFolder, "30"), "cmOutput")
      if (!file.exists(cmOutputFolder))
          dir.create(cmOutputFolder)
          
      
    writeLines("Running analyses")
    cmAnalysisListFile <- system.file("settings",
                                      "cmAnalysisList1.txt",
                                      package = "HypertensionCombination")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    
    
    drugComparatorOutcomesListFile <- system.file("settings",
                                                   "drugComparatorOutcomesList1.txt",
                                                   package = "HypertensionCombination")
    drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
    
    
    CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                #oracleTempSchema = oracleTempSchema,
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
                                psCvThreads = min(16, maxCores),
                                createStudyPopThreads = min(3, maxCores),
                                trimMatchStratifyThreads = min(10, maxCores),
                                computeCovarBalThreads = min(3, maxCores),
                                fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                outcomeCvThreads = min(4, maxCores))}
  
  if (packageResults) {
      writeLines("Packaging results in export folder for sharing")
      packageResults(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     outputFolder = file.path(outputFolder, "30"))
      writeLines("")
  }
  
  ##180 analysis 2
  

    
  if (runAnalyses) {
      if (!file.exists(file.path(outputFolder, "180")))
          dir.create(file.path(outputFolder, "180"))
      
      cmOutputFolder <- file.path(file.path(outputFolder, "180"), "cmOutput")
      if (!file.exists(cmOutputFolder))
          dir.create(cmOutputFolder)
      
      writeLines("Running analyses")
      cmAnalysisListFile <- system.file("settings",
                                        "cmAnalysisList2.txt",
                                        package = "HypertensionCombination")
      cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
      
      
      drugComparatorOutcomesListFile <- system.file("settings",
                                                    "drugComparatorOutcomesList2.txt",
                                                    package = "HypertensionCombination")
      drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
      
      
      CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                  #oracleTempSchema = oracleTempSchema,
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
                                  psCvThreads = min(16, maxCores),
                                  createStudyPopThreads = min(3, maxCores),
                                  trimMatchStratifyThreads = min(10, maxCores),
                                  computeCovarBalThreads = min(3, maxCores),
                                  fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                  outcomeCvThreads = min(4, maxCores))}
  
  if (packageResults) {
      writeLines("Packaging results in export folder for sharing")
      packageResults(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     outputFolder = file.path(outputFolder, "180"))
                     writeLines("")
  }  
    
  ##365 analysis 3

    
    if (runAnalyses) {
        if (!file.exists(file.path(outputFolder, "365")))
            dir.create(file.path(outputFolder, "365"))
        
        cmOutputFolder <- file.path(file.path(outputFolder, "365"), "cmOutput")
        if (!file.exists(cmOutputFolder))
            dir.create(cmOutputFolder)
        
        writeLines("Running analyses")
        cmAnalysisListFile <- system.file("settings",
                                          "cmAnalysisList3.txt",
                                          package = "HypertensionCombination")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        
        
        drugComparatorOutcomesListFile <- system.file("settings",
                                                      "drugComparatorOutcomesList3.txt",
                                                      package = "HypertensionCombination")
        drugComparatorOutcomesList <- CohortMethod::loadDrugComparatorOutcomesList(drugComparatorOutcomesListFile)
        
        
        CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                    cdmDatabaseSchema = cdmDatabaseSchema,
                                    #oracleTempSchema = oracleTempSchema,
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
                                    psCvThreads = min(16, maxCores),
                                    createStudyPopThreads = min(3, maxCores),
                                    trimMatchStratifyThreads = min(10, maxCores),
                                    computeCovarBalThreads = min(3, maxCores),
                                    fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                    outcomeCvThreads = min(4, maxCores))}
    
    if (packageResults) {
        writeLines("Packaging results in export folder for sharing")
        packageResults(connectionDetails = connectionDetails,
                       cdmDatabaseSchema = cdmDatabaseSchema,
                       outputFolder = file.path(outputFolder, "365"))
                       writeLines("")
    }  
    
    
  invisible(NULL)
}
