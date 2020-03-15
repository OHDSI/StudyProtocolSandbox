# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of SkeletonPredictionStudy
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
populateCustomCohortCovariates <- function(settingsName = 'customCohortCov.csv',
                                           settingsLocation = "inst/settings",
                                           baseUrl = 'https://...',
                                           atlasIds = c(1,109),
                                           atlasNames = c('Testing 1', 'Testing 109'),
                                           startDays = c(-999,-30),
                                           endDays = c(-1,0)){
  
  cohortsToCreate <- data.frame(cohortId = 1:length(atlasIds),
                                atlasId = atlasIds, 
                                cohortName = atlasNames,
                                startDay = startDays,
                                endDay = endDays)
  
  write.csv(cohortsToCreate, file.path(settingsLocation,settingsName ), row.names = F)
  
  for (i in 1:nrow(cohortsToCreate)) {
    writeLines(paste("Inserting cohort:", cohortsToCreate$cohortName[i]))
    OhdsiRTools::insertCohortDefinitionInPackage(definitionId = cohortsToCreate$atlasId[i], 
                                                 name = cohortsToCreate$cohortName[i], 
                                                 baseUrl = baseUrl, 
                                                 generateStats = F)
  }
}