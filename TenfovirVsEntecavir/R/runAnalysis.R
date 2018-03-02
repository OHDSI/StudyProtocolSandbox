
# Study: ----
# [SOS_osh]tenofovir_vs_entecavir_fracture 

# CohortMethod Installation & Load ----


# Uncomment to install CohortMethod
 install.packages("devtools")
 install.packages("drat")
 drat::addRepo(c("OHDSI","cloudyr"))
 devtools::install_github("ohdsi/FeatureExtraction", ref = "v1.2.3")
 devtools::install_github("ohdsi/CohortMethod", ref = "v2.4.4")
 install.packages("EmpiricalCalibration")

# Load the Cohort Method library
library(CohortMethod) 
library(SqlRender)
library(EmpiricalCalibration)

# Data extraction ----

# TODO: Insert your connection details here
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "<>",
                                                                server = "<>",
                                                                user = "<>",
                                                                password = "<>")
cdmDatabaseSchema <- "<>"
resultsDatabaseSchema <- "<>"
exposureTable <- "<>"
outcomeTable <- "<>"
cdmVersion <- "5" 
outputFolder <- "<>"
maxCores <- 4 
if(!dir.exists(outputFolder)){
  dir.create(outputFolder, recursive = TRUE)
}
setwd(outputFolder)

targetCohortId <- 389
comparatorCohortId <- 387
outcomeCohortId <- 388
outcomeList <- c(outcomeCohortId)

# Default Prior & Control settings ----
defaultPrior <- Cyclops::createPrior("laplace", 
                                     exclude = c(0),
                                     useCrossValidation = TRUE)

defaultControl <- Cyclops::createControl(cvType = "auto",
                                         startingVariance = 0.01,
                                         noiseLevel = "quiet",
                                         tolerance  = 2e-07,
                                         cvRepetitions = 10,
                                         threads = 1)

# PLEASE NOTE ----
# If you want to use your code in a distributed network study
# you will need to create a temporary cohort table with common cohort IDs.
# The code below ASSUMES you are only running in your local network 
# where common cohort IDs have already been assigned in the cohort table.

