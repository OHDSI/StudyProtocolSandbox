
# THANK YOU FOR PARTICIPATING IN THIS RESEARCH PROJECT!
# TO PARTICIPATE, PLEASE UPDATE THE CODE BELOW WHERE MARKED 
# "make your change!" THESE CHANGES INCLUDE:
#   - SETTING THE WORKING DIRECTORY SO THE FINAL FILE IN THE PATH IS "/Study1"
#   - INPUTTING THE OHDSI SCHEMA (cdmDatabaseSchema, generally 'public')
#   - INPUTTING THE NAME OF THE SCHEMA THAT WILL HOLD THE STUDY DATA (resultsDatabaseSchema)
#   - INPUTTING THE NAME OF YOUR RESEARCH SITE
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
install.packages("CohortMethod", dependencies = TRUE)
install.packages("stringr", dependencies = TRUE)
install.packages("reshape2", dependencies = TRUE)
install.packages("ggplot2", dependencies = TRUE)
install.packages("DescTools", dependencies = TRUE)

library(reshape2)
library(ggplot2)
library(rJava)
library(SqlRender)
library(DatabaseConnector)
library(stringr)
library(CohortMethod)
library(xlsx) 
library(DescTools)
library(FeatureExtraction)

##########################################################
# CREATING OUTPUT STRUCTURES
##########################################################

Study1_NCT01189890_output <- data.frame("Iteration",
                                 "Unadjusted_OR", "Unadjusted_LL", "Unadjusted_UL", 
                                 "Adjusted_S_OR", "Adjusted_S_LL", "Adjusted_S_UL", 
                                 "Adjusted_M_OR", "Adjusted_M_LL", "Adjusted_M_UL", 
                                 stringsAsFactors=FALSE)

Study1_NCT01189890_Counts <- data.frame("Iteration",
                                 "Sita_Hypo", 
                                 "Sita_NoHypo", 
                                 "Glime_hypo", 
                                 "Glime_NoHypo", 
                                  stringsAsFactors=FALSE)

########################################################## 
# SETUP THE CONNECTION
##########################################################

#Set Working Directory 
WorkingDir = "~/Desktop/AIM_1A_v1/Study1" #make your change!
TempDir = 'temp'
setwd(WorkingDir)

#Create Folder in Working Directory called 'temp' if one does not exist. Set the fftempdir option to temp directory
if (file.exists(TempDir)){
  options(fftempdir = file.path(WorkingDir, TempDir))
} else {
  dir.create(file.path(WorkingDir, TempDir))
  options(fftempdir = file.path(WorkingDir, TempDir))
}

#Input the name of the OHDSI schema (cdmDatabaseSchema), schema that will hold cohort tables (resultsDatabaseSchema), and the name of your study site
cdmDatabaseSchema <- "public" #make your change!
resultsDatabaseSchema <- "" #make your change!
trialTable <- "Study1_NCT01189890"
cdmVersion <- "5" 
siteName = "" #make your change!

#Insert connection details here
#dbms = The SQL flavor attached to your OHDSI database. Options include, "oracle", "postgresql", "pdw", "impala", "netezza, "redshift"
connectionDetails <- createConnectionDetails(dbms = "", #make your change!
                                             user = "", #make your change!
                                             password = "", #make your change!
                                             port = "", #make your change!
                                             server = "") #make your change!

conn <- DatabaseConnector::connect(connectionDetails)

#########################################################################
#CREATE COHORT TABLES
#########################################################################

# Create study cohort table structure:
writeLines("Creating Cohort Table")
sql <- "IF OBJECT_ID('@work_database_schema.@target_cohort_table', 'U') IS NOT NULL\n  DROP TABLE @work_database_schema.@target_cohort_table;\n    CREATE TABLE @work_database_schema.@target_cohort_table (cohort_definition_id INT, subject_id BIGINT, cohort_start_date DATE, cohort_end_date DATE);"
sql <- SqlRender::renderSql(sql,
                            work_database_schema = resultsDatabaseSchema,
                            target_cohort_table = trialTable)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql 
DatabaseConnector::executeSql(conn, sql, progressBar = FALSE, reportOverallTime = FALSE)

#Drop temporary table, Codesets  subs
sql_drop <- "DISCARD TEMP"
DatabaseConnector::executeSql(conn, sql_drop, progressBar = FALSE, reportOverallTime = FALSE)

#########################################################################
#POPULATE COHORT TABLE WITH OUTCOME-POSITIVE DATA
#########################################################################

