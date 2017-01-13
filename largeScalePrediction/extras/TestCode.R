# @file TestCode.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of LargeScalePrediction
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

library(LargeScalePrediction)
options('fftempdir' = 's:/fftemp')

workFolder <- "t:/temp2/LargeScalePrediction/CCAE"

pw <- NULL
dbms <- "pdw"
user <- NULL
server <- Sys.getenv('server')
cdmDatabaseSchema <- Sys.getenv('ccae')
oracleTempSchema <- NULL
workDatabaseSchema <- Sys.getenv('work') # must have write access
studyCohortTable <- "sbsTest_depression_cohort"
exposureCohortSummaryTable <- "sbsTest_depression_summary"
port <- Sys.getenv('port')

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)


fetchAllDataFromServer(connectionDetails = connectionDetails,
                       cdmDatabaseSchema = cdmDatabaseSchema,
                       oracleTempSchema = oracleTempSchema,
                       workDatabaseSchema = workDatabaseSchema,
                       studyCohortTable = studyCohortTable,
                       workFolder = workFolder)

generateAllPopulations(workFolder)

fitAllPredictionModels(workFolder)

#fitGBMPredictionModels(workFolder)
#fitLassoPredictionModels(workFolder)
#fitRFPredictionModels(workFolder)
#fitNaiveBayesPredictionModels(workFolder)
#fitKNNPredictionModels(workFolder)

createSummary(workFolder)
