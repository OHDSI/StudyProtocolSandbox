# @file TestCode.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of PopEstT2Dm
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

library(PopEstT2Dm)
#setwd('s:/temp')
options('fftempdir' = 's:/fftemp')

workFolder <- "s:/temp/PopEstT2Dm"

pw <- NULL
dbms <- "pdw"
user <- NULL
server <- "JRDUSAPSCTL01"
cdmDatabaseSchema <- "CDM_Truven_MDCD_V432.dbo"
oracleTempSchema <- NULL
workDatabaseSchema <- "scratch.dbo"
studyCohortTable <- "mschuemie_t2dm_cohorts"
exposureCohortSummaryTable <- "mschuemie_t2dm_exposure_summary"
port <- 17001

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
              exposureCohortSummaryTable = exposureCohortSummaryTable,
              outputFolder = workFolder)
