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
  
  
  #add readme file
  file.copy(system.file("readme.txt",package="DataQuality"), exportFolder)
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
  
  writeLines("Looking at population size data")
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
  DatabaseConnector::disconnect(conn)
  #RJDBC::dbDisconnect(conn)
  
  writeLines("Done (doTree)")
  
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
  
  writeLines('Inspecting Achilles pre-computations data')
  #connect
  connectionDetails$schema=resultsDatabaseSchema
  conn <- DatabaseConnector::connect(connectionDetails)
  
  #1 derived measures 
  
  
  sql <- "select * from @results_database_schema.achilles_results_derived where measure_id not like '%PersonCnt%' order by measure_id,stratum_1"
  
  #old query (smaller was)
  # select * from @results_database_schema.achilles_results_derived r where measure_id in ('ach_2000:Percentage',
  #                                      'ach_2001:Percentage','ach_2002:Percentage','ach_2003:Percentage')
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  dataDerived <- DatabaseConnector::querySql(conn, sql)
  
  
  #process the data 
  #make sure the names are the same case accross different DB engines
  names(dataDerived) <- tolower(names(dataDerived))
  dataDerived$analysis_id <- NULL
  
  #get names of the derived measures from Achilles package  (getting the file may generate errors)
      # derived <- read.csv(system.file("csv", "derived_analysis_details.csv", package = "Achilles"))
      # derivedSmall<-derived[,1:2]
      # 
      # data2<-merge(data,derivedSmall,by='measure_id',all.x=T)
  
  write.csv(dataDerived,file = file.path(exportFolder,'SelectedDerivedMeasures.csv'),row.names = F)
  
  
  
  #2 ------dist results table section

  
  sql <- "select d.analysis_id, stratum_1, stratum_2,count_value,avg_value, median_value, a.analysis_name,
  a.stratum_1_name,stratum_2_name, stdev_value,p10_value,p25_value,p75_value,p90_value from @results_database_schema.achilles_results_dist d 
  join @results_database_schema.achilles_analysis a on d.analysis_id = a.analysis_id
  where d.analysis_id 
  in (103,104,105,106,107,203,206,211,403,506,511,512,513,514,515,603,703,803,903,1003,1803) order by analysis_id"
  
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  dataDist <- DatabaseConnector::querySql(conn, sql)
  
  
  #process the data 
  #make sure the names are the same case accross different DB engines
  names(dataDist) <- tolower(names(dataDist))
  
  
  write.csv(dataDist,file = file.path(exportFolder,'SelectedAchillesResultsDistMeasures.csv'),row.names = F)
  
  
  
  #3 ------Heel results  table section
  
  
  sql <- "select * from  @results_database_schema.achilles_heel_results a"
  
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  dataHeel <- DatabaseConnector::querySql(conn, sql)
  
  
  #process the data 
  #make sure the names are the same case accross different DB engines
  names(dataHeel) <- tolower(names(dataHeel))
  
  #mask rows that have <10 pts  
  # dplyr incorrect approach dataHeel2<- dataHeel %>% dplyr::filter(rule_id %in% c(12,14,23)) %>%  dplyr::filter(record_count < 2) %>%   dplyr::mutate(record_count=NA)
  # dataHeel3<-dataHeel
  # dataHeel3[(dataHeel3$rule_id %in% c(6,12,14,23) & dataHeel3$record_count < 10),"record_count"]<-NA
  #TODO some of them are just named badly, they do not represent patient count
  # one db fails here
  
  # dplyr::mutate(record_count=dplyr::replace(record_count=NA))
  #export
  write.csv(dataHeel,file = file.path(exportFolder,'HeelOutput.csv'),row.names = F)
  
  
  
  
  
  #4 ------Achilles  results  table section (selected measures) (recomputed as percentages of all patients)
  
  #treshold on patient count was added (in addition to achilles default filtering)
  sql <- "select analysis_id,stratum_1,stratum_2,stratum_3,count_value from @results_database_schema.achilles_results a 
    where analysis_id in (0,1,2,4,5,10,11,12,109,113,212,200,505)
    and count_value >10
    "
  
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  data <- DatabaseConnector::querySql(conn, sql)
  
  # ok so I will use upper case all the time  names(data) <- tolower(names(data))
  
  
  #get person count
  persons<-data$COUNT_VALUE[data$ANALYSIS_ID == 1]
  
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
  
  newrow<-data.frame(ANALYSIS_ID = 99,STRATUM_1='',STRATUM_2='',STRATUM_3='',COUNT_VALUE=0,VALUE=as.character(personsFuzzy))
  data$VALUE<-''
  data<-rbind(data,newrow)
  
  
  
  
  data$PCT_VALUE <- data$COUNT_VALUE/persons
  #drop actual counts
  data$COUNT_VALUE <- NULL
  
  write.csv(data,file = file.path(exportFolder,'SelectedAchillesResultsMeasuresPerc.csv'),row.names = F)
  
  #generate graph for 212
  
  visits<-data[data$ANALYSIS_ID == 212,] #only analysis 212
  #eliminate the gender stratum from the graph
  
  if (nrow(visits) >0) {
    # temp<-dplyr::summarize(dplyr::group_by(visits,STRATUM_1,STRATUM_3),PCT_VALUE=sum(PCT_VALUE))
    temp<-visits %>% dplyr::group_by(STRATUM_1,STRATUM_3) %>% dplyr::summarise(PCT_VALUE=sum(PCT_VALUE))
    
    
    
    ggplot2::ggplot(data=temp, ggplot2::aes(x=STRATUM_1, y=STRATUM_3,size=PCT_VALUE)) + ggplot2::geom_point() + 
      ggplot2::labs(x='year',y='decile') 
    ggplot2::ggsave(file.path(exportFolder, "VisitsByDecileDotPlot.png"), width = 9, height = 9, dpi= 200)
    
  }
  
  #5 ------Achilles  results  table section (not person dependent)
  
  
  sql <- "select analysis_id,stratum_1,count_value from @results_database_schema.achilles_results a where analysis_id in (201)"
  
  
  sql <- SqlRender::renderSql(sql,results_database_schema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  data <- DatabaseConnector::querySql(conn, sql)
  
  # ok so I will use upper case all the time  names(data) <- tolower(names(data))
  
  

  write.csv(data,file = file.path(exportFolder,'SelectedAchillesResultsMeasuresOther.csv'),row.names = F)
  
  writeLines("Done with core part of DQ study. Export files were generated.")
  
  #-------------empiric rules -----------------------------------------------------------------------
  
  #currently using only dataDerived
  #goal join dataDist
  
  writeLines('Applying empiric rules')
  tta<-dataDist %>% dplyr::mutate(measure_id=paste0(analysis_id)) %>% dplyr::select(stratum_1,stratum_2,statistic_value=median_value,measure_id)
  dataInput<-rbind(dataDerived,tta)
  
  #read reference values
  pathToCsv <- system.file("csv", "empiric_reference.csv", package = "DataQuality")
  e <- read.csv(pathToCsv,as.is=T)
  
  #read rules
  r <- read.csv(system.file("csv", "empiric_rule.csv", package = "DataQuality"),as.is=T)
  
  ruleData<-dplyr::inner_join(e,r,by='measure_id')

  #do empiric Rules only
  ruleData<-dplyr::filter(ruleData,grepl('empiric',empiric_rule_type))
  
        #decide emiric threshold
        for (i in 1:nrow(ruleData)){
          if (ruleData$empiric_threshold_value[i] == 'perc10') ruleData$threshold[i] <- ruleData$perc10[i]
          if (ruleData$empiric_threshold_value[i] == 'perc50') ruleData$threshold[i] <- ruleData$perc50[i]
        }
  
  #add actual data
  ruleData.full<-ruleData
  
   ruleData <- dplyr::inner_join(ruleData,dataInput,by='measure_id')
  # ruleData2 <- dplyr::inner_join(ruleData,dataDerived)
  
   # i=9
    ruleData$fulfilled=0
   
  #check what rules fire
  for (i in 1:nrow(ruleData)){
  
     if (trimws(ruleData$direction[i]) == '>') {
  
       if (ruleData$statistic_value[i] > ruleData$threshold[i] ) {
         ruleData$fulfilled[i]<-1
       }
     } #greater
    
  
     if (trimws(ruleData$direction[i]) == '<') {
       if (ruleData$statistic_value[i] < ruleData$threshold[i] ) {
         ruleData$fulfilled[i]<-1
       }
     } #less
    
  }#loop
  
  
  #join with data
  
  # ruleData<-dplyr::inner_join(dataDerived,er)
  # ruleData<-dplyr::left_join(e2,r)
  
  

  # str(ruleData)
  # i=1

  

  #final fired rules are here  
  # View(dplyr::filter(ruleData,fulfilled==1))  
    ruleData$score_weight
  score <-sum(dplyr::filter(ruleData,fulfilled==1)$score_weight)
  writeLines(paste('DQScoreA:',score))
  ruleDataOutput <- ruleData %>%  dplyr::filter(fulfilled==1) %>%  
    dplyr::select(measure_id,measure_name,message_grade,statistic_value,direction,threshold) %>% 
    dplyr::arrange(message_grade)
  write.csv(ruleDataOutput,file = file.path(exportFolder,'DataQuality.csv'),row.names = F)

  # Clean up
  
  DatabaseConnector::disconnect(conn)
  
  writeLines("Done (selectiveExport)")
  
}


# assessFeasibility(connectionDetails = connectionDetails,
#                   cdmDatabaseSchema = "cdm_data",
#                   workDatabaseSchema = "results",
#                   studyCohortTable = "ohdsi_alendronate_raloxifene",
#                   oracleTempSchema = NULL,
#                   outputFolder = "c:/temp/study_results")

