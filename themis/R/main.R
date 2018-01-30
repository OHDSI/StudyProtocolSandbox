execute<-function(connection) {
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "units-larger.sql",
                                           packageName = "themis",
                                           dbms = attr(connection, "dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable)
 cat(sql)
 return(sql)
}