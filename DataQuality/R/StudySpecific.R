#' Execute all components of the DataQuality study (resultsDatabaseSchema is where Achilles results are)
#' @export
executeDQ <- function(connectionDetails,
                    cdmDatabaseSchema,
                    resultsDatabaseSchema = cdmDatabaseSchema,
                    oracleTempSchema = resultsDatabaseSchema,
                    cdmVersion = 5,
                    workFolder ='output'){
  
  
  #create export folder
  #create export subfolder in workFolder
  exportFolder <- file.path(workFolder, "export")
  if (!file.exists(exportFolder))
    dir.create(exportFolder)
  
  
  #multiple steps here exporting to export folder
  
  doTree(connectionDetails,
         cdmDatabaseSchema,
         resultsDatabaseSchema = resultsDatabaseSchema,
         oracleTempSchema = resultsDatabaseSchema,
         cdmVersion = cdmVersion,
         workFolder = workFolder)
  
  
  #export of data
  #done separately for now, may be included later
  
  
  #final cleanup
  writeLines("Done with executeDQ")
  
  
}


#' experimental funtion with graphic output
#' @export
doTree <- function(connectionDetails,
                   cdmDatabaseSchema,
                   resultsDatabaseSchema = cdmDatabaseSchema,
                   oracleTempSchema = resultsDatabaseSchema,
                   cdmVersion = 5,
                   workFolder) {
  
  if (cdmVersion == 4) {
    stop("CDM version 4 not supported")
  }
  
  exportFolder<-file.path(workFolder,"export")
  
  if (!file.exists(exportFolder))
    dir.create(exportFolder)
  
  # cmexportFolder <- file.path(exportFolder, "cmOutput")
  # if (!file.exists(cmexportFolder))
  #     dir.create(cmexportFolder)
  
  #connect
  connectionDetails$schema=resultsDatabaseSchema
  conn <- DatabaseConnector::connect(connectionDetails)
  
  #get query
  
  
  sql <- "select stratum_1,
  100.0*count_value/(select count_value as total_pts from @results_database_schema.achilles_results r where analysis_id =1) as statistic_value,
  'ach_'+CAST(analysis_id as VARCHAR) + ':Percentage' as measure_id
  from @results_database_schema.achilles_results
  where analysis_id in (3)
  "
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  data <- DatabaseConnector::querySql(conn, sql)
  
  
  #render tree
  names(data) <- tolower(names(data))
  cyear=as.numeric(format(Sys.Date(), "%Y"))
  data$age=cyear-as.numeric(data$stratum_1)
  
  
  ggplot2::ggplot(data=data, ggplot2::aes(x=age, y=statistic_value)) + ggplot2::geom_bar(stat="identity") + ggplot2::coord_flip()
  ggplot2::ggsave(file.path(exportFolder, "DemogrPyramidFigure.png"), width = 9, height = 9, dpi= 200)
  
  write.csv(data,file = file.path(exportFolder,'DemogrPyramidData.csv'),row.names = F)
  
  # Clean up
  RJDBC::dbDisconnect(conn)
  
  writeLines("Done")
  
}




