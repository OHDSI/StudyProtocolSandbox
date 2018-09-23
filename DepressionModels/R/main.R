
main <- function(){

  library(DatabaseConnector)
  library(PatientLevelPrediction)
  library(DepressionModels)
  options('fftempdir' = 's:/fftemp')

  connectionDetails <- createConnectionDetails(dbms = "pdw",
                                               server = Sys.getenv('server'),
                                               port = Sys.getenv('port'),
                                               user = NULL,
                                               password = NULL)

  cdmDatabaseSchema <- Sys.getenv('mdcr')
  targetDatabaseSchema <- 'scratch.dbo'
  outputDir <- 'S:/externVal'


  # 1) first create the data in the data cdm_database
  plpData <- extractData(connectionDetails,
              cdmDatabaseSchema,
              targetDatabaseSchema,
              targetCohortTable = 'extValCohort',
              targetCohortId=1, outcomeCohortId = 2:22)

  # 2) apply each of the outcome id 2 models
  applyModel(plpData, outcomeCohortId=2, outputDir=file.path(getwd(), 'externalValidation'))

}
