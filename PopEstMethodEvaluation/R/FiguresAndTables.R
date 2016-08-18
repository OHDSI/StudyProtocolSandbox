# @file FiguresAndTables.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of PopEstMethodEvaluation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' @export
createFiguresAndTables <- function(exportFolder) {
    # exportFolder <- file.path(workFolder, "shareableResults")
    estimatesFile <- file.path(exportFolder, "Estimates.csv")
    estimates <- read.csv(estimatesFile)
    analysisRefFile <- file.path(exportFolder, "AnalysisRef.csv")
    analysisRef <-  read.csv(analysisRefFile)
    injectionSummaryFile <- file.path(exportFolder, "InjectionSummary.csv")
    injectedSignals <-  read.csv(injectionSummaryFile)

    injectedSignals$outcomeId <- injectedSignals$newOutcomeId
    data <- merge(estimates, injectedSignals[, c("exposureId", "outcomeId", "targetEffectSize", "trueEffectSize", "trueEffectSizeFirstExposure")])

    errorModels <- data.frame(method = analysisRef$method,
                              analysisId = analysisRef$analysisId,
                              meanIntercept = 0,
                              meanSlope = 0,
                              sdIntercept = 0,
                              sdSlope = 0)
    performance <- data.frame()
    for (i in 1:nrow(analysisRef)) {
        # i <- 8
        method <- analysisRef$method[i]
        analysisId <- analysisRef$analysisId[i]
        analysisData <- data[data$analysisId == analysisId & data$method == method, ]

        analysisPerformance <- MethodEvaluation::computeMetrics(logRr = analysisData$logRr,
                                                                seLogRr = analysisData$seLogRr,
                                                                trueLogRr = log(analysisData$targetEffectSize))
        analysisPerformance$method <- method
        analysisPerformance$analysisId <- analysisId
        analysisPerformance$trueRr <- exp(analysisPerformance$trueLogRr)
        performance <- rbind(performance, analysisPerformance)

        trueAndObsFile <- file.path(exportFolder, paste0("trueAndObs_",method, "_a", analysisId, ".png"))
        EmpiricalCalibration::plotTrueAndObserved(logRr = analysisData$logRr,
                                                  seLogRr = analysisData$seLogRr,
                                                  trueLogRr = log(analysisData$targetEffectSize),
                                                  xLabel = "Incidence rate ratio",
                                                  fileName = trueAndObsFile)

        rocsFile <- file.path(exportFolder, paste0("aucs_",method, "_a", analysisId,".png"))
        MethodEvaluation::plotRocsInjectedSignals(logRr = analysisData$logRr,
                                                  trueLogRr = log(analysisData$targetEffectSize),
                                                  showAucs = TRUE,
                                                  fileName = rocsFile)

        nullDistFile <- file.path(exportFolder, paste0("nullDist_",method, "_a", analysisId,".png"))
        EmpiricalCalibration::plotCalibrationEffect(logRrNegatives = analysisData$logRr[analysisData$targetEffectSize == 1],
                                                    seLogRrNegatives = analysisData$seLogRr[analysisData$targetEffectSize == 1],
                                                    xLabel = "Incidence rate ratio",
                                                    fileName = nullDistFile)

        calibrationFile <- file.path(exportFolder, paste0("calibration_",method, "_a", analysisId,".png"))
        EmpiricalCalibration::plotCalibration(logRr = analysisData$logRr[analysisData$targetEffectSize == 1],
                                              seLogRr = analysisData$seLogRr[analysisData$targetEffectSize == 1],
                                              useMcmc = FALSE,
                                              fileName = calibrationFile)

        errorModel <- EmpiricalCalibration::fitSystematicErrorModel(logRr = analysisData$logRr,
                                                                    seLogRr = analysisData$seLogRr,
                                                                    trueLogRr = log(analysisData$targetEffectSize))
        idx <- errorModels$analysisId == analysisId & errorModels$method == method
        errorModels$meanIntercept[idx] <- errorModel[1]
        errorModels$meanSlope[idx] <- errorModel[2]
        errorModels$sdIntercept[idx] <- errorModel[3]
        errorModels$sdSlope[idx] <- errorModel[4]

        calibrated <- EmpiricalCalibration::calibrateConfidenceInterval(logRr = analysisData$logRr,
                                                                        seLogRr = analysisData$seLogRr,
                                                                        model = errorModel)

        calibrated$targetEffectSize <- analysisData$targetEffectSize
        trueAndObsCaliFile <- file.path(exportFolder, paste0("trueAndObsCali_",method, "_a", analysisId, ".png"))
        EmpiricalCalibration::plotTrueAndObserved(logRr = calibrated$logRr,
                                                  seLogRr = calibrated$seLogRr,
                                                  trueLogRr = log(calibrated$targetEffectSize),
                                                  xLabel = "Incidence rate ratio",
                                                  fileName = trueAndObsCaliFile)


        coverageFile <- file.path(exportFolder, paste0("coverage_",method, "_a", analysisId,".png"))
        EmpiricalCalibration::plotCiCalibration(logRr = analysisData$logRr,
                                                seLogRr = analysisData$seLogRr,
                                                trueLogRr = log(analysisData$targetEffectSize),
                                                fileName = coverageFile)
    }
    errorModelsFile <- file.path(exportFolder, paste0("errorModels.csv"))
    write.csv(errorModels, file = errorModelsFile, row.names = FALSE)
    performanceFile <- file.path(exportFolder, paste0("performance.csv"))
    write.csv(performance, file = performanceFile, row.names = FALSE)
}

