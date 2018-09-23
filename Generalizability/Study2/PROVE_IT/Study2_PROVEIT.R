
# THANK YOU FOR PARTICIPATING IN THIS RESEARCH PROJECT!
# TO PARTICIPATE, PLEASE UPDATE THE CODE BELOW WHERE MARKED 
# "make your change!" THESE CHANGES INCLUDE:
#   - SETTING THE WORKING DIRECTORY SO THE FINAL FILE IN THE PATH IS "/Study2"
#   - INPUTTING THE OHDSI SCHEMA (cdmDatabaseSchema, generally 'public')
#   - INPUTTING THE NAME OF THE SCHEMA THAT WILL HOLD THE STUDY DATA (resultsDatabaseSchema)
#   - INPUTTING YOUR SQL DATABASE CONNECTION INFORMATION
# 
# AFTER RUNNING THE SCRIPT, PLEASE ZIP THE FILE "Results_To_Share" AND SEND
# TO STUDY COORDINATOR, AMELIA J AVERITT AT aja2149@cumc.columbia.edu

##########################################################
# INSTALLATION & LOAD
##########################################################

#Install packages, Require libraries. 
install.packages("drat", dependencies = TRUE)
install.packages("xlsx", dependencies = TRUE)
drat::addRepo(c("OHDSI","cloudyr"))
install.packages("devtools", dependencies = TRUE )
install.packages("rJava", dependencies = TRUE)
install.packages("SqlRender", dependencies = TRUE )
install.packages("DatabaseConnector", dependencies = TRUE )

library(rJava)
library(SqlRender)
library(DatabaseConnector)
library(stringr)
library(xlsx)

########################################################## 
# CREATING OUTPUT STRUCTURE
##########################################################

PROVEIT_Indi_Output <- data.frame("metric", "count", "min", "IQR25", "median", 
                                     "IQR75", "max", "mean", "stddev", 
                                     stringsAsFactors=FALSE)

PROVEIT_wElig_Output <- data.frame("metric", "count", "min", "IQR25", "median", 
                                      "IQR75", "max", "mean", "stddev", 
                                      stringsAsFactors=FALSE)

########################################################## 
# SETUP THE CONNECTION
##########################################################

WorkingDir = "~/Desktop/AIM_1A_v1/Study2" #make your change!
setwd(WorkingDir)

#Input the location of the Project folder (workFolder) and the name of the OHDSI schema (cdmDatabaseSchema)
cdmDatabaseSchema <- "public" #make your change!
resultsDatabaseSchema <- "" #make your change!
trialTable <- "Study2_PROVE_IT"
cdmVersion <- "5" 

#Insert connection details here
#dbms = The SQL flavor attached to your OHDSI database. Options include, "oracle", "postgresql", "pdw", "impala", "netezza, "redshift"
connectionDetails <- createConnectionDetails(dbms = "",  #make your change!
                                             user = "",  #make your change!
                                             password = "",  #make your change!
                                             port = "",  #make your change!
                                             server = "")  #make your change! 

conn <- DatabaseConnector::connect(connectionDetails)

########################################################################
# SETTING UP TABLE STRUCTURES 
########################################################################

# Create table structure to hold individual study cohort data
sql <- "IF OBJECT_ID('@work_database_schema.@study_cohort_table', 'U') IS NOT NULL\n  DROP TABLE @work_database_schema.@study_cohort_table;\n    CREATE TABLE @work_database_schema.@study_cohort_table (cohort_definition_id INT, subject_id BIGINT, cohort_start_date DATE, cohort_end_date DATE);"
sql <- SqlRender::renderSql(sql,
                            work_database_schema = resultsDatabaseSchema,
                            study_cohort_table = trialTable)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql 
DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)

#Drop temporary table, Codesets
sql_drop <- "DISCARD TEMP"
DatabaseConnector::executeSql(conn, sql_drop, progressBar = FALSE, reportOverallTime = FALSE)

########################################################################
# READING IN INDICATION ONLY COHORT # 
########################################################################

