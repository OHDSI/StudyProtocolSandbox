library(ShortTermMortalityPrediction)

# USER INPUTS
#=======================
# Specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "s:/FFtemp")

# The folder where the study intermediate and result files will be written:
outputFolder <- "s:/ShortTermMortalityPredictionResults"

# Details for connecting to the server:
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

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm_database.dbo'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'workdatabase.dbo'

# table name where the cohorts will be generated
cohortTable <- 'ShortTermMortalityPredictionCohort'
#=======================

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        outputFolder = outputFolder,
        createCohorts = T,
        runAnalyses = T,
        packageResults = T,
        createValidationPackage = F,
        minCellCount= 5)
