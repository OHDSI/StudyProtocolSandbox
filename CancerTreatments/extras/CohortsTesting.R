#source create cohorts
library(DatabaseConnector)
library(SqlRender)
library(CancerTreatments)

#create connection details  object
#your local code here or source it from external file or environment variables

#connect to databasse
conn <- DatabaseConnector::connect(connectionDetails)

workFolder='c:/b/cath'

.createCohorts(connection = conn,cdmDatabaseSchema = 'OHDSI.dbo'
               ,cohortDatabaseSchema = workDatabaseSchema
               ,cohortTable = studyCohortTable
               ,outputFolder = workFolder)
#see sizes
d<-readr::read_csv(file.path(workFolder,'CohortCounts.csv'))
d

#disconnect
DatabaseConnector::disconnect(conn)



