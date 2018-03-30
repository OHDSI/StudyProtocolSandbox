# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of EvaluatingCaseControl
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

#' @title
#' Create figures and tables
#'
#' @description
#' Create figures and tables for the paper.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)
createFiguresAndTables <- function(connectionDetails,
                                   cdmDatabaseSchema,
                                   oracleTempSchema,
                                   outputFolder) {
  connection <- DatabaseConnector::connect(connectionDetails)

  OhdsiRTools::logInfo("Fetching population characteristics for Crockett study")
  getCharacteristics(ccFile = file.path(outputFolder, "ccIbd", "caseControls_cd1_cc1_o3.rds"),
                     connection = connection,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     resultsFolder = file.path(outputFolder, "resultsIbd"))

  OhdsiRTools::logInfo("Fetching population characteristics for Chou study")
  getCharacteristics(ccFile = file.path(outputFolder, "ccAp", "caseControls_cd1_n1_cc1_o2.rds"),
                     connection = connection,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     resultsFolder = file.path(outputFolder, "resultsAp"))

  createVisitPlot(resultsFolder = file.path(outputFolder, "resultsIbd"))
  createVisitPlot(resultsFolder = file.path(outputFolder, "resultsAp"))
  createCharacteristicsTable(resultsFolder = file.path(outputFolder, "resultsIbd"))
  createCharacteristicsTable(resultsFolder = file.path(outputFolder, "resultsAp"))
  plotOddsRatios(ccSummaryFile = file.path(outputFolder, "ccSummaryIbd.rds"),
                 exposureId = 5,
                 exposureName = "Isotretinoin",
                 resultsFolder = file.path(outputFolder, "resultsIbd"),
                 pubOr = 4.36,
                 pubLb = 1.97,
                 pubUb = 9.66)
  plotOddsRatios(ccSummaryFile = file.path(outputFolder, "ccSummaryAp.rds"),
                 exposureId = 4,
                 exposureName = "DPP-4",
                 resultsFolder = file.path(outputFolder, "resultsAp"),
                 pubOr = 1.04,
                 pubLb = 0.89,
                 pubUb = 1.21)

  calibrateCi(ccSummaryFile = file.path(outputFolder, "ccSummaryIbd.rds"),
              exposureId = 5,
              allControlsFile = file.path(outputFolder, "AllControlsIbd.csv"),
              resultsFolder = file.path(outputFolder, "resultsIbd"))
  calibrateCi(ccSummaryFile = file.path(outputFolder, "ccSummaryAp.rds"),
              exposureId = 4,
              allControlsFile = file.path(outputFolder, "AllControlsAp.csv"),
              resultsFolder = file.path(outputFolder, "resultsAp"))
}

calibrateCi <- function(ccSummaryFile, exposureId, allControlsFile, resultsFolder) {
  ccSummary <- readRDS(ccSummaryFile)
  allControls <- read.csv(allControlsFile)
  allControls <- allControls[, c("targetId", "outcomeId", "targetEffectSize")]
  colnames(allControls) <- c("exposureId", "outcomeId", "targetEffectSize")
  allControls <- merge(allControls, ccSummary)
  negativeControls <- allControls[allControls$targetEffectSize == 1, ]
  hoi <- ccSummary[ccSummary$exposureId == exposureId & ccSummary$outcomeId < 10000, ]
  null <- EmpiricalCalibration::fitNull(logRr = negativeControls$logRr,
                                        seLogRr = negativeControls$seLogRr)
  hoiCal <- EmpiricalCalibration::calibrateP(null,
                                             logRr = hoi$logRr,
                                             seLogRr = hoi$seLogRr)
  hoi$calP <- hoiCal
  model <- EmpiricalCalibration::fitSystematicErrorModel(logRr = allControls$logRr,
                                                         seLogRr = allControls$seLogRr,
                                                         trueLogRr = log(allControls$targetEffectSize))

  hoiCal <- EmpiricalCalibration::calibrateConfidenceInterval(logRr = hoi$logRr,
                                                    seLogRr = hoi$seLogRr,
                                                    model = model)
  hoi$calRr <- exp(hoiCal$logRr)
  hoi$calCi95lb <- exp(hoiCal$logLb95Rr)
  hoi$calCi95ub <- exp(hoiCal$logUb95Rr)
  fileName <- file.path(resultsFolder, "EmpiricalCalibration.csv")
  write.csv(hoi, fileName, row.names = FALSE)
  fileName <- file.path(resultsFolder, "TrueAndObservedForest.png")
  EmpiricalCalibration::plotTrueAndObserved(logRr = allControls$logRr,
                                            seLogRr = allControls$seLogRr,
                                            trueLogRr = log(allControls$targetEffectSize),
                                            fileName = fileName)
}