# Get all Tenofovir&Entecavir Concept IDs for exclusion ----
sql <- paste("select distinct I.concept_id FROM
             ( 
             select concept_id from @cdm_database_schema.CONCEPT where concept_id in (1711246,19011093,1710281)and invalid_reason is null
             UNION  select c.concept_id
             from @cdm_database_schema.CONCEPT c
             join @cdm_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
             and ca.ancestor_concept_id in (1711246,19011093,1710281)
             and c.invalid_reason is null
             
             ) I
             ")
sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
connection <- DatabaseConnector::connect(connectionDetails)
excludedConcepts <- DatabaseConnector::querySql(connection, sql)
excludedConcepts <- excludedConcepts$CONCEPT_ID

# Get all  Concept IDs for inclusion ----

includedConcepts <- c()


# Get all  Concept IDs for exclusion in the outcome model ----

omExcludedConcepts <- c()

# Get all  Concept IDs for inclusion exclusion in the outcome model ----

omIncludedConcepts <- c()


# Get all  Concept IDs for empirical calibration ----

negativeControlConcepts <- c()


# Create drug comparator and outcome arguments by combining target + comparitor + outcome + negative controls ----
dcos <- CohortMethod::createDrugComparatorOutcomes(targetId = targetCohortId,
                                                   comparatorId = comparatorCohortId,
                                                   excludedCovariateConceptIds = excludedConcepts,
                                                   includedCovariateConceptIds = includedConcepts,
                                                   outcomeIds = c(outcomeList, negativeControlConcepts))

drugComparatorOutcomesList <- list(dcos)



# Define which types of covariates must be constructed ----
covariateSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                                useCovariateDemographicsGender = TRUE,
                                                                useCovariateDemographicsRace = FALSE,
                                                                useCovariateDemographicsEthnicity = FALSE,
                                                                useCovariateDemographicsAge = TRUE, 
                                                                useCovariateDemographicsYear = FALSE,
                                                                useCovariateDemographicsMonth = FALSE,
                                                                useCovariateConditionOccurrence = TRUE,    
                                                                useCovariateConditionOccurrenceLongTerm = TRUE,
                                                                useCovariateConditionOccurrenceShortTerm = TRUE,
                                                                useCovariateConditionOccurrenceInptMediumTerm = TRUE,
                                                                useCovariateConditionEra = TRUE, 
                                                                useCovariateConditionEraEver = TRUE,
                                                                useCovariateConditionEraOverlap = FALSE,
                                                                useCovariateConditionGroup = TRUE,
                                                                useCovariateConditionGroupMeddra = FALSE,
                                                                useCovariateConditionGroupSnomed = TRUE,
                                                                useCovariateDrugExposure = TRUE, 
                                                                useCovariateDrugExposureLongTerm = TRUE,
                                                                useCovariateDrugExposureShortTerm = TRUE, 
                                                                useCovariateDrugEra = TRUE,
                                                                useCovariateDrugEraLongTerm = TRUE, 
                                                                useCovariateDrugEraShortTerm = TRUE,
                                                                useCovariateDrugEraOverlap = FALSE, 
                                                                useCovariateDrugEraEver = TRUE,
                                                                useCovariateDrugGroup = TRUE, 
                                                                useCovariateProcedureOccurrence = TRUE,
                                                                useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                                useCovariateProcedureOccurrenceShortTerm = TRUE,
                                                                useCovariateProcedureGroup = FALSE, 
                                                                useCovariateObservation = FALSE,
                                                                useCovariateObservationLongTerm = FALSE, 
                                                                useCovariateObservationShortTerm = FALSE,
                                                                useCovariateObservationCountLongTerm = FALSE, 
                                                                useCovariateMeasurement = FALSE,
                                                                useCovariateMeasurementLongTerm = FALSE, 
                                                                useCovariateMeasurementShortTerm = FALSE,
                                                                useCovariateMeasurementCountLongTerm = FALSE,
                                                                useCovariateMeasurementBelow = FALSE,
                                                                useCovariateMeasurementAbove = FALSE, 
                                                                useCovariateConceptCounts = FALSE,
                                                                useCovariateRiskScores = TRUE, 
                                                                useCovariateRiskScoresCharlson = TRUE,
                                                                useCovariateRiskScoresDCSI = FALSE, 
                                                                useCovariateRiskScoresCHADS2 = FALSE,
                                                                useCovariateRiskScoresCHADS2VASc = FALSE,
                                                                useCovariateInteractionYear = FALSE, 
                                                                useCovariateInteractionMonth = FALSE,
                                                                deleteCovariatesSmallCount = 100,
                                                                longTermDays = 365,
                                                                mediumTermDays = 180,
                                                                shortTermDays = 30,
                                                                windowEndDays = 0)



getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 0,
                                                                 firstExposureOnly = FALSE,
                                                                 removeDuplicateSubjects = FALSE,
                                                                 studyStartDate = "",
                                                                 studyEndDate = "",
                                                                 excludeDrugsFromCovariates = FALSE,
                                                                 covariateSettings = covariateSettings)

createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                    firstExposureOnly = FALSE,
                                                                    washoutPeriod = 0,
                                                                    removeDuplicateSubjects = FALSE,
                                                                    minDaysAtRisk = 0,
                                                                    riskWindowStart = 1,
                                                                    addExposureDaysToStart = FALSE,
                                                                    riskWindowEnd = 0,
                                                                    addExposureDaysToEnd = TRUE)


fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(useCovariates = FALSE,
                                                                modelType = "cox",
                                                                stratified = TRUE,
                                                                includeCovariateIds = omIncludedConcepts, 
                                                                excludeCovariateIds = omExcludedConcepts,
                                                                prior = defaultPrior, 
                                                                control = defaultControl)

createPsArgs1 <- CohortMethod::createCreatePsArgs(control = defaultControl) # Using only defaults
trimByPsArgs1 <- CohortMethod::createTrimByPsArgs() # Using only defaults 
trimByPsToEquipoiseArgs1 <- CohortMethod::createTrimByPsToEquipoiseArgs() # Using only defaults 
matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs(caliper = 0.25, caliperScale = "standardized", maxRatio = 4) 
stratifyByPsArgs1 <- CohortMethod::createStratifyByPsArgs() # Using only defaults 

cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                              description = "[SOS_osh]tenofovir_vs_entecavir_fracture",
                                              getDbCohortMethodDataArgs = getDbCmDataArgs,
                                              createStudyPopArgs = createStudyPopArgs,
                                              createPs = TRUE,
                                              createPsArgs = createPsArgs1,
                                              trimByPs = FALSE,
                                              trimByPsArgs = trimByPsArgs1,
                                              trimByPsToEquipoise = FALSE,
                                              trimByPsToEquipoiseArgs = trimByPsToEquipoiseArgs1,
                                              matchOnPs = TRUE,
                                              matchOnPsArgs = matchOnPsArgs1,
                                              stratifyByPs = FALSE,
                                              stratifyByPsArgs = stratifyByPsArgs1,
                                              computeCovariateBalance = TRUE,
                                              fitOutcomeModel = TRUE,
                                              fitOutcomeModelArgs = fitOutcomeModelArgs1)


cmAnalysisList <- list(cmAnalysis1)

# Run the analysis ----
result <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                      cdmDatabaseSchema = cdmDatabaseSchema,
                                      exposureDatabaseSchema = resultsDatabaseSchema,
                                      exposureTable = exposureTable,
                                      outcomeDatabaseSchema = resultsDatabaseSchema,
                                      outcomeTable = outcomeTable,
                                      cdmVersion = cdmVersion,
                                      outputFolder = outputFolder,
                                      cmAnalysisList = cmAnalysisList,
                                      drugComparatorOutcomesList = drugComparatorOutcomesList,
                                      getDbCohortMethodDataThreads = 1,
                                      createPsThreads = 1,
                                      psCvThreads = min(16, maxCores),
                                      computeCovarBalThreads = min(3, maxCores),
                                      createStudyPopThreads = min(3, maxCores),
                                      trimMatchStratifyThreads = min(10, maxCores),
                                      fitOutcomeModelThreads = max(1, round(maxCores/4)),
                                      outcomeCvThreads = min(4, maxCores),
                                      refitPsForEveryOutcome = FALSE)

## Summarize the results
analysisSummary <- CohortMethod::summarizeAnalyses(result)
head(analysisSummary)

# Perform Empirical Calibration ----
newSummary <- data.frame()
# Calibrate p-values:
drugComparatorOutcome <- drugComparatorOutcomesList[[1]]
for (drugComparatorOutcome in drugComparatorOutcomesList) {
  for (analysisId in unique(analysisSummary$analysisId)) {
    subset <- analysisSummary[analysisSummary$analysisId == analysisId &
                                analysisSummary$targetId == drugComparatorOutcome$targetId &
                                analysisSummary$comparatorId == drugComparatorOutcome$comparatorId, ]
    
    negControlSubset <- subset[analysisSummary$outcomeId %in% negativeControlConcepts, ]
    negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr != 0, ]
    
    hoiSubset <- subset[!(analysisSummary$outcomeId %in% negativeControlConcepts), ]
    hoiSubset <- hoiSubset[!is.na(hoiSubset$logRr) & hoiSubset$logRr != 0, ]
    
    if (nrow(negControlSubset) > 10) {
      null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
      
      # View the empirical calibration plot with only negative controls
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr)
      
      # Save the empirical calibration plot with only negative controls
      plotName <- paste("calEffectNoHois_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr,
                                                  fileName = file.path(outputFolder, plotName))
      
      # View the empirical calibration plot with  negative controls and HOIs plotted
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr,
                                                  hoiSubset$logRr, 
                                                  hoiSubset$seLogRr)
      
      # Save the empirical calibration plot with  negative controls and HOIs plotted
      plotName <- paste("calEffect_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr,
                                                  hoiSubset$logRr, 
                                                  hoiSubset$seLogRr,
                                                  fileName = file.path(outputFolder, plotName))
      
      calibratedP <- calibrateP(null, subset$logRr, subset$seLogRr)
      subset$calibratedP <- calibratedP$p
      subset$calibratedP_lb95ci <- calibratedP$lb95ci
      subset$calibratedP_ub95ci <- calibratedP$ub95ci
      mcmc <- attr(null, "mcmc")
      subset$null_mean <- mean(mcmc$chain[, 1])
      subset$null_sd <- 1/sqrt(mean(mcmc$chain[, 2]))
    } else {
      subset$calibratedP <- NA
      subset$calibratedP_lb95ci <- NA
      subset$calibratedP_ub95ci <- NA
      subset$null_mean <- NA
      subset$null_sd <- NA
    }
    newSummary <- rbind(newSummary, subset)
  }
}

