# @file TestCode.R
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

library(PopEstMethodEvaluation)
options('fftempdir' = 'r:/fftemp')
options(java.parameters = "-Xmx8000m")


pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_MDCD_V610.dbo"
databaseName <- "MDCD"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch.dbo"
outcomeTable <- "mschuemi_ohdsi_hois2"
nestingCohortDatabaseSchema <- "scratch.dbo"
nestingCohortTable <- "mschuemi_ohdsi_nesting"
port <- 17001
cdmVersion <- "5"
workFolder <- "r:/PopEstMethodEvaluation"
maxCores <- 32


pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_CCAE_V608.dbo"
databaseName <- "CCAE"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch.dbo"
outcomeTable <- "mschuemi_ohdsi_hois_ccae"
nestingCohortDatabaseSchema <- "scratch.dbo"
nestingCohortTable <- "mschuemi_ohdsi_nesting_ccae"
port <- 17001
cdmVersion <- "5"
workFolder <- "r:/PopEstMethodEvaluation_ccae"
maxCores <- 32

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# MethodEvaluation::createReferenceSetCohorts(connectionDetails = connectionDetails,
#                                             oracleTempSchema = oracleTempSchema,
#                                             cdmDatabaseSchema = cdmDatabaseSchema,
#                                             outcomeDatabaseSchema = outcomeDatabaseSchema,
#                                             outcomeTable = outcomeTable,
#                                             nestingDatabaseSchema = nestingCohortDatabaseSchema,
#                                             nestingTable = nestingCohortTable,
#                                             referenceSet = "ohdsiNegativeControls")
#
# injectSignals(connectionDetails = connectionDetails,
#               cdmDatabaseSchema = cdmDatabaseSchema,
#               oracleTempSchema = oracleTempSchema,
#               outcomeDatabaseSchema = outcomeDatabaseSchema,
#               outcomeTable = outcomeTable,
#               workFolder = workFolder,
#               maxCores = maxCores)



runCohortMethod(connectionDetails = connectionDetails,
                cdmDatabaseSchema = cdmDatabaseSchema,
                oracleTempSchema = oracleTempSchema,
                outcomeDatabaseSchema = outcomeDatabaseSchema,
                outcomeTable = outcomeTable,
                workFolder = workFolder,
                cdmVersion = cdmVersion,
                maxCores = 32)

runSelfControlledCaseSeries(connectionDetails = connectionDetails,
                            cdmDatabaseSchema = cdmDatabaseSchema,
                            oracleTempSchema = oracleTempSchema,
                            outcomeDatabaseSchema = outcomeDatabaseSchema,
                            outcomeTable = outcomeTable,
                            workFolder = workFolder,
                            cdmVersion = cdmVersion)

runSelfControlledCohort(connectionDetails = connectionDetails,
                        cdmDatabaseSchema = cdmDatabaseSchema,
                        oracleTempSchema = oracleTempSchema,
                        outcomeDatabaseSchema = outcomeDatabaseSchema,
                        outcomeTable = outcomeTable,
                        workFolder = workFolder,
                        cdmVersion = cdmVersion)

runIctpd(connectionDetails = connectionDetails,
         cdmDatabaseSchema = cdmDatabaseSchema,
         oracleTempSchema = oracleTempSchema,
         outcomeDatabaseSchema = outcomeDatabaseSchema,
         outcomeTable = outcomeTable,
         workFolder = workFolder,
         cdmVersion = cdmVersion)

runCaseControl(connectionDetails = connectionDetails,
               cdmDatabaseSchema = cdmDatabaseSchema,
               oracleTempSchema = oracleTempSchema,
               outcomeDatabaseSchema = outcomeDatabaseSchema,
               outcomeTable = outcomeTable,
               nestingCohortDatabaseSchema = nestingCohortDatabaseSchema,
               nestingCohortTable = nestingCohortTable,
               workFolder = workFolder,
               cdmVersion = cdmVersion,
               maxCores = 20)

runCaseCrossover(connectionDetails = connectionDetails,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 oracleTempSchema = oracleTempSchema,
                 outcomeDatabaseSchema = outcomeDatabaseSchema,
                 outcomeTable = outcomeTable,
                 nestingCohortDatabaseSchema = nestingCohortDatabaseSchema,
                 nestingCohortTable = nestingCohortTable,
                 workFolder = workFolder,
                 cdmVersion = cdmVersion,
                 maxCores = 20)

packageResults(connectionDetails = connectionDetails,
               cdmDatabaseSchema = cdmDatabaseSchema,
               workFolder = workFolder)

createFiguresAndTables(file.path(workFolder, "export"))


# Create some plots -------------------------------------------------------
results <- readRDS(file.path(workFolder, "ccrSummary.rds"))
plotFolder <- file.path(workFolder, "plots")

library(MethodEvaluation)
data("ohdsiNegativeControls")

