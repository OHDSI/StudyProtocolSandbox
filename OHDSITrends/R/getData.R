#' @export
getOMOPData <- function(connectionDetails,resultsDatabaseSchema,dataExportFolder) {
  #start of get data function

  #db connector for some reason expects refernece to results schema in both places
  connectionDetails$schema = resultsDatabaseSchema
  conn<-DatabaseConnector::connect(connectionDetails,schema = resultsDatabaseSchema)

  if (!file.exists(dataExportFolder))
    dir.create(dataExportFolder)

  if(resultsDatabaseSchema == 'ge')
  {
    d116<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 116')
    d804 <- DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 804')
    write.csv(d116,file.path(dataExportFolder,'a116.csv'),row.names=F)
    write.csv(d804,file.path(dataExportFolder,'a804.csv'),row.names=F)
  }

  else
  {
    #get 116
    d116<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 116')
    #dx
    d404<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 404')
    #proc
    d604<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 604')

    d704<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 704')
    #drug era
    d904<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 904')




    #meas
    #d1804<-DatabaseConnector::querySql(conn,'select * from achilles_results where analysis_id = 1804')


    #create export
    # exportFolder <- file.path(outputFolder, "export")


    #write export
    write.csv(d116,file.path(dataExportFolder,'a116.csv'),row.names=F)
    write.csv(d404,file.path(dataExportFolder,'a404.csv'),row.names=F)
    write.csv(d604,file.path(dataExportFolder,'a604.csv'),row.names=F)
    write.csv(d704,file.path(dataExportFolder,'a704.csv'),row.names=F)
    write.csv(d904,file.path(dataExportFolder,'a904.csv'),row.names=F)
    #write.csv(d1804,file.path(dataExportFolder,'a1804.csv'),row.names=F)
  }
  #end of function
  writeLines('Done getting data')
}
