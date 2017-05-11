#' @export
createAnalysesDetails <- function(outputFolder) {

  includedCovariateConceptIds <- c()
  excludedCovariateConceptIds <- readRDS(system.file("settings",
                                                     "htn_med_list",
                                                     package = "HypertensionCombination"))
  
  cohortset <- list(AC=13,
                    AD=13,
                    CD=34,
                    AC_ITT = 131,
                    AD_ITT = 141,
                    CD_ITT = 341)
  comparatorset <- list(AC=13,
                        AD=13,
                        CD=34,
                        AC_ITT = 131,
                        AD_ITT = 141,
                        CD_ITT = 341)
  
  outcomeset <- c(0,4320,2,3,4, 378424, 4004352, 4280726, 133141, 137053, 140480, 380731,
                  381581, 75344,  80809, 376415,  4224118, 4253054, 437409, 199067, 434272, 373478, 140641, 139099,
                  4142905, 195862, 4271016, 375552, 380038, 135473, 138102, 29735, 4153877, 74396, 134870, 74855,
                  200169, 194997,  192367, 4267582, 434872, 4329707, 4288544, 198075) 
  #any death / #composite + any death / MI/HF/STROKE
  #c(4320,4321, 420, 421, 0,1,2,3,4) 
  #composite + any death / composite + cardiocerebral death / stroke+MI+any death / stroke+MI+cc death/ any death/ cc death/MI/HF/STROKE
  
  dcos1 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14,
                                                     comparatorId = 34,
                                                     excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                     outcomeIds = outcomeset)
  dcos1<-list(dcos1)
  
  dcos2 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1454,
                                                      comparatorId = 3454,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos2<-list(dcos2)
  
  dcos3 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1456,
                                                      comparatorId = 3456,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos3<-list(dcos3)
  
  dcos4 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13,
                                                     comparatorId = 34,
                                                     excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                     outcomeIds = outcomeset)
  dcos4<-list(dcos4)
  
  dcos5 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1354,
                                                      comparatorId = 3454,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos5<-list(dcos5)
  
  dcos6 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1356,
                                                      comparatorId = 3456,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos6<-list(dcos6)
  
  dcos7 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14,
                                                      comparatorId = 13,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos7<-list(dcos7)
  
  dcos8 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1454,
                                                      comparatorId = 1354,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos8<-list(dcos8)
  
  dcos9 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1456,
                                                      comparatorId = 1356,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos9<-list(dcos9)
  
  dcos10 <- CohortMethod::createDrugComparatorOutcomes(targetId = 141,
                                                      comparatorId = 341,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos10<-list(dcos10)
  
  dcos11 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14154,
                                                      comparatorId = 34154,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos11<-list(dcos11)
  
  dcos12 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14156,
                                                      comparatorId = 34156,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos12<-list(dcos12)
  dcos13 <- CohortMethod::createDrugComparatorOutcomes(targetId = 131,
                                                      comparatorId = 341,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos13<-list(dcos13)
  
  dcos14 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13154,
                                                      comparatorId = 34154,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos14<-list(dcos14)
  
  dcos15 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13156,
                                                      comparatorId = 34156,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos15<-list(dcos15)
  dcos16 <- CohortMethod::createDrugComparatorOutcomes(targetId = 141,
                                                      comparatorId = 131,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos16<-list(dcos16)
  
  dcos17 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14154,
                                                      comparatorId = 13154,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos17<-list(dcos17)
  
  dcos18 <- CohortMethod::createDrugComparatorOutcomes(targetId = 14156,
                                                      comparatorId = 13156,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos18<-list(dcos18)
  
  drugComparatorOutcomesList <- c(dcos1,dcos2,dcos3,dcos4,dcos5,dcos6,
                                  dcos7,dcos8,dcos9,dcos10,dcos11,dcos12,
                                  dcos13,dcos14,dcos15,dcos16,dcos17,dcos18)
  
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
                                                              useCovariateConditionGroupSnomed = TRUE,
                                                              useCovariateDrugExposure = TRUE, 
                                                              useCovariateDrugExposure365d = TRUE,
                                                              useCovariateDrugExposure30d = TRUE, 
                                                              useCovariateDrugEra = TRUE,
                                                              useCovariateDrugEra365d = TRUE, 
                                                              useCovariateDrugEra30d = TRUE,
                                                              useCovariateDrugEraOverlap = TRUE, 
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
                                                                   firstExposureOnly = TRUE,
                                                                   removeDuplicateSubjects = TRUE,
                                                                   washoutPeriod = 0,
                                                                   covariateSettings = covarSettings)

  #createStudyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = TRUE,
  #                                                                     washoutPeriod = 0,
  #                                                                     removeDuplicateSubjects = TRUE,
  #                                                                     removeSubjectsWithPriorOutcome = TRUE,
  #                                                                     minDaysAtRisk = 0,
  #                                                                     riskWindowStart = 0,
  #                                                                     addExposureDaysToStart = FALSE,
  #                                                                     riskWindowEnd = 0,
  #                                                                     addExposureDaysToEnd = TRUE)
  
  createStudyPopArgs2 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = TRUE,
                                                                       washoutPeriod = 0,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 30,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 0,
                                                                       addExposureDaysToEnd = TRUE)
  
  #createStudyPopArgs3 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = TRUE,
  #                                                                     washoutPeriod = 0,
  #                                                                     removeDuplicateSubjects = TRUE,
  #                                                                     removeSubjectsWithPriorOutcome = TRUE,
  #                                                                     minDaysAtRisk = 60,
  #                                                                     riskWindowStart = 0,
  #                                                                     addExposureDaysToStart = FALSE,
  #                                                                     riskWindowEnd = 0,
  #                                                                     addExposureDaysToEnd = TRUE)
  
  createStudyPopArgs4 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = TRUE,
                                                                       washoutPeriod = 0,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 180,
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


  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 30,
                                                description = "Hypertension Combination (risk started after 30days)",
                                                #targetType = 34,
                                                #comparatorType = "BC",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs2,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 180,
                                                description = "Hypertension Combination (risk started after 180days)",
                                                #targetType = 34,
                                                #comparatorType = "BC",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs4,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)

  
  cmAnalysisList <- list(cmAnalysis1, cmAnalysis2)
#  cmAnalysisList <- list(cmAnalysis1, cmAnalysis2)
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
