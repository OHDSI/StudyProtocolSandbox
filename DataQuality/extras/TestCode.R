#' @file TestCode.R


library(DataQuality)

workFolder <- 'c:/temp'

#get connection details
source('c:/r/conn.R')  #

#database parameters
cdmDatabaseSchema <-'ccae'
resultsDatabaseSchema <-'ccae' #at most sites this likely will not be the same as cdmDatabaseSchema

workFolder <- 'c:/temp'   #this folder must exist (use forward slashes)


executeDQ(connectionDetails = connectionDetails,cdmDatabaseSchema = cdmDatabaseSchema,workFolder = workFolder)

packageResults(connectionDetails,cdmDatabaseSchema,workFolder)

submitResults(exportFolder =file.path(workFolder,'export'),
              studyBucketName = 'ohdsi-study-dataquality',
              key=studyKey,
              secret =studySecret
              )

