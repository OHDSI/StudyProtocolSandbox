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
  #writeLines("create_exposure_cohort_table.sql")
  #renderedSql<-SqlRender::loadRenderTranslateSql("create_cohort_table.sql",
  #                                               packageName="HypertensionCombination",
  #                                               dbms=connectionDetails$dbms,
  #                                               target_database_schema=resultsDatabaseSchema,
  #                                               cohort_table=exposureTable
  #)
  #DatabaseConnector::executeSql(conn, renderedSql)
  
  #writeLines("create_outcome_cohort_table.sql")
  #renderedSql<-SqlRender::loadRenderTranslateSql("create_cohort_table.sql",
  #                                               packageName="HypertensionCombination",
  #                                               dbms=connectionDetails$dbms,
  #                                               target_database_schema=resultsDatabaseSchema,
  #                                               cohort_table=outcomeTable
  #)
  #DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ac_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort_per_protocol.sql",
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
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort_per_protocol.sql",
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
  
  #################################################################################
  writeLines("ac_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac_cohort_per_protocol.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=730,
                                                 target_cohort_id=130730
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ca_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ca_cohort_per_protocol.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=730,
                                                 target_cohort_id=310730
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad_cohort_per_protocol.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=730,
                                                 target_cohort_id=140730
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("da_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("da_cohort_per_protocol.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=730,
                                                 target_cohort_id=410730
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd_cohort_per_protocol.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=730,
                                                 target_cohort_id=340730
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("dc_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("dc_cohort_per_protocol.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=exposureTable,
                                                 drug_period=730,
                                                 target_cohort_id=430730
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  #####################################################################
  
  
  
  ##aggregation code
  
  writeLines("ac cohort aggregation")
  sql <- SqlRender::renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=1330,
                   target_cohort_set="(13030,31030)")$sql
  sql <- SqlRender::translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("ad cohort aggregation")
  sql <- SqlRender::renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=1430,
                   target_cohort_set="(14030,41030)")$sql
  sql <- SqlRender::translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql)
  
  writeLines("cd cohort aggregation")
  sql <- SqlRender::renderSql(aggregate_sql,
                   cdm_database_schema=cdmDatabaseSchema,
                   target_database_schema=resultsDatabaseSchema,
                   target_cohort_table=exposureTable,
                   target_cohort_id=3430,
                   target_cohort_set="(34030,43030)")$sql
  sql <- SqlRender::translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
  ###################################################################
    ###################################################################
    
    writeLines("ac cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13180,
                     target_cohort_set="(130180,310180)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("ad cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14180,
                     target_cohort_set="(140180,410180)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("cd cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34180,
                     target_cohort_set="(340180,430180)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    ###################################################################
    writeLines("ac cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13365,
                     target_cohort_set="(130365,310365)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("ad cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14365,
                     target_cohort_set="(140365,410365)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("cd cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34365,
                     target_cohort_set="(340365,430365)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    
    ###################################################################
    writeLines("ac cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13730,
                     target_cohort_set="(130730,310730)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("ad cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14730,
                     target_cohort_set="(140730,410730)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("cd cohort aggregation")
    sql <- SqlRender::renderSql(aggregate_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34730,
                     target_cohort_set="(340730,430730)")$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    
    ###Subpopulation#######################################
    gender_sql<-("
                DELETE FROM @target_database_schema.@target_cohort_table WHERE cohort_definition_id=@new_cohort_id

                INSERT INTO @target_database_schema.@target_cohort_table(cohort_definition_id,subject_id,cohort_start_date,cohort_end_date)
                SELECT @new_cohort_id AS cohort_definition_id,coh.subject_id,coh.cohort_start_date,coh.cohort_end_date
                 FROM @target_database_schema.@target_cohort_table coh
                 JOIN @cdm_database_schema.PERSON per
                 ON coh.subject_id = per.person_id
                 WHERE coh.COHORT_DEFINITION_ID = @target_cohort_id
                 AND per.gender_concept_id = @gender_id;")
    
    writeLines("subpopulation_male_AC")
    sql <- SqlRender::renderSql(gender_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13180,
                     new_cohort_id=1318001,
                     gender_id = 8507)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_female_AC")
    sql <- SqlRender::renderSql(gender_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13180,
                     new_cohort_id=1318002,
                     gender_id = 8532)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_male_AD")
    sql <- SqlRender::renderSql(gender_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14180,
                     new_cohort_id=1418001,
                     gender_id = 8507)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_female_AD")
    sql <- SqlRender::renderSql(gender_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14180,
                     new_cohort_id=1418002,
                     gender_id = 8532)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_male_CD")
    sql <- SqlRender::renderSql(gender_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34180,
                     new_cohort_id=3418001,
                     gender_id = 8507)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_female_CD")
    sql <- SqlRender::renderSql(gender_sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34180,
                     new_cohort_id=3418002,
                     gender_id = 8532)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    over60sql<-
        "DELETE FROM @target_database_schema.@target_cohort_table WHERE cohort_definition_id=@new_cohort_id
INSERT INTO @target_database_schema.@target_cohort_table(cohort_definition_id,subject_id,cohort_start_date,cohort_end_date)
SELECT @new_cohort_id AS cohort_definition_id,coh.subject_id,coh.cohort_start_date,coh.cohort_end_date
FROM @target_database_schema.@target_cohort_table coh
JOIN @cdm_database_schema.PERSON per
ON coh.subject_id = per.person_id
	WHERE coh.COHORT_DEFINITION_ID = @target_cohort_id
	  AND YEAR(coh.cohort_start_date)-per.year_of_birth >=60;"
    
    under60sql<-"DELETE FROM @target_database_schema.@target_cohort_table WHERE cohort_definition_id=@new_cohort_id
INSERT INTO @target_database_schema.@target_cohort_table(cohort_definition_id,subject_id,cohort_start_date,cohort_end_date)
SELECT @new_cohort_id AS cohort_definition_id,coh.subject_id,coh.cohort_start_date,coh.cohort_end_date
FROM @target_database_schema.@target_cohort_table coh
JOIN @cdm_database_schema.PERSON per
ON coh.subject_id = per.person_id
	WHERE coh.COHORT_DEFINITION_ID = @target_cohort_id
	  AND YEAR(coh.cohort_start_date)-per.year_of_birth <60;"
    
    writeLines("subpopulation_over_60_AC")
    sql <- SqlRender::renderSql(over60sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13180,
                     new_cohort_id=1318061)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_over_60_AD")
    sql <- SqlRender::renderSql(over60sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14180,
                     new_cohort_id=1418061)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_over_60_CD")
    sql <- SqlRender::renderSql(over60sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34180,
                     new_cohort_id=3418061)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_under_60_AC")
    sql <- SqlRender::renderSql(under60sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=13180,
                     new_cohort_id=1318059)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_under_60_AD")
    sql <- SqlRender::renderSql(under60sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=14180,
                     new_cohort_id=1418059)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_under_60_CD")
    sql <- SqlRender::renderSql(under60sql,
                     cdm_database_schema=cdmDatabaseSchema,
                     target_database_schema=resultsDatabaseSchema,
                     target_cohort_table=exposureTable,
                     target_cohort_id=34180,
                     new_cohort_id=3418059)$sql
    sql <- SqlRender::translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    
    dm_sql<-("
            SELECT DISTINCT person_id as subject_id
                INTO #wo_dm
                FROM @target_database_schema.@target_cohort_table coh
                JOIN @cdm_database_schema.condition_occurrence con
                ON coh.subject_id = con.person_id
                    WHERE con.condition_start_date <= coh.cohort_start_date
                    AND coh.cohort_definition_id = @target_cohort_id
                    AND condition_concept_id in 
                        (select concept_id from @cdm_database_schema.CONCEPT where concept_id in (201820)and invalid_reason is null
                        UNION  select c.concept_id
                        from @cdm_database_schema.CONCEPT c
                        join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in (201820)
                        and c.invalid_reason is null);
            DELETE FROM @target_database_schema.@target_cohort_table WHERE cohort_definition_id=@new_cohort_id;
            
            INSERT INTO @target_database_schema.@target_cohort_table(cohort_definition_id,subject_id,cohort_start_date,cohort_end_date)
            SELECT @new_cohort_id AS cohort_definition_id,coh.subject_id,coh.cohort_start_date,coh.cohort_end_date
             FROM @target_database_schema.@target_cohort_table coh
             WHERE 
            coh.cohort_definition_id = @target_cohort_id
            AND subject_id NOT IN (SELECT subject_id from #wo_dm);
            DROP TABLE #wo_dm")
    
    writeLines("subpopulation_without_DM_AC")
    sql <- SqlRender::renderSql(dm_sql,
                                cdm_database_schema=cdmDatabaseSchema,
                                target_database_schema=resultsDatabaseSchema,
                                target_cohort_table=exposureTable,
                                target_cohort_id=13180,
                                new_cohort_id=1318011)$sql
    sql <- SqlRender::translateSql(sql,
                                   targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_without_DM_AD")
    sql <- SqlRender::renderSql(dm_sql,
                                cdm_database_schema=cdmDatabaseSchema,
                                target_database_schema=resultsDatabaseSchema,
                                target_cohort_table=exposureTable,
                                target_cohort_id=14180,
                                new_cohort_id=1418011)$sql
    sql <- SqlRender::translateSql(sql,
                                   targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
    writeLines("subpopulation_without_DM_CD")
    sql <- SqlRender::renderSql(dm_sql,
                                cdm_database_schema=cdmDatabaseSchema,
                                target_database_schema=resultsDatabaseSchema,
                                target_cohort_table=exposureTable,
                                target_cohort_id=34180,
                                new_cohort_id=3418011)$sql
    sql <- SqlRender::translateSql(sql,
                                   targetDialect=connectionDetails$dbms)$sql
    DatabaseConnector::executeSql(conn, sql)
    
  
  writeLines("outcome_cohort.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("outcome_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 outcomeTable=outcomeTable)
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ESRD.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ESRD_cohort.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdm_database_schema=cdmDatabaseSchema,
                                                 target_database_schema=resultsDatabaseSchema,
                                                 target_cohort_table=outcomeTable,
                                                 target_cohort_id = 6
                                                 )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("negative_control.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("negative_control.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 outcomeTable=outcomeTable)
  
  DatabaseConnector::executeSql(conn, renderedSql)
  
}

addCohortNames <- function(data, IdColumnName = "outcomeId", nameColumnName = "outcomeName") {
  idToName <- data.frame(cohortId = c(1330,1430,3430,13180,14180,34180,13365,14365,34365,13730,14730,34730,
                                      1318001,1418001,3418001,1318002,1418002,3418002,1318061,1418061,3418061,1318059,1418059,3418059,
                                      1318011,1418011,3418011),
                         cohortName = c("AC30","AD30","CD30","AC180","AD180","CD180","AC365","AD365","CD365","AC730","AD730","CD730",
                                        "ACmale","ADmale","CDmale","ACfemale","ADfemale","CDfemale",
                                        "AC60ormore","AD60ormore","CD60ormore","ACunder60","ADunder60","CDunder60",
                                        "AC_wo_DM","AD_wo_DM","CD_wo_DM"))
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