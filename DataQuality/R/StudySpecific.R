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
  
  doSelectiveExport(connectionDetails,
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



#' selected Achilles Measures
#' @export
doSelectiveExport <- function(connectionDetails,
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
  
  
  #connect
  connectionDetails$schema=resultsDatabaseSchema
  conn <- DatabaseConnector::connect(connectionDetails)
  
  #get query
  
  
  sql <- "select * from @results_database_schema.achilles_results_derived where measure_id not like '%PersonCnt%' order by measure_id,stratum_1;"
  
  #old query (smaller was)
  # select * from @results_database_schema.achilles_results_derived r where measure_id in ('ach_2000:Percentage',
  #                                      'ach_2001:Percentage','ach_2002:Percentage','ach_2003:Percentage')
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  data <- DatabaseConnector::querySql(conn, sql)
  
  
  #process the data 
  #make sure the names are the same case accross different DB engines
  names(data) <- tolower(names(data))
  
  #get names of the derived measures from Achilles package  (getting the file may generate errors)
      # derived <- read.csv(system.file("csv", "derived_analysis_details.csv", package = "Achilles"))
      # derivedSmall<-derived[,1:2]
      # 
      # data2<-merge(data,derivedSmall,by='measure_id',all.x=T)
  
  write.csv(data,file = file.path(exportFolder,'SelectedDerivedMeasures.csv'),row.names = F)
  
  
  
  #------dist results table section

  
  sql <- "select d.analysis_id, stratum_1, stratum_2,count_value,avg_value,stdev_value, median_value, a.analysis_name,
  a.stratum_1_name,stratum_2_name  from @results_database_schema.achilles_results_dist d 
  join @results_database_schema.achilles_analysis a on d.analysis_id = a.analysis_id
  where d.analysis_id 
  in (103,104,105,106,107,203,206,211,403,506,511,512,513,514,515,603,703,803,903,1803) order by analysis_id;"
  
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  data <- DatabaseConnector::querySql(conn, sql)
  
  
  #process the data 
  #make sure the names are the same case accross different DB engines
  names(data) <- tolower(names(data))
  
  
  write.csv(data,file = file.path(exportFolder,'SelectedAchillesResultsDistMeasures.csv'),row.names = F)
  
  
  
  #------dist results table section
  
  
  sql <- "select * from  @results_database_schema.achilles_heel_results a;"
  
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  data <- DatabaseConnector::querySql(conn, sql)
  
  
  #process the data 
  #make sure the names are the same case accross different DB engines
  names(data) <- tolower(names(data))
  
  
  write.csv(data,file = file.path(exportFolder,'HeelOutput.csv'),row.names = F)
  
  
  
  
  
  
  
  
  
  
  
  # Clean up
  RJDBC::dbDisconnect(conn)
  
  writeLines("SelectiveExport Done")
  
}