plotOddsRatios <- function(ccSummaryFile, exposureId, exposureName, resultsFolder, pubOr, pubLb, pubUb) {
  ccSummary <- readRDS(ccSummaryFile)
  ccSummary <- ccSummary[ccSummary$outcomeId < 10000, ] # No positive controls
  estimates <- data.frame(logRr = ccSummary$logRr,
                          seLogRr = ccSummary$seLogRr,
                          label = "Negative control (our replication)",
                          stringsAsFactors = FALSE)
  estimates$label[ccSummary$exposureId == exposureId] <- paste(exposureName, "(our replication)")
  estimates <- rbind(estimates,
                     data.frame(logRr = log(pubOr),
                                seLogRr = -(log(pubUb) - log(pubLb)) / (2*qnorm(0.025)),
                                label = paste(exposureName, "(original study)"),
                                stringsAsFactors = FALSE))

  alpha <- 0.05
  idx <- estimates$label == "Negative control (our replication)"
  null <- EmpiricalCalibration::fitNull(estimates$logRr[idx], estimates$seLogRr[idx])
  x <- exp(seq(log(0.25), log(10), by = 0.01))
  y <- EmpiricalCalibration:::logRrtoSE(log(x), alpha, null[1], null[2])
  seTheoretical <- sapply(x, FUN = function(x) {
    abs(log(x))/qnorm(1 - alpha/2)
  })
  breaks <- c(0.25, 0.5, 1, 2, 4, 6, 8, 10)
  theme <- ggplot2::element_text(colour = "#000000", size = 12)
  themeRA <- ggplot2::element_text(colour = "#000000", size = 12, hjust = 1)
  plot <- ggplot2::ggplot(data.frame(x, y, seTheoretical), ggplot2::aes(x = x, y = y), environment = environment()) +
    ggplot2::geom_vline(xintercept = breaks, colour = "#AAAAAA", lty = 1, size = 0.5) +
    ggplot2::geom_vline(xintercept = 1, size = 0.7) +
    ggplot2::geom_area(fill = rgb(1, 0.5, 0, alpha = 0.5), color = rgb(1, 0.5, 0), size = 1, alpha = 0.5) +
    ggplot2::geom_area(ggplot2::aes(y = seTheoretical),
                       fill = rgb(0, 0, 0),
                       colour = rgb(0, 0, 0, alpha = 0.1),
                       alpha = 0.1) +
    ggplot2::geom_line(ggplot2::aes(y = seTheoretical),
                       colour = rgb(0, 0, 0),
                       linetype = "dashed",
                       size = 1,
                       alpha = 0.5) +
    ggplot2::geom_point(ggplot2::aes(x, y, shape = label, color = label, fill = label, size = label),
                        data = data.frame(x = exp(estimates$logRr), y = estimates$seLogRr, label = estimates$label),
                        alpha = 0.7) +
    ggplot2::scale_color_manual(values = c(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0.8))) +
    ggplot2::scale_fill_manual(values = c(rgb(0.8, 0, 0.8, alpha = 0.8), rgb(1, 1, 0, alpha = 0.8), rgb(0, 0, 0.8, alpha = 0.5))) +
    ggplot2::scale_shape_manual(values = c(24, 23, 21)) +
    ggplot2::scale_size_manual(values = c(3, 3, 2)) +
    ggplot2::geom_hline(yintercept = 0) +
    ggplot2::scale_x_continuous("Odds ratio", trans = "log10", limits = c(0.25, 10), breaks = breaks, labels = breaks) +
    ggplot2::scale_y_continuous("Standard Error", limits = c(0, 1.5)) +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
                   panel.background = ggplot2::element_rect(fill = "#FAFAFA", colour = NA),
                   panel.grid.major = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(), axis.text.y = themeRA,
                   axis.text.x = theme, legend.key = ggplot2::element_blank(),
                   strip.text.x = theme, strip.background = ggplot2::element_blank(),
                   legend.position = "top",
                   legend.title = ggplot2::element_blank())

  fileName <- file.path(resultsFolder, "estimates.png")
  ggplot2::ggsave(fileName, plot, width = 6, height = 4.5, dpi = 400)
}

createCharacteristicsTable <- function(resultsFolder) {
  covariateData1 <- FeatureExtraction::loadCovariateData(file.path(resultsFolder, "covsCases"))
  covariateData2 <- FeatureExtraction::loadCovariateData(file.path(resultsFolder, "covsControls"))
  table1 <- FeatureExtraction::createTable1(covariateData1 = covariateData1,                                            covariateData2 = covariateData2)
  write.csv(table1, file.path(resultsFolder, "characteristics.csv"), row.names = FALSE)
}

