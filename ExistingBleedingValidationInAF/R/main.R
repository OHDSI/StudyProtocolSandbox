main <- function(connectionDetails,
                 databaseName,
                 cdmDatabaseSchema,
                 cohortDatabaseSchema,
                 outputLocation,
                 cohortTable,
                 removeLessThanN = F,
                 N=10,
                 getTable1=F){


  names <- createCohorts(connectionDetails,
                         cdmDatabaseSchema=cdmDatabaseSchema,
                         cohortDatabaseSchema=cohortDatabaseSchema,
                         cohortTable=cohortTable)


  for(i in 4:9){
    if (i==6|i==9) next #pass the noac
    for (j in 1:3){
      if(getTable1){
        table1 <- getTable1(connectionDetails,
                            cdmDatabaseSchema=cdmDatabaseSchema,
                            cohortDatabaseSchema=cohortDatabaseSchema,
                            cohortTable= cohortTable,
                            targetId=names$cohortId[i],
                            outcomeId=names$cohortId[j])
      } else{
        table1 <- NULL
      }

      results <- applyExistingstrokeModels(connectionDetails=connectionDetails,
                                           cdmDatabaseSchema=cdmDatabaseSchema,
                                           cohortDatabaseSchema=cohortDatabaseSchema,
                                           cohortTable= cohortTable,
                                           targetId=names$cohortId[i],
                                           outcomeId=names$cohortId[j])

      for(n in 1:length(results)){
        resultLoc <- PatientLevelPrediction::standardOutput(result = results[[n]],
                                                            table1=table1,
                                                            outputLocation = outputLocation ,
                                                            studyName = names(results)[n],
                                                            databaseName = databaseName,
                                                            cohortName = names$cohortName[i],
                                                            outcomeName = names$cohortName[j] )

        PatientLevelPrediction::packageResults(mainFolder=resultLoc,
                                               includeROCplot= T,
                                               includeCalibrationPlot = T,
                                               includePRPlot = T,
                                               includeTable1 = T,
                                               includeThresholdSummary =T,
                                               includeDemographicSummary = T,
                                               includeCalibrationSummary = T,
                                               includePredictionDistribution =T,
                                               includeCovariateSummary = F,
                                               removeLessThanN = removeLessThanN,
                                               N = N)
      }

    }


  }
  return(T)
}
