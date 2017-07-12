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
                  maxCores = 4,
                  createTableAndFigures=FALSE){
  
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
    
  if (createTableAndFigures){
      writeLines("createTableAndFigures")
      createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"30"), "export"),
                            cmOutputFolder= file.path(file.path(outputFolder,"30"),"cmOutput"))
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
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"180"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"180"),"cmOutput"))
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
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"365"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"365"),"cmOutput"))
                              writeLines("")
    }
    
    ##730 analysis 4
    
    
    if (runAnalyses) {
        if (!file.exists(file.path(outputFolder, "730")))
            dir.create(file.path(outputFolder, "730"))
        
        cmOutputFolder <- file.path(file.path(outputFolder, "730"), "cmOutput")
        if (!file.exists(cmOutputFolder))
            dir.create(cmOutputFolder)
        
        writeLines("Running analyses")
        cmAnalysisListFile <- system.file("settings",
                                          "cmAnalysisList4.txt",
                                          package = "HypertensionCombination")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        
        
        drugComparatorOutcomesListFile <- system.file("settings",
                                                      "drugComparatorOutcomesList4.txt",
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
                       outputFolder = file.path(outputFolder, "730"))
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"730"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"730"),"cmOutput"))
        writeLines("")
    }
    
    ##18001 analysis
    
    if (runAnalyses) {
        if (!file.exists(file.path(outputFolder, "18001")))
            dir.create(file.path(outputFolder, "18001"))
        
        cmOutputFolder <- file.path(file.path(outputFolder, "18001"), "cmOutput")
        if (!file.exists(cmOutputFolder))
            dir.create(cmOutputFolder)
        
        writeLines("Running analyses")
        cmAnalysisListFile <- system.file("settings",
                                          "cmAnalysisList5.txt",
                                          package = "HypertensionCombination")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        
        
        drugComparatorOutcomesListFile <- system.file("settings",
                                                      "drugComparatorOutcomesList5.txt",
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
                       outputFolder = file.path(outputFolder, "18001"))
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"18001"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"18001"),"cmOutput"))
        writeLines("")
    }
    
    ##18002  analysis
    
    if (runAnalyses) {
        if (!file.exists(file.path(outputFolder, "18002")))
            dir.create(file.path(outputFolder, "18002"))
        
        cmOutputFolder <- file.path(file.path(outputFolder, "18002"), "cmOutput")
        if (!file.exists(cmOutputFolder))
            dir.create(cmOutputFolder)
        
        writeLines("Running analyses")
        cmAnalysisListFile <- system.file("settings",
                                          "cmAnalysisList6.txt",
                                          package = "HypertensionCombination")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        
        
        drugComparatorOutcomesListFile <- system.file("settings",
                                                      "drugComparatorOutcomesList6.txt",
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
                       outputFolder = file.path(outputFolder, "18002"))
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"18002"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"18002"),"cmOutput"))
        writeLines("")
    }
    
    ##18059  analysis
    
    if (runAnalyses) {
        if (!file.exists(file.path(outputFolder, "18059")))
            dir.create(file.path(outputFolder, "18059"))
        
        cmOutputFolder <- file.path(file.path(outputFolder, "18059"), "cmOutput")
        if (!file.exists(cmOutputFolder))
            dir.create(cmOutputFolder)
        
        writeLines("Running analyses")
        cmAnalysisListFile <- system.file("settings",
                                          "cmAnalysisList7.txt",
                                          package = "HypertensionCombination")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        
        
        drugComparatorOutcomesListFile <- system.file("settings",
                                                      "drugComparatorOutcomesList7.txt",
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
                       outputFolder = file.path(outputFolder, "18059"))
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"18059"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"18059"),"cmOutput"))
        writeLines("")
    }
    
    ##18061  analysis
    
    if (runAnalyses) {
        if (!file.exists(file.path(outputFolder, "18061")))
            dir.create(file.path(outputFolder, "18061"))
        
        cmOutputFolder <- file.path(file.path(outputFolder, "18061"), "cmOutput")
        if (!file.exists(cmOutputFolder))
            dir.create(cmOutputFolder)
        
        writeLines("Running analyses")
        cmAnalysisListFile <- system.file("settings",
                                          "cmAnalysisList8.txt",
                                          package = "HypertensionCombination")
        cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
        
        
        drugComparatorOutcomesListFile <- system.file("settings",
                                                      "drugComparatorOutcomesList8.txt",
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
                       outputFolder = file.path(outputFolder, "18061"))
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= exportFolder <- file.path( file.path(outputFolder,"18061"), "export"),
                              cmOutputFolder= file.path(file.path(outputFolder,"18061"),"cmOutput"))
        writeLines("")
    }
    
    
  invisible(NULL)
}
