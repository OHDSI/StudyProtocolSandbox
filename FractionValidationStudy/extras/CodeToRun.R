rm(list = ls())
library(FractionValidationStudy)

# add details of your database setting:
databaseName <- 'add a shareable name for the database used to develop the models'

# add the cdm database schema with the data
cdmDatabaseschema <- 'cdm_yourdatabase.dbo'

# add the work database schema this requires read/write privileges
cohortDatabaseschema <- 'cdm_yourworkdatabase.dbo'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'studyFractionCohortTable'

# the location to save the prediction models results to:
outputFolder <- getwd()

# add connection details:
options(fftempdir = 'T:/fftemp')
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv('server')
port <- Sys.getenv('port')
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Now run the study
execute(connectionDetails = connectionDetails,
        databaseName = databaseName,
        cdmDatabaseschema = cdmDatabaseschema,
        cohortDatabaseschema = cohortDatabaseschema,
        cohortTable = cohortTable,
        outputFolder = outputFolder,
        createCohorts = T,
        runValidation = T,
        packageResults = T,
        minCellCount = 5)

