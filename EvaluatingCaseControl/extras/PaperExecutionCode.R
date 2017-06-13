# @file PaperExecutionCode.R
#
# Copyright 2017 Observational Health Data Sciences and Informatics
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

library(EvaluatingCaseControl)
options(fftempdir = "S:/fftemp")

# pw <- NULL
# dbms <- "pdw"
# user <- NULL
# server <- "JRDUSAPSCTL01"
# cdmDatabaseSchema <- "CDM_Truven_MDCD_V569.dbo"
# oracleTempSchema <- NULL
# workDatabaseSchema <- "scratch.dbo"
# studyCohortTable <- "mschuemie_case_control_ap"
# port <- 17001
# workFolder <- "S:/Temp/EvaluatingCaseControl"
# maxCores <- 30


pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_ccae_V568.dbo"
oracleTempSchema <- NULL
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "mschuemie_case_control_ap_ccae"
port <- 17001
workFolder <- "S:/Temp/EvaluatingCaseControl_ccae"
maxCores <- 30


connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

createCohorts(connectionDetails = connectionDetails,
              cdmDatabaseSchema = cdmDatabaseSchema,
              oracleTempSchema = oracleTempSchema,
              workDatabaseSchema = workDatabaseSchema,
              studyCohortTable = studyCohortTable,
              workFolder = workFolder)
# conn <- connect(connectionDetails)
# querySql(conn, "SELECT DISTINCT cohort_definition_id FROM scratch.dbo.mschuemie_case_control_ap_ccae")

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        oracleTempSchema = oracleTempSchema,
        workDatabaseSchema = workDatabaseSchema,
        studyCohortTable = studyCohortTable,
        study = study,
        workFolder = workFolder,
        createCohorts = FALSE,
        injectSignals = FALSE,
        runAnalyses = TRUE,
        empiricalCalibration = TRUE,
        maxCores = maxCores)
