# @file TestCode.R
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

library(PopEstMethodEvaluation)
#setwd('s:/temp')
options('fftempdir' = 's:/fftemp')

workFolder <- "s:/temp/PopEstMethodEvaluation"


pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_MDCD_V432.dbo"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch.dbo"
outcomeTable <- "mschuemie_outcomes"
nestingCohortDatabaseSchema <- "scratch.dbo"
nestingCohortTable <- "mschuemi_nesting_cohorts"
port <- 17001
cdmVersion <- "5"

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

injectSignals(connectionDetails = connectionDetails,
              cdmDatabaseSchema = cdmDatabaseSchema,
              oracleTempSchema = oracleTempSchema,
              outcomeDatabaseSchema = outcomeDatabaseSchema,
              outcomeTable = outcomeTable,
              workFolder = workFolder,
              cdmVersion = cdmVersion,
              createBaselineCohorts = FALSE)

createNestingCohorts(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     oracleTempSchema = oracleTempSchema,
                     nestingCohortDatabaseSchema = nestingCohortDatabaseSchema,
                     nestingCohortTable = nestingCohortTable,
                     cdmVersion = cdmVersion)

runCohortMethod(connectionDetails = connectionDetails,
                cdmDatabaseSchema = cdmDatabaseSchema,
                oracleTempSchema = oracleTempSchema,
                outcomeDatabaseSchema = outcomeDatabaseSchema,
                outcomeTable = outcomeTable,
                workFolder = workFolder,
                cdmVersion = cdmVersion)

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

packageResults(connectionDetails = connectionDetails,
               cdmDatabaseSchema = cdmDatabaseSchema,
               workFolder = workFolder)

createFiguresAndTables(file.path(workFolder, "export"))

