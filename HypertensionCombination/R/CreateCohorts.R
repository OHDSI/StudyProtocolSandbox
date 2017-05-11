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
  
  writeLines("ac180_wo_hx.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac180_wo_hx.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 13,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ac180_wo_hx_55_or_more.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac180_wo_hx_55_or_more.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 1356,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ac180_wo_hx_less_than_55.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac180_wo_hx_less_than_55.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 1354,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ac180_wo_hx_itt.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac180_wo_hx_itt.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 131,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ac180_wo_hx_itt_55_or_more.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac180_wo_hx_itt_55_or_more.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 13156,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ac180_wo_hx_itt_less_than_55.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ac180_wo_hx_itt_less_than_55.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 13154,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad180_wo_hx.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad180_wo_hx.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 14,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad180_wo_hx_55_or_more.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad180_wo_hx_55_or_more.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 1456,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad180_wo_hx_less_than_55.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad180_wo_hx_less_than_55.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 1454,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad180_wo_hx_itt.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad180_wo_hx_itt.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 141,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)

  writeLines("ad180_wo_hx_itt_55_or_more.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad180_wo_hx_itt_55_or_more.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 14156,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("ad180_wo_hx_itt_less_than_55.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("ad180_wo_hx_itt_less_than_55.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 14154,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd180_wo_hx.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd180_wo_hx.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 34,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable  
                                                 )
  
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd180_wo_hx_55_or_more.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd180_wo_hx_55_or_more.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 3456,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable  
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd180_wo_hx_less_than_55.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd180_wo_hx_less_than_55.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 3454,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable  
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd180_wo_hx_itt.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd180_wo_hx_itt.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 341,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable  
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd180_wo_hx_itt_55_or_more.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd180_wo_hx_itt_55_or_more.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 34156,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable  
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("cd180_wo_hx_itt_less_than_55.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("cd180_wo_hx_itt_less_than_55.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 target_cohort_id = 34154,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable  
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
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
  idToName <- data.frame(cohortId = c(13, 1354, 1356, 131, 13154, 13156, 14, 1454, 1456, 141, 14154, 14156, 34, 3454, 3456, 341, 34154, 34156),
                         cohortName = c("AC","AC less than 55", "AC 55 or more", 
                                        "AC_ITT", "AC_ITT less than 55","AC_ITT 55 or more",
                                        "AD","AD less than 55","AD 55 or more",
                                        "AD_ITT", "AD_ITT less than 55","AD_ITT 55 or more",
                                        "CD", "CD less than 55","CD 55 or more",
                                        "CD_ITT","CD_ITT less than 55","CD_ITT 55 or more"))
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