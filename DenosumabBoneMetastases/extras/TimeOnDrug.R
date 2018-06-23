targetId <- 1
comparatorId <- 2

cmOutputFolder <- file.path(outputFolder, "cmOutput")
reference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
connection <- DatabaseConnector::connect(connectionDetails)
 
# Get denosumab exposures of T and C -------------------------------
sql <- "SELECT DISTINCT subject_id,
cohort_start_date,
drug_exposure_start_date,
DATEADD(DAY, days_supply, drug_exposure_start_date) AS drug_exposure_end_date
FROM @cohort_database_schema.@cohort_table cohort
INNER JOIN @cdm_database_schema.drug_exposure
ON person_id = subject_id
AND drug_exposure_start_date >= cohort_start_date
WHERE drug_concept_id IN (SELECT descendant_concept_id FROM @cdm_database_schema.concept_ancestor WHERE ancestor_concept_id = 40222444)
AND cohort_definition_id IN (@target_id, @comparator_id);"
sql <- SqlRender::renderSql(sql = sql, 
                            cdm_database_schema = cdmDatabaseSchema,
                            cohort_database_schema = cohortDatabaseSchema,
                            cohort_table = cohortTable,
                            target_id = targetId,
                            comparator_id = comparatorId)$sql
sql <- SqlRender::translateSql(sql = sql,
                               targetDialect = connectionDetails$dbms,
                               oracleTempSchema = oracleTempSchema)$sql
exposureDenosumab <- DatabaseConnector::querySql(connection, sql)
colnames(exposureDenosumab) <- SqlRender::snakeCaseToCamelCase(colnames(exposureDenosumab))

exposureDenosumab[exposureDenosumab$subjectId == 33003391273, ]
# sql <- "SELECT TOP 100 * FROM @cdm_database_schema.drug_exposure WHERE drug_concept_id IN (SELECT descendant_concept_id FROM @cdm_database_schema.concept_ancestor WHERE ancestor_concept_id = 40222444)"

# Get zoledronic acid exposures of T and C -------------------------------
sql <- "SELECT DISTINCT subject_id,
cohort_start_date,
drug_exposure_start_date,
DATEADD(DAY, days_supply, drug_exposure_start_date) AS drug_exposure_end_date
FROM @cohort_database_schema.@cohort_table cohort
INNER JOIN @cdm_database_schema.drug_exposure
ON person_id = subject_id
AND drug_exposure_start_date >= cohort_start_date
WHERE drug_concept_id IN (SELECT descendant_concept_id FROM @cdm_database_schema.concept_ancestor WHERE ancestor_concept_id = 1524674)
AND cohort_definition_id IN (@target_id, @comparator_id)

UNION ALL

SELECT DISTINCT subject_id,
cohort_start_date,
procedure_date AS drug_exposure_start_date,
procedure_date AS drug_exposure_end_date
FROM @cohort_database_schema.@cohort_table cohort
INNER JOIN @cdm_database_schema.procedure_occurrence
ON person_id = subject_id
AND procedure_date >= cohort_start_date
WHERE procedure_source_concept_id IN (2718650,2720787,2718649,44786564,44786608)
AND cohort_definition_id IN (@target_id, @comparator_id);"
sql <- SqlRender::renderSql(sql = sql, 
                            cdm_database_schema = cdmDatabaseSchema,
                            cohort_database_schema = cohortDatabaseSchema,
                            cohort_table = cohortTable,
                            target_id = targetId,
                            comparator_id = comparatorId)$sql
sql <- SqlRender::translateSql(sql = sql,
                               targetDialect = connectionDetails$dbms,
                               oracleTempSchema = oracleTempSchema)$sql
exposureZoledronicAcid <- DatabaseConnector::querySql(connection, sql)
colnames(exposureZoledronicAcid) <- SqlRender::snakeCaseToCamelCase(colnames(exposureZoledronicAcid))

DatabaseConnector::disconnect(connection)

createEras <- function(exposure, gap = 60, append = 30) {
  exposure <- exposure[order(exposure$subjectId, 
                             exposure$cohortStartDate, 
                             exposure$drugExposureStartDate), ]
  n  <- nrow(exposure)
  # dup <- duplicated(exposure[, c("subjectId", "cohortStartDate")])
  # dup <- which(dup)
  idx <- exposure$subjectId[1:(n-1)] == exposure$subjectId[2:n] &
    exposure$cohortStartDate[1:(n-1)] == exposure$cohortStartDate[2:n] &
    (exposure$drugExposureStartDate[1:(n-1)] - exposure$drugExposureStartDate[2:n]>= -gap)
  idx <- which(idx)
  # print(length(idx))
  exposure$eraEndDate <- as.Date(NA)
  exposure$eraEndDate[idx] <- exposure$drugExposureStartDate[idx+1]
  head(exposure)
  while(length(idx) > 0) {
    idx <- exposure$subjectId[1:(n-1)] == exposure$subjectId[2:n] &
      exposure$cohortStartDate[1:(n-1)] == exposure$cohortStartDate[2:n] &
      (exposure$drugExposureStartDate[1:(n-1)] - exposure$drugExposureStartDate[2:n]>= -gap) &
      !is.na(exposure$eraEndDate[2:n]) &
      (is.na(exposure$eraEndDate[1:(n-1)]) | exposure$eraEndDate[2:n] > exposure$eraEndDate[1:(n-1)])
    idx <- which(idx)
    # print(length(idx))
    exposure$eraEndDate[idx] <- exposure$eraEndDate[idx+1]
  }
  exposure$eraEndDate[is.na(exposure$eraEndDate)] <- exposure$drugExposureStartDate[is.na(exposure$eraEndDate)]
  exposure$eraEndDate <- exposure$eraEndDate + append
  return(exposure)
}