createVisitPlot <- function(resultsFolder) {
  visitCounts <- readRDS(file.path(resultsFolder, "visitCounts.rds"))
  visitCounts$label <- "Cases"
  visitCounts$label[!visitCounts$isCase] <- "Controls"
  plot <- ggplot2::ggplot(visitCounts, ggplot2::aes(x = day, y = rate, group = label, color = label)) +
    ggplot2::geom_vline(xintercept = 0, color = rgb(0, 0, 0), size = 0.5) +
    ggplot2::geom_line(alpha = 0.7, size = 1) +
    ggplot2::scale_color_manual(values = c(rgb(0.8, 0, 0), rgb(0, 0, 0.8))) +
    ggplot2::labs(x = "Days relative to index date", y = "Visits / persons") +
    ggplot2::theme(legend.title = ggplot2::element_blank(),
                   legend.position = "top")
  ggplot2::ggsave(file.path(resultsFolder, "priorVisitRates.png"), plot, width = 5, height = 4, dpi = 400)
}


getCharacteristics <- function(ccFile, connection, cdmDatabaseSchema, oracleTempSchema, resultsFolder) {
  if (!file.exists(resultsFolder))
    dir.create(resultsFolder)
  cc <- readRDS(ccFile)
  # stratumIds <- unique(cc$stratumId)
  # sampledStratumIds <- sample(stratumIds, 10000, replace = FALSE)
  # cc <- cc[cc$stratumId %in% sampledStratumIds, ]
  tableToUpload <- data.frame(subjectId = cc$personId,
                              cohortStartDate = cc$indexDate,
                              cohortDefinitionId = as.integer(cc$isCase))

  colnames(tableToUpload) <- SqlRender::camelCaseToSnakeCase(colnames(tableToUpload))

  DatabaseConnector::insertTable(connection = connection,
                                 tableName = "#temp",
                                 data = tableToUpload,
                                 dropTableIfExists = TRUE,
                                 createTable = TRUE,
                                 tempTable = TRUE,
                                 oracleTempSchema = oracleTempSchema)
  covariateSettings <- FeatureExtraction::createCovariateSettings(useConditionGroupEraLongTerm = TRUE,
                                                                  useDrugGroupEraLongTerm = TRUE,
                                                                  useProcedureOccurrenceLongTerm = TRUE,
                                                                  useMeasurementLongTerm = TRUE,
                                                                  useMeasurementRangeGroupLongTerm = TRUE,
                                                                  useObservationLongTerm = TRUE,
                                                                  endDays = -30,
                                                                  longTermStartDays = - 365)
  covsCases <- FeatureExtraction::getDbCovariateData(connection = connection,
                                                     oracleTempSchema = oracleTempSchema,
                                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                                     cohortTable = "#temp",
                                                     cohortTableIsTemp = TRUE,
                                                     cohortId = 1,
                                                     covariateSettings = covariateSettings,
                                                     aggregated = TRUE)
  FeatureExtraction::saveCovariateData(covsCases, file.path(resultsFolder, "covsCases"))
  covsControls <- FeatureExtraction::getDbCovariateData(connection = connection,
                                                        oracleTempSchema = oracleTempSchema,
                                                        cdmDatabaseSchema = cdmDatabaseSchema,
                                                        cohortTable = "#temp",
                                                        cohortTableIsTemp = TRUE,
                                                        cohortId = 0,
                                                        covariateSettings = covariateSettings,
                                                        aggregated = TRUE)
  FeatureExtraction::saveCovariateData(covsControls, file.path(resultsFolder, "covsControls"))

  sql <- "SELECT DATEDIFF(DAY, cohort_start_date, visit_start_date) AS day,
  cohort_definition_id AS is_case,
  COUNT(*) AS visit_count
  FROM #temp
  INNER JOIN @cdm_database_schema.visit_occurrence
  ON subject_id = person_id
  WHERE cohort_start_date > visit_start_date
  AND DATEDIFF(DAY, cohort_start_date, visit_start_date) > -365
  GROUP BY DATEDIFF(DAY, cohort_start_date, visit_start_date),
  cohort_definition_id;"
  sql <- SqlRender::renderSql(sql = sql,
                              cdm_database_schema = cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql = sql,
                                 targetDialect = attr(connection, "dbms"),
                                 oracleTempSchema = oracleTempSchema)$sql
  visitCounts <- querySql(connection = connection, sql = sql)
  colnames(visitCounts) <- SqlRender::snakeCaseToCamelCase(colnames(visitCounts))
  cc$personCount <- 1
  personCounts <- aggregate(personCount ~ isCase, cc, sum)
  visitCounts <- merge(visitCounts, personCounts)
  visitCounts$rate <- visitCounts$visitCount / visitCounts$personCount
  saveRDS(visitCounts, file.path(resultsFolder, "visitCounts.rds"))

  sql <- "TRUNCATE TABLE #temp; DROP TABLE #temp;"
  sql <- SqlRender::translateSql(sql = sql,
                                 targetDialect = attr(connection, "dbms"),
                                 oracleTempSchema = oracleTempSchema)$sql
  DatabaseConnector::executeSql(connection = connection,
                                sql = sql,
                                progressBar = FALSE,
                                reportOverallTime = FALSE)
}
