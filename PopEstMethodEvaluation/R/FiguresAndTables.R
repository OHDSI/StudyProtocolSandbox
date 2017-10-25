# @file FiguresAndTables.R
#
# Copyright 2017 Observational Health Data Sciences and Informatics
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
    # exportFolder <- file.path(workFolder, "export")
    plotFolder <- file.path(exportFolder, "plot")
    if (!file.exists(plotFolder))
        dir.create(plotFolder)
    estimatesFile <- file.path(exportFolder, "Estimates.csv")
    estimates <- read.csv(estimatesFile, stringsAsFactors = FALSE)
    analysisRefFile <- file.path(exportFolder, "AnalysisRef.csv")
    analysisRef <-  read.csv(analysisRefFile, stringsAsFactors = FALSE)
    injectionSummaryFile <- file.path(exportFolder, "InjectionSummary.csv")
    injectedSignals <-  read.csv(injectionSummaryFile, stringsAsFactors = FALSE)
    negativeControlFile <- file.path(exportFolder, "negativeControls.csv")
    negativeControls <- read.csv(negativeControlFile, stringsAsFactors = FALSE)
    negativeControls$stratum <- negativeControls$outcomeName
    negativeControls$stratum[negativeControls$type == "Outcome control"] <- negativeControls$targetName[negativeControls$type == "Outcome control"]
    negativeControls$exposureId <- negativeControls$targetId
    injectedSignals <- merge(injectedSignals, negativeControls[, c("exposureId", "outcomeId", "stratum")])
    injectedSignals$outcomeId <- injectedSignals$newOutcomeId
    negativeControls$targetEffectSize <- 1
    negativeControls$trueEffectSize <- 1
    negativeControls$trueEffectSizeFirstExposure <- 1

    groundTruth <- rbind(injectedSignals[, c("exposureId", "outcomeId", "targetEffectSize", "trueEffectSize", "trueEffectSizeFirstExposure", "stratum")],
                         negativeControls[, c("exposureId", "outcomeId", "targetEffectSize", "trueEffectSize", "trueEffectSizeFirstExposure", "stratum")])
    data <- merge(estimates, groundTruth)

    errorModels <- data.frame(method = analysisRef$method,
                              analysisId = analysisRef$analysisId,
                              meanIntercept = 0,
                              meanSlope = 0,
                              sdIntercept = 0,
                              sdSlope = 0)
    strata <- c(unique(groundTruth$stratum), "All")
    performance <- data.frame()
    for (i in 1:nrow(analysisRef)) {
        for (stratum in strata) {
            # i <- 1
            method <- analysisRef$method[i]
            analysisId <- analysisRef$analysisId[i]
            if (stratum == "All") {
                analysisData <- data[data$analysisId == analysisId & data$method == method, ]
            } else {
                analysisData <- data[data$analysisId == analysisId & data$method == method & data$stratum == stratum, ]
            }
            analysisData <- analysisData[!is.na(analysisData$seLogRr), ]
            if (sum(analysisData$trueEffectSize == 1) > 0 && sum(analysisData$trueEffectSize != 1) > 0) {
                analysisPerformance <- MethodEvaluation::computeMetrics(logRr = analysisData$logRr,
                                                                        seLogRr = analysisData$seLogRr,
                                                                        trueLogRr = log(analysisData$targetEffectSize))
                analysisPerformance$method <- method
                analysisPerformance$analysisId <- analysisId
                analysisPerformance$stratum <- stratum
                analysisPerformance$trueRr <- exp(analysisPerformance$trueLogRr)
                performance <- rbind(performance, analysisPerformance)

                trueAndObsFile <- file.path(plotFolder, paste0("trueAndObs_",method, "_a", analysisId, "_", stratum, ".png"))
                EmpiricalCalibration::plotTrueAndObserved(logRr = analysisData$logRr,
                                                          seLogRr = analysisData$seLogRr,
                                                          trueLogRr = log(analysisData$targetEffectSize),
                                                          xLabel = "Incidence rate ratio",
                                                          fileName = trueAndObsFile)

                rocsFile <- file.path(plotFolder, paste0("aucs_",method, "_a", analysisId, "_", stratum, ".png"))
                MethodEvaluation::plotRocsInjectedSignals(logRr = analysisData$logRr,
                                                          trueLogRr = log(analysisData$targetEffectSize),
                                                          showAucs = TRUE,
                                                          fileName = rocsFile)

                nullDistFile <- file.path(plotFolder, paste0("nullDist_",method, "_a", analysisId, "_", stratum, ".png"))
                EmpiricalCalibration::plotCalibrationEffect(logRrNegatives = analysisData$logRr[analysisData$targetEffectSize == 1],
                                                            seLogRrNegatives = analysisData$seLogRr[analysisData$targetEffectSize == 1],
                                                            xLabel = "Incidence rate ratio",
                                                            fileName = nullDistFile)

                # calibrationFile <- file.path(exportFolder, paste0("calibration_",method, "_a", analysisId,".png"))
                # EmpiricalCalibration::plotCalibration(logRr = analysisData$logRr[analysisData$targetEffectSize == 1],
                #                                       seLogRr = analysisData$seLogRr[analysisData$targetEffectSize == 1],
                #                                       useMcmc = FALSE,
                #                                       fileName = calibrationFile)
                #
                # errorModel <- EmpiricalCalibration::fitSystematicErrorModel(logRr = analysisData$logRr,
                #                                                             seLogRr = analysisData$seLogRr,
                #                                                             trueLogRr = log(analysisData$targetEffectSize))
                # idx <- errorModels$analysisId == analysisId & errorModels$method == method
                # errorModels$meanIntercept[idx] <- errorModel[1]
                # errorModels$meanSlope[idx] <- errorModel[2]
                # errorModels$sdIntercept[idx] <- errorModel[3]
                # errorModels$sdSlope[idx] <- errorModel[4]
                #
                # calibrated <- EmpiricalCalibration::calibrateConfidenceInterval(logRr = analysisData$logRr,
                #                                                                 seLogRr = analysisData$seLogRr,
                #                                                                 model = errorModel)
                #
                # calibrated$targetEffectSize <- analysisData$targetEffectSize
                # trueAndObsCaliFile <- file.path(exportFolder, paste0("trueAndObsCali_",method, "_a", analysisId, ".png"))
                # EmpiricalCalibration::plotTrueAndObserved(logRr = calibrated$logRr,
                #                                           seLogRr = calibrated$seLogRr,
                #                                           trueLogRr = log(calibrated$targetEffectSize),
                #                                           xLabel = "Incidence rate ratio",
                #                                           fileName = trueAndObsCaliFile)
                #
                #
                # coverageFile <- file.path(exportFolder, paste0("coverage_",method, "_a", analysisId,".png"))
                # EmpiricalCalibration::plotCiCalibration(logRr = analysisData$logRr,
                #                                         seLogRr = analysisData$seLogRr,
                #                                         trueLogRr = log(analysisData$targetEffectSize),
                #                                         fileName = coverageFile)
            }
        }
    }
    # errorModelsFile <- file.path(exportFolder, paste0("errorModels.csv"))
    # write.csv(errorModels, file = errorModelsFile, row.names = FALSE)
    performanceFile <- file.path(plotFolder, paste0("performance.csv"))
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
packageResults <- function(connectionDetails, cdmDatabaseSchema, databaseName, workFolder) {
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
    allControls <- read.csv(file.path(workFolder , "allControls.csv"), stringsAsFactors = FALSE)
    # Add controls not in database:
    ohdsiNegativeControls <- readRDS(system.file("ohdsiNegativeControls.rds", package = "MethodEvaluation"))
    ohdsiNegativeControls$oldOutcomeId <- ohdsiNegativeControls$outcomeId
    ohdsiNegativeControls$stratum <- ohdsiNegativeControls$outcomeName
    idx <- ohdsiNegativeControls$type == "Outcome control"
    ohdsiNegativeControls$stratum[idx] <- ohdsiNegativeControls$targetName[idx]
    ohdsiNegativeControls <- ohdsiNegativeControls[, c("targetId", "targetName", "comparatorId", "comparatorName", "nestingId", "nestingName", "oldOutcomeId", "outcomeName", "type", "stratum")]
    fullGrid <- do.call("rbind", replicate(4, ohdsiNegativeControls, simplify = FALSE))
    fullGrid$targetEffectSize <- rep(c(1, 1.5, 2, 4), each = nrow(ohdsiNegativeControls))
    idx <- fullGrid$targetEffectSize != 1
    fullGrid$outcomeName[idx] <- paste0(fullGrid$outcomeName[idx], ", RR=", fullGrid$targetEffectSize[idx])
    allControls <- merge(allControls, fullGrid, all.y = TRUE)
    toJson <- function(object) {
        object <- OhdsiRTools:::convertAttrToMember(object)
        return(jsonlite::toJSON(object, pretty = TRUE, force = TRUE, null = "null", auto_unbox = TRUE))
    }

    estimates <- data.frame()
    analysisRef <- data.frame()

    # SCCS #
    sccsAnalysisListFile <- system.file("settings", "sccsAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    sccsAnalysisList <- SelfControlledCaseSeries::loadSccsAnalysisList(sccsAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(sccsAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(sccsAnalysisList, "description"))
    json <- sapply(sccsAnalysisList, toJson)
    analysisRef <- rbind(analysisRef, data.frame(method = "SCCS",
                                                 analysisId = analysisId,
                                                 description = description,
                                                 json = json))

    sccsSummaryFile <- file.path(workFolder, "sccsSummary.rds")
    if (!file.exists(sccsSummaryFile)) {
        stop(paste0("Couldn't find ", sccsSummaryFile, ", please make sure you've successfully completed runSelfControlledCaseSeries"))
    }
    sccsEstimates <- readRDS(sccsSummaryFile)
    colnames(sccsEstimates)[colnames(sccsEstimates) == "exposureId"] <- "targetId"
    colnames(sccsEstimates)[colnames(sccsEstimates) == "logRr(Exposure of interest)"] <- "logRr"
    colnames(sccsEstimates)[colnames(sccsEstimates) == "seLogRr(Exposure of interest)"] <- "seLogRr"
    colnames(sccsEstimates)[colnames(sccsEstimates) == "ci95lb(Exposure of interest)"] <- "ci95lb"
    colnames(sccsEstimates)[colnames(sccsEstimates) == "ci95ub(Exposure of interest)"] <- "ci95ub"
    fullGrid <- do.call("rbind", replicate(length(analysisId), allControls, simplify = FALSE))
    fullGrid$analysisId <- rep(analysisId, each = nrow(allControls))
    sccsEstimates <- merge(fullGrid, sccsEstimates[, c("targetId", "outcomeId", "analysisId", "logRr", "seLogRr", "ci95lb", "ci95ub")], all.x = TRUE)
    sccsEstimates$method <- "SCCS"
    sccsEstimates$cer <- FALSE
    sccsEstimates$nesting <- FALSE
    sccsEstimates$firstExposureOnly <- FALSE
    estimates <- rbind(estimates, sccsEstimates)

    # CohortMethod #
    cmAnalysisListFile <- system.file("settings", "cmAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(cmAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(cmAnalysisList, "description"))
    json <- sapply(cmAnalysisList, toJson)
    analysisRef <- rbind(analysisRef, data.frame(method = "Cohort method",
                                                 analysisId = analysisId,
                                                 description = description,
                                                 json = json))

    cmSummaryFile <- file.path(workFolder, "cmSummary.rds")
    if (!file.exists(cmSummaryFile)) {
        stop(paste0("Couldn't find ", cmSummaryFile, ", please make sure you've successfully completed cohortMethod"))
    }
    cmEstimates <- readRDS(cmSummaryFile)
    fullGrid <- do.call("rbind", replicate(length(analysisId), allControls, simplify = FALSE))
    fullGrid$analysisId <- rep(analysisId, each = nrow(allControls))
    cmEstimates <- merge(fullGrid, cmEstimates[, c("targetId", "comparatorId", "outcomeId", "analysisId", "logRr", "seLogRr", "ci95lb", "ci95ub")], all.x = TRUE)
    cmEstimates$method <- "Cohort method"
    cmEstimates$cer <- TRUE
    cmEstimates$nesting <- FALSE
    cmEstimates$firstExposureOnly <- TRUE
    estimates <- rbind(estimates, cmEstimates)


    # SelfControlledCohort #
    sccAnalysisListFile <- system.file("settings", "sccAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    sccAnalysisList <- SelfControlledCohort::loadSccAnalysisList(sccAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(sccAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(sccAnalysisList, "description"))
    json <- sapply(sccAnalysisList, toJson)
    analysisRef <- rbind(analysisRef, data.frame(method = "Self-controlled cohort",
                                                 analysisId = analysisId,
                                                 description = description,
                                                 json = json))

    sccSummaryFile <- file.path(workFolder, "sccSummary.rds")
    if (!file.exists(sccSummaryFile)) {
        stop(paste0("Couldn't find ", sccSummaryFile, ", please make sure you've successfully completed runSelfControlledCohort"))
    }
    sccEstimates <- readRDS(sccSummaryFile)
    colnames(sccEstimates)[colnames(sccEstimates) == "exposureId"] <- "targetId"
    colnames(sccEstimates)[colnames(sccEstimates) == "irrLb95"] <- "ci95lb"
    colnames(sccEstimates)[colnames(sccEstimates) == "irrUb95"] <- "ci95ub"
    fullGrid <- do.call("rbind", replicate(length(analysisId), allControls, simplify = FALSE))
    fullGrid$analysisId <- rep(analysisId, each = nrow(allControls))
    sccEstimates <- merge(fullGrid, sccEstimates[, c("targetId", "outcomeId", "analysisId", "logRr", "seLogRr", "ci95lb", "ci95ub")], all.x = TRUE)
    sccEstimates$method <- "Self-controlled cohort"
    sccEstimates$cer <- FALSE
    sccEstimates$nesting <- FALSE
    sccEstimates$firstExposureOnly <- FALSE
    estimates <- rbind(estimates, sccEstimates)


    # Case-control #
    ccAnalysisListFile <- system.file("settings", "ccAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    ccAnalysisList <- CaseControl::loadCcAnalysisList(ccAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(ccAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(ccAnalysisList, "description"))
    json <- sapply(ccAnalysisList, toJson)
    analysisRef <- rbind(analysisRef, data.frame(method = "Case-control",
                                                 analysisId = analysisId,
                                                 description = description,
                                                 json = json))


    ccSummaryFile <- file.path(workFolder, "ccSummary.rds")
    if (!file.exists(ccSummaryFile)) {
        stop(paste0("Couldn't find ", ccSummaryFile, ", please make sure you've successfully completed runCaseControl"))
    }
    ccEstimates <- readRDS(ccSummaryFile)
    colnames(ccEstimates)[colnames(ccEstimates) == "exposureId"] <- "targetId"
    fullGrid <- do.call("rbind", replicate(length(analysisId), allControls, simplify = FALSE))
    fullGrid$analysisId <- rep(analysisId, each = nrow(allControls))
    ccEstimates <- merge(fullGrid, ccEstimates[, c("targetId", "outcomeId", "analysisId", "logRr", "seLogRr", "ci95lb", "ci95ub")], all.x = TRUE)
    ccEstimates$method <- "Case-control"
    ccEstimates$cer <- FALSE
    ccEstimates$nesting <- FALSE
    ccEstimates$nesting[ccEstimates$analysisId %in% c(3, 4)] <- TRUE
    ccEstimates$firstExposureOnly <- FALSE
    estimates <- rbind(estimates, ccEstimates)


    # Case-crossover #
    ccrAnalysisListFile <- system.file("settings", "ccrAnalysisSettings.txt", package = "PopEstMethodEvaluation")
    ccrAnalysisList <- CaseCrossover::loadCcrAnalysisList(ccrAnalysisListFile)
    analysisId <- unlist(OhdsiRTools::selectFromList(ccrAnalysisList, "analysisId"))
    description <- unlist(OhdsiRTools::selectFromList(ccrAnalysisList, "description"))
    json <- sapply(ccrAnalysisList, toJson)
    analysisRef <- rbind(analysisRef, data.frame(method = "Case-crossover",
                                                 analysisId = analysisId,
                                                 description = description,
                                                 json = json))

    ccrSummaryFile <- file.path(workFolder, "ccrSummary.rds")
    if (!file.exists(ccrSummaryFile)) {
        stop(paste0("Couldn't find ", ccrSummaryFile, ", please make sure you've successfully completed runSelfControlledCohort"))
    }
    ccrEstimates <- readRDS(ccrSummaryFile)
    colnames(ccrEstimates)[colnames(ccrEstimates) == "exposureId"] <- "targetId"
    fullGrid <- do.call("rbind", replicate(length(analysisId), allControls, simplify = FALSE))
    fullGrid$analysisId <- rep(analysisId, each = nrow(allControls))
    ccrEstimates <- merge(fullGrid, ccrEstimates[, c("targetId", "outcomeId", "analysisId", "logRr", "seLogRr", "ci95lb", "ci95ub")], all.x = TRUE)
    ccrEstimates$method <- "Case-crossover"
    ccrEstimates$cer <- FALSE
    ccrEstimates$nesting <- FALSE
    ccrEstimates$firstExposureOnly <- FALSE
    estimates <- rbind(estimates, ccrEstimates)

    estimates$db <- databaseName
    estimatesFile <- file.path(exportFolder, "Estimates.csv")
    write.csv(estimates, estimatesFile, row.names = FALSE)

    analysisRefFile <- file.path(exportFolder, "AnalysisRef.csv")
    write.csv(analysisRef, analysisRefFile, row.names = FALSE)

    write.csv(allControls, file.path(exportFolder, "AllControls.csv"), row.names = FALSE)

    # injectedSignals <- injectedSignals[, c("exposureId", "outcomeId", "newOutcomeId", "targetEffectSize", "trueEffectSize", "trueEffectSizeFirstExposure")]
    # injectionSummaryFile <- file.path(exportFolder, "InjectionSummary.csv")
    # write.csv(injectedSignals, injectionSummaryFile, row.names = FALSE)
    #
    # negativeControls <- readRDS(system.file("ohdsiNegativeControls.rds", package = "MethodEvaluation"))
    # negativeControlFile <- file.path(exportFolder, "negativeControls.csv")
    # write.csv(negativeControls, negativeControlFile, row.names = FALSE)

    ### Add all to zip file ###
    # zipName <- file.path(exportFolder, "StudyResults.zip")
    # OhdsiSharing::compressFolder(exportFolder, zipName)
    # writeLines(paste("\nStudy results are ready for sharing at:", zipName))
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
        DatabaseConnector::disconnect(conn)
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

#' @export
addCalibration <- function(exportFolder) {
    # exportFolder <- file.path(workFolder, "export")
    estimates <- read.csv(file.path(exportFolder, "Estimates.csv"))
    combis <- unique(estimates[, c("method", "analysisId", "stratum")])
    calibrate <- function(i , combis, estimates) {
        # print(i)
        subset <- estimates[estimates$method == combis$method[i] & estimates$analysisId == combis$analysisId[i] & estimates$stratum == combis$stratum[i], ]
        filterSubset <- subset[!is.na(subset$seLogRr) & !is.infinite(subset$seLogRr), ]
        if (nrow(filterSubset) < 5 || length(unique(filterSubset$targetEffectSize)) < 2) {
            subset$calLogRr <- rep(NA, nrow(subset))
            subset$calSeLogRr <- rep(NA, nrow(subset))
            subset$calCi95lb <- rep(NA, nrow(subset))
            subset$calCi95ub <- rep(NA, nrow(subset))
            subset$calP <- rep(NA, nrow(subset))
        } else {
            model <- EmpiricalCalibration::fitSystematicErrorModel(logRr = filterSubset$logRr,
                                                                   seLogRr = filterSubset$seLogRr,
                                                                   trueLogRr = log(filterSubset$targetEffectSize),
                                                                   estimateCovarianceMatrix = FALSE)
            caliCi <- EmpiricalCalibration::calibrateConfidenceInterval(logRr = subset$logRr,
                                                                        seLogRr = subset$seLogRr,
                                                                        model = model)
            null <- EmpiricalCalibration::fitNull(logRr = filterSubset$logRr[filterSubset$targetEffectSize == 1],
                                                  seLogRr = filterSubset$seLogRr[filterSubset$targetEffectSize == 1])
            caliP <- EmpiricalCalibration::calibrateP(null = null,
                                                      logRr = subset$logRr,
                                                      seLogRr = subset$seLogRr)
            subset$calLogRr <- caliCi$logRr
            subset$calSeLogRr <- caliCi$seLogRr
            subset$calCi95lb <- exp(caliCi$logLb95Rr)
            subset$calCi95ub <- exp(caliCi$logUb95Rr)
            subset$calP <- caliP
        }
        return(subset)
    }
    calibratedEstimates <- sapply(1:nrow(combis), calibrate, combis = combis, estimates = estimates, simplify = FALSE)
    calibratedEstimates <- do.call("rbind", calibratedEstimates)
    write.csv(calibratedEstimates, file.path(exportFolder, "calibrated.csv"), row.names = FALSE)
}

