execute <- function(connectionDetails,
                 databaseName,
                 cdmDatabaseSchema,
                 cohortDatabaseSchema,
                 cohortTable,
                 outputFolder,
                 createCohorts = T,
                 runValidations = T,
                 packageResults = T,
                 minCellCount = 5,
                 sampleSize = NULL){

  if (!dir.exists(file.path(outputFolder,databaseName)))
    dir.create(file.path(outputFolder,databaseName), recursive = TRUE)

OhdsiRTools::addDefaultFileLogger(file.path(outputFolder,databaseName, "log.txt"))

if(createCohorts){
  OhdsiRTools::logInfo("Creating Cohorts")
  createCohorts(connectionDetails,
                       cdmDatabaseSchema=cdmDatabaseSchema,
                       cohortDatabaseSchema=cohortDatabaseSchema,
                       cohortTable=cohortTable,
                       outputFolder = file.path(outputFolder, databaseName))
}

if(runValidations){
  OhdsiRTools::logInfo("Validating Models")
# for each model externally validate
analysesLocation <- system.file("plp_models",
                               package = "StrokeInAfibValidationStudy")
val <- PatientLevelPrediction::evaluateMultiplePlp(analysesLocation = analysesLocation,
                           outputLocation = outputFolder, sampleSize = sampleSize,
                           connectionDetails = connectionDetails,
                           validationSchemaTarget = cohortDatabaseSchema,
                           validationSchemaOutcome = cohortDatabaseSchema,
                           validationSchemaCdm = cdmDatabaseSchema,
                           databaseNames = databaseName,
                           validationTableTarget = cohortTable,
                           validationTableOutcome = cohortTable)
}

# package the results: this creates a compressed file with sensitive details removed - ready to be reviewed and then
# submitted to the network study manager

# results saved to outputFolder/databaseName
if (packageResults) {
  OhdsiRTools::logInfo("Packaging results")
  packageResults(outputFolder = file.path(outputFolder, datbaseName),
                 minCellCount = minCellCount)
}


invisible(NULL)

}

