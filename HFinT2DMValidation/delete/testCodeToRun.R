# get the latest PatientLevelPrediction
install.packages("devtools")
devtools::install_github("OHDSI/PatientLevelPrediction")
# check the package
PatientLevelPrediction::checkPlpInstallation()

# install the network package
devtools::install_github('OHDSI/StudyProtocolSandbox/HFinT2DMValidation')

library(HFinT2DMValidation)

# add details of your database setting:
databaseName <- 'ccae'

# add the cdm database schema with the data
cdmDatabaseSchema <- 'CDM_TRUVEN_CCAE_V778.dbo'

# add the work database schema this requires read/write privileges
cohortDatabaseSchema <- 'Scratch.dbo'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'studyHFinT2DMCohortTable'

# the location to save the prediction models results to:
outputFolder <- file.path(getwd(), 'delete')

# add connection details:
options(fftempdir = 'T:/fftemp')
dbms = "pdw"
server = "JRDUSAPSCTL01"
user = NULL
pw = NULL
port = 17001
connectionDetails <-
  DatabaseConnector::createConnectionDetails(
    dbms = "pdw",
    server = "JRDUSAPSCTL01",
    user = NULL,
    password = NULL,
    port = 17001
  )
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Now run the study
HFinT2DMValidation::execute(connectionDetails = connectionDetails,
                            databaseName = databaseName,
                            cdmDatabaseSchema = cdmDatabaseSchema,
                            cohortDatabaseSchema = cohortDatabaseSchema,
                            cohortTable = cohortTable,
                            outputFolder = outputFolder,
                            createCohorts = T,
                            runValidation = T,
                            packageResults = T,
                            minCellCount = 5)
