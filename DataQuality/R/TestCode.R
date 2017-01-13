#' @keywords internal
test <- function(connectionDetails,cdmDatabaseSchema) {
  

  workFolder=paste0('c:/temp/',cdmDatabaseSchema)
  unlink(workFolder)
  dir.create(workFolder)
  
  
  # conn<-connect(connectionDetails)
  cdmVersion='5'
  
  # library(DataQuality)
  DataQuality::executeDQ(connectionDetails = connectionDetails,cdmDatabaseSchema = cdmDatabaseSchema,
                         resultsDatabaseSchema = resultsDatabaseSchema,
                         workFolder = workFolder)
  
  exportFolder<-file.path(workFolder,'export')
  writeReport(exportFolder = exportFolder,outputFile = file.path(workFolder,'reportA.docx'))
  
  dbName=cdmDatabaseSchema
  
  #dbName='synpuf1k'
  # 'synpuf1k'
  packageResults(connectionDetails,cdmDatabaseSchema,workFolder,dbName)
  
  
}

# DataQuality:::test(connectionDetails,cdmDatabaseSchema)
