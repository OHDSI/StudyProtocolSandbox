rm(list = ls())
library(StrokeInAfibValidationStudy)
library(PatientLevelPrediction)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "s:/FFtemp")

# The folder where the study intermediate and result files will be written:
outputFolder <- "s:/StrokeInAfibValidationStudy"

# Details for connecting to the server:
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv("server")
port <- Sys.getenv("port")

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# debug(execute)
StrokeInAfibValidationStudy::execute(connectionDetails = connectionDetails,
                                 databaseName = 'your database name',
                                 cdmDatabaseSchema = "your cdm database.dbo",
                                 cohortDatabaseSchema = "workingdatabase.dbo",
                                 cohortTable = "strokeafibcohortval",
                                 outputFolder = outputFolder,
                                 createCohorts = F,
                                 runValidations = T,
                                 packageResults = F,
                                 minCellCount = 5)

