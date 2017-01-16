#' @export
createAnalysesDetails <- function(outputFolder) {

  includedCovariateConceptIds <- c()
  excludedCovariateConceptIds <- readRDS(system.file("settings",
                                                     "htn_med_list",
                                                     package = "HypertensionCombination"))
  
  cohortset <- list(CD=34,
                    BC=23,
                    AC=13,
                    BD=24,
                    AD=14)
  comparatorset <- list(BC=23,
                        AC=13)
  
  outcomeset <- c(4320,4321, 420, 421, 0,1,2,3,4) 
  #composite + any death / composite + cardiocerebral death / stroke+MI+any death / stroke+MI+cc death/ any death/ cc death/MI/HF/STROKE
  
  dcos1 <- CohortMethod::createDrugComparatorOutcomes(targetId = 12,
                                                     comparatorId = 13,
                                                     excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                     outcomeIds = outcomeset)
  dcos1<-list(dcos1)
  dcos2 <- CohortMethod::createDrugComparatorOutcomes(targetId = 12,
                                                     comparatorId = 14,
                                                     excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                     outcomeIds = outcomeset)
  dcos2<-list(dcos2)
  dcos3 <- CohortMethod::createDrugComparatorOutcomes(targetId = 12,
                                                      comparatorId = 23,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos3<-list(dcos3)
  dcos4 <- CohortMethod::createDrugComparatorOutcomes(targetId = 12,
                                                      comparatorId = 24,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos4<-list(dcos4)
  dcos5 <- CohortMethod::createDrugComparatorOutcomes(targetId = 12,
                                                      comparatorId = 34,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos5<-list(dcos5)
  dcos6 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13,
                                                      comparatorId = 14,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos6<-list(dcos6)
  dcos7 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13,
                                                      comparatorId = 23,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos7<-list(dcos7)
  dcos8 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13,
                                                      comparatorId = 24,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos8<-list(dcos8)
  dcos9 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13,
                                                      comparatorId = 34,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos9<-list(dcos9)
  dcos10 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14,
                                                      comparatorId = 23,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos10<-list(dcos10)
  dcos11 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14,
                                                      comparatorId = 24,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos11<-list(dcos11)
  dcos12 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14,
                                                      comparatorId = 34,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos12<-list(dcos12)
  dcos13 <- CohortMethod::createDrugComparatorOutcomes(targetId = 23,
                                                      comparatorId = 24,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos13<-list(dcos13)
  dcos14 <- CohortMethod::createDrugComparatorOutcomes(targetId = 23,
                                                      comparatorId = 34,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos14<-list(dcos14)
  dcos15 <- CohortMethod::createDrugComparatorOutcomes(targetId = 24,
                                                      comparatorId = 34,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos15<-list(dcos15)
  drugComparatorOutcomesList <- c(dcos1,dcos2,dcos3,dcos4,dcos5,dcos6,dcos7,dcos8,dcos9,dcos10,dcos11,dcos12,dcos13,dcos14,dcos15)
  
  covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                              useCovariateDemographicsGender = TRUE,
                                                              useCovariateDemographicsRace = TRUE,
                                                              useCovariateDemographicsEthnicity = TRUE,
                                                              useCovariateDemographicsAge = TRUE, 
                                                              useCovariateDemographicsYear = TRUE,
                                                              useCovariateDemographicsMonth = FALSE,
                                                              useCovariateConditionOccurrence = TRUE,    
                                                              useCovariateConditionOccurrence365d = TRUE,
                                                              useCovariateConditionOccurrence30d = TRUE,
                                                              useCovariateConditionOccurrenceInpt180d = TRUE,
                                                              useCovariateConditionEra = TRUE, 
                                                              useCovariateConditionEraEver = TRUE,
                                                              useCovariateConditionEraOverlap = FALSE,
                                                              useCovariateConditionGroup = TRUE,
                                                              useCovariateConditionGroupMeddra = TRUE,
                                                              useCovariateConditionGroupSnomed = FALSE,
                                                              useCovariateDrugExposure = TRUE, 
                                                              useCovariateDrugExposure365d = TRUE,
                                                              useCovariateDrugExposure30d = TRUE, 
                                                              useCovariateDrugEra = TRUE,
                                                              useCovariateDrugEra365d = FALSE, 
                                                              useCovariateDrugEra30d = FALSE,
                                                              useCovariateDrugEraOverlap = FALSE, 
                                                              useCovariateDrugEraEver = TRUE,
                                                              useCovariateDrugGroup = TRUE, 
                                                              useCovariateProcedureOccurrence = TRUE,
                                                              useCovariateProcedureOccurrence365d = TRUE,
                                                              useCovariateProcedureOccurrence30d = TRUE,
                                                              useCovariateProcedureGroup = TRUE, 
                                                              useCovariateObservation = FALSE,
                                                              useCovariateObservation365d = FALSE, 
                                                              useCovariateObservation30d = FALSE,
                                                              useCovariateObservationCount365d = FALSE, 
                                                              useCovariateMeasurement = FALSE,
                                                              useCovariateMeasurement365d = FALSE, 
                                                              useCovariateMeasurement30d = FALSE,
                                                              useCovariateMeasurementCount365d = FALSE,
                                                              useCovariateMeasurementBelow = FALSE,
                                                              useCovariateMeasurementAbove = FALSE, 
                                                              useCovariateConceptCounts = TRUE,
                                                              useCovariateRiskScores = TRUE, 
                                                              useCovariateRiskScoresCharlson = TRUE,
                                                              useCovariateRiskScoresDCSI = TRUE, 
                                                              useCovariateRiskScoresCHADS2 = FALSE,
                                                              useCovariateRiskScoresCHADS2VASc = FALSE,
                                                              useCovariateInteractionYear = FALSE, 
                                                              useCovariateInteractionMonth = FALSE,
                                                              excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                              includedCovariateConceptIds = includedCovariateConceptIds,
                                                              deleteCovariatesSmallCount = 50)

  getDbCmDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(studyStartDate = "",
                                                                   studyEndDate = "",
                                                                   excludeDrugsFromCovariates = FALSE,
                                                                   firstExposureOnly = FALSE,
                                                                   removeDuplicateSubjects = TRUE,
                                                                   washoutPeriod = 0,
                                                                   covariateSettings = covarSettings)

  createStudyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = FALSE,
                                                                       washoutPeriod = 0,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 0,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 0,
                                                                       addExposureDaysToEnd = TRUE)

  # Fixing seed for reproducability:
  createPsArgs <- CohortMethod::createCreatePsArgs(prior = Cyclops::createPrior("laplace",
                                                                                exclude = c(0),
                                                                                useCrossValidation = TRUE),
                                                   control = Cyclops::createControl(noiseLevel = "quiet",
                                                                                    cvType = "auto",
                                                                                    tolerance  = 2e-07,
                                                                                    cvRepetitions = 10,
                                                                                    startingVariance = 0.01,
                                                                                    threads = 1))

  matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs(caliper = 0.25,
                                                      caliperScale = "standardized",
                                                      maxRatio = 1.0)

  omExcludedConcepts <- c()
  omIncludedConcepts <- c()
  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(modelType = "cox",
                                                                  stratified = FALSE,
                                                                  useCovariates = FALSE,
                                                                  excludeCovariateIds = omExcludedConcepts,
                                                                  includeCovariateIds = omIncludedConcepts)


  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 1,
                                                description = "Hypertension Combination",
                                                #targetType = 34,
                                                #comparatorType = "BC",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 2,
                                                description = "CD vs AC",
                                                targetType = "CD",
                                                comparatorType = "AC",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis3 <- CohortMethod::createCmAnalysis(analysisId = 3,
                                                description = "CD vs BD",
                                                targetType = "CD",
                                                comparatorType = "BD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 4,
                                                description = "CD vs AD",
                                                targetType = "CD",
                                                comparatorType = "AD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis5 <- CohortMethod::createCmAnalysis(analysisId = 5,
                                                description = "BC vs AC",
                                                targetType = "BC",
                                                comparatorType = "AC",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis6 <- CohortMethod::createCmAnalysis(analysisId = 6,
                                                description = "BC vs BD",
                                                targetType = "BC",
                                                comparatorType = "BD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis7 <- CohortMethod::createCmAnalysis(analysisId = 7,
                                                description = "BC vs AD",
                                                targetType = "BC",
                                                comparatorType = "AD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis8 <- CohortMethod::createCmAnalysis(analysisId = 8,
                                                description = "AC vs BD",
                                                targetType = "AC",
                                                comparatorType = "BD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  cmAnalysis9 <- CohortMethod::createCmAnalysis(analysisId = 9,
                                                description = "AC vs AD",
                                                targetType = "AC",
                                                comparatorType = "AD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysis10 <- CohortMethod::createCmAnalysis(analysisId = 10,
                                                description = "BD vs AD",
                                                targetType = "BD",
                                                comparatorType = "AD",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs1,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysisList <- list(cmAnalysis1)
#  cmAnalysisList <- list(cmAnalysis1,
#                         cmAnalysis2,
#                         cmAnalysis3,
#                         cmAnalysis4,
#                         cmAnalysis5,
#                         cmAnalysis6,
#                         cmAnalysis7,
#                         cmAnalysis8,
#                         cmAnalysis9,
#                         cmAnalysis10)

  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(outputFolder, "cmAnalysisList.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList.txt"))
}