#' Package the results for sharing with OHDSI researchers
#'
#' @details
#' This function packages the results.
#'
#' @param connectionDetails   An object of type \code{connectionDetails} as created using the
#'                            \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                            DatabaseConnector package.
#' @param cdmDatabaseSchema   Schema name where your patient-level data in OMOP CDM format resides.
#'                            Note that for SQL Server, this should include both the database and
#'                            schema name, for example 'cdm_data.dbo'.
#' @param workFolder          Name of local folder to place results; make sure to use forward slashes
#'                            (/)
#'
#' @export
packageResults <- function(connectionDetails, cdmDatabaseSchema, workFolder) {
    injectionSummaryFile <- file.path(workFolder, "injectionSummary.rds")
    if (!file.exists(injectionSummaryFile))
        stop("Cannot find injection summary file. Please run injectSignals first.")
    injectedSignals <- readRDS(injectionSummaryFile)

    exportFolder <- file.path(workFolder, "export")
    if (!file.exists(exportFolder))
        dir.create(exportFolder)

    createMetaData(addCdmSource = TRUE,
                   connectionDetails = connectionDetails,
                   cdmDatabaseSchema = cdmDatabaseSchema,
                   addPackageVersions = TRUE,
                   package = "PopEstMethodEvaluation",
                   exportFolder = exportFolder)

    ### Create overall results table and analysisRef table ###
    estimates <- data.frame()
    analysisRef <- data.frame()

    # SCCS #
    sccsSummaryFile <- file.path(workFolder, "sccsSummary.rds")
    if (!file.exists(sccsSummaryFile)) {
        stop(paste0("Couldn't find ", sccsSummaryFile, ", please make sure you've successfully completed runSelfControlledCaseSeries"))
    }
    sccsEstimates <- readRDS(sccsSummaryFile)
    sccsEstimates$method <- "sccs"
    colnames(sccsEstimates)[colnames(sccsEstimates) == "logRr(Exposure of interest)"] <- "logRr"
    colnames(sccsEstimates)[colnames(sccsEstimates) == "seLogRr(Exposure of interest)"] <- "seLogRr"
    estimates <- rbind(estimates, sccsEstimates[, c("exposureId", "outcomeId", "method", "analysisId", "logRr", "seLogRr")])

    sccsAnalysisListFile <- system.file("settings", "sccsAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(sccsAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(sccsAnalysisList, "description"))
    analysisRef <- rbind(analysisRef, data.frame(method = "sccs",
                                                 analysisId = analysisId,
                                                 description = description))

    # CohortMethod #
    cmSummaryFile <- file.path(workFolder, "cmSummary.rds")
    if (!file.exists(cmSummaryFile)) {
        stop(paste0("Couldn't find ", cmSummaryFile, ", please make sure you've successfully completed runCohortMethod"))
    }
    cmEstimates <- readRDS(cmSummaryFile)
    cmEstimates$method <- "cm"
    colnames(cmEstimates)[colnames(cmEstimates) == "targetId"] <- "exposureId"
    estimates <- rbind(estimates, cmEstimates[, c("exposureId", "outcomeId", "method", "analysisId", "logRr", "seLogRr")])

    cmAnalysisListFile <- system.file("settings", "cmAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(cmAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(cmAnalysisList, "description"))
    analysisRef <- rbind(analysisRef, data.frame(method = "cm",
                                                 analysisId = analysisId,
                                                 description = description))


    # SelfControlledCohort #
    sccSummaryFile <- file.path(workFolder, "sccSummary.rds")
    if (!file.exists(sccSummaryFile)) {
        stop(paste0("Couldn't find ", sccSummaryFile, ", please make sure you've successfully completed runSelfControlledCohort"))
    }
    sccEstimates <- readRDS(sccSummaryFile)
    sccEstimates$method <- "scc"
    colnames(sccEstimates)[colnames(sccEstimates) == "targetId"] <- "exposureId"
    estimates <- rbind(estimates, sccEstimates[, c("exposureId", "outcomeId", "method", "analysisId", "logRr", "seLogRr")])

    sccAnalysisListFile <- system.file("settings", "sccAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    sccAnalysisList <- SelfControlledCohort::loadSccAnalysisList(sccAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(sccAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(sccAnalysisList, "description"))
    analysisRef <- rbind(analysisRef, data.frame(method = "scc",
                                                 analysisId = analysisId,
                                                 description = description))

    # ICTPD #
    ictpdSummaryFile <- file.path(workFolder, "ictpdSummary.rds")
    if (!file.exists(ictpdSummaryFile)) {
        stop(paste0("Couldn't find ", ictpdSummaryFile, ", please make sure you've successfully completed run runIctpd"))
    }
    ictpdEstimates <- readRDS(ictpdSummaryFile)
    ictpdEstimates$method <- "ictpd"
    colnames(ictpdEstimates)[colnames(ictpdEstimates) == "exposureofinterest"] <- "exposureId"
    colnames(ictpdEstimates)[colnames(ictpdEstimates) == "outcomeofinterest"] <- "outcomeId"
    estimates <- rbind(estimates, ictpdEstimates[, c("exposureId", "outcomeId", "method", "analysisId", "logRr", "seLogRr")])

    ictpdAnalysisListFile <- system.file("settings", "ictpdAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    ictpdAnalysisList <- IcTemporalPatternDiscovery::loadIctpdAnalysisList(ictpdAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(ictpdAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(ictpdAnalysisList, "description"))
    analysisRef <- rbind(analysisRef, data.frame(method = "ictpd",
                                                 analysisId = analysisId,
                                                 description = description))

    # Case-control #
    ccSummaryFile <- file.path(workFolder, "ccSummary.rds")
    if (!file.exists(ccSummaryFile)) {
        stop(paste0("Couldn't find ", ccSummaryFile, ", please make sure you've successfully completed run runIctpd"))
    }
    ccEstimates <- readRDS(ccSummaryFile)
    ccEstimates$method <- "cc"
    estimates <- rbind(estimates, ccEstimates[, c("exposureId", "outcomeId", "method", "analysisId", "logRr", "seLogRr")])

    ccAnalysisListFile <- system.file("settings", "ccAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    ccAnalysisList <- CaseControl::loadCcAnalysisList(ccAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(ccAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(ccAnalysisList, "description"))
    analysisRef <- rbind(analysisRef, data.frame(method = "cc",
                                                 analysisId = analysisId,
                                                 description = description))

    estimatesFile <- file.path(exportFolder, "Estimates.csv")
    write.csv(estimates, estimatesFile, row.names = FALSE)

    analysisRefFile <- file.path(exportFolder, "AnalysisRef.csv")
    write.csv(analysisRef, analysisRefFile, row.names = FALSE)

    injectedSignals <- injectedSignals[, c("exposureId", "outcomeId", "newOutcomeId", "targetEffectSize", "trueEffectSize", "trueEffectSizeFirstExposure")]
    injectionSummaryFile <- file.path(exportFolder, "InjectionSummary.csv")
    write.csv(injectedSignals, injectionSummaryFile, row.names = FALSE)

    ### Add all to zip file ###
    zipName <- file.path(exportFolder, "StudyResults.zip")
    OhdsiSharing::compressFolder(exportFolder, zipName)
    writeLines(paste("\nStudy results are ready for sharing at:", zipName))
}

#' Create metadata file
#'
#' @details
#' Creates a file containing metadata about the source data (taken from the cdm_source table) and R
#' package versions.
#'
#' @param addCdmSource        Add information from the CDM_SOURCE table?
#' @param connectionDetails   An object of type \code{connectionDetails} as created using the
#'                            \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                            DatabaseConnector package.
#' @param cdmDatabaseSchema   Schema name where your patient-level data in OMOP CDM format resides.
#'                            Note that for SQL Server, this should include both the database and
#'                            schema name, for example 'cdm_data.dbo'.
#' @param exportFolder        The name of the folder where the metadata file should be created.
#' @param addPackageVersions  Add information on the versions of dependency packages?
#' @param package             Name of the package for which we want to list the versions of its dependencies.#'
#'
#' @export
createMetaData <- function(addCdmSource = TRUE,
                           connectionDetails,
                           cdmDatabaseSchema,
                           addPackageVersions = TRUE,
                           package,
                           exportFolder) {
    lines <- c()
    if (addCdmSource) {
        conn <- DatabaseConnector::connect(connectionDetails)
        sql <- "SELECT * FROM @cdm_database_schema.cdm_source"
        sql <- SqlRender::renderSql(sql, cdm_database_schema = cdmDatabaseSchema)$sql
        sql <- SqlRender::translateSql(sql, targetDialect = connectionDetails$dbms)$sql
        cdmSource <- DatabaseConnector::querySql(conn, sql)
        RJDBC::dbDisconnect(conn)
        lines <- c(lines, paste(names(cdmSource), cdmSource[1, ], sep = ": "))
    }
    if (addPackageVersions) {
        installed <- utils::installed.packages()[,c("Package", "Version", "Depends", "Imports")]
        pkg <- installed[installed[,"Package"] == package,]
        depends <- strsplit(pkg["Depends"], ",")[[1]]
        imports <- strsplit(pkg["Imports"], ",")[[1]]
        dependencies <- c(depends, imports)
        dependencies <- gsub("\n| (.*)", "", dependencies)
        dependencies <- installed[installed[, "Package"] %in% c(dependencies, package),]
        lines <- c(lines,paste0(dependencies[, "Package"], " version: ", dependencies[, "Version"]))
    }
    write(lines, file.path(exportFolder, "MetaData.txt"))
    invisible(NULL)
}
