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

addCalibration(file.path(workFolder, "export"))


# Merge results from multiple databases

folders <- c("s:/PopEstMethodEvaluation", "r:/PopEstMethodEvaluation_ccae")
calibrated <- data.frame()
for (folder in folders) {
  temp <- read.csv(file.path(folder, "export", "calibrated.csv"), stringsAsFactors = FALSE)
  calibrated <- rbind(calibrated, temp)
}
head(calibrated)
write.csv(calibrated, "r:/calibrated.csv", row.names = FALSE)
