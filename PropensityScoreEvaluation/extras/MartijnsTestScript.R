# Install packages
# install.packages("devtools")
# library(devtools)
# install_github("ohdsi/OhdsiRTools")
# install_github("ohdsi/SqlRender")
# install_github("ohdsi/DatabaseConnector")
# install_github("ohdsi/Cyclops", ref="HDPS")
# install_github("ohdsi/FeatureExtraction")
# install_github("ohdsi/CohortMethod", ref = "hdps_clean")
library(SqlRender)
library(DatabaseConnector)
library(CohortMethod)
library(PropensityScoreEvaluation)
options('fftempdir' = 's:/fftemp')

dbms <- "pdw"
user <- NULL
pw <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "cdm_truven_mdcd_v446.dbo"
resultsDatabaseSchema <- "scratch.dbo"
port <- 17001
cdmVersion <- "5"
extraSettings <- NULL
workFolder <- "s:/temp/Yuxi"
threads <- 30

#########################################################
# Constructing CohortMethodData Object
#########################################################

# specify file and tables to use
file <- "inst/sql/sql_server/coxibVsNonselVsGiBleed.sql"
exposureTable <- "coxibVsNonselVsGiBleed"
outcomeTable <- "coxibVsNonselVsGiBleed"

# specify targetId, comparatorId, outcomeId constructed in the file
targetId <- 1
comparatorId <- 2
outcomeId <- 3

# use HDPS covariates or regular FeatureExtraction covariates
hdpsCovariates <- TRUE

# what covariate cutoff to use
deleteCovariatesSmallCount <- deleteCovariatesSmallCount

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port,
                                                                extraSettings = extraSettings)

connection <- DatabaseConnector::connect(connectionDetails)

# specify any exclusion criteria; currently geared towards coxibVsNonselVsGiBleed example
sql <- "SELECT concept_id FROM @cdmDatabaseSchema.concept_ancestor INNER JOIN @cdmDatabaseSchema.concept ON descendant_concept_id = concept_id WHERE ancestor_concept_id = 21603933"
sql <- SqlRender::renderSql(sql, cdmDatabaseSchema = cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql 
nsaids <- DatabaseConnector::querySql(connection, sql)
nsaids <- nsaids$CONCEPT_ID
excludedCovariateConceptIds <- nsaids

dbDisconnect(connection)

# create cohortMethodData object
# maybe we go with existing tutorial cohorts instead?
cohortMethodData <- createCohortMethodData(connectionDetails = connectionDetails,
                                           file = file,
                                           exposureTable = exposureTable,
                                           outcomeTable = outcomeTable,
                                           cdmVersion = cdmVersion,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           hdpsCovariates = hdpsCovariates,
                                           targetId = targetId,
                                           comparatorId = comparatorId,
                                           outcomeId = outcomeId,
                                           excludedCovariateConceptIds = excludedCovariateConceptIds,
                                           deleteCovariatesSmallCount = deleteCovariatesSmallCount)

saveCohortMethodData(cohortMethodData = cohortMethodData, file = file.path(workFolder, "cmData_hdps"))

# cohortMethodData <- loadCohortMethodData(file.path(workFolder, "cmData_hdps"))

#########################################################
# Create Study Population 
#########################################################

# taken from tutorials

# Garbe
studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
                                  outcomeId = 2729,
                                  firstExposureOnly = FALSE,
                                  washoutPeriod = 0,
                                  removeDuplicateSubjects = TRUE,
                                  removeSubjectsWithPriorOutcome = FALSE,
                                  minDaysAtRisk = 0,
                                  riskWindowStart = 0,
                                  addExposureDaysToStart = FALSE,
                                  riskWindowEnd = 0,
                                  addExposureDaysToEnd = TRUE)



# Graham - need to pick one of three outcomes
studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
                                  outcomeId = 2652,
                                  removeSubjectsWithPriorOutcome = TRUE,
                                  minDaysAtRisk = 1,
                                  riskWindowStart = 1,
                                  addExposureDaysToStart = FALSE,
                                  riskWindowEnd = 0,
                                  addExposureDaysToEnd = TRUE)

#########################################################
# Setup and Run Simulation 
#########################################################

# for each of the four cohortMethodData objects, specify "cmd1", "cmd2", "cmd3", or "cmd4"
workSubFolder <- file.path(workFolder, "cmd1")

# create and save simulation profile
simulationProfile <- createCMDSimulationProfile(cohortMethodData, outcomeId = outcomeId, studyPop = studyPop, threads = threads)
saveSimulationProfile(simulationProfile, file = file.path(workSubFolder, "simulationProfile"))
#simulationProfile <- loadSimulationProfile(file = file.path(workSubFolder, "simulationProfile"))

# set up simulation (calculates lasso propensity score for confounding / sample size combinations)
confoundingSchemeList <- c(0,2,2)
confoundingProportionList <- c(NA,0.1,0.5)
sampleSizeList <- c(5000, 10000, NA)

setUpSimulations(simulationProfile, cohortMethodData,
                 confoundingSchemeList = confoundingSchemeList,
                 confoundingProportionList = confoundingProportionList, 
                 sampleSizeList = sampleSizeList,
                 outputFolder = file.path(workSubFolder, "simulationSetups"), 
                 threads = threads)

# run simulations
trueEffectSizeList <- c(log(1), log(1.5), log(2), log(4))
outcomePrevalenceList <- c(0.005, 0.01, 0.05, 0.1)
hdpsFeatures <- hdpsFeatures
simulationRuns <- 100
simulationSetupsLocation <- file.path(workSubFolder, "simulationSetups")
simulationStudiesFolder <- file.path(workSubFolder, "simulationStudies")

# run simulations for single confounding / sample size pair, for example the first confounding/size pair
simulationSetupFolder <- file.path(simulationSetupsLocation, "c1_s1")

simulationStudies <- runSimulationStudies(simulationProfile, cohortMethodData, simulationSetup = NULL, 
                                          simulationRuns = simulationRuns, 
                                          trueEffectSizeList = trueEffectSizeList, 
                                          outcomePrevalenceList = outcomePrevalenceList,
                                          hdpsFeatures = hdpsFeatures,
                                          simulationSetupFolder = simulationSetupFolder,
                                          outputFolder = simulationStudiesFolder)

# OR run simulations for all confounding / sample size pairs
for (i in 1:length(confoundingSchemeList)) {
  for (j in 1:length(sampleSizeList)) {
    simulationSetupFolder <- file.path(simulationSetupsLocation, paste("c", i, "_s", j, sep = ""))
    simulationStudies <- runSimulationStudies(simulationProfile, cohortMethodData, simulationSetup = NULL, 
                                              simulationRuns = simulationRuns, 
                                              trueEffectSizeList = trueEffectSizeList, 
                                              outcomePrevalenceList = outcomePrevalenceList,
                                              hdpsFeatures = hdpsFeatures,
                                              simulationSetupFolder = simulationSetupFolder,
                                              outputFolder = simulationStudiesFolder)
  }
}

# view a simulation study
simulationStudies <- loadSimulationStudies(outputFolder)
simulationStudy <- simulationStudies[[1]][[1]]