writeLines("- Creating outcome cohort")
sql_out <- paste(readLines('NCT01189890/SQL/FINAL_NCT01189890_hypoglycemia.sql'), collapse = " ")
sql_out <- SqlRender::renderSql(sql_out,
                                cdm_database_schema = cdmDatabaseSchema,
                                target_database_schema = resultsDatabaseSchema,
                                target_cohort_table = trialTable,
                                cohort_definition_id = 3)$sql
sql_out <- SqlRender::translateSql(sql_out, targetDialect = connectionDetails$dbms)$sql
DatabaseConnector::executeSql(conn, sql_out, progressBar = TRUE, reportOverallTime = FALSE)

#########################################################################
#ITERATE THROUGH THE FILES WITH INCREASING NUMBER OF ELIGIBILITY CRITERIA
#########################################################################

for (i in 1:17 ) { 
  temp = str_pad(i, 2, "left", pad="0")
  
  #########################################################################
  #CLEARING COHORT TABLE AT EACH NEW ITERATION
  #########################################################################
  
  writeLines("Clearing Cohort Table")
  clear_qry <- "DELETE FROM @work_database_schema.@target_cohort_table WHERE cohort_definition_id = 1 or cohort_definition_id = 2;"
  clear_qry <- SqlRender::renderSql(clear_qry,
                                    work_database_schema = resultsDatabaseSchema,
                                    target_cohort_table = trialTable)$sql
  clear_qry <- SqlRender::translateSql(clear_qry, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, clear_qry, progressBar = FALSE, reportOverallTime = FALSE)
  
  #########################################################################
  #INTERVENTION
  #########################################################################
  
  writeLines(paste('Populating Study Cohort - Sitagliptin: number ', toString(temp), sep = "", collapse=NULL))
  sita = paste('NCT01189890/SQL/FINAL_NCT01189890_sitagliptin_', toString(temp), '.sql', sep="", collapse=NULL)
  sql_sita <- paste(readLines(sita), collapse = " ")
  sql_sita <- SqlRender::renderSql(sql_sita,
                                    cdm_database_schema = cdmDatabaseSchema,
                                    target_database_schema = resultsDatabaseSchema,
                                    target_cohort_table = trialTable,
                                    cohort_definition_id = 1)$sql
  sql_sita <- SqlRender::translateSql(sql_sita, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql_sita, progressBar = TRUE, reportOverallTime = FALSE)
  
  #########################################################################
  #COMPARATOR
  #########################################################################
  
  writeLines(paste('Populating Study Cohort - Glimepiride: number ', toString(temp), sep = "", collapse=NULL))
  glime = paste('NCT01189890/SQL/FINAL_NCT01189890_glimepiride_', toString(temp), '.sql', sep="", collapse=NULL)
  sql_glime <- paste(readLines(glime), collapse = " ")
  sql_glime <- SqlRender::renderSql(sql_glime,
                                     cdm_database_schema = cdmDatabaseSchema,
                                     target_database_schema = resultsDatabaseSchema,
                                     target_cohort_table = trialTable,
                                     cohort_definition_id = 2)$sql
  sql_glime <- SqlRender::translateSql(sql_glime, targetDialect = connectionDetails$dbms)$sql
  DatabaseConnector::executeSql(conn, sql_glime, progressBar = TRUE, reportOverallTime = FALSE)
  
  #########################################################################
  #CHECK COUNTS
  #########################################################################
  
  sql_count <- paste("SELECT cohort_definition_id, COUNT(*) as count",
                     "FROM @resultsDatabaseSchema.@target_cohort_table",
                     "GROUP BY cohort_definition_id")
  sql_count <- renderSql(sql_count, resultsDatabaseSchema = resultsDatabaseSchema, target_cohort_table = trialTable)$sql
  sql_count <- translateSql(sql_count, targetDialect = connectionDetails$dbms)$sql
  querySql(conn, sql_count)
  
  #########################################################################
  #COHORT METHOD
  #########################################################################
  
  # Get sitagliptin & descendants for exclusion: 1580747 sitagliptin and 1597756 glimepiride
  excludedConcepts <- c(1597756, 1580747)
  includedConcepts <- c()
  
  covSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = TRUE,
                                                                  useDemographicsAge = TRUE, useDemographicsAgeGroup = TRUE,
                                                                  useDemographicsRace = TRUE, useDemographicsEthnicity = TRUE,
                                                                  useDemographicsIndexYear = TRUE, useDemographicsIndexMonth = TRUE,
                                                                  useDemographicsPriorObservationTime = TRUE,
                                                                  useDemographicsPostObservationTime = TRUE,
                                                                  useDemographicsTimeInCohort = TRUE,
                                                                  useDemographicsIndexYearMonth = TRUE,
                                                                  useConditionOccurrenceAnyTimePrior = TRUE,
                                                                  useConditionOccurrenceLongTerm = TRUE,
                                                                  useConditionOccurrenceMediumTerm = TRUE,
                                                                  useConditionOccurrenceShortTerm = TRUE,
                                                                  useConditionOccurrenceInpatientAnyTimePrior = TRUE,
                                                                  useConditionOccurrenceInpatientLongTerm = TRUE,
                                                                  useConditionOccurrenceInpatientMediumTerm = TRUE,
                                                                  useConditionOccurrenceInpatientShortTerm = TRUE,
                                                                  useConditionEraAnyTimePrior = TRUE, useConditionEraLongTerm = TRUE,
                                                                  useConditionEraMediumTerm = TRUE, useConditionEraShortTerm = TRUE,
                                                                  useConditionEraOverlapping = TRUE, useConditionEraStartLongTerm = TRUE,
                                                                  useConditionEraStartMediumTerm = TRUE,
                                                                  useConditionEraStartShortTerm = TRUE,
                                                                  useConditionGroupEraAnyTimePrior = TRUE,
                                                                  useConditionGroupEraLongTerm = TRUE,
                                                                  useConditionGroupEraMediumTerm = TRUE,
                                                                  useConditionGroupEraShortTerm = TRUE,
                                                                  useConditionGroupEraOverlapping = TRUE,
                                                                  useConditionGroupEraStartLongTerm = TRUE,
                                                                  useConditionGroupEraStartMediumTerm = TRUE,
                                                                  useConditionGroupEraStartShortTerm = TRUE,
                                                                  useDrugExposureAnyTimePrior = TRUE, useDrugExposureLongTerm = TRUE,
                                                                  useDrugExposureMediumTerm = TRUE, useDrugExposureShortTerm = TRUE,
                                                                  useDrugEraAnyTimePrior = TRUE, useDrugEraLongTerm = TRUE,
                                                                  useDrugEraMediumTerm = TRUE, useDrugEraShortTerm = TRUE,
                                                                  useDrugEraOverlapping = TRUE, useDrugEraStartLongTerm = TRUE,
                                                                  useDrugEraStartMediumTerm = TRUE, useDrugEraStartShortTerm = TRUE,
                                                                  useDrugGroupEraAnyTimePrior = TRUE, useDrugGroupEraLongTerm = TRUE,
                                                                  useDrugGroupEraMediumTerm = TRUE, useDrugGroupEraShortTerm = TRUE,
                                                                  useDrugGroupEraOverlapping = TRUE, useDrugGroupEraStartLongTerm = TRUE,
                                                                  useDrugGroupEraStartMediumTerm = TRUE,
                                                                  useDrugGroupEraStartShortTerm = TRUE,
                                                                  useProcedureOccurrenceAnyTimePrior = TRUE,
                                                                  useProcedureOccurrenceLongTerm = TRUE,
                                                                  useProcedureOccurrenceMediumTerm = TRUE,
                                                                  useProcedureOccurrenceShortTerm = TRUE,
                                                                  useDeviceExposureAnyTimePrior = TRUE, useDeviceExposureLongTerm = TRUE,
                                                                  useDeviceExposureMediumTerm = TRUE, useDeviceExposureShortTerm = TRUE,
                                                                  useMeasurementAnyTimePrior = TRUE, useMeasurementLongTerm = TRUE,
                                                                  useMeasurementMediumTerm = TRUE, useMeasurementShortTerm = TRUE,
                                                                  useMeasurementValueAnyTimePrior = TRUE,
                                                                  useMeasurementValueLongTerm = TRUE,
                                                                  useMeasurementValueMediumTerm = TRUE,
                                                                  useMeasurementValueShortTerm = TRUE,
                                                                  useMeasurementRangeGroupAnyTimePrior = TRUE,
                                                                  useMeasurementRangeGroupLongTerm = TRUE,
                                                                  useMeasurementRangeGroupMediumTerm = TRUE,
                                                                  useMeasurementRangeGroupShortTerm = TRUE,
                                                                  useObservationAnyTimePrior = TRUE, useObservationLongTerm = TRUE,
                                                                  useObservationMediumTerm = TRUE, useObservationShortTerm = TRUE,
                                                                  useCharlsonIndex = TRUE, useDcsi = TRUE, useChads2 = TRUE,
                                                                  useChads2Vasc = TRUE, useDistinctConditionCountLongTerm = TRUE,
                                                                  useDistinctConditionCountMediumTerm = TRUE,
                                                                  useDistinctConditionCountShortTerm = TRUE,
                                                                  useDistinctIngredientCountLongTerm = TRUE,
                                                                  useDistinctIngredientCountMediumTerm = TRUE,
                                                                  useDistinctIngredientCountShortTerm = TRUE,
                                                                  useDistinctProcedureCountLongTerm = TRUE,
                                                                  useDistinctProcedureCountMediumTerm = TRUE,
                                                                  useDistinctProcedureCountShortTerm = TRUE,
                                                                  useDistinctMeasurementCountLongTerm = TRUE,
                                                                  useDistinctMeasurementCountMediumTerm = TRUE,
                                                                  useDistinctMeasurementCountShortTerm = TRUE,
                                                                  useVisitCountLongTerm = TRUE, useVisitCountMediumTerm = TRUE,
                                                                  useVisitCountShortTerm = TRUE, longTermStartDays = -365,
                                                                  mediumTermStartDays = -180, shortTermStartDays = -30, endDays = 0,
                                                                  includedCovariateConceptIds = includedConcepts, addDescendantsToInclude = TRUE,
                                                                  excludedCovariateConceptIds = excludedConcepts, addDescendantsToExclude = TRUE,
                                                                  includedCovariateIds = c())
  
  cohortMethodData <- getDbCohortMethodData(connectionDetails = connectionDetails,
                                            cdmDatabaseSchema = cdmDatabaseSchema,
                                            targetId = 1,
                                            comparatorId = 2,
                                            outcomeIds = 3,
                                            studyStartDate = "",
                                            studyEndDate = "",
                                            exposureDatabaseSchema = resultsDatabaseSchema,
                                            exposureTable = trialTable,
                                            outcomeDatabaseSchema = resultsDatabaseSchema,
                                            outcomeTable = trialTable,
                                            cdmVersion = cdmVersion,
                                            excludeDrugsFromCovariates = T,
                                            firstExposureOnly = F,
                                            removeDuplicateSubjects = F,
                                            restrictToCommonPeriod = F,
                                            washoutPeriod = 0,
                                            maxCohortSize = 0, #indicates no maximum size
                                            covariateSettings = covSettings) 
  
  # Defining the study population
  studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
                                    outcomeId = 3,
                                    firstExposureOnly = F,
                                    restrictToCommonPeriod = F,
                                    washoutPeriod = 0,
                                    removeDuplicateSubjects = F,
                                    removeSubjectsWithPriorOutcome = F, 
                                    minDaysAtRisk = 0, #mindaysatrisk!
                                    riskWindowStart = 1,
                                    addExposureDaysToStart = F,
                                    riskWindowEnd = 210,
                                    addExposureDaysToEnd = F) 
  
  ##########################################################
  # UNADJUSTED ESTIMATES 
  ##########################################################
  
  sita_hypo = nrow(subset(studyPop, treatment==1 & outcomeCount>=1))
  sita_NoHypo = nrow(subset(studyPop, treatment==1 & outcomeCount==0))
  glime_hypo = nrow(subset(studyPop, treatment==0 & outcomeCount>=1))
  glime_NoHypo = nrow(subset(studyPop, treatment==0 & outcomeCount==0))
  M <- matrix(c(sita_hypo, sita_NoHypo, glime_hypo, glime_NoHypo), nrow=2, ncol=2)
  OR <- OddsRatio(M, conf.level = 0.95)
  
  Unadjusted_OR = OR[1]
  Unadjusted_LL = OR[2]
  Unadjusted_UL = OR[3]
  
  ##########################################################
  # ADJUSTED ESTIMATES 
  ########################################################## 
  
  # Fitting a propensity model
  ps <- createPs(cohortMethodData = cohortMethodData, 
                 population = studyPop,
                 prior = createPrior("laplace", exclude = c(0), useCrossValidation = T), 
                 control = createControl(cvType = "auto",
                                         startingVariance = 0.01,
                                         noiseLevel = "quiet",
                                         tolerance  = 2e-07,
                                         cvRepetitions = 10,
                                         threads = 24))
  
  # Get all  Concept IDs for exclusion:
  omExcludedConcepts <- c()
  
  # Get all  Concept IDs for inclusion:
  omIncludedConcepts <- c()

  ##########################################################
  # STRATIFIED
  ########################################################## 
  
  strataPop <- stratifyByPs(population=ps, numberOfStrata = 5, stratificationColumns = c())
  
  outcomeModel_Strat <- fitOutcomeModel(cohortMethodData = cohortMethodData, 
                                        population = strataPop,
                                        stratified = T,
                                        modelType = "logistic",    
                                        useCovariates = F,
                                        includeCovariateIds = omIncludedConcepts, 
                                        excludeCovariateIds = omExcludedConcepts)
  
  Adjusted_OR_S = exp(coef(outcomeModel_Strat))
  Adjusted_LL_S = exp(confint(outcomeModel_Strat))[1]
  Adjusted_UL_S = exp(confint(outcomeModel_Strat))[2]

  ##########################################################
  # MATCHED
  ##########################################################

  matchedPop <- matchOnPs(ps, caliper = 0.2, caliperScale = "standardized logit", maxRatio = 1)
  
  outcomeModel_Match <- fitOutcomeModel(cohortMethodData = cohortMethodData, 
                                        population = matchedPop,
                                        stratified = T,
                                        modelType = "logistic",   
                                        useCovariates = F,
                                        includeCovariateIds = omIncludedConcepts, 
                                        excludeCovariateIds = omExcludedConcepts)
  
  Adjusted_OR_M = exp(coef(outcomeModel_Match))
  Adjusted_LL_M = exp(confint(outcomeModel_Match))[1]
  Adjusted_UL_M = exp(confint(outcomeModel_Match))[2]
  
  ##########################################################
  #WRITING OUT TO OUTPUT STRUCTURE
  ##########################################################
  
  Study1_NCT01189890_output <- rbind(Study1_NCT01189890_output, c(temp, Unadjusted_OR, Unadjusted_LL, Unadjusted_UL, Adjusted_OR_S, Adjusted_LL_S, Adjusted_UL_S, Adjusted_OR_M, Adjusted_LL_M, Adjusted_UL_M))
  Study1_NCT01189890_Counts <- rbind(Study1_NCT01189890_Counts, c(temp, sita_hypo, sita_NoHypo, glime_hypo, glime_NoHypo))
  
} #end for loop

