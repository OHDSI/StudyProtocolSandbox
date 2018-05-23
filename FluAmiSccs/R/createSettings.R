#' @export
createSettings <- function(settingsFolder)
{
  # 1. Create analyses settings

  # set observation period, i.e. not fixed on exposure date
  getDbSccsDataArgs1 <- SelfControlledCaseSeries::createGetDbSccsDataArgs(
    deleteCovariatesSmallCount = 0,
    studyStartDate             = "20080501",
    studyEndDate               = "20150531",
    maxCasesPerOutcome         = 0,
    exposureIds                = "exposureId"
  )
  # observation period truncated, fixed on exposure date
  getDbSccsDataArgs2 <- SelfControlledCaseSeries::createGetDbSccsDataArgs(
    useNestingCohort           = TRUE,
    nestingCohortId            = 59870,
    deleteCovariatesSmallCount = 0,
    studyStartDate             = "20080501",
    studyEndDate               = "20150531",
    maxCasesPerOutcome         = 0,
    exposureIds                = "exposureId"
  )

  # create covariates
  exposureCovar <- SelfControlledCaseSeries::createCovariateSettings(
    label                 = "Exposure of interest",
    includeCovariateIds   = "exposureId",
    stratifyById          = TRUE,
    start                 = 0,
    addExposedDaysToStart = FALSE,
    end                   = 0,
    addExposedDaysToEnd   = TRUE,
    firstOccurrenceOnly   = FALSE         # TAR start: visit end+1d; TAR end: visit start+7d; set in createRiskInterval.sql
  )

  # exposureCovar <- SelfControlledCaseSeries::createCovariateSettings(
  #   label                 = "Exposure of interest",
  #   includeCovariateIds   = "exposureId",
  #   stratifyById          = TRUE,
  #   start                 = 0,
  #   addExposedDaysToStart = TRUE,
  #   end                   = 7,
  #   addExposedDaysToEnd   = FALSE,
  #   firstOccurrenceOnly   = FALSE     # Could've set TAR this way without using createRiskInterval.sql
  # )

  createSccsEraDataArgs1 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(
    naivePeriod          = 0,
    firstOutcomeOnly     = FALSE,
    covariateSettings    = list(exposureCovar)
  )
  preExposureCovar <- SelfControlledCaseSeries::createCovariateSettings(
    label                 = "Pre-Exposure window",
    includeCovariateIds   = "exposureId",
    start                 = -14,
    addExposedDaysToStart = FALSE,
    end                   = -1,
    addExposedDaysToEnd   = FALSE,
    splitPoints           = c(-8),
    stratifyById          = TRUE,
    firstOccurrenceOnly   = FALSE
  )
  createSccsEraDataArgs2 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(
    naivePeriod          = 0,
    firstOutcomeOnly     = FALSE,
    covariateSettings    = list(preExposureCovar, exposureCovar)
  )
  ageSettings <- SelfControlledCaseSeries::createAgeSettings(includeAge = TRUE, ageKnots = 3)
  seasonalitySettings <- SelfControlledCaseSeries::createSeasonalitySettings(includeSeasonality = TRUE, seasonKnots = 5)
  createSccsEraDataArgs3 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(
    naivePeriod          = 0,
    firstOutcomeOnly     = FALSE,
    covariateSettings    = list(exposureCovar),
    ageSettings          = ageSettings,
    seasonalitySettings  = seasonalitySettings
  )
  createSccsEraDataArgs4 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(
    naivePeriod          = 0,
    firstOutcomeOnly     = FALSE,
    covariateSettings    = list(preExposureCovar, exposureCovar),
    ageSettings          = ageSettings,
    seasonalitySettings  = seasonalitySettings
  )
  createSccsEraDataArgs5 <- SelfControlledCaseSeries::createCreateSccsEraDataArgs(
    naivePeriod               = 0,
    firstOutcomeOnly          = FALSE,
    covariateSettings         = list(exposureCovar),
    eventDependentObservation = TRUE
  )
  fitSccsModelArgs <- SelfControlledCaseSeries::createFitSccsModelArgs()

  # full study period analysis settings
  sccsAnalysis1 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 1,
    description           = "Simple SCCS",
    getDbSccsDataArgs     = getDbSccsDataArgs1,
    createSccsEraDataArgs = createSccsEraDataArgs1,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis2 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 2,
    description           = "SCCS with -14:-8, -7:-1 pre-exposure windows",
    getDbSccsDataArgs     = getDbSccsDataArgs1,
    createSccsEraDataArgs = createSccsEraDataArgs2,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis3 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 3,
    description           = "SCCS with age and seasonality adjustment",
    getDbSccsDataArgs     = getDbSccsDataArgs1,
    createSccsEraDataArgs = createSccsEraDataArgs3,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis4 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 4,
    description           = "SCCS with -14:-8, -7:-1 pre-exposure windows and age and seasonality adjustment",
    getDbSccsDataArgs     = getDbSccsDataArgs1,
    createSccsEraDataArgs = createSccsEraDataArgs4,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis5 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 5,
    description           = "SCCS with event-dependent observation period adjustment",
    getDbSccsDataArgs     = getDbSccsDataArgs1,
    createSccsEraDataArgs = createSccsEraDataArgs5,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  # truncated study period analysis settings
  sccsAnalysis6 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 6,
    description           = "Simple SCCS; truncated",
    getDbSccsDataArgs     = getDbSccsDataArgs2,
    createSccsEraDataArgs = createSccsEraDataArgs1,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis7 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 7,
    description           = "SCCS with -14:-8, -7:-1 pre-exposure windows; truncated",
    getDbSccsDataArgs     = getDbSccsDataArgs2,
    createSccsEraDataArgs = createSccsEraDataArgs2,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis8 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 8,
    description           = "SCCS with age and seasonality adjustment; truncated",
    getDbSccsDataArgs     = getDbSccsDataArgs2,
    createSccsEraDataArgs = createSccsEraDataArgs3,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis9 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 9,
    description           = "SCCS with -14:-8, -7:-1 pre-exposure windows and age and seasonality adjustment; truncated",
    getDbSccsDataArgs     = getDbSccsDataArgs2,
    createSccsEraDataArgs = createSccsEraDataArgs4,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysis10 <- SelfControlledCaseSeries::createSccsAnalysis(
    analysisId            = 10,
    description           = "SCCS with event-dependent observation period adjustment; truncated",
    getDbSccsDataArgs     = getDbSccsDataArgs2,
    createSccsEraDataArgs = createSccsEraDataArgs5,
    fitSccsModelArgs      = fitSccsModelArgs
  )
  sccsAnalysisList <- list(sccsAnalysis1, sccsAnalysis2, sccsAnalysis3, sccsAnalysis4, sccsAnalysis5,
                           sccsAnalysis6, sccsAnalysis7, sccsAnalysis8, sccsAnalysis9, sccsAnalysis10)
  SelfControlledCaseSeries::saveSccsAnalysisList(sccsAnalysisList, file.path(settingsFolder, "sccsAnalysisList.json"))

  # 2. Create EO pairs

  # with exclusions
  cohortsToCreate <- read.csv(system.file("settings", "cohortsToCreate.csv", package = "nejmfluami"), stringsAsFactors = FALSE)[-1:-2, ] #remove cohort for creating nesting cohort, common cold cohort
  toPairs <- as.data.frame(cbind(
    c(cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0 & cohortsToCreate$visit == "any"] * 100, # IDs for TAR adjusted flu cohorts
      cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0 & cohortsToCreate$visit == "IP"]  * 100,
      cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 0 & cohortsToCreate$visit == "OP"]  * 100),
    c(rep(cohortsToCreate$cohortId[cohortsToCreate$isOutcome == 1 & cohortsToCreate$visit == "IP"], 3))))
  names(toPairs) <- c("t", "o")

  exposureOutcomeList <- list()
  for (i in 1:nrow(toPairs))
  {
    exposureOutcome <- SelfControlledCaseSeries::createExposureOutcome(
      exposureId = toPairs$t[i],
      outcomeId  = toPairs$o[i]
    )
    exposureOutcomeList[[length(exposureOutcomeList)+1]] <- exposureOutcome
  }
  SelfControlledCaseSeries::saveExposureOutcomeList(exposureOutcomeList, file.path(settingsFolder, "exposureOutcomeList.json"))
}
