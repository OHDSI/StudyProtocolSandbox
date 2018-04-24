#' Level one data about dataset MIAD stands for minimum information about a dataset
#' percentage measures are used that hide exact patient counts
#' @export
createMIAD <- function(connectionDetails,
                               cdmDatabaseSchema,
                               workDatabaseSchema = cdmDatabaseSchema,
                               outputFolder,
                               level=3) {
  
  #assumption  outputFolder is where study output is (and exists)
  #assumption outputFolder has subfolder export 
  
  #assuming that result database would be added to packageresults
  #workDatabaseSchema = "results" and the same wordDatabaseSchema happens to also have
  #achilles results data
  #the function above requires knowing workDatabaseSchema (currently package data does not have that)
  #so either would have to be added or executed during study execution or feasibility
  
  
  
  exportFolder<-file.path(outputFolder,"export")
  
  if (!file.exists(exportFolder))
    dir.create(exportFolder)
  
  
  
  
  
  
  
  #check if Achilles_results tables are in workDatabaseSchema (hoping they would)
  conn <- DatabaseConnector::connect(connectionDetails)    
  
  tables<-getTableNames(conn,workDatabaseSchema) #requires certain version of DatabaseConnector
  tables<-toupper(tables)
  if (!("ACHILLES_RESULTS_DERIVED" %in% tables)) hasAchillesDerivedTable=F else hasAchillesDerivedTable=T
  #testing just one table. if achilles_results_derived table is present, it is assumed that all achilles tables are present
  if (hasAchillesDerivedTable) {
    
    

    
    
    #assuming colum names will be upper case for all outputs
    
    #1 derived measures 
    
    
    sql <- "select measure_id, stratum_1,stratum_2, statistic_value as value from @results_database_schema.achilles_results_derived where measure_id not like '%PersonCnt%' order by measure_id,stratum_1"
    
    #old query (smaller was)
    # select * from @results_database_schema.achilles_results_derived r where measure_id in ('ach_2000:Percentage',
    #                                      'ach_2001:Percentage','ach_2002:Percentage','ach_2003:Percentage')
    
    sql <- SqlRender::renderSql(sql,results_database_schema = workDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    dataDerived <- DatabaseConnector::querySql(conn, sql)
    
    
    
    
    #2 ------dist results table section
    
    
    sql <- "select d.analysis_id, stratum_1, stratum_2,count_value,avg_value, median_value, a.analysis_name,
    a.stratum_1_name,stratum_2_name, stdev_value,p10_value,p25_value,p75_value,p90_value from @results_database_schema.achilles_results_dist d 
    join @results_database_schema.achilles_analysis a on d.analysis_id = a.analysis_id
    where d.analysis_id 
    in (103,104,105,106,107,203,206,211,403,506,511,512,513,514,515,603,703,803,903,1003,1803) order by analysis_id"
    
    
    sql <- SqlRender::renderSql(sql,results_database_schema = workDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    dataDist <- DatabaseConnector::querySql(conn, sql)
    
    
    
    # write.csv(dataDist,file = file.path(exportFolder,'SelectedAchillesResultsDistMeasures.csv'),row.names = F)
    
    
    
    
    #4 ------Achilles  results  table section (selected measures) (recomputed as percentages of all patients)
    
    #treshold on patient count was added (in addition to achilles default filtering)
    sql <- "select analysis_id as measure_id,stratum_1,stratum_2,stratum_3,count_value from @results_database_schema.achilles_results a 
    where analysis_id in (0,1,2,4,5,10,11,12,109,113,212,200,505)
    and count_value >10
    "
    
    # where analysis_id in (0,1,2,4,5,10,11,12,109,113,212,200,505)
    
    sql <- SqlRender::renderSql(sql,results_database_schema = workDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    data <- DatabaseConnector::querySql(conn, sql)
    
    
    
    
    #get person count
    persons<-data$COUNT_VALUE[data$MEASURE_ID == 1]
    
    data$VALUE <- data$COUNT_VALUE/persons
    data$COUNT_VALUE <- NULL
    
    #create fuzzy count
    if (persons > 100000000) personsFuzzy<-'>100M'  
    if (persons < 100000000) personsFuzzy<-'40-100M'  
    if (persons < 40000000) personsFuzzy<-'20-40M'  
    if (persons < 20000000) personsFuzzy<-'10-20M'  
    if (persons < 10000000) personsFuzzy<-'5-10M'  
    if (persons < 50000000) personsFuzzy<-'1-5M'  
    if (persons < 1000000) personsFuzzy<-'100k-1M'
    if (persons < 100000) personsFuzzy<-'10-100k'
    if (persons < 10000)  personsFuzzy<-'<10k'
    
    #binned size of dataset
    newrow<-data.frame(MEASURE_ID = 99,STRATUM_1='',STRATUM_2='',STRATUM_3='',VALUE=as.character(personsFuzzy))
    
    data<-rbind(data,newrow)
    
    
    
    
    
    
    
    # write.csv(data,file = file.path(exportFolder,'SelectedAchillesResultsMeasuresPerc.csv'),row.names = F)
    
    
    #5 ------Achilles  results  table section (not person dependent)
    
    
    sql <- "select analysis_id,stratum_1,count_value from @results_database_schema.achilles_results a where analysis_id in (201)"
    
    
    sql <- SqlRender::renderSql(sql,results_database_schema = workDatabaseSchema)$sql
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
    dataAchillesResults <- DatabaseConnector::querySql(conn, sql)
    
    
    
    
    #combine data from variouse streams
    dataDerived2<-data.frame(MEASURE_ID=dataDerived$MEASURE_ID,STRATUM_1=dataDerived$STRATUM_1,STRATUM_2=dataDerived$STRATUM_2,STRATUM_3=NA,VALUE=dataDerived$VALUE)
    export<-rbind(data,dataDerived2)
    
    
    #further prune the measures
      #no proning done at this point
    
    export <- dplyr::arrange(export,MEASURE_ID,STRATUM_1,STRATUM_2,STRATUM_3)
    
    #restrict data to a given level
    #level 1 is most restrictive, level 3 has most data
    if (level==1) {
      writeLines(paste('Using level',level))
      export <-  dplyr::filter(export,MEASURE_ID %in% c('0','2','4'))
    }
    
    
    #export data
    write.csv(export,file = file.path(exportFolder,'DatasetMetadata.csv'),row.names = F)
    
    # Clean up
    DatabaseConnector::disconnect(conn)
    
    
    
  }
  writeLines('Done generating MIAD')
  #return value
  invisible(NULL)
}




