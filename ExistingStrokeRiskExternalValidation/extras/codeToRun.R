#file to run study
library(PredictionComparison)
library(ExistingStrokeRiskExternalValidation)
options(fftempdir = 'T:/yourFftemp')
dbms <- yourDbms
user <- yourUsername
pw <-yourPassword
server <- Sys.getenv('server')
port <- Sys.getenv('port')
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

databaseName = 'friendlyDatabaseName'
cdmDatabaseSchema <- 'yourCdmDatabaseSchema'
cohortDatabaseSchema <- 'yourCohortDatabaseSchema'
cohortTable <- 'existingStrokeVal'
outputLocation <- 'C:/existingStrokeVal'

ExistingStrokeRiskExternalValidation::main(
  connectionDetails=connectionDetails,
  oracleTempSchema = NULL,
  databaseName=databaseName,
  cdmDatabaseSchema=cdmDatabaseSchema,
  cohortDatabaseSchema=cohortDatabaseSchema,
  outputLocation=outputLocation,
  cohortTable=cohortTable,
  createCohorts = F,
  runAtria = F,
  runFramingham = F,
  runChads2 = F,
  runChads2Vas = F,
  runQstroke = F,
  summariseResults = F,
  packageResults = F,
  N=10)

#submitResults(exportFolder=outputLocation,
#              dbName= databaseName, key, secret)
