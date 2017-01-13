createCohorts<-function(connectionDetails,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema,
                        exposureTable,
                        outcomeTable){
  conn<-DatabaseConnector::connect(connectionDetails)
  
  writeLines("drop_tables.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("drop_tables.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
  )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  writeLines("htn_combi_cohort_ver0.6.sql")
  renderedSql<-SqlRender::loadRenderTranslateSql("htn_combi_cohort_ver0.6.sql",
                                                 packageName="HypertensionCombination",
                                                 dbms=connectionDetails$dbms,
                                                 cdmDatabaseSchema=cdmDatabaseSchema,
                                                 resultsDatabaseSchema=resultsDatabaseSchema,
                                                 exposureTable=exposureTable,
                                                 outcomeTable=outcomeTable
                                                 )
  DatabaseConnector::executeSql(conn, renderedSql)
  
  RJDBC::dbDisconnect(conn)
}

addCohortNames <- function(data, IdColumnName = "outcomeId", nameColumnName = "outcomeName") {
  idToName <- data.frame(cohortId = c(12, 13, 14, 23, 24, 34),
                         cohortName = c("AB","AC","AD","BC","BD","CD"))
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