##########################################################
# WRITING OUT TO XLS
##########################################################

write.xlsx(x = Study1_NCT01189890_output, file = "Results_To_Share/NCT01189890_Strata_Matched.xlsx", sheetName = siteName, col.names = TRUE, row.names = FALSE)
write.xlsx(x = Study1_NCT01189890_Counts, file = "Results_To_Share/Study1_NCT01189890_Counts.xlsx", sheetName = siteName, col.names = TRUE, row.names = FALSE)

##########################################################
# GRAPHING
##########################################################   

#Saved Matched Plot: All inclusion
jpeg('Results_To_Share/Study1_NCT01189890_Matched_plot.jpg')
plotPs(matchedPop, ps)
dev.off() 

#Saved Matched Plot: All inclusion
jpeg('Results_To_Share/Study1_NCT01189890_Stratified_plot.jpg')
plotPs(strataPop, ps, scale = "preference")
dev.off()

#Odds Ratios Under Sequential Inclusion Criteria

graph_data <- Study1_NCT01189890_output[-1,]

ggplot(graph_data, aes(X.Iteration., group = 1)) +
  geom_line(aes(y=as.numeric(X.Unadjusted_LL.), color = "Unadjusted LL")) + 
  geom_line(aes(y=as.numeric(X.Unadjusted_OR.), color = "Unadjusted OR")) +
  geom_line(aes(y=as.numeric(X.Unadjusted_UL.), color = "Unadjusted UL")) +
  geom_line(aes(y=as.numeric(X.Adjusted_S_LL.), color = "Adjusted Strat LL")) +
  geom_line(aes(y=as.numeric(X.Adjusted_S_OR.), color = "Adjusted Strat OR")) +
  geom_line(aes(y=as.numeric(X.Adjusted_S_UL.), color = "Adjusted Strat UL")) +
  geom_line(aes(y=as.numeric(X.Adjusted_M_LL.), color = "Adjusted Matched LL")) +
  geom_line(aes(y=as.numeric(X.Adjusted_M_OR.), color = "Adjusted Matched OR")) +
  geom_line(aes(y=as.numeric(X.Adjusted_M_UL.), color = "Adjusted Matched UL")) +
  scale_color_manual(values=c("#ffce84", "#d8870d", "#ffce84", "#c4efff", "#18a6db", "#c4efff", "#90EE90", "#008000", "#90EE90")) +
  scale_y_continuous(limits=c(0.0, 1.2), name="Effect Estimate") +
  scale_x_discrete(name="Iteration")

ggsave("Results_To_Share/Study1_NCT01189890_matched_strat.pdf") 