exposureDenosumab <- createEras(exposureDenosumab)
exposureZoledronicAcid <- createEras(exposureZoledronicAcid)
saveRDS(exposureDenosumab, file.path(outputFolder, "exposureDenosumab.rds"))
saveRDS(exposureZoledronicAcid, file.path(outputFolder, "exposureZoledronicAcid.rds"))


# Compute new time at risk -----------------------------------------------------------
strataPop <- readRDS(reference$strataFile[reference$targetId == targetId & reference$comparatorId == comparatorId & reference$analysisId == 1 & reference$outcomeId == 21])
CohortMethod::plotFollowUpDistribution(strataPop)  
exposureDenosumab$treatment <- 1
exposureZoledronicAcid$treatment <- 0
exposure <- rbind(exposureDenosumab, exposureZoledronicAcid)
exposure <- exposure[exposure$cohortStartDate == exposure$drugExposureStartDate, ]
exposure <- exposure[, c("subjectId", "cohortStartDate", "treatment", "eraEndDate")]
exposure <- exposure[order(exposure$subjectId, 
                           exposure$cohortStartDate, 
                           exposure$treatment), ]
dup <- duplicated(exposure[, c("subjectId", "cohortStartDate", "treatment")])
exposure <- exposure[!dup, ]
strataPop <- merge(strataPop, exposure[, c("subjectId", "cohortStartDate", "treatment", "eraEndDate")])

strataPop$daysToEndOfExposure <- as.integer(strataPop$eraEndDate - strataPop$cohortStartDate)
strataPop$timeAtRiskItt <- strataPop$timeAtRisk
strataPop$timeAtRisk[strataPop$timeAtRisk > strataPop$daysToEndOfExposure] <- strataPop$daysToEndOfExposure[strataPop$timeAtRisk > strataPop$daysToEndOfExposure] 
sum(as.numeric(strataPop$timeAtRisk[strataPop$treatment == 1])) / sum(strataPop$timeAtRiskItt[strataPop$treatment == 1])
sum(as.numeric(strataPop$timeAtRisk[strataPop$treatment == 0])) / sum(strataPop$timeAtRiskItt[strataPop$treatment == 0])
CohortMethod::plotFollowUpDistribution(strataPop)  

# Find switchers ------------------------------------------------------------------------
strataPop <- readRDS(reference$strataFile[reference$targetId == targetId & reference$comparatorId == comparatorId & reference$analysisId == 1 & reference$outcomeId == 21])
exposureDenosumab$treatment <- 0
exposureZoledronicAcid$treatment <- 1
exposure <- rbind(exposureDenosumab, exposureZoledronicAcid)
exposure <- exposure[, c("subjectId", "cohortStartDate", "treatment", "drugExposureStartDate")]
exposure <- exposure[order(exposure$subjectId, 
                           exposure$cohortStartDate, 
                           exposure$treatment,
                           exposure$drugExposureStartDate), ]
dup <- duplicated(exposure[, c("subjectId", "cohortStartDate", "treatment")])
exposure <- exposure[!dup, ]
switchers <- merge(strataPop, exposure[, c("subjectId", "cohortStartDate", "treatment", "drugExposureStartDate")])
switchers <- switchers[switchers$drugExposureStartDate < switchers$cohortStartDate + switchers$timeAtRisk, ]
writeLines(paste("Fractions switching from C to T:", sum(switchers$treatment == 0) / sum(strataPop$treatment == 0)))
writeLines(paste("Fractions switching from T to C:", sum(switchers$treatment == 1) / sum(strataPop$treatment == 1)))

# Additional: look at time trends of death in the database


sql <- "SELECT death_date
FROM @cdm_database_schema.death
INNER JOIN @cdm_database_schema.observation_period
ON death.person_id = observation_period.person_id
AND death_date >= observation_period_start_date
AND death_date <= observation_period_end_date;"
sql <- SqlRender::renderSql(sql = sql, 
                            cdm_database_schema = cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql = sql,
                               targetDialect = connectionDetails$dbms,
                               oracleTempSchema = oracleTempSchema)$sql
deathDates <- DatabaseConnector::querySql(connection, sql)
deathDates$dummy <- 0
library(ggplot2)
ggplot(deathDates[deathDates$DEATH_DATE > as.Date("2010-12-01"), ], aes(x=DEATH_DATE)) +
  geom_density()

cmOutputFolder <- file.path(outputFolder, "cmOutput")
reference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
idx <- reference$targetId == targetId & reference$comparatorId == comparatorId & reference$outcomeId == 26 & reference$analysisId == 2
strataPop <- readRDS(reference$strataFile[idx])
strataPop <- strataPop[!is.na(strataPop$daysToEvent), ]
strataPop$deathDate <- strataPop$cohortStartDate + strataPop$daysToEvent
strataPop$group <- "Zoledronic acid"
strataPop$group[strataPop$treatment == 1] <- "Denosumab"
ggplot(strataPop, aes(x=deathDate, group=group, color = group, fill = group)) +
  geom_histogram() +
  facet_grid(group~.)


idx <- reference$targetId == targetId & reference$comparatorId == comparatorId & reference$outcomeId == 26 & reference$analysisId == 2
strataPop <- readRDS(reference$strataFile[idx])
strataPop <- strataPop[strataPop$cohortStartDate >= as.Date("2012-01-01"), ]
CohortMethod::fitOutcomeModel(strataPop, modelType = "cox", useCovariates = FALSE, stratified = TRUE)
  