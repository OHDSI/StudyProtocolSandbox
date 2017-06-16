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
  ##############################################################################
  writeLines("ac_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=30,
                                                 target_cohort_id=13030
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ca_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=30,
                                                 target_cohort_id=31030
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=30,
                                                 target_cohort_id=14030
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("da_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=30,
                                                 target_cohort_id=41030
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=30,
                                                 target_cohort_id=34030
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("dc_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=30,
                                                 target_cohort_id=43030
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  ###############################################################################
  writeLines("ac_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=180,
                                                 target_cohort_id=130180
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ca_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=180,
                                                 target_cohort_id=310180
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=180,
                                                 target_cohort_id=140180
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("da_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=180,
                                                 target_cohort_id=410180
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=180,
                                                 target_cohort_id=340180
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("dc_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=180,
                                                 target_cohort_id=430180
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  #################################################################################
  writeLines("ac_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=365,
                                                 target_cohort_id=130365
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ca_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=365,
                                                 target_cohort_id=310365
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=365,
                                                 target_cohort_id=140365
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("da_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=365,
                                                 target_cohort_id=410365
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=365,
                                                 target_cohort_id=340365
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("dc_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=365,
                                                 target_cohort_id=430365
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  #####################################################################
  
  
  
  ##aggregation code
  
  writeLines("ac cohort aggregation")
  sql <- renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=1330,
                   target_cohort_set="(13030,31030)")$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("ad cohort aggregation")
  sql <- renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=1430,
                   target_cohort_set="(14030,41030)")$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("cd cohort aggregation")
  sql <- renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=3430,
                   target_cohort_set="(34030,43030)")$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
  ###################################################################
    ###################################################################
    
    writeLines("ac cohort aggregation")
    sql <- renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13180,
                     target_cohort_set="(130180,310180)")$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("ad cohort aggregation")
    sql <- renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14180,
                     target_cohort_set="(140180,410180)")$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("cd cohort aggregation")
    sql <- renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34180,
                     target_cohort_set="(340180,430180)")$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    ###################################################################
    writeLines("ac cohort aggregation")
    sql <- renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13365,
                     target_cohort_set="(130365,310365)")$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("ad cohort aggregation")
    sql <- renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14365,
                     target_cohort_set="(140365,410365)")$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("cd cohort aggregation")
    sql <- renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34365,
                     target_cohort_set="(340365,430365)")$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    
    ###Subpopulation#######################################
    writeLines("subpopulation_male")
    gender_sql<-("
          INSERT INTO target_database_schema.target_cohort_table
          SELECT @target_cohort_id, subject_id, cohort_start_date, cohort_end_date
          FROM target_database_schema.target_cohort_table co
          JOIN cdm_database_schema.person pe
          ON co.subject_id = pe.person_id
          WHERE pe.gender_concept_id = @gender_concept_id")
    
  
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
  idToName <- data.frame(cohortId = c(1330,1430,3430,13180,14180,34180,13365,14365,34365),
                         cohortName = c("AC30","AD30","CD30","AC180","AD180","CD180","AC365","AD365","CD365"))
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