
# Study: ----
# Mortality between Febuxostat Vs Allopurinol in 
# general population 

# CohortMethod Installation & Load ----


# Uncomment to install CohortMethod
# install.packages("devtools")
# install.packages("drat")
# drat::addRepo(c("OHDSI","cloudyr"))
#devtools::install_github("ohdsi/FeatureExtraction", ref = "v2.0.2")
#devtools::install_github("ohdsi/CohortMethod", ref = "v2.5.0")
# install.packages("EmpiricalCalibration")

# Load the Cohort Method library
library(CohortMethod) 
library(SqlRender)
library(EmpiricalCalibration)

# Data extraction ----

# TODO: Insert your connection details here
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                server = "localhost/ohdsi",
                                                                user = "joe",
                                                                password = "supersecret")
cdmDatabaseSchema <- "my_cdm_data"
exposureDatabaseSchema <- "my_cdm_data"
outcomeDatabaseSchema <- "my_cdm_data"
exposureTable <- "exposure_table"
outcomeTable <- "outcome_table"
cdmVersion <- "5" 
outputFolder <- "<insert your directory here>"
maxCores <- 1 
if(!dir.exists(outputFolder)){
    dir.create(outputFolder, recursive = TRUE)
}
setwd(outputFolder)

targetCohortId <- 542
comparatorCohortId <- 543
outcomeCohortId <- 20
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

# Get all Febuxostat and Allopurinol Concept IDs for exclusion ----
sql <- paste("select distinct I.concept_id FROM
             ( 
             select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (1167322,19017742)and invalid_reason is null
             UNION  select c.concept_id
             from @vocabulary_database_schema.CONCEPT c
             join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
             and ca.ancestor_concept_id in (1167322,19017742)
             and c.invalid_reason is null
             
             ) I
             ")
sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema, vocabulary_database_schema = cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
connection <- DatabaseConnector::connect(connectionDetails)
excludedConcepts <- DatabaseConnector::querySql(connection, sql)
excludedConcepts <- excludedConcepts$CONCEPT_ID
DatabaseConnector::disconnect(connection)

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

covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsGender = TRUE,
                                                                useDemographicsAge = FALSE, 
                                                                useDemographicsAgeGroup = TRUE,
                                                                useDemographicsRace = TRUE,
                                                                useDemographicsEthnicity = FALSE,
                                                                useDemographicsIndexYear = TRUE,
                                                                useDemographicsIndexMonth = FALSE,
                                                                useDemographicsPriorObservationTime = FALSE,
                                                                useDemographicsPostObservationTime = FALSE,
                                                                useDemographicsTimeInCohort = FALSE,
                                                                useDemographicsIndexYearMonth = FALSE,
                                                                useConditionOccurrenceAnyTimePrior = TRUE,
                                                                useConditionOccurrenceLongTerm = TRUE,
                                                                useConditionOccurrenceMediumTerm = FALSE,
                                                                useConditionOccurrenceShortTerm = TRUE,
                                                                useConditionOccurrenceInpatientAnyTimePrior = FALSE,
                                                                useConditionOccurrenceInpatientLongTerm = FALSE,
                                                                useConditionOccurrenceInpatientMediumTerm = FALSE,
                                                                useConditionOccurrenceInpatientShortTerm = TRUE,
                                                                useConditionEraAnyTimePrior = FALSE,
                                                                useConditionEraLongTerm = FALSE,
                                                                useConditionEraMediumTerm = FALSE,
                                                                useConditionEraShortTerm = FALSE,
                                                                useConditionEraOverlapping = FALSE,
                                                                useConditionEraStartLongTerm = FALSE,
                                                                useConditionEraStartMediumTerm = FALSE,
                                                                useConditionEraStartShortTerm = FALSE,
                                                                useConditionGroupEraAnyTimePrior = TRUE,
                                                                useConditionGroupEraLongTerm = TRUE,
                                                                useConditionGroupEraMediumTerm = FALSE,
                                                                useConditionGroupEraShortTerm = TRUE,
                                                                useConditionGroupEraOverlapping = FALSE,
                                                                useConditionGroupEraStartLongTerm = FALSE,
                                                                useConditionGroupEraStartMediumTerm = FALSE,
                                                                useConditionGroupEraStartShortTerm = FALSE,
                                                                useDrugExposureAnyTimePrior = TRUE,
                                                                useDrugExposureLongTerm = TRUE,
                                                                useDrugExposureMediumTerm = FALSE,
                                                                useDrugExposureShortTerm = TRUE, 
                                                                useDrugEraAnyTimePrior = FALSE,
                                                                useDrugEraLongTerm = FALSE,
                                                                useDrugEraMediumTerm = FALSE,
                                                                useDrugEraShortTerm = FALSE,
                                                                useDrugEraOverlapping = FALSE, 
                                                                useDrugEraStartLongTerm = FALSE, 
                                                                useDrugEraStartMediumTerm = FALSE,
                                                                useDrugEraStartShortTerm = FALSE,
                                                                useDrugGroupEraAnyTimePrior = TRUE,
                                                                useDrugGroupEraLongTerm = TRUE,
                                                                useDrugGroupEraMediumTerm = FALSE,
                                                                useDrugGroupEraShortTerm = TRUE,
                                                                useDrugGroupEraOverlapping = FALSE,
                                                                useDrugGroupEraStartLongTerm = FALSE,
                                                                useDrugGroupEraStartMediumTerm = FALSE,
                                                                useDrugGroupEraStartShortTerm = FALSE,
                                                                useProcedureOccurrenceAnyTimePrior = TRUE,
                                                                useProcedureOccurrenceLongTerm = TRUE,
                                                                useProcedureOccurrenceMediumTerm = FALSE,
                                                                useProcedureOccurrenceShortTerm = TRUE,
                                                                useDeviceExposureAnyTimePrior = TRUE,
                                                                useDeviceExposureLongTerm = TRUE,
                                                                useDeviceExposureMediumTerm = FALSE,
                                                                useDeviceExposureShortTerm = TRUE,
                                                                useMeasurementAnyTimePrior = FALSE,
                                                                useMeasurementLongTerm = FALSE, 
                                                                useMeasurementMediumTerm = FALSE,
                                                                useMeasurementShortTerm = FALSE,
                                                                useMeasurementValueAnyTimePrior = FALSE,
                                                                useMeasurementValueLongTerm = FALSE,
                                                                useMeasurementValueMediumTerm = FALSE,
                                                                useMeasurementValueShortTerm = FALSE,
                                                                useMeasurementRangeGroupAnyTimePrior = FALSE,
                                                                useMeasurementRangeGroupLongTerm = FALSE,
                                                                useMeasurementRangeGroupMediumTerm = FALSE,
                                                                useMeasurementRangeGroupShortTerm = FALSE,
                                                                useObservationAnyTimePrior = FALSE,
                                                                useObservationLongTerm = FALSE, 
                                                                useObservationMediumTerm = FALSE,
                                                                useObservationShortTerm = FALSE,
                                                                useCharlsonIndex = TRUE,
                                                                useDcsi = FALSE, 
                                                                useChads2 = FALSE,
                                                                useChads2Vasc = FALSE,
                                                                useDistinctConditionCountLongTerm = FALSE,
                                                                useDistinctConditionCountMediumTerm = FALSE,
                                                                useDistinctConditionCountShortTerm = FALSE,
                                                                useDistinctIngredientCountLongTerm = FALSE,
                                                                useDistinctIngredientCountMediumTerm = FALSE,
                                                                useDistinctIngredientCountShortTerm = FALSE,
                                                                useDistinctProcedureCountLongTerm = FALSE,
                                                                useDistinctProcedureCountMediumTerm = FALSE,
                                                                useDistinctProcedureCountShortTerm = FALSE,
                                                                useDistinctMeasurementCountLongTerm = FALSE,
                                                                useDistinctMeasurementCountMediumTerm = FALSE,
                                                                useDistinctMeasurementCountShortTerm = FALSE,
                                                                useVisitCountLongTerm = FALSE,
                                                                useVisitCountMediumTerm = FALSE,
                                                                useVisitCountShortTerm = FALSE,
                                                                longTermStartDays = -365,
                                                                mediumTermStartDays = -180, 
                                                                shortTermStartDays = -30, 
                                                                endDays = 0,
                                                                includedCovariateConceptIds = includedConcepts, 
                                                                addDescendantsToInclude = FALSE,
                                                                excludedCovariateConceptIds = excludedConcepts, 
                                                                addDescendantsToExclude = FALSE,
                                                                includedCovariateIds = c())																				 


getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(washoutPeriod = 0,
                                                                 firstExposureOnly = FALSE,
                                                                 removeDuplicateSubjects = TRUE,
                                                                 studyStartDate = "",
                                                                 studyEndDate = "",
                                                                 excludeDrugsFromCovariates = FALSE,
                                                                 covariateSettings = covariateSettings)

createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(removeSubjectsWithPriorOutcome = TRUE,
                                                                    firstExposureOnly = FALSE,
                                                                    washoutPeriod = 0,
                                                                    removeDuplicateSubjects = TRUE,
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
                                              description = "Mortality risk between febuxostat and allopurinol",
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
                                      exposureDatabaseSchema = exposureDatabaseSchema,
                                      exposureTable = exposureTable,
                                      outcomeDatabaseSchema = outcomeDatabaseSchema,
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
                                                        negControlSubset$seLogRr,showCis = TRUE)
            
            # Save the empirical calibration plot with only negative controls
            plotName <- paste("calEffectNoHois_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
            EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                        negControlSubset$seLogRr,
                                                        fileName = file.path(outputFolder, plotName),showCis = TRUE)
            
            # View the empirical calibration plot with  negative controls and HOIs plotted
            EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                        negControlSubset$seLogRr,
                                                        hoiSubset$logRr, 
                                                        hoiSubset$seLogRr,showCis = TRUE)
            
            # Save the empirical calibration plot with  negative controls and HOIs plotted
            plotName <- paste("calEffect_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
            EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                        negControlSubset$seLogRr,
                                                        hoiSubset$logRr, 
                                                        hoiSubset$seLogRr,
                                                        fileName = file.path(outputFolder, plotName),showCis = TRUE)
            
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
for (drugComparatorOutcome in drugComparatorOutcomesList) {
    for (analysisId in unique(analysisSummary$analysisId)) {
        currentAnalysisSubset <- analysisSummary[analysisSummary$analysisId == analysisId &
                                                     analysisSummary$targetId == drugComparatorOutcome$targetId &
                                                     analysisSummary$comparatorId == drugComparatorOutcome$comparatorId &
                                                     analysisSummary$outcomeId %in% outcomeList, ]
        
        for(currentOutcomeId in unique(currentAnalysisSubset$outcomeId)) {
            outputImageSuffix <- paste0("_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, "_o", currentOutcomeId, ".png")
            
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