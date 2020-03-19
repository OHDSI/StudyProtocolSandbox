# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonExistingModelStudy
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

# Insert covariate cohort definitions from ATLAS into package -----------------------
populatePackage <- function(targetCohortId,
                            targetCohortName,
                            outcomeId,
                            outcomeName,
                            standardCovariates = data.frame(covariateId = c(0003, 1003,
                                                                            2003, 3003,
                                                                            4003, 5003,
                                                                            6003, 7003,
                                                                            8003, 9003,
                                                                            10003, 11003,
                                                                            12003, 13003,
                                                                            14003, 15003,
                                                                            16003, 17003,
                                                                            8507001),
                                                            covariateName = c('Age 0-4', 'Age 5-9',
                                                                              'Age 10-14', 'Age 15-19',
                                                                              'Age 20-24', 'Age 25-30',
                                                                              'Age 30-34', 'Age 35-40',
                                                                              'Age 40-44', 'Age 45-50',
                                                                              'Age 50-54', 'Age 55-60',
                                                                              'Age 60-64', 'Age 65-70',
                                                                              'Age 70-74', 'Age 75-80',
                                                                              'Age 80-84', 'Age 85-90',
                                                                              'Male'), 
                                                            points = c(rep(0,19))),
                            baseUrl = 'https://...',
                            atlasCovariateIds = c(1,109),
                            atlasCovariateNames = c('Testing 1', 'Testing 109'),
                            startDays = c(-999,-30),
                            endDays = c(-1,0),
                            points = c(1,2)){
  
  # insert the target and outcome cohorts:
  cohortsToCreate <- data.frame(cohortId = 1:2,
                                atlasId = c(targetCohortId, outcomeId),
                                name = c(targetCohortName, outcomeName))
  
  write.csv(cohortsToCreate, file.path("./inst/settings",'CohortsToCreate.csv' ), row.names = F)
  
  for (i in 1:nrow(cohortsToCreate)) {
    writeLines(paste("Inserting cohort:", cohortsToCreate$name[i]))
    OhdsiRTools::insertCohortDefinitionInPackage(definitionId = cohortsToCreate$atlasId[i], 
                                                 name = cohortsToCreate$name[i], 
                                                 baseUrl = baseUrl, 
                                                 generateStats = F)
  }
  
  
  
  # insert the custom covariate settings
  cohortsToCreate <- data.frame(cohortId = 3:(2+length(atlasCovariateIds)),
                                atlasId = atlasCovariateIds, 
                                cohortName = atlasCovariateNames,
                                startDay = startDays,
                                endDay = endDays)
  
  write.csv(cohortsToCreate, file.path("./inst/settings",'CustomCovariates.csv' ), row.names = F)
  
  for (i in 1:nrow(cohortsToCreate)) {
    writeLines(paste("Inserting cohort:", cohortsToCreate$cohortName[i]))
    OhdsiRTools::insertCohortDefinitionInPackage(definitionId = cohortsToCreate$atlasId[i], # atlas or cohort? 
                                                 name = cohortsToCreate$cohortName[i], 
                                                 baseUrl = baseUrl, 
                                                 generateStats = F)
  }
  
  
  # add the model
  model <- data.frame(covariateName = paste0(atlasCovariateNames, 
                                             '- start day: ', startDays,
                                             '- end day: ', endDays),
                      covariateId = 1000*(3:(2+length(atlasCovariateIds)))+456,
                      points = points
  )
  
  model <- rbind(model, standardCovariates)
  write.csv(model, file.path("./inst/settings",'SimpleModel.csv' ), row.names = F)
  
  return(TRUE)
}

