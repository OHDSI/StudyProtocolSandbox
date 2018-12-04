#devtools::install_github("ABMI/FeatureExtraction",ref= "hfrs")
#devtools::install_github("ABMI/PredictionComparison",ref= "addExposureDaysToEnd")
#devtools::install_github("ABMI/StudyProtocolSandbox/ExistingBleedingValidationInAF",ref= "bleedingvalidation")

#file to run study
options(fftempdir = '')
dbms <- ""
user <- ""
pw <- ""
port <- NULL
server <- ""
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)
cdmDatabaseSchema = ""
cohortDatabaseSchema = ""
cohortTable = 'bleeding_cohort'
# createCohorts(connectionDetails = connectionDetails,
#               cdmDatabaseSchema=cdmDatabaseSchema,
#               cohortDatabaseSchema = cohortDatabaseSchema ,
#               cohortTable=cohortTable)

outputLocation = ""

# If the check passes and you have cohort values submit the cohort counts to the study
# organizor to confirm the cohort definitions run across the network.

#================================= STEP 2: MAIN STUDY ==================================
#  Once definitons have been checked across sites run:
main(connectionDetails=connectionDetails,
     databaseName='NHIS-NSC',
     cdmDatabaseSchema=cdmDatabaseSchema,
     cohortDatabaseSchema=cohortDatabaseSchema,
     outputLocation=outputLocation,
     cohortTable=cohortTable)

#submitResults(exportFolder=outputLocation,
#              dbName=databasename, key, secret)

table1 <- getTable1(connectionDetails,
                    cdmDatabaseSchema=cdmDatabaseSchema,
                    cohortDatabaseSchema=cohortDatabaseSchema,
                    cohortTable=cohortTable)

results <- applyExistingstrokeModels(connectionDetails=connectionDetails,
                                     cdmDatabaseSchema= cdmDatabaseSchema ,
                                     cohortDatabaseSchema= cohortDatabaseSchema ,
                                     cohortTable=cohortTable)

packageResults(results, table1=NULL, saveFolder=file.path( outputLocation),
               dbName='NHIS-NSC')

submitResults(exportFolder=file.path(getwd(),
                                     'testing_bleeding_study'),
              dbName='NHIS-NSC', key, secret)
