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

  SQL_commands <- paste('select * from achilles_results where analysis_id =', medical_event_ids)

  for(i in 1:length(resultsDatabaseSchema))
  {
    # select right output path
    fpath <- fpaths[i]

    db <- resultsDatabaseSchema[[i]]

    connectionDetails$schema = db
    conn<-DatabaseConnector::connect(connectionDetails,schema = db)

    print(db)

    for(j in 1:length(SQL_commands))
    {
      com = SQL_commands[[j]]
      aid = medical_event_ids[[j]]
      d <- DatabaseConnector::querySql(conn, com)
      write.csv(d, paste0(fpath, 'a', aid, '.csv'), row.names = F)


      print(aid)
    }
    rm(d)
  }
  #gc()
}