extraInfo <- data.frame(exposureId = ohdsiNegativeControls$targetId,
                        exposureName = ohdsiNegativeControls$targetName,
                        outcomeId = ohdsiNegativeControls$outcomeId,
                        outcomeName = ohdsiNegativeControls$outcomeName,
                        type = ohdsiNegativeControls$type)
results <- merge(results, extraInfo)
analysisIds <- unique(results$analysisId)
if (!file.exists(plotFolder))
    dir.create(plotFolder)
for (analysisId in analysisIds) {
  ncs <- results[results$analysisId == analysisId, ]
  # Overall plot
  fileName <- file.path(plotFolder, paste0("rrvsse_a",analysisId, ".png"))
  EmpiricalCalibration::plotCalibrationEffect(ncs$logRr, ncs$seLogRr, fileName = fileName, title = "All")

  # Per exposure of interest
  outcomeControls <- ncs[ncs$type == "Outcome control", ]
  exposureNames <- as.character(unique(outcomeControls$exposureName))
  for (exposureName in exposureNames) {
      subset <- outcomeControls[outcomeControls$exposureName == exposureName, ]
      fileName <- file.path(plotFolder, paste0("rrvsse_a",analysisId, "_", exposureName,".png"))
      EmpiricalCalibration::plotCalibrationEffect(subset$logRr, subset$seLogRr, fileName = fileName, title = exposureName)
  }

  # Per outcome of interest
  exposureControls <- ncs[ncs$type == "Exposure control", ]
  outcomeNames <- as.character(unique(exposureControls$outcomeName))
  for (outcomeName in outcomeNames) {
      subset <- exposureControls[exposureControls$outcomeName == outcomeName, ]
      fileName <- file.path(plotFolder, paste0("rrvsse_a",analysisId, "_", outcomeName,".png"))
      EmpiricalCalibration::plotCalibrationEffect(subset$logRr, subset$seLogRr, fileName = fileName, title = outcomeName)
  }
}



results <- readRDS(file.path(workFolder, "sccSummary.rds"))
plotFolder <- file.path(workFolder, "plotsScc")


results <- readRDS(file.path(workFolder, "ccSummary.rds"))
plotFolder <- file.path(workFolder, "plotsCc")

# Day fluctuations --------------------------------------------------------
library(ggplot2)

sql <- "SELECT visit_start_date,
	visit_count,
COUNT(DISTINCT person_id) AS denominator
FROM (
SELECT visit_start_date,
COUNT(*) AS visit_count
FROM CDM_Truven_MDCD_V569.dbo.visit_occurrence
GROUP BY visit_start_date
) visit_dates
INNER JOIN CDM_Truven_MDCD_V569.dbo.observation_period
ON observation_period_start_date <= visit_start_date
AND observation_period_end_date >= visit_start_date
GROUP BY visit_start_date,
	visit_count;"
conn <- DatabaseConnector::connect(connectionDetails)
dayCounts <- DatabaseConnector::querySql(conn, sql)
names(dayCounts) <- SqlRender::snakeCaseToCamelCase(names(dayCounts))
dayCounts$rate <- dayCounts$visitCount / dayCounts$denominator
RJDBC::dbDisconnect(conn)
saveRDS(dayCounts, "s:/temp/dayCounts.rds")

dayCounts <- readRDS("s:/temp/dayCounts.rds")
dayCounts <- dayCounts[order(dayCounts$visitStartDate), ]
subset <- dayCounts[dayCounts$visitStartDate >= as.Date("2013-10-01") & dayCounts$visitStartDate <= as.Date("2015-03-31"), ]
subset$day = as.integer(subset$visitStartDate - as.Date("2013-10-01"))
doi <- data.frame(date = as.Date(c("2013-11-27", "2013-12-25","2014-11-27", "2014-12-25", "2014-7-4")),
                  label = c("Thanksgiving", "Christmas","Thanksgiving", "Christmas", "4th of July"),
                  y = c(0.095, 0.085, 0.095,0.085,0.095))
doi$day <- as.integer(doi$date - as.Date("2013-10-01"))
breaks <- subset$day[subset$visitStartDate %in% as.Date(c("2014-01-01", "2014-07-01","2015-01-01"))]
labels <- c("January 1, 2014", "July 1, 2014", "January 1, 2015")

ggplot(subset, aes(x = day, y = rate)) +
    geom_vline(aes(xintercept = day), data = doi, linetype = "dashed", size = 0.5, alpha = 0.5) +
    geom_bar(stat = "identity", width = 1, alpha = 0.75, fill = rgb(0,0,0.8)) +
    geom_label(aes(x = day, y = y, label = label), data = doi) +
    scale_x_continuous("Calendar time", breaks = breaks, labels = labels) +
    scale_y_continuous("Visits per person") +
    theme(panel.grid.minor = ggplot2::element_blank(),
          panel.background = ggplot2::element_rect(fill = "#FAFAFA", colour = NA),
          panel.grid.major = ggplot2::element_blank(),
          strip.background = ggplot2::element_blank())

ggsave(filename = "s:/temp/days.png", width = 10, height = 5, dpi = 100)

