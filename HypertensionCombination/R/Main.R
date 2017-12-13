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
                  maxCores = 4,
                  packageResults = TRUE,
                  createTableAndFigures=TRUE,
                  compressResults = TRUE,
                  writeReport = TRUE,
                  submitResults = TRUE,
                  localName = "AUSOM_test"){

	if(cdmVersion == 4) {
		stop("CDM version 4 not supported")
	}
	
	if(!file.exists(file.path(outputFolder)))
		dir.create(file.path(outputFolder))
		
	cmOutputFolder <- file.path(file.path(outputFolder), "cmOutput")
	if(!file.exists(cmOutputFolder))
		dir.create(cmOutputFolder)
	exportFolder <- file.path(file.path(outputFolder), "export")
	if(!file.exists(exportFolder))
		dir.create(exportFolder)
	
	if(createCohorts){
		writeLines("Creating cohort for hypertension combination treatment")
		createCohorts(connectionDetails,
					  cdmDatabaseSchema,
					  resultsDatabaseSchema,
					  exposureTable,
					  outcomeTable)
		writeLines("")
	}

	analysesList <- c("30","180","365","730","18001","18002","18059","18061","18011")
	#analysesList <- c("30")
	analysesPaths <- file.path(cmOutputFolder,analysesList)
	exportPaths <- file.path(exportFolder,analysesList)
	
	cmAnalysisListFileName <- paste0("cmAnalysisList",c(1:9),".txt")
	drugComparatorOutcomeListPathFileName <- paste0("drugComparatorOutcomesList",c(1:9),".txt")
	
	if (runAnalyses) {
		for(i in 1:length(analysesList)){
			cmAnalysisOutputFolder <- analysesPaths[i]
			if (!file.exists(cmAnalysisOutputFolder))
				dir.create(cmAnalysisOutputFolder)
			  
			writeLines("Running analyses")
			cmAnalysisListFile <- system.file("settings",
											  cmAnalysisListFileName[i],
											  package = "HypertensionCombination")
			cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
			
			
			drugComparatorOutcomesListFile <- system.file("settings",
														   drugComparatorOutcomeListPathFileName[i],
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
										outputFolder = cmAnalysisOutputFolder,
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
										outcomeCvThreads = min(4, maxCores))
		}
	}
    
    if(packageResults){
		for(i in 1:length(analysesList)){
			cmAnalysisExportFolder <- exportPaths[i]
			if (!file.exists(cmAnalysisExportFolder))
				dir.create(cmAnalysisExportFolder)
				
			writeLines("Packaging results in export folder for sharing")
			packageResults(connectionDetails = connectionDetails,
						   cdmDatabaseSchema = cdmDatabaseSchema,
						   cmOutputFolder = analysesPaths[i],
						   exportFolder= exportPaths[i])
			writeLines("")
		}
    }  
    
    if(createTableAndFigures){
		for(i in 1:length(analysesList)){
			writeLines("createTableAndFigures")
			createTableAndFigures(exportFolder= exportPaths[i],
								  cmOutputFolder= analysesPaths[i])
			writeLines("")
		}
    }

	if(writeReport){
		writeReport(normalizePath(exportFolder,winslash="/"))
	}

	if(compressResults){
		writeLines("Compressing study results")
		compressResults(exportFolder)
		writeLines("")
	}

	if(submitResults){
		submitResults(exportFolder, localName)
	}
	
  invisible(NULL)
}
