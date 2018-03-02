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




#' @description This function will get all data for all DBs. User will specify one main
#' directory. Program will create subdirectories in this folder, named after the
#' different {\code resultsDatabaseSchema} from which data is gathered. Each folder in the sub-diretory
#' will have .csv files in the format {\code paste0('a', analysis_id, '.csv')}
#' @param conncectionDetails Credentials to access database (see readme for help)
#' @param resultsDatabaseSchema Character vector with the names of the different
#' shcema to pull data from.
#' @param medical_event_ids Include the event analysis ids you are interested in AND the population
#' id.
#' @export
getData2 <- function(connectionDetails,resultsDatabaseSchema, dataExportFolder,
                     medical_event_ids) {
  fpaths <- paste0(dataExportFolder, resultsDatabaseSchema, "/") # dir.create can't have trailing /

  # 2. check if fpath exists. if not, create
  for(fpath in fpaths)
    if (!dir.exists(fpath))
      dir.create(fpath)

  #sql server needs prefix even though the database is set in connectionDetails
  SQL_commands <- paste0('select * from ',resultsDatabaseSchema,'.achilles_results where analysis_id =', medical_event_ids)

  for(i in 1:length(resultsDatabaseSchema))
  {
    # select right output path
    fpath <- fpaths[i]

    db <- resultsDatabaseSchema[[i]]

    connectionDetails$schema = db
    conn<-DatabaseConnector::connect(connectionDetails,schema = db)

    #print(db)

    for(j in 1:length(SQL_commands))
    {
      com = SQL_commands[[j]]
      aid = medical_event_ids[[j]]
      d <- DatabaseConnector::querySql(conn, com)
      write.csv(d, paste0(fpath, 'a', aid, '.csv'), row.names = F)


      #print(aid)
    }
    rm(d)
    DatabaseConnector::disconnect(conn)
    #done with one database
  }
  #gc()
}
