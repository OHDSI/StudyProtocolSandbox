# noteCovariateExtraction

## Getting Start
PredictionOfRehospitalization with variable Model

### Library
<pre><code>
library(DatabaseConnector)
library(SqlRender)
library(FeatureExtraction)
library(PatientLevelPrediction)
</code></pre>

### DataBase Connection & CDM Settings
<pre><code>
workingFolder<- '???' ## Change to noteCovariateExtraction path

connectionDetails<-DatabaseConnector::createConnectionDetails(dbms="sql server",
                                                              server="???.???.???.???", ## Change to your IP
                                                              schema="???.dbo", ## Change to your DB
                                                              user="???", ## Change to your DataBase ID
                                                              password="???") ## Change to your DataBase PW
connection <- DatabaseConnector::connect(connectionDetails)

connectionDetails <-connectionDetails
connection <- connection

cdmDatabaseSchema<-"???.dbo" ## Change to CDM DB
targetDatabaseSchema<-"???.dbo" ## Change to target CDM DB
targetCohortTable<-"cohort"
targetCohortId <- ??? ## Change to Target Cohort Number
outcomeCohortId <- ??? ## Change to Outcome Cohort Number
cdmversion <- "5"
</code></pre>

### CREATE TABLE & INPUT VALUE
#### TargetCohort
<pre><code>
sql <- SqlRender::readSql(paste(workingFolder,'/inst/sql/sql_server/','all_admission.sql',sep = '')) #local
sql <- SqlRender::renderSql(sql,
                            cdm_database_schema=cdmDatabaseSchema,
                            target_database_schema=targetDatabaseSchema,
                            target_cohort_table=targetCohortTable,
                            target_cohort_id=targetCohortId

)$sql
sql <- SqlRender::translateSql(sql,
                               targetDialect=connectionDetails$dbms)$sql

DatabaseConnector::executeSql(connection,sql)
</code></pre>
#### OutcomeCohort
<pre><code>
sql <- SqlRender::readSql(paste(workingFolder,'/inst/sql/sql_server/','ed_visit.sql',sep = '')) #local
sql <- SqlRender::renderSql(sql,
                            cdm_database_schema=cdmDatabaseSchema,
                            target_database_schema=targetDatabaseSchema,
                            target_cohort_table=targetCohortTable,
                            target_cohort_id=outcomeCohortId
)$sql
sql <- SqlRender::translateSql(sql,
                               targetDialect=connectionDetails$dbms)$sql
DatabaseConnector::executeSql(connection,sql)
</code></pre>


### Extract from the Note
<pre><code>
#Setting for ff package
options("fftempdir"="???")

connectionDetails<-DatabaseConnector::createConnectionDetails(dbms="sql server",
                                                              server="???.???.???.???", ## Change to your IP
                                                              schema="???.dbo", ## Change to your DB
                                                              user="???", ## Change to your DataBase ID
                                                              password="???") ## Change to your DataBase PW
connection <- DatabaseConnector::connect(connectionDetails)

connectionDetails <-connectionDetails
connection <- connection

oracleTempSchema = NULL
cdmDatabaseSchema <- '???.dbo' ## Change to CDM DB
targetDatabaseSchema<-"???.dbo" ## Change to target CDM DB
resultsDatabaseSchema<-"???.dbo" ## Change to result CDM DB
cohortTable <- 'cohort'
cohortId = targetCohortId
outcomeId <- outcomeCohortId
noteConceptId = 44814637 ## It is Discharge record
cdmVersion = "5"
rowIdField = "subject_id"


covariateSettings <- noteCovariateExtraction::createTopicFromNoteSettings(useTopicFromNote = TRUE,
                                                 useDictionary = TRUE,
                                                 useTopicModeling = TRUE,
                                                 noteConceptId = 44814637,
                                                 numberOfTopics = 100,
                                                 sampleSize = 1000
                                                 )

covariates <- FeatureExtraction::getDbCovariateData(connectionDetails = connectionDetails,
                                 cdmDatabaseSchema = cdmDatabaseSchema,
                                 cohortDatabaseSchema = cdmDatabaseSchema,
                                 cohortTable = "cohort",
                                 cohortId = 747,
                                 covariateSettings = covariateSettings)


covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = TRUE,
                                                                useDemographicsAgeGroup = TRUE,
                                             useDemographicsRace = TRUE,
                                             useDemographicsEthnicity = TRUE,
                                             useDemographicsIndexYear = TRUE,
                                             useDemographicsIndexMonth = TRUE)


noteCovSet <- CustomCovariateSetting::createTopicFromNoteSettings(useTopicFromNote = TRUE,
                                                                         useDictionary = TRUE,
                                                                         useTopicModeling = TRUE,
                                                                         noteConceptId = 44814637,
                                                                         numberOfTopics = 100,
                                                                         sampleSize = 1000
)


covariateSettingsList <- list(covariateSettings, noteCovSet)

covariates <-  FeatureExtraction::getDbCovariateData(connectionDetails = connectionDetails,
                                 cdmDatabaseSchema = cdmDatabaseSchema,
                                 cohortDatabaseSchema = resultsDatabaseSchema,
                                 cohortTable = "cohort",
                                 cohortId = 747,
                                 covariateSettings = covariateSettingsList)



plpData <- PatientLevelPrediction::getPlpData(connectionDetails = connectionDetails,
                      cdmDatabaseSchema = cdmDatabaseSchema,
                      oracleTempSchema = oracleTempSchema,
                      cohortDatabaseSchema = targetDatabaseSchema,
                      cohortTable = "cohort",
                      cohortId = cohortId,
                      washoutPeriod = 0,
                      covariateSettings = covariateSettingsList,
                      outcomeDatabaseSchema = resultsDatabaseSchema,
                      outcomeTable = "cohort",
                      outcomeIds = outcomeId,
                      cdmVersion = cdmVersion)

population <- PatientLevelPrediction::createStudyPopulation(plpData,
                                    outcomeId = outcomeId,
                                    includeAllOutcomes = TRUE,
                                    firstExposureOnly = FALSE,
                                    washoutPeriod = 0,
                                    removeSubjectsWithPriorOutcome = FALSE,
                                    riskWindowStart = 1,
                                    requireTimeAtRisk = FALSE,
                                    riskWindowEnd = 30)

lrModel <- setLassoLogisticRegression()
lrResults <- runPlp(population,plpData, modelSettings = lrModel, testSplit = 'person',
                    testFraction = 0.25, nfold = 2)

</code></pre>
