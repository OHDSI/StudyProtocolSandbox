main <- function(connectionDetails,
                 outputLocation,
                 databaseName,
                 cdmDatabaseschema,
                 cohortDatabaseschema,
                 cohortTable){

names <- createCohorts(connectionDetails,
                       cdmDatabaseschema=cdmDatabaseschema,
                       cohortDatabaseschema=cohortDatabaseschema,
                       cohortTable=cohortTable)


# substitute function here from helpers.R to run a different model...
results <- applyExistingAtriaStrokeModel(connectionDetails=connectionDetails,
                                         cdmDatabaseSchema=cdmDatabaseSchema,
                                         cohortDatabaseSchema=cohortDatabaseschema,
                                         cohortTable= cohortTable,
                                         targetId=names$cohortId[1],
                                         outcomeId=names$cohortId[2])

# this save the results in standard output
resultLoc <- PatientLevelPrediction::
  standardOutput(result = results,
                 outputLocation = outputLocation ,
                 studyName = 'Atria validation',
                 databaseName = databaseName,
                 cohortName = names$cohortName[1],
                 outcomeName = names$cohortName[2] )

# this creates a compressed file with sensitive details removed - ready to be reviewed and then
# submitted to the network study manager
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
                                       removeLessThanN = F,
                                       N = 10)

return(TRUE)

}

