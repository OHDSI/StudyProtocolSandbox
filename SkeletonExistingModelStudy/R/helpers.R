getData <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cdmDatabaseName,
                    cohortDatabaseSchema,
                    cohortTable,
                    oracleTempSchema,
                    standardCovariates,
                    firstExposureOnly,
                    sampleSize,
                    cdmVersion){
  
  
  pathToCustom <- system.file("settings", 'CustomCovariates.csv', package = "SkeletonExistingModelStudy")
  cohortVarsToCreate <- utils::read.csv(pathToCustom)
  covSets <- list()
  length(covSets) <- nrow(cohortVarsToCreate)+1
  covSets[[1]] <- standardCovariates
  
  for(i in 1:nrow(cohortVarsToCreate)){
    covSets[[1+i]] <- createCohortCovariateSettings(covariateName = as.character(cohortVarsToCreate$cohortName[i]),
                                                      covariateId = cohortVarsToCreate$cohortId[i]*1000+456, count = F,
                                                      cohortDatabaseSchema = cohortDatabaseSchema,
                                                      cohortTable = cohortTable,
                                                      cohortId = cohortVarsToCreate$atlasId[i],
                                                      startDay=cohortVarsToCreate$startDay[i], 
                                                      endDay=cohortVarsToCreate$endDay[i])
  }
  
  result <- PatientLevelPrediction::getPlpData(connectionDetails = connectionDetails,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     oracleTempSchema = oracleTempSchema, 
                                     cohortId = 1, 
                                     outcomeIds = 2, 
                                     cohortDatabaseSchema = cohortDatabaseSchema, 
                                     outcomeDatabaseSchema = cohortDatabaseSchema, 
                                     cohortTable = cohortTable, 
                                     outcomeTable = cohortTable, 
                                     cdmVersion = cdmVersion, 
                                     firstExposureOnly = firstExposureOnly, 
                                     sampleSize =  sampleSize, 
                                     covariateSettings = covSets)
  
  return(result)
  
}


getModel <- function(){
  
  pathToCustom <- system.file("settings", 'SimpleModel.csv', package = "SkeletonExistingModelStudy")
  coefficients <- utils::read.csv(pathToCustom)
 
   return(coefficients)
}

predictExisting <- function(plpData, population){
  coefficients <- getModel()
  
  prediction <- merge(plpData$covariates, ff::as.ffdf(coefficients), by = "covariateId")
  prediction$value <- prediction$covariateValue * prediction$points
  prediction <- PatientLevelPrediction:::bySumFf(prediction$value, prediction$rowId)
  colnames(prediction) <- c("rowId", "value")
  prediction <- merge(population, prediction, by ="rowId", all.x = TRUE)
  prediction$value[is.na(prediction$value)] <- 0
  
  scaleVal <- max(prediction$value)
  if(scaleVal>1){
    prediction$value <- prediction$value/scaleVal
  }
  
  attr(prediction, "metaData") <- list(predictionType = 'binary', scale = scaleVal)
  
  return(prediction)
}




