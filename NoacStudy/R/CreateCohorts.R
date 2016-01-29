

#' Create the exposure and outcome cohorts
#'
#' @details
#' This function will create the exposure and outcome cohorts following the definitions included in
#' this package.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param workDatabaseSchema   Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param studyCohortTable     The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param cdmVersion           Version of the CDM. Can be "4" or "5"
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)
#'
#' @export
createCohorts <- function(connectionDetails,
                          cdmDatabaseSchema,
                          workDatabaseSchema,
                          studyCohortTable = "cohort_noac",
                          studyCohortDefinitionTable = "cohort_definition_noac",
                          oracleTempSchema = NULL,
                          cdmVersion = 5,
                          outputFolder) {
  sqlFolder <- file.path(outputFolder, "sql")
  if (!file.exists(sqlFolder)) {
    dir.create(sqlFolder)
  }
  
  #create table shells to populate
  connection <- DatabaseConnector::connect(connectionDetails)
  sql <- SqlRender::loadRenderTranslateSql("create_tables.sql", 
                                           "Rivaroxaban", 
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           target_database_schema=workDatabaseSchema, 
                                           target_cohort_definition_table=studyCohortDefinitionTable, 
                                           target_cohort_table=studyCohortTable)
  SqlRender::writeSql(sql, file.path(sqlFolder, "create_tables.sql"))
  DatabaseConnector::executeSql(connection,sql)
  
  #populate cohort definitions and cohorts 
  cohortDefinitionsFile <- system.file("settings", "cohorts.csv", package = "Rivaroxaban")
  cohortDefinitions <- read.csv(cohortDefinitionsFile)
  cohortDefinitions <- cohortDefinitions[cohortDefinitions$cohortType %in% c(0,1),]
  for(i in 1:nrow(cohortDefinitions)) {
    writeLines(paste("Starting work on cohort definition ",cohortDefinitions$cohortDefinitionId[i]," (",cohortDefinitions$cohortDefinitionName[i],")",sep=""))
    
    cohortDefinitionSql <- "DELETE FROM @target_database_schema.@target_cohort_definition_table WHERE COHORT_DEFINITION_ID = @cohort_definition_id;\n
     INSERT INTO @target_database_schema.@target_cohort_definition_table VALUES (@cohort_definition_id, '@cohort_definition_name', @cohortType); \n\n"
    
    sql <- SqlRender::renderSql(cohortDefinitionSql, 
                         target_database_schema=workDatabaseSchema,
                         target_cohort_definition_table=studyCohortDefinitionTable, 
                         cohort_definition_id = cohortDefinitions$cohortDefinitionId[i], 
                         cohort_definition_name = cohortDefinitions$cohortDefinitionName[i], 
                         cohortType=cohortDefinitions$cohortType[i])$sql
    
    sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms, oracleTempSchema = oracleTempSchema)$sql
    DatabaseConnector::executeSql(connection,sql, progressBar = FALSE, reportOverallTime = FALSE) 
    
    sql <- SqlRender::loadRenderTranslateSql(cohortDefinitions$filename[i], 
                                             "Rivaroxaban", 
                                             dbms = connectionDetails$dbms,
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             target_database_schema=workDatabaseSchema, 
                                             target_cohort_table=studyCohortTable,
                                             cohort_definition_id = cohortDefinitions$cohortDefinitionId[i])
    SqlRender::writeSql(sql, file.path(sqlFolder, cohortDefinitions$filename[i]))
    DatabaseConnector::executeSql(connection,sql)
  }
  writeLines("Starting creating negative control")
  sql <- SqlRender::loadRenderTranslateSql("create_negative_controls.sql", 
                                           "Rivaroxaban", 
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           target_database_schema=workDatabaseSchema, 
                                           target_cohort_table=studyCohortTable,
                                           target_cohort_definition_table = studyCohortDefinitionTable)
  
  SqlRender::writeSql(sql, file.path(sqlFolder, "create_negative_controls.sql"))
  DatabaseConnector::executeSql(connection,sql)
  
  # Check number of subjects per cohort:
  sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @work_database_schema.@study_cohort_table GROUP BY cohort_definition_id"
  sql <- SqlRender::renderSql(sql,
                              work_database_schema = workDatabaseSchema,
                              study_cohort_table = studyCohortTable)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
  counts <- DatabaseConnector::querySql(connection, sql)
  names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
  write.csv(counts, file.path(outputFolder, "CohortCounts.csv"))
  print(counts)
  
  DBI::dbDisconnect(connection)
  
  writeLines("Finished all cohorts")
}