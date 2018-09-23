
# Study: ----
# [PUBLISH A THON] cabergoline vs bromocriptine 
# cardiac valve defects 

# CohortMethod Installation & Load ----


# Uncomment to install CohortMethod
# install.packages("devtools")
# library(devtools)
# devtools::install_github("ohdsi/SqlRender")
# devtools::install_github("ohdsi/DatabaseConnector")
# devtools::install_github("ohdsi/OhdsiRTools")
# devtools::install_github("ohdsi/FeatureExtraction", ref = "v2.0.2")
# devtools::install_github("ohdsi/CohortMethod", ref = "v2.5.0")
# devtools::install_github("ohdsi/EmpiricalCalibration")
# library(ggplot2)


options(fftempdir = 'D:/temp')

setwd('D:/projects/publish a thon/R/results/OPTM/Stratified Results')

# Load the Cohort Method library
library(CohortMethod) 
library(SqlRender)
library(EmpiricalCalibration)

# Data extraction ----

# TODO: Insert your connection details here
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms     = Sys.getenv("dbms"),
  server   = Sys.getenv("server"),
  port     = as.numeric(Sys.getenv("port")),
  user     = NULL,
  password = NULL
)



#CDM_TRUVEN_MDCD_V699.dbo
#CDM_TRUVEN_CCAE_V697.dbo
#CDM_Optum_Extended_SES_V694.dbo

cdmDatabaseSchema <- "CDM_TRUVEN_CCAE_V697.dbo"
cohortDatabaseSchema <- "Scratch.dbo"
cohortTable <- "HARDIN_CCAE_outcomes_broad"
cdmVersion <- "5" 
outputFolder <- "D:/projects/publish a thon/R/results/CCAE/Stratified Results"
maxCores <- parallel::detectCores()


if(!dir.exists(outputFolder)){
  dir.create(outputFolder, recursive = TRUE)
}
setwd(outputFolder)

targetCohortId <- 4991
comparatorCohortId <- 4992
outcomeCohortId <- 4993
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
                                         threads = 1,
                                         seed = 1234)


# PLEASE NOTE ----
# If you want to use your code in a distributed network study
# you will need to create a temporary cohort table with common cohort IDs.
# The code below ASSUMES you are only running in your local network 
# where common cohort IDs have already been assigned in the cohort table.

excludedConcepts <- c(1558471, 730548)

# Get all  Concept IDs for inclusion ----

includedConcepts <- c()


# Get all  Concept IDs for exclusion in the outcome model ----

omExcludedConcepts <- c()

# Get all  Concept IDs for inclusion exclusion in the outcome model ----

omIncludedConcepts <- c()


# Get all  Concept IDs for empirical calibration ----

negativeControlConcepts <- c(24609,      72990,   72993,   73008,   75911,   78228,   79864,   80463,   133727,                134718,                 136661,                 136773,                 136788,                 138479,                 139099,                 140641,                140648,                 192731,                 193255,                 194081,                 194083,                 195873,                 196163,                198400,                 200461,                 200528,                 200779,                 200845,                 201078,                 201254,                201620,                 201916,                 256531,                 257683,                 315078,                 374375,                 375281,                375827,                 381877,                 432738,                 433270,                 433577,                 434005,                 435796,                436785,                 436940,                 437246,                 437264,                 437827,                 437833,                 438398,                438720,                 440021,                 440329,                 440360,                 444239,                 444367,                 4016359,                4066371,              4079750,              4081648,              4084966,              4090425,              4115991,              4214376,                4308509)


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
                                                                useDemographicsEthnicity = TRUE,
                                                                useDemographicsIndexYear = TRUE,
                                                                useDemographicsIndexMonth = TRUE,
                                                                useDemographicsPriorObservationTime = FALSE,
                                                                useDemographicsPostObservationTime = FALSE,
                                                                useDemographicsTimeInCohort = FALSE,
                                                                useDemographicsIndexYearMonth = FALSE,
                                                                useConditionOccurrenceAnyTimePrior = FALSE,
                                                                useConditionOccurrenceLongTerm = TRUE,
                                                                useConditionOccurrenceMediumTerm = FALSE,
                                                                useConditionOccurrenceShortTerm = TRUE,
                                                                useConditionOccurrenceInpatientAnyTimePrior = FALSE,
                                                                useConditionOccurrenceInpatientLongTerm = FALSE,
                                                                useConditionOccurrenceInpatientMediumTerm = TRUE,
                                                                useConditionOccurrenceInpatientShortTerm = FALSE,
                                                                useConditionEraAnyTimePrior = TRUE,
                                                                useConditionEraLongTerm = FALSE,
                                                                useConditionEraMediumTerm = FALSE,
                                                                useConditionEraShortTerm = FALSE,
                                                                useConditionEraOverlapping = TRUE,
                                                                useConditionEraStartLongTerm = FALSE,
                                                                useConditionEraStartMediumTerm = FALSE,
                                                                useConditionEraStartShortTerm = FALSE,
                                                                useConditionGroupEraAnyTimePrior = FALSE,
                                                                useConditionGroupEraLongTerm = FALSE,
                                                                useConditionGroupEraMediumTerm = FALSE,
                                                                useConditionGroupEraShortTerm = FALSE,
                                                                useConditionGroupEraOverlapping = FALSE,
                                                                useConditionGroupEraStartLongTerm = FALSE,
                                                                useConditionGroupEraStartMediumTerm = FALSE,
                                                                useConditionGroupEraStartShortTerm = FALSE,
                                                                useDrugExposureAnyTimePrior = FALSE,
                                                                useDrugExposureLongTerm = FALSE,
                                                                useDrugExposureMediumTerm = FALSE,
                                                                useDrugExposureShortTerm = FALSE, 
                                                                useDrugEraAnyTimePrior = TRUE,
                                                                useDrugEraLongTerm = FALSE,
                                                                useDrugEraMediumTerm = FALSE,
                                                                useDrugEraShortTerm = FALSE,
                                                                useDrugEraOverlapping = TRUE, 
                                                                useDrugEraStartLongTerm = FALSE, 
                                                                useDrugEraStartMediumTerm = FALSE,
                                                                useDrugEraStartShortTerm = FALSE,
                                                                useDrugGroupEraAnyTimePrior = FALSE,
                                                                useDrugGroupEraLongTerm = FALSE,
                                                                useDrugGroupEraMediumTerm = FALSE,
                                                                useDrugGroupEraShortTerm = FALSE,
                                                                useDrugGroupEraOverlapping = FALSE,
                                                                useDrugGroupEraStartLongTerm = FALSE,
                                                                useDrugGroupEraStartMediumTerm = FALSE,
                                                                useDrugGroupEraStartShortTerm = FALSE,
                                                                useProcedureOccurrenceAnyTimePrior = FALSE,
                                                                useProcedureOccurrenceLongTerm = FALSE,
                                                                useProcedureOccurrenceMediumTerm = FALSE,
                                                                useProcedureOccurrenceShortTerm = FALSE,
                                                                useDeviceExposureAnyTimePrior = FALSE,
                                                                useDeviceExposureLongTerm = FALSE,
                                                                useDeviceExposureMediumTerm = FALSE,
                                                                useDeviceExposureShortTerm = FALSE,
                                                                useMeasurementAnyTimePrior = FALSE,
                                                                useMeasurementLongTerm = TRUE, 
                                                                useMeasurementMediumTerm = FALSE,
                                                                useMeasurementShortTerm = TRUE,
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
                                                                useDcsi = TRUE, 
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
                                                                    riskWindowStart = 0,
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
matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs() # Using only defaults 
stratifyByPsArgs1 <- CohortMethod::createStratifyByPsArgs(numberOfStrata = 5) 

cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                              description = "[PUBLISH A THON] cabergoline vs bromocriptine cardiac valve defects",
                                              getDbCohortMethodDataArgs = getDbCmDataArgs,
                                              createStudyPopArgs = createStudyPopArgs,
                                              createPs = TRUE,
                                              createPsArgs = createPsArgs1,
                                              trimByPs = FALSE,
                                              trimByPsArgs = trimByPsArgs1,
                                              trimByPsToEquipoise = FALSE,
                                              trimByPsToEquipoiseArgs = trimByPsToEquipoiseArgs1,
                                              matchOnPs = FALSE,
                                              matchOnPsArgs = matchOnPsArgs1,
                                              stratifyByPs = TRUE,
                                              stratifyByPsArgs = stratifyByPsArgs1,
                                              computeCovariateBalance = TRUE,
                                              fitOutcomeModel = TRUE,
                                              fitOutcomeModelArgs = fitOutcomeModelArgs1)



cmAnalysisList <- list(cmAnalysis1)


# Run the analysis ----
result <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,
                                      cdmDatabaseSchema = cdmDatabaseSchema,
                                      exposureDatabaseSchema = cohortDatabaseSchema,
                                      exposureTable = cohortTable,
                                      outcomeDatabaseSchema = cohortDatabaseSchema,
                                      outcomeTable = cohortTable,
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

saveRDS(result, file="results.rds")


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
                                                  negControlSubset$seLogRr,
                                                  showCis = TRUE)
      
      # Save the empirical calibration plot with only negative controls
      plotName <- paste("calEffectNoHois_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr,showCis = TRUE,
                                                  fileName = file.path(outputFolder, plotName))
      
      # View the empirical calibration plot with  negative controls and HOIs plotted
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr,
                                                  hoiSubset$logRr, showCis = TRUE,
                                                  hoiSubset$seLogRr)
      
      # Save the empirical calibration plot with  negative controls and HOIs plotted
      plotName <- paste("calEffect_a",analysisId, "_t", drugComparatorOutcome$targetId, "_c", drugComparatorOutcome$comparatorId, ".png", sep = "")
      EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                  negControlSubset$seLogRr,
                                                  hoiSubset$logRr, 
                                                  hoiSubset$seLogRr,showCis = TRUE,
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
      computeMdrr(studyPop)
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

library(ggplot2)
kmPlot <- plotKaplanMeier(studyPop,censorMarks = FALSE, confidenceIntervals = TRUE, includeZero = FALSE, 
                          dataTable = TRUE, dataCutoff = 0.9, treatmentLabel="Cabergoline", comparatorLabel="Bromocriptine", 
                          title = "OPTUM SES")
ggsave(filename = "OPTM_studypop_kmplot.jpg", plot=kmPlot)

kmPlot <- plotKaplanMeier(studyPop,censorMarks = FALSE, confidenceIntervals = TRUE,includeZero = TRUE, 
                          dataTable = TRUE, dataCutoff = 0.9,treatmentLabel="Cabergoline", comparatorLabel="Bromocriptine", 
                          title = "OPTUM SES")
ggsave(filename = "OPTM_studypop_kmplot_0.jpg", plot=kmPlot)


x <- computeMdrr(studyPop)
write.csv(x, file.path(outputFolder , "MDRR.csv"), row.names = FALSE)
write.csv(analysisSummary, file.path(outputFolder , "analysis_summary.csv"), row.names = FALSE)
write.csv(outcomeSummaryOutput, file.path(outputFolder , "outcomeSummaryOutput.csv"), row.names = FALSE)
write.csv(outcomeModelOutput, file.path(outputFolder , "outcomeModelOutput.csv"), row.names = FALSE)

library(imager)
CCAE_covar <- load.image("D:/projects/publish a thon/R/results/CCAE/Stratified Results/covBalScatter_a1_t4991_c4992_o4993.png")
OPTM_covar <- load.image("D:/projects/publish a thon/R/results/OPTM/Stratified Results/covBalScatter_a1_t4991_c4992_o4993.png")
CCAE_negCtrl <- load.image("D:/projects/publish a thon/R/results/CCAE/Stratified Results/calEffectNoHois_a1_t4991_c4992.png")
OPTM_negCtrl <- load.image("D:/projects/publish a thon/R/results/OPTM/Stratified Results/calEffectNoHois_a1_t4991_c4992.png")

op <- par(mfrow = c(2,2),
          oma = c(5,4,0,0) + 0.1,
          mar = c(0,0,1,1) + 0.1)
plot(CCAE_covar)
plot(CCAE_negCtrl)
plot(OPTM_covar)
plot(OPTM_negCtrl)