# Results ----
drugComparatorOutcome <- drugComparatorOutcomesList[[1]]
for (drugComparatorOutcome in drugComparatorOutcomesList) {
  for (analysisId in unique(analysisSummary$analysisId)) {
    currentAnalysisSubset <- analysisSummary[analysisSummary$analysisId == analysisId &
                                               analysisSummary$targetId == drugComparatorOutcome$targetId &
                                               analysisSummary$comparatorId == drugComparatorOutcome$comparatorId &
                                               analysisSummary$outcomeId %in% outcomeList, ]
    
    for(currentOutcomeId in unique(currentAnalysisSubset$outcomeId)) {
      outputImageSuffix <- paste0("_a",analysisId, "_t", currentAnalysisSubset$targetId, "_c", currentAnalysisSubset$comparatorId, "_o", currentOutcomeId, ".png")
      
      cohortMethodFile <- result$cohortMethodDataFolder[result$target == currentAnalysisSubset$targetId &
                                                          result$comparatorId == currentAnalysisSubset$comparatorId &
                                                          result$outcomeId == currentOutcomeId &
                                                          result$analysisId == analysisId]
      
      cohortMethodData <- loadCohortMethodData(cohortMethodFile)
      
      studyPopFile <- result$studyPopFile[result$target == currentAnalysisSubset$targetId &
                                            result$comparatorId == currentAnalysisSubset$comparatorId &
                                            result$outcomeId == currentOutcomeId &
                                            result$analysisId == analysisId]
      
      # Return the attrition table for the study population ----
      studyPop <- readRDS(studyPopFile)
      getAttritionTable(studyPop)
      
      # View the attrition diagram
      drawAttritionDiagram(studyPop, 
                           treatmentLabel = "Target", 
                           comparatorLabel = "Comparator")
      
      # Save the attrition diagram ----
      plotName <- paste0("attritionDiagram", outputImageSuffix);
      drawAttritionDiagram(studyPop, 
                           treatmentLabel = "Target", 
                           comparatorLabel = "Comparator", 
                           fileName = file.path(outputFolder, plotName))
      
      
      psFile <- result$psFile[result$target == currentAnalysisSubset$targetId &
                                result$comparatorId == currentAnalysisSubset$comparatorId &
                                result$outcomeId == currentOutcomeId &
                                result$analysisId == analysisId]
      
      ps <- readRDS(psFile)
      
      # Compute the area under the receiver-operator curve (AUC) for the propensity score model ----
      CohortMethod::computePsAuc(ps)
      
      # Plot the propensity score distribution ----
      CohortMethod::plotPs(ps, 
                           scale = "preference")
      
      # Save the propensity score distribution ----
      plotName <- paste0("propensityScorePlot", outputImageSuffix);
      CohortMethod::plotPs(ps, 
                           scale = "preference",
                           fileName = file.path(outputFolder, plotName))
      
      
      # Inspect the propensity model ----
      propensityModel <- CohortMethod::getPsModel(ps, cohortMethodData)
      head(propensityModel)
      
      
      strataFile <- result$strataFile[result$target == currentAnalysisSubset$targetId &
                                        result$comparatorId == currentAnalysisSubset$comparatorId &
                                        result$outcomeId == currentOutcomeId &
                                        result$analysisId == analysisId]
      strataPop <- readRDS(strataFile)
      
      # View PS With Population Trimmed By Percentile ----
      CohortMethod::plotPs(strataPop, 
                           ps, 
                           scale = "preference")
      
      # Save PS With Population Trimmed By Percentile ----
      plotName <- paste0("propensityScorePlotStrata", outputImageSuffix);
      CohortMethod::plotPs(strataPop, 
                           ps, 
                           scale = "preference",
                           fileName = file.path(outputFolder, plotName))
      
      
      # Get the attrition table and diagram for the strata pop ----
      CohortMethod::getAttritionTable(strataPop)
      
      # View the attrition diagram for the strata pop ----
      CohortMethod::drawAttritionDiagram(strataPop)
      
      # Save the attrition diagram for the strata pop ----
      plotName <- paste0("attritionDiagramStrata", outputImageSuffix);
      CohortMethod::drawAttritionDiagram(strataPop,
                                         fileName = file.path(outputFolder, plotName))
      
      
      # Plot the covariate balance ----
      balanceFile <- result$covariateBalanceFile[result$target == currentAnalysisSubset$targetId &
                                                   result$comparatorId == currentAnalysisSubset$comparatorId &
                                                   result$outcomeId == currentOutcomeId &
                                                   result$analysisId == analysisId]
      balance <- readRDS(balanceFile)
      
      # View the covariate balance scatter plot ----
      CohortMethod::plotCovariateBalanceScatterPlot(balance)
      
      # Save the covariate balance scatter plot ----
      plotName <- paste0("covBalScatter", outputImageSuffix);
      CohortMethod::plotCovariateBalanceScatterPlot(balance,
                                                    fileName = file.path(outputFolder, plotName))
      
      # View the plot of top variables ----
      CohortMethod::plotCovariateBalanceOfTopVariables(balance)
      
      # Save the plot of top variables ----
      plotName <- paste0("covBalTop", outputImageSuffix);
      CohortMethod::plotCovariateBalanceOfTopVariables(balance,
                                                       fileName = file.path(outputFolder, plotName))
      
      
      # Outcome Model ----
      
      outcomeFile <- result$outcomeModelFile[result$target == currentAnalysisSubset$targetId &
                                               result$comparatorId == currentAnalysisSubset$comparatorId &
                                               result$outcomeId == currentOutcomeId &
                                               result$analysisId == analysisId]
      outcomeModel <- readRDS(outcomeFile)
      
      # Calibrated results -----
      outcomeSummary <- newSummary[newSummary$targetId == currentAnalysisSubset$targetId & 
                                     newSummary$comparatorId == currentAnalysisSubset$comparatorId & 
                                     newSummary$outcomeId == currentOutcomeId & 
                                     newSummary$analysisId == analysisId, ]  
      
      outcomeSummaryOutput <- data.frame(outcomeSummary$rr, 
                                         outcomeSummary$ci95lb, 
                                         outcomeSummary$ci95ub, 
                                         outcomeSummary$logRr, 
                                         outcomeSummary$seLogRr,
                                         outcomeSummary$p,
                                         outcomeSummary$calibratedP, 
                                         outcomeSummary$calibratedP_lb95ci,
                                         outcomeSummary$calibratedP_ub95ci,
                                         outcomeSummary$null_mean,
                                         outcomeSummary$null_sd)
      
      colnames(outcomeSummaryOutput) <- c("Estimate", 
                                          "lower .95", 
                                          "upper .95", 
                                          "logRr", 
                                          "seLogRr", 
                                          "p", 
                                          "cal p",  
                                          "cal p - lower .95",  
                                          "cal p - upper .95", 
                                          "null mean",  
                                          "null sd")
      
      rownames(outcomeSummaryOutput) <- "treatment"
      
      # View the outcome model -----
      outcomeModelOutput <- capture.output(outcomeModel)
      outcomeModelOutput <- head(outcomeModelOutput,n=length(outcomeModelOutput)-2)
      outcomeSummaryOutput <- capture.output(printCoefmat(outcomeSummaryOutput))
      outcomeModelOutput <- c(outcomeModelOutput, outcomeSummaryOutput)
      writeLines(outcomeModelOutput)
      
    }
  }
}




















