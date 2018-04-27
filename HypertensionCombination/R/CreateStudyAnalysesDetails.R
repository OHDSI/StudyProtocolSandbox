#' @export
createAnalysesDetails <- function(outputFolder) {

  includedCovariateConceptIds <- c()
  excludedCovariateConceptIds <- readRDS(system.file("settings",
                                                     "htn_med_list",
                                                     package = "HypertensionCombination"))
  
  cohortset <- list(AC30=1330,
                    AD30=1430,
                    CD30=3430,
                    AC180=13180,
                    AD180=14180,
                    CD180=34180,
                    AC365=13365,
                    AD365=14365,
                    CD365=34365,
                    AC730=13730,
                    AD730=14730,
                    CD730=34730,
                    
                    ACmale=1318001,
                    ADmale=1418001,
                    CDmale=3418001,
                    
                    ACfemale=1318002,
                    ADfemale=1418002,
                    CDfemale=3418002,
                    
                    AC60ormore=1318061,
                    AD60ormore=1418061,
                    CD60ormore=3418061,
                    
                    ACunder60=1318059,
                    ADunder60=1418059,
                    CDunder60=3418059,
                    
                    ACwoDM=1318011,
                    ADwoDM=1418011,
                    CDwoDM=3418011)
  
  comparatorset <- list(AC30=1330,
                        AD30=1430,
                        CD30=3430,
                        AC180=13180,
                        AD180=14180,
                        CD180=34180,
                        AC365=13365,
                        AD365=14365,
                        CD365=34365,
                        AC365=13730,
                        AD365=14730,
                        CD365=34730,
                        
                        ACmale=1318001,
                        ADmale=1418001,
                        CDmale=3418001,
                        
                        ACfemale=1318002,
                        ADfemale=1418002,
                        CDfemale=3418002,
                        
                        AC60ormore=1318061,
                        AD60ormore=1418061,
                        CD60ormore=3418061,
                        
                        ACunder60=1318059,
                        ADunder60=1418059,
                        CDunder60=3418059,
                        
                        ACwoDM=1318011,
                        ADwoDM=1418011,
                        CDwoDM=3418011)
  
  outcomeset <- c(0, 4320, 1,2,3,4,6
                  , 378424, 4004352, 4280726, 133141, 137053, 140480, 380731,
                  381581, 75344,  80809, 376415,  4253054, 437409, 199067, 434272, 373478, 140641, 139099,
                  4142905, 195862, 4271016, 375552, 380038, 135473, 138102, 29735, 4153877, 74396, 134870, 74855,
                  200169, 194997,  192367, 4267582, 434872, 4329707, 4288544, 198075
                  ) 
  #any death / #composite + any death / MI/HF/STROKE
  #c(4320,4321, 420, 421, 0,1,2,3,4) 
  #composite + any death / composite + cardiocerebral death / stroke+MI+any death / stroke+MI+cc death/ any death/ cc death/MI/HF/STROKE
  
  dcos1 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1330,
                                                     comparatorId = 1430,
                                                     excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                     outcomeIds = outcomeset)
  dcos1<-list(dcos1)
  
  dcos2 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3430,
                                                      comparatorId = 1430,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos2<-list(dcos2)
  
  dcos3 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3430,
                                                      comparatorId = 1330,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos3<-list(dcos3)
  
  dcos4 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13180,
                                                      comparatorId = 14180,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos4<-list(dcos4)
  
  dcos5 <- CohortMethod::createDrugComparatorOutcomes(targetId = 34180,
                                                      comparatorId = 14180,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos5<-list(dcos5)
  
  dcos6 <- CohortMethod::createDrugComparatorOutcomes(targetId = 34180,
                                                      comparatorId = 13180,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos6<-list(dcos6)
  
  dcos7 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13365,
                                                      comparatorId = 14365,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos7<-list(dcos7)
  
  dcos8 <- CohortMethod::createDrugComparatorOutcomes(targetId = 34365,
                                                      comparatorId = 14365,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos8<-list(dcos8)
  
  dcos9 <- CohortMethod::createDrugComparatorOutcomes(targetId = 34365,
                                                      comparatorId = 13365,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos9<-list(dcos9)
  
  dcos10 <- CohortMethod::createDrugComparatorOutcomes(targetId = 13730,
                                                      comparatorId = 14730,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos10<-list(dcos10)
  
  dcos11 <- CohortMethod::createDrugComparatorOutcomes(targetId = 34730,
                                                      comparatorId = 14730,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos11<-list(dcos11)
  
  dcos12 <- CohortMethod::createDrugComparatorOutcomes(targetId = 34730,
                                                      comparatorId = 13730,
                                                      excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                      outcomeIds = outcomeset)
  dcos12<-list(dcos12)
  ##Subpopulation : male
  dcos21 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1318001,
                                                       comparatorId = 1418001,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos21<-list(dcos21)
  
  dcos22 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418001,
                                                       comparatorId = 1418001,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos22<-list(dcos22)
  
  dcos23 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418001,
                                                       comparatorId = 1318001,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos23<-list(dcos23)
  
  ##Subpopulation : Female
  
  dcos24 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1318002,
                                                       comparatorId = 1418002,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos24<-list(dcos24)
  
  dcos25 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418002,
                                                       comparatorId = 1418002,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos25<-list(dcos25)
  
  dcos26 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418002,
                                                       comparatorId = 1318002,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos26<-list(dcos26)
  
  ##Subpopulation : Age 60 or more
  
  dcos31 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1318061,
                                                       comparatorId = 1418061,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos31<-list(dcos31)
  
  dcos32 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418061,
                                                       comparatorId = 1418061,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos32<-list(dcos32)
  
  dcos33 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418061,
                                                       comparatorId = 1318061,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos33<-list(dcos33)
  
  ##Subpopulation : Age under 60
  
  dcos34 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1318059,
                                                       comparatorId = 1418059,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos34<-list(dcos34)
  
  dcos35 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418059,
                                                       comparatorId = 1418059,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos35<-list(dcos35)
  
  dcos36 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418059,
                                                       comparatorId = 1318059,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos36<-list(dcos36)
  
  ##Subpopulation : population without DM
  
  dcos37 <- CohortMethod::createDrugComparatorOutcomes(targetId = 1318011,
                                                       comparatorId = 1418011,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos37<-list(dcos37)
  
  dcos38 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418011,
                                                       comparatorId = 1418011,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos38<-list(dcos38)
  
  dcos39 <- CohortMethod::createDrugComparatorOutcomes(targetId = 3418011,
                                                       comparatorId = 1318011,
                                                       excludedCovariateConceptIds = excludedCovariateConceptIds,
                                                       outcomeIds = outcomeset)
  dcos39<-list(dcos39)
  
  
  drugComparatorOutcomesList1 <- c(
      dcos1,
      dcos2,
      dcos3)
  
  drugComparatorOutcomesList2 <- c(
      dcos4,
      dcos5,
      dcos6)
  
  drugComparatorOutcomesList3 <- c(
      dcos7,
      dcos8,
      dcos9)
  
  drugComparatorOutcomesList4 <- c(
      dcos10,
      dcos11,
      dcos12)
  
  drugComparatorOutcomesList5 <- c(
      dcos21,
      dcos22,
      dcos23)
  
  drugComparatorOutcomesList6 <- c(
      dcos24,
      dcos25,
      dcos26)
  
  drugComparatorOutcomesList7 <- c(
      dcos31,
      dcos32,
      dcos33)
  
  drugComparatorOutcomesList8 <- c(
      dcos34,
      dcos35,
      dcos36)
  
  drugComparatorOutcomesList9 <- c(
      dcos37,
      dcos38,
      dcos39)
  
  covarSettings <- FeatureExtraction::createCovariateSettings(useCovariateDemographics = TRUE,
                                                              useCovariateDemographicsGender = TRUE,
                                                              useCovariateDemographicsRace = TRUE,
                                                              useCovariateDemographicsEthnicity = TRUE,
                                                              useCovariateDemographicsAge = TRUE, 
                                                              useCovariateDemographicsYear = TRUE,
                                                              useCovariateDemographicsMonth = FALSE,
                                                              useCovariateConditionOccurrence = TRUE,    
                                                              useCovariateConditionOccurrenceLongTerm = TRUE,
                                                              useCovariateConditionOccurrenceShortTerm = TRUE,
                                                              useCovariateConditionOccurrenceInptMediumTerm = TRUE,
                                                              useCovariateConditionEra = TRUE, 
                                                              useCovariateConditionEraEver = TRUE,
                                                              useCovariateConditionEraOverlap = FALSE,
                                                              useCovariateConditionGroup = TRUE,
                                                              useCovariateConditionGroupMeddra = TRUE,
                                                              useCovariateConditionGroupSnomed = TRUE,
                                                              useCovariateDrugExposure = TRUE, 
                                                              useCovariateDrugExposureLongTerm = TRUE,
                                                              useCovariateDrugExposureShortTerm = TRUE, 
                                                              useCovariateDrugEra = TRUE,
                                                              useCovariateDrugEraLongTerm = TRUE, 
                                                              useCovariateDrugEraShortTerm = TRUE,
                                                              useCovariateDrugEraOverlap = TRUE, 
                                                              useCovariateDrugEraEver = TRUE,
                                                              useCovariateDrugGroup = TRUE, 
                                                              useCovariateProcedureOccurrence = TRUE,
                                                              useCovariateProcedureOccurrenceLongTerm = TRUE,
                                                              useCovariateProcedureOccurrenceShortTerm = TRUE,
                                                              useCovariateProcedureGroup = TRUE, 
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
                                                              deleteCovariatesSmallCount = 50,
															  longTermDays = 365,
															  mediumTermDays = 180,
															  shortTermDays = 30,
															  windowEndDays = 0)

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
                                                                       riskWindowStart = 30,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 0,
                                                                       addExposureDaysToEnd = TRUE)
  
  
  createStudyPopArgs2 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = FALSE,
                                                                       washoutPeriod = 0,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 180,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 0,
                                                                       addExposureDaysToEnd = TRUE)
  
  createStudyPopArgs3 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = FALSE,
                                                                       washoutPeriod = 0,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 365,
                                                                       addExposureDaysToStart = FALSE,
                                                                       riskWindowEnd = 0,
                                                                       addExposureDaysToEnd = TRUE)
  
  createStudyPopArgs4 <- CohortMethod::createCreateStudyPopulationArgs(firstExposureOnly = FALSE,
                                                                       washoutPeriod = 0,
                                                                       removeDuplicateSubjects = TRUE,
                                                                       removeSubjectsWithPriorOutcome = TRUE,
                                                                       minDaysAtRisk = 0,
                                                                       riskWindowStart = 730,
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
                                                                                    threads = 5))

  matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs(caliper = 0.15,
                                                      caliperScale = "standardized",
                                                      maxRatio = 1.0)

  omExcludedConcepts <- excludedCovariateConceptIds
  omIncludedConcepts <- c()
  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(modelType = "cox",
                                                                  stratified = TRUE,
                                                                  useCovariates = FALSE,
                                                                  excludeCovariateIds = omExcludedConcepts,
                                                                  includeCovariateIds = omIncludedConcepts)


  cmAnalysis1 <- CohortMethod::createCmAnalysis(analysisId = 30,
                                                description = "Hypertension Combination (risk started after 30days)",
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
  
  cmAnalysis2 <- CohortMethod::createCmAnalysis(analysisId = 180,
                                                description = "Hypertension Combination (risk started after 180days)",
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
  
  cmAnalysis3 <- CohortMethod::createCmAnalysis(analysisId = 365,
                                                description = "Hypertension Combination (risk started after 365days)",
                                                #targetType = 34,
                                                #comparatorType = "BC",
                                                getDbCohortMethodDataArgs = getDbCmDataArgs,
                                                createStudyPopArgs = createStudyPopArgs3,
                                                createPs = TRUE,
                                                createPsArgs = createPsArgs,
                                                matchOnPs = TRUE,
                                                matchOnPsArgs = matchOnPsArgs1,
                                                computeCovariateBalance = TRUE,
                                                fitOutcomeModel = TRUE,
                                                fitOutcomeModelArgs = fitOutcomeModelArgs1)
  
  cmAnalysis4 <- CohortMethod::createCmAnalysis(analysisId = 730,
                                                description = "Hypertension Combination (risk started after 365days)",
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
  
  cmAnalysis5 <- CohortMethod::createCmAnalysis(analysisId = 18001,
                                                description = "Hypertension Combination (risk started after 180days)-male",
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
  
  cmAnalysis6 <- CohortMethod::createCmAnalysis(analysisId = 18002,
                                                description = "Hypertension Combination (risk started after 180days)-female",
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
  
  cmAnalysis7 <- CohortMethod::createCmAnalysis(analysisId = 18061,
                                                description = "Hypertension Combination (risk started after 180days)-age 60 or over",
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
  
  cmAnalysis8 <- CohortMethod::createCmAnalysis(analysisId = 18059,
                                                description = "Hypertension Combination (risk started after 180days)-age under 60",
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
  
  
  
  cmAnalysis9 <- CohortMethod::createCmAnalysis(analysisId = 18011,
                                                description = "Hypertension Combination (risk started after 180days)-without DM",
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

  
  cmAnalysisList1 <- list(cmAnalysis1)
  cmAnalysisList2 <- list(cmAnalysis2)
  cmAnalysisList3 <- list(cmAnalysis3)
  cmAnalysisList4 <- list(cmAnalysis4)
  cmAnalysisList5 <- list(cmAnalysis5)
  cmAnalysisList6 <- list(cmAnalysis6)
  cmAnalysisList7 <- list(cmAnalysis7)
  cmAnalysisList8 <- list(cmAnalysis8)
  cmAnalysisList9 <- list(cmAnalysis9)
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

  CohortMethod::saveCmAnalysisList(cmAnalysisList1, file.path(outputFolder, "cmAnalysisList1.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList2, file.path(outputFolder, "cmAnalysisList2.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList3, file.path(outputFolder, "cmAnalysisList3.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList4, file.path(outputFolder, "cmAnalysisList4.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList5, file.path(outputFolder, "cmAnalysisList5.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList6, file.path(outputFolder, "cmAnalysisList6.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList7, file.path(outputFolder, "cmAnalysisList7.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList8, file.path(outputFolder, "cmAnalysisList8.txt"))
  CohortMethod::saveCmAnalysisList(cmAnalysisList9, file.path(outputFolder, "cmAnalysisList9.txt"))
  
  
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList1,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList1.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList2,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList2.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList3,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList3.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList4,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList4.txt"))
  
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList5,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList5.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList6,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList6.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList7,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList7.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList8,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList8.txt"))
  CohortMethod::saveDrugComparatorOutcomesList(drugComparatorOutcomesList9,
                                               file.path(outputFolder,
                                                         "drugComparatorOutcomesList9.txt"))
  
}