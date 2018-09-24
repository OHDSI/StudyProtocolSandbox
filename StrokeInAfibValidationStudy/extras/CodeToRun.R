rm(list = ls())
library(StrokeInAfibValidationStudy)

# add details of your database setting:
databaseName <- 'add a shareable name for the database used to develop the models'

# add the cdm database schema with the data
cdmDatabaseSchema <- 'yourcdmdatabase'

# add the work database schema this requires read/write privileges
cohortDatabaseSchema <- 'yourworkdatabase'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'studyAfibStrokeCohortTable'

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
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        outputFolder = outputFolder,
        createCohorts = T,
        runValidation = T,
        packageResults = T,
        minCellCount = 5)

