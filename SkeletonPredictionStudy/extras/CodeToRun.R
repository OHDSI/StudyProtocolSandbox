library(SkeletonPredictionStudy)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "s:/FFtemp")

# If you are creating the study then run:
## createStudyFiles(baseUrl='http://api.ohdsi.org:80/WebAPI',   
##                  packageName='SkeletonPredictionStudy')

# The folder where the study intermediate and result files will be written:
outputFolder <- "s:/SkeletonpredictionStudy"

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

debug(execute)
execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = 'cdm_database',
        cohortDatabaseSchema = 'cohort_database',
        cohortTable = "cohort",
        outputFolder = outputFolder,
        createCohorts = F,
        packageResults = TRUE,
        minCellCount= 5,
        packageName="SkeletonPredictionStudy")
