library(CohortMethod) 
library(SqlRender)
library(EmpiricalCalibration)

library(ff)
options("fftempdir"="C:/Users/Songheui OH/Documents/ffTEMP")

connectionDetails<-createConnectionDetails(dbms="",
                                           server="",
                                           schema="",
                                           user="",
                                           password="")
cdm_database_schema <- ""
target_database_schema <- ""
target_cohort_table <- ""
target_cohort_id <-           # int???
  comparator_cohort_id<-         # int???
  outcome_cohort_id <-          # int???
  cdmVersion <- "5" 
connection<-connect(connectionDetails)  

#===========================================
# (T)
#===========================================

sql <- readSql(".sql") #local
sql <- renderSql(sql,
                 cdm_database_schema=cdm_database_schema,
                 target_database_schema=target_database_schema,
                 target_cohort_table=target_cohort_table,
                 target_cohort_id=target_cohort_id
)$sql
sql <- translateSql(sql,
                    targetDialect=connectionDetails$dbms)$sql
executeSql(connection,sql)



#===========================================
# (C)
#===========================================


sql <- readSql(".sql") #local
sql <- renderSql(sql,
                 cdm_database_schema=cdm_database_schema,
                 target_database_schema=target_database_schema,
                 target_cohort_table=target_cohort_table,
                 target_cohort_id=comparator_cohort_id
)$sql
sql <- translateSql(sql,
                    targetDialect=connectionDetails$dbms)$sql
executeSql(connection,sql)

#===========================================
# (O)
#===========================================

sql <- readSql(".sql") #local
sql <- renderSql(sql,
                 cdm_database_schema=cdm_database_schema,
                 target_database_schema=target_database_schema,
                 target_cohort_table=target_cohort_table,
                 target_cohort_id=outcome_cohort_id
)$sql
sql <- translateSql(sql,
                    targetDialect=connectionDetails$dbms)$sql
executeSql(connection,sql)



#------------------------------------------------------------

cdm_database_schema <- ""
target_database_schema <- ""
target_cohort_table <- ""
target_cohort_id <-           # int???
  comparator_cohort_id<-         # int???
  outcome_cohort_id <-          # int???
  cdmVersion <- "5" 
connection<-connect(connectionDetails)  

#===========================================
# (T)
#===========================================

sql <- ("") 
sql <- renderSql(sql,
                 cdm_database_schema=cdm_database_schema,
                 target_database_schema=target_database_schema,
                 target_cohort_table=target_cohort_table,
                 target_cohort_id=target_cohort_id
)$sql
sql <- translateSql(sql,
                    targetDialect=connectionDetails$dbms)$sql
executeSql(connection,sql)



#===========================================
# (C)
#===========================================


sql <- ("") 
sql <- renderSql(sql,
                 cdm_database_schema=cdm_database_schema,
                 target_database_schema=target_database_schema,
                 target_cohort_table=target_cohort_table,
                 target_cohort_id=comparator_cohort_id
)$sql
sql <- translateSql(sql,
                    targetDialect=connectionDetails$dbms)$sql
executeSql(connection,sql)

#===========================================
# (O)
#===========================================

sql <- ("") 
sql <- renderSql(sql,
                 cdm_database_schema=cdm_database_schema,
                 target_database_schema=target_database_schema,
                 target_cohort_table=target_cohort_table,
                 target_cohort_id=outcome_cohort_id
)$sql
sql <- translateSql(sql,
                    targetDialect=connectionDetails$dbms)$sql
executeSql(connection,sql)

