createCohorts<-function(connectionDetails,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema,
                        exposureTable,
                        outcomeTable){
  conn<-DatabaseConnector::connect(connectionDetails)
  
  #writeLines("drop_tables.sql")
  #renderedSql<-SqlRender::loadRenderTranslateSql("drop_tables.sql",
  #                                               packageName="HypertensionCombination",
  #                                               dbms=connectionDetails$dbms,
  #                                               resultsDatabaseSchema=resultsDatabaseSchema,
  #                                               exposureTable=exposureTable,
  #                                               outcomeTable=outcomeTable
  #)
  #DatabaseConnector::executeSql(conn, renderedSql)
  
  aggregate_sql <- "DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
  INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
  SELECT @target_cohort_id as cohort_definition, subject_id, min(cohort_start_date), min(cohort_end_date) 
  from @target_database_schema.@target_cohort_table
  WHERE cohort_definition_id in @target_cohort_set
  GROUP BY subject_id"
  
  
  writeLines("ac_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 target_cohort_id=1300
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ca_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 target_cohort_id=3100
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 target_cohort_id=1400
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("da_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 target_cohort_id=4100
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 target_cohort_id=3400
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("dc_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 target_cohort_id=4300
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  ##aggregation code
  
  writeLines("ac cohort aggregation")
  sql <- renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=13,
                   target_cohort_set="(1300,3100)")$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("ad cohort aggregation")
  sql <- renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=14,
                   target_cohort_set="(1400,4100)")$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("cd cohort aggregation")
  sql <- renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=34,
                   target_cohort_set="(3400,4300)")$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("outcome_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("outcome_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable)
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("negative_control.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("negative_control.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable)
  
  DatabaseConnector::executeSql(conn, renderedSql)
  
  RJDBC::dbDisconnect(conn)
}

addCohortNames <- function(data, IdColumnName = "outcomeId", nameColumnName = "outcomeName") {
  idToName <- data.frame(cohortId = c(13,14,34),
                         cohortName = c("AC","AD","CD"))
  names(idToName)[1] <- IdColumnName
  names(idToName)[2] <- nameColumnName
  data <- merge(data, idToName, all.x = TRUE)
  # Change order of columns:
  idCol <- which(colnames(data) == IdColumnName)
  if (idCol < ncol(data) - 1) {
    data <- data[, c(1:idCol, ncol(data) , (idCol+1):(ncol(data)-1))]
  }
  return(data)
}