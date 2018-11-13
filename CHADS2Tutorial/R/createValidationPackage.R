createValidationPackage <- function(modelFolder, 
                                    outputFolder,
                                    minCellCount = 5,
                                    databaseName = 'sharable name of development data',
                                    jsonSettings){
  
  # json needs to contain the cohort details and packagename
  
  Hydra::hydrate(specifications = jsonSettings, 
                 outputFolder=outputFolder)
  
  transportPlpModels(analysesDir = modelFolder,
                     minCellCount = minCellCount,
                     databaseName = databaseName,
                     outputDir = file.path(outputFolder,"inst/plp_models"))
  
  return(TRUE)
  
}

transportPlpModels <- function(analysesDir,
                               minCellCount = 5,
                               databaseName = 'sharable name of development data',
                               outputDir = "./inst/plp_models"){
  
  files <- dir(analysesDir, recursive = F, full.names = F)
  files <- files[grep('Analysis_', files)]
  filesIn <- file.path(analysesDir, files , 'plpResult')
  filesOut <- file.path(outputDir, files, 'plpResult')
  
  for(i in 1:length(filesIn)){
    plpResult <- PatientLevelPrediction::loadPlpResult(filesIn[i])
    PatientLevelPrediction::transportPlp(plpResult,
                                         modelName= files[i], dataName=databaseName,
                                         outputFolder = filesOut[i],
                                         n=minCellCount,
                                         includeEvaluationStatistics=T,
                                         includeThresholdSummary=T, includeDemographicSummary=T,
                                         includeCalibrationSummary =T, includePredictionDistribution=T,
                                         includeCovariateSummary=T, save=T)
    
  }
}