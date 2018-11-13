# get the latest PatientLevelPrediction
install.packages("devtools")
devtools::install_github("OHDSI/PatientLevelPrediction")
# check the package
PatientLevelPrediction::checkPlpInstallation()

# install the network package
devtools::install_github('OHDSI/StudyProtocolSandbox/HFinT2DMValidation')

library(HFinT2DMValidation)

# add details of your database setting:
databaseName <- 'add a shareable name for the database used to develop the models'

# add the cdm database schema with the data
cdmDatabaseSchema <- 'cdm_yourdatabase.dbo'

# add the work database schema this requires read/write privileges
cohortDatabaseSchema <- 'yourworkdatabase.dbo'

# the name of the table that will be created in cohortDatabaseSchema to hold the cohorts
cohortTable <- 'studyHFinT2DMeCohortTable'

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
