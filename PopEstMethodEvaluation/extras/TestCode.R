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
setwd('s:/temp')
options('fftempdir' = 's:/fftemp')

workFolder <- "s:/temp/PopEstMethodEvaluation"

pw <- NULL
dbms <- "sql server"
user <- NULL
server <- "RNDUSRDHIT07.jnj.com"
cdmDatabaseSchema <- "cdm_truven_mdcd.dbo"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch.dbo"
outcomeTable <- "mschuemie_outcomes"
port <- NULL
cdmVersion <- "4"

dbms <- "postgresql"
user <- "postgres"
server <- "localhost/ohdsi"
cdmDatabaseSchema <- "vocabulary5"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch"
outcomeTable <- "mschuemie_outcomes"
port <- NULL
cdmVersion <- "4"

pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_ccae.dbo"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch.dbo"
outcomeTable <- "mschuemie_outcomes"
port <- 17001
cdmVersion <- "4"

pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_MDCD_V5.dbo"
oracleTempSchema <- NULL
outcomeDatabaseSchema <- "scratch.dbo"
outcomeTable <- "mschuemie_outcomes"
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

createShareableResults(workFolder = workFolder)
