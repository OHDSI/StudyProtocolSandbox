main <- function(modelLocations,
                 cohortIds,
                 outcomeIds,
                 connectionDetails,
                 outputLocation,
                 databaseName,
                 cdmDatabaseSchema,
                 cohortDatabaseSchema,
                 cohortTable,
                 N=5
){

  allResults <- c()
  for(i in 1:length(modelLocations)){

    result <- applyDevelopedPlpModel(connectionDetails=connectionDetails,
                                     cdmDatabaseSchema=cdmDatabaseSchema,
                                     cohortDatabaseSchema=cohortDatabaseSchema,
                                     cohortTable= cohortTable,
                                     modelLocation = modelLocations[i],
                                     targetId=cohortIds[i],
                                     outcomeId=outcomeIds[i])

    allResults <- rbind(allResults, result$summary)

    resultLoc <- PatientLevelPrediction::standardOutput(result = result$validation[[1]],
                                                        outputLocation = outputLocation ,
                                                        studyName = paste0(modelLocations[i],'val on ',databaseName),
                                                        databaseName = databaseName,
                                                        cohortName = cohortIds[i],
                                                        outcomeName = outcomeIds[i] )

    PatientLevelPrediction::packageResults(mainFolder=resultLoc,
                                           includeROCplot= T,
                                           includeCalibrationPlot = T,
                                           includePRPlot = T,
                                           includeTable1 = T,
                                           includeThresholdSummary =T,
                                           includeDemographicSummary = T,
                                           includeCalibrationSummary = T,
                                           includePredictionDistribution =T,
                                           includeCovariateSummary = T,
                                           removeLessThanN = T,
                                           N = N)
  }

  return(allResults)

}

