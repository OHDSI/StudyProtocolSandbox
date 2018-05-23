#' @export
execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    cohortDatabaseSchema,
                    cohortTable,
                    outputFolder,
                    createCohorts    = FALSE,
                    runSccs          = FALSE,
                    analyzeResults   = FALSE,
                    runCm            = FALSE,
                    analyzeCmResults = FALSE)
{
  start <- Sys.time()

  if (createCohorts)
  {
    if (!file.exists(outputFolder))
      dir.create(outputFolder)
    db <- gsub("\\..*", "" , cdmDatabaseSchema)
    dbOutputFolder <- file.path(outputFolder, db)
    if (!file.exists(dbOutputFolder))
      dir.create(dbOutputFolder)

    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    .createCohorts(connection           = connection,
                   cdmDatabaseSchema    = cdmDatabaseSchema,
                   cohortDatabaseSchema = cohortDatabaseSchema,
                   cohortTable          = cohortTable,
                   oracleTempSchema     = NULL,
                   outputFolder         = dbOutputFolder
    )

    # create nesting cohort
    sql <- SqlRender::loadRenderTranslateSql(
      sqlFilename            = "createNestingCohort.sql",
      packageName            = "nejmfluami",
      dbms                   = connectionDetails$dbms,
      oracleTempSchema       = NULL,
      cohort_database_schema = cohortDatabaseSchema,
      cohort_table           = cohortTable
    )
    DatabaseConnector::executeSql(connection = connection, sql = sql)

    # create adjusted TARs for IP flu visits
    cohortsToCreate <- read.csv(system.file("settings", "CohortsToCreate.csv", package = "nejmfluami"))[-1:-2, ]
    fluCohortIds <- cohortsToCreate[cohortsToCreate$isOutcome == 0, 1]
    sql <- SqlRender::loadRenderTranslateSql(
      sqlFilename            = "createRiskInterval.sql",
      packageName            = "nejmfluami",
      dbms                   = connectionDetails$dbms,
      oracleTempSchema       = NULL,
      cohort_database_schema = cohortDatabaseSchema,
      cohort_table           = cohortTable,
      new_ip_flu_cohort_ids  = fluCohortIds * 100,
      ip_flu_cohort_ids      = fluCohortIds
    )
    DatabaseConnector::executeSql(connection = connection, sql = sql)

  }

  if (runSccs)
  {
    if (!file.exists(outputFolder))
      dir.create(outputFolder)
    db <- gsub("\\..*", "" , cdmDatabaseSchema)
    dbOutputFolder <- file.path(outputFolder, db)
    if (!file.exists(dbOutputFolder))
      dir.create(dbOutputFolder)
    sccsOutputFolder <- file.path(dbOutputFolder, "sccsOutput")
    if (!file.exists(sccsOutputFolder))
      dir.create(sccsOutputFolder)

    sccsAnalysisListFile <- system.file("settings", "sccsAnalysisList.json", package = "nejmfluami")
    sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
    exposureOutcomeListFile <- system.file("settings", "exposureOutcomeList.json", package = "nejmfluami")
    exposureOutcomeList <- SelfControlledCaseSeries::loadExposureOutcomeList(exposureOutcomeListFile)
    sccsResult <- SelfControlledCaseSeries::runSccsAnalyses(
      connectionDetails           = connectionDetails,
      cdmDatabaseSchema           = cdmDatabaseSchema,
      exposureDatabaseSchema      = cohortDatabaseSchema,
      exposureTable               = cohortTable,
      outcomeDatabaseSchema       = cohortDatabaseSchema,
      outcomeTable                = cohortTable,
      nestingCohortDatabaseSchema = cohortDatabaseSchema,
      nestingCohortTable          = cohortTable,
      sccsAnalysisList            = sccsAnalysisList,
      exposureOutcomeList         = exposureOutcomeList,
      cdmVersion                  = 5,
      outputFolder                = sccsOutputFolder,
      getDbSccsDataThreads        = 1,
      createSccsEraDataThreads    = 10,
      fitSccsModelThreads         = 10,
      cvThreads                   = 10
    )
    sccsSummary <- SelfControlledCaseSeries::summarizeSccsAnalyses(sccsResult)
    sccsSummaryFile <- file.path(sccsOutputFolder, "sccsSummary.rds")
    base::saveRDS(sccsSummary, sccsSummaryFile)
  }

  if (analyzeResults)
  {
    nejmfluami::analyzeResults(cdmDatabaseSchema = cdmDatabaseSchema,
                               outputFolder      = outputFolder)
  }

  if (runCm)
  {
    if (!file.exists(outputFolder))
      dir.create(outputFolder)
    db <- gsub("\\..*", "" , cdmDatabaseSchema)
    dbOutputFolder <- file.path(outputFolder, db)
    if (!file.exists(dbOutputFolder))
      dir.create(dbOutputFolder)
    cmOutputFolder <- file.path(dbOutputFolder, "cmOutput")
    if (!file.exists(cmOutputFolder))
      dir.create(cmOutputFolder)

    maxCores <- parallel::detectCores()
    cmAnalysisListFile <- system.file("settings", "cmAnalysisList.json", package = "nejmfluami")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    tcoListFile <- system.file("settings", "tcoList.json", package = "nejmfluami")
    tcoList <- CohortMethod::loadDrugComparatorOutcomesList(tcoListFile)
    cmResult <- CohortMethod::runCmAnalyses(
      connectionDetails            = connectionDetails,
      cdmDatabaseSchema            = cdmDatabaseSchema,
      exposureDatabaseSchema       = cohortDatabaseSchema,
      exposureTable                = cohortTable,
      outcomeDatabaseSchema        = cohortDatabaseSchema,
      outcomeTable                 = cohortTable,
      outputFolder                 = cmOutputFolder,
      cmAnalysisList               = cmAnalysisList,
      cdmVersion                   = 5,
      drugComparatorOutcomesList   = tcoList,
      getDbCohortMethodDataThreads = 1,
      createStudyPopThreads        = min(3, maxCores),
      createPsThreads              = 1, #min(3, maxCores),
      psCvThreads                  = min(16, maxCores),
      computeCovarBalThreads       = min(3, maxCores),
      trimMatchStratifyThreads     = min(10, maxCores),
      refitPsForEveryOutcome       = FALSE
    )
    cmSummary <- CohortMethod::summarizeAnalyses(cmResult)
    cmSummaryFile <- file.path(cmOutputFolder, "cmSummary.rds")
    base::saveRDS(cmSummary, cmSummaryFile)
  }

  if (analyzeCmResults)
  {
    nejmfluami::analyzeCmResults(cdmDatabaseSchema = cdmDatabaseSchema,
                                 outputFolder      = outputFolder)
  }

  delta <- Sys.time() - start
  writeLines(paste("Completed analyses in", signif(delta, 3), attr(delta, "units")))
}