writeLines("- Creating indication only cohort")
sql_indi <- paste(readLines("PROVE_IT/SQL/PROVEIT_Indication_Only.sql"), collapse = " ")
sql_indi <- SqlRender::renderSql(sql_indi,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = resultsDatabaseSchema,
                                target_cohort_table = trialTable,
                                cohort_definition_id = 1)$sql
sql_indi <- SqlRender::translateSql(sql_indi, targetDialect = connectionDetails$dbms)$sql
DatabaseConnector::executeSql(conn, sql_indi, progressBar = FALSE, reportOverallTime = FALSE)

########################################################################
# READING IN COHORT SUBJECT TO ELIGIBILITY CRITERIA #  
########################################################################

writeLines("- Creating with Elig cohort")
sql_elig <- paste(readLines("PROVE_IT/SQL/PROVEIT_with_Eligibility_Criteria.sql"), collapse = " ")
sql_elig <- SqlRender::renderSql(sql_elig,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = resultsDatabaseSchema,
                                target_cohort_table = trialTable,
                                cohort_definition_id = 0)$sql
sql_elig <- SqlRender::translateSql(sql_elig, targetDialect = connectionDetails$dbms)$sql
DatabaseConnector::executeSql(conn, sql_elig, progressBar = TRUE, reportOverallTime = FALSE)

########################################################################
# QUERYING DATA AND POPULATING OUTPUT TABLES #  
########################################################################

filenames_indi <- list.files(path=file.path(WorkingDir, "PROVE_IT/SQL/Queries/Indication_Only"))
filenames_wElig <- list.files(path=file.path(WorkingDir, "PROVE_IT/SQL/Queries/With_Eligibility_Criteria"))

writeLines("Querying for Indication Only Data")

for(i in filenames_indi){
  print(i)
  temp <- file.path("PROVE_IT/SQL/Queries/Indication_Only",i)

  sql_OI <- paste(readLines(temp), collapse = " ")
  sql_OI <- gsub('\t',"", sql_OI)
  sql_OI <- SqlRender::renderSql(sql_OI,
                                  cdm_database_schema = cdmDatabaseSchema,
                                  target_database_schema = resultsDatabaseSchema,
                                  target_cohort_table = trialTable)$sql
  sql_OI <- SqlRender::translateSql(sql_OI, targetDialect = connectionDetails$dbms)$sql
  x <- querySql(conn, sql_OI) 
  colnames(x) <- colnames(PROVEIT_Indi_Output)  
  
  PROVEIT_Indi_Output <- rbind(PROVEIT_Indi_Output, x) 
  
} #end indi for loop
 
writeLines("Querying for with Eligibility Data") 

for(i in filenames_wElig){ 
  print(i)
  temp <- file.path("PROVE_IT/SQL/Queries/With_Eligibility_Criteria",i)
  
  sql_OwE <- paste(readLines(temp), collapse = " ") 
  sql_OwE <- gsub('\t',"", sql_OwE)
  sql_OwE <- SqlRender::renderSql(sql_OwE,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = resultsDatabaseSchema,
                                target_cohort_table = trialTable)$sql
  sql_OwE <- SqlRender::translateSql(sql_OwE, targetDialect = connectionDetails$dbms)$sql
  y <- querySql(conn, sql_OwE) 
  colnames(y) <- colnames(PROVEIT_wElig_Output) 
  
  PROVEIT_wElig_Output <- rbind(PROVEIT_wElig_Output, y)
  
} #end wElig for loop 

########################################################################
# WRITE OUT FILES #  
########################################################################

write.xlsx(PROVEIT_Indi_Output, file="Results_To_Share/Study2_PROVEIT_Output.xlsx", sheetName="Indication Only", row.names=FALSE)
write.xlsx(PROVEIT_wElig_Output, file="Results_To_Share/Study2_PROVEIT_Output.xlsx", sheetName="With Eligibility Criteria", append=TRUE, row.names=FALSE)


