execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    resultsDatabaseSchema = cdmDatabaseSchema,
                    oracleTempSchema = resultsDatabaseSchema,
                    cdmVersion = 5,
                    workFolder ='output'){
  
  
  #create export folder
  
  #multiple steps here exporting to export folder
  doTree(connectionDetails,
         cdmDatabaseSchema,
         resultsDatabaseSchema = cdmDatabaseSchema,
         oracleTempSchema = resultsDatabaseSchema,
         cdmVersion = cdmVersion,
         exportFolder ='output/export')
  
  
}

#' experimental funtion with graphic output
#' @export
doTree <- function(connectionDetails,
                   cdmDatabaseSchema,
                   resultsDatabaseSchema = cdmDatabaseSchema,
                   oracleTempSchema = resultsDatabaseSchema,
                   cdmVersion = 5,
                   exportFolder ='output/export'
) {
  
  if (cdmVersion == 4) {
    stop("CDM version 4 not supported")
  }
  
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
  ggplot2::ggsave(file.path(exportFolder, "DemogrPyramid.png"), width = 9, height = 9, dpi= 200)
  
  
  # Clean up
  RJDBC::dbDisconnect(conn)
  
  writeLines("Done")
  output
}




