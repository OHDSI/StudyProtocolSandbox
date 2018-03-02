# @file Example.R
#
# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of LearningCurve
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
library(LearningCurve)
options(fftempdir = "")

workFolder <- ""

pw <- ""
dbms <- ""
server <- ""
user <- ""
cdmDatabaseSchema <- ""
oracleTempSchema <- NULL
workDatabaseSchema <- ""  # must have write access
studyCohortTable <- ""


connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw)


fetchAllDataFromServer(connectionDetails = connectionDetails,
                       cdmDatabaseSchema = cdmDatabaseSchema,
                       oracleTempSchema = oracleTempSchema,
                       workDatabaseSchema = workDatabaseSchema,
                       studyCohortTable = studyCohortTable,
                       workFolder = workFolder)

generateAllPopulations(workFolder)

# register a parallel backend
PatientLevelPrediction::registerParallelBackend()

# generate the learning curves
learningCurveList <- generateLearningCurve(workFolder)

# de-register parallel backend by registering a sequential backend
PatientLevelPrediction::registerSequentialBackend()
