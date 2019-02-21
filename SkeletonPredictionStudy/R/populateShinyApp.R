populateShinyApp <- function(resultFolder,
                             minCellCount = 10,
                             databaseName = 'sharable name of development data'){
  
  # create the data folder
  if(!dir.exists(file.path(resultFolder,'data'))){
    dir.create(file.path(resultFolder,'data'), recursive = T)
  }
  
  # copy the settings csv
  file <- utils::read.csv(file.path(resultFolder,'settings.csv'))
  utils::write.csv(file, file.path(resultFolder,'data/settings.csv'), row.names = F)
  
  # copy each analysis as a rds file and copy the log
  files <- dir(resultFolder, full.names = F)
  files <- files[grep('Analysis', files)]
  for(file in files){
    
    if(!dir.exists(file.path(resultFolder,'data',file))){
      dir.create(file.path(resultFolder,'data',file))
    }
    
    if(dir.exists(file.path(resultFolder,file, 'plpResult'))){
      res <- PatientLevelPrediction::loadPlpResult(file.path(resultFolder,file, 'plpResult'))
      res <- PatientLevelPrediction::transportPlp(res, n= minCellCount, 
                                                  save = F, dataName = databaseName)
      saveRDS(res, file.path(resultFolder,'data',file, 'plpResult.rds'))
    }
    if(file.exists(file.path(resultFolder,file, 'plpLog.txt'))){
      file.copy(from = file.path(resultFolder,file, 'plpLog.txt'), 
                to = file.path(resultFolder,'data',file, 'plpLog.txt'))
    }
  }
  
  return(file.path(resultFolder,'data'))
  
}