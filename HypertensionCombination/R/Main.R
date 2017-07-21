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
                  createTableAndFigures=FALSE,
				  compressResults = FALSE,
                  maxCores = 4){
  
  if (cdmVersion == 4) {
    stop("CDM version 4 not supported")
  }
  
    
    if (!file.exists(file.path(outputFolder)))
        dir.create(file.path(outputFolder))
    
    cmOutputFolder <- file.path(file.path(outputFolder), "cmOutput")
    if (!file.exists(cmOutputFolder))
        dir.create(cmOutputFolder)
    exportFolder <- file.path(file.path(outputFolder), "export")
    if (!file.exists(exportFolder))
        dir.create(exportFolder)
    
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
      cmAnalysisOutputFolder <- file.path(cmOutputFolder, "30")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		  cmAnalysisExportFolder <- file.path(exportFolder, "30")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
          
      
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
                     cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
      writeLines("")
  }
    
  if (createTableAndFigures){
      writeLines("createTableAndFigures")
      createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
      writeLines("")
  }
  
  ##180 analysis 2
  

    
  if (runAnalyses) {
      cmAnalysisOutputFolder <- file.path(cmOutputFolder, "180")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		  cmAnalysisExportFolder <- file.path(exportFolder, "180")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
      
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
                     cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
                     writeLines("")
  }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
                              writeLines("")
    }
    
  ##365 analysis 3

    
    if (runAnalyses) {
        cmAnalysisOutputFolder <- file.path(cmOutputFolder, "365")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		  cmAnalysisExportFolder <- file.path(exportFolder, "365")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
        
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
                       cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
                       writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
                              writeLines("")
    }
    
    ##730 analysis 4
    
    
    if (runAnalyses) {
        cmAnalysisOutputFolder <- file.path(cmOutputFolder, "730")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		  cmAnalysisExportFolder <- file.path(exportFolder, "730")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
        
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
                       cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
        writeLines("")
    }
    
    ##18001 analysis
    
    if (runAnalyses) {
        cmAnalysisOutputFolder <- file.path(cmOutputFolder, "18001")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		  cmAnalysisExportFolder <- file.path(exportFolder, "18001")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
        
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
                       cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
        writeLines("")
    }
    
    ##18002  analysis
    
    if (runAnalyses) {
        cmAnalysisOutputFolder <- file.path(cmOutputFolder, "18002")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		  cmAnalysisExportFolder <- file.path(exportFolder, "18002")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
        
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
                       cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
        writeLines("")
    }
    
    ##18059  analysis
    
    if (runAnalyses) {
        cmAnalysisOutputFolder <- file.path(cmOutputFolder, "18059")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		cmAnalysisExportFolder <- file.path(exportFolder, "18059")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
        
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
                       cmOutputFolder = cmAnalysisOutputFolder,
					   exportFolder= cmAnalysisExportFolder)
        writeLines("")
    }  
    
    if (createTableAndFigures){
        writeLines("createTableAndFigures")
        createTableAndFigures(exportFolder= cmAnalysisExportFolder,
                              cmOutputFolder= cmAnalysisOutputFolder)
        writeLines("")
    }
    
    ##18061  analysis
    
    if (runAnalyses) {
        cmAnalysisOutputFolder <- file.path(cmOutputFolder, "18061")
      if (!file.exists(cmAnalysisOutputFolder))
          dir.create(cmAnalysisOutputFolder)
		cmAnalysisExportFolder <- file.path(exportFolder, "18061")
      if (!file.exists(cmAnalysisExportFolder))
          dir.create(cmAnalysisExportFolder)
        
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
    
	#analysesList <- c("30","180","365","730","18001","18002","18059","18061")
	#analysesPaths <- file.path(cmOutputFolder,analysesList)
	#exportPaths <- file.path(exportFolder,analysesList)
    if (packageResults) {
		writeLines("Packaging results in export folder for sharing")
		packageResults(connectionDetails = connectionDetails,
					   cdmDatabaseSchema = cdmDatabaseSchema,
					   cmOutputFolder = cmOutputFolder,
					   exportFolder= exportFolder)
		writeLines("")
    }  
    
    if (createTableAndFigures){
		writeLines("createTableAndFigures")
		createTableAndFigures(exportFolder= exportFolder,
							  cmOutputFolder= cmOutputFolder)
		writeLines("")
    }

  if (compressResults) {
    writeLines("Compressing study results")
    compressResults(exportFolder)
    writeLines("")
  }    
    
  invisible(NULL)
}
