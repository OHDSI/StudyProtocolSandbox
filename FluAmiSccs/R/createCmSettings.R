#' @export
createCmSettings <- function(settingsFolder)
{

  # 1. create CM analysis settings

  # covariateSettings <- FeatureExtraction::createDefaultCovariateSettings(
  #   excludedCovariateConceptIds = c(4266367,  # Influenza
  #                                   4277745,  # Disease due to Orthomyxoviridae
  #                                   4181583,  # Upper respiratory infection
  #                                   4193169,  # Viral respiratory infection
  #                                   4339468), # Ear, nose and throat disorder
  #   addDescendantsToExclude     = TRUE
  # )

  covariateSettings <- FeatureExtraction::createCovariateSettings(
    useDemographicsGender            = TRUE,
    useDemographicsAgeGroup          = TRUE,
    useDemographicsRace              = TRUE,
    useDemographicsEthnicity         = TRUE,
    useDemographicsIndexYear         = TRUE,
    useDemographicsIndexMonth        = TRUE,
    useConditionGroupEraLongTerm     = TRUE,
    useConditionGroupEraShortTerm    = TRUE,
    useDrugGroupEraLongTerm          = TRUE,
    useDrugGroupEraShortTerm         = TRUE,
    useDrugGroupEraOverlapping       = TRUE,
    useProcedureOccurrenceLongTerm   = TRUE,
    useProcedureOccurrenceShortTerm  = TRUE,
    useDeviceExposureLongTerm        = TRUE,
    useDeviceExposureShortTerm       = TRUE,
    useMeasurementLongTerm           = TRUE,
    useMeasurementShortTerm          = TRUE,
    useMeasurementRangeGroupLongTerm = TRUE,
    useObservationLongTerm           = TRUE,
    useObservationShortTerm          = TRUE,
    useCharlsonIndex                 = TRUE,
    useDcsi                          = TRUE,
    useChads2                        = TRUE,
    useChads2Vasc                    = TRUE,
    endDays                          = -1,
    excludedCovariateConceptIds      = c(4266367,  # Influenza
                                         4170143,  # Respiratory tract infection
                                         4277745), # Disease due to Orthomyxoviridae
    addDescendantsToExclude          = TRUE
  )

  getDbCmDataArgs1 <- CohortMethod::createGetDbCohortMethodDataArgs(
    washoutPeriod              = 365,
    firstExposureOnly          = FALSE,
    removeDuplicateSubjects    = TRUE,
    restrictToCommonPeriod     = TRUE,
    studyStartDate             = "20080501",
    studyEndDate               = "20150531",
    excludeDrugsFromCovariates = FALSE,
    covariateSettings          = covariateSettings,
    maxCohortSize              = 0
  )

  studyPopArgs1 <- CohortMethod::createCreateStudyPopulationArgs(
    removeSubjectsWithPriorOutcome = TRUE,
    firstExposureOnly              = FALSE,
    washoutPeriod                  = 0,
    removeDuplicateSubjects        = TRUE,
    minDaysAtRisk                  = 0,
    riskWindowStart                = 0,
    addExposureDaysToStart         = TRUE,
    riskWindowEnd                  = 7,
    addExposureDaysToEnd           = FALSE
  )

  control <- Cyclops::createControl(
    noiseLevel       = "quiet",
    cvType           = "auto",
    tolerance        = 2e-07,
    cvRepetitions    = 1,
    startingVariance = 0.01,
    seed             = 123
  )

  createPsArgs1 <- CohortMethod::createCreatePsArgs(control = control)

  matchOnPsArgs1 <- CohortMethod::createMatchOnPsArgs(
    caliper      = 0.2,
    caliperScale = "standardized logit",
    maxRatio     = 1
  )

  fitOutcomeModelArgs1 <- CohortMethod::createFitOutcomeModelArgs(
    useCovariates = FALSE,
    modelType     = "cox",
    stratified    = TRUE
  )

  cmAnalysis1 <- CohortMethod::createCmAnalysis(
    analysisId                = 1,
    description               = "hazards 7d time-at-risk",
    getDbCohortMethodDataArgs = getDbCmDataArgs1,
    createStudyPopArgs        = studyPopArgs1,
    createPs                  = TRUE,
    createPsArgs              = createPsArgs1,
    matchOnPs                 = TRUE,
    matchOnPsArgs             = matchOnPsArgs1,
    computeCovariateBalance   = TRUE,
    fitOutcomeModel           = TRUE,
    fitOutcomeModelArgs       = fitOutcomeModelArgs1
  )

  cmAnalysisList <- list(cmAnalysis1)
  CohortMethod::saveCmAnalysisList(cmAnalysisList, file.path(settingsFolder, "cmAnalysisList.json"))

  # 2. create TCOs

  cohortsToCreate <- read.csv(system.file("settings", "cohortsToCreate.csv", package = "nejmfluami"), stringsAsFactors = FALSE)
  outcomeIds <- cohortsToCreate[cohortsToCreate$isOutcome == 1, 1]
  tcos <- CohortMethod::createDrugComparatorOutcomes(
    targetId     = 5987,
    comparatorId = 6629,
    outcomeIds   = outcomeIds
  )
  tcoList <- list(tcos)
  CohortMethod::saveDrugComparatorOutcomesList(tcoList, file.path(settingsFolder, "tcoList.json"))

}
