# @file generateAllPopulations.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of LargeScalePrediction package
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

#' Creates the populations for the predictions for each outcome
#'
#' @description
#' This function creates the popualtions for each outcome in the plpData
#'
#' @details
#' For each outcome the population of people who fit the prediction criteria are found
#' and the people who have the outcome during the year after the 'at risk' cohort are
#' identified
#'
#' @param workFolder                   The directory where the plpData is saved to
#'
#' @return
#' Returns TRUE when finished and saves the populations as csvs into the workFolder directory
#' in the subdirectory names populations
#' @export
generateAllPopulations <- function(workFolder, verbosity=INFO){

    flog.seperator()
    flog.info('Calculating populations')
    flog.seperator()
    #load the plpData
    flog.info('Loading plpData')
    plpData <- PatientLevelPrediction::loadPlpData(file.path(workFolder,'data'))

    flog.info('Creating populations for each outcome ')
    outcomeIds <- plpData$metaData$call$outcomeIds
    # for each outcomeId create the popualtion:
    for(oid in outcomeIds){
        # add log message to state oid population being created...
        # get all the non outcome people with 365 days observation
        population_non <- PatientLevelPrediction::createStudyPopulation(plpData, outcomeId=oid,
                                                                        requireTimeAtRisk=T,
                                                                        minTimeAtRisk = 365,
                                                                        riskWindowStart=1,
                                                                        addExposureDaysToStart=F,
                                                                        riskWindowEnd=366,
                                                                        addExposureDaysToEnd=F)
        population_non <- population_non[population_non$outcomeCount==0,]
        # get all the outcomes (even if only partially observed)
        population_out <- PatientLevelPrediction::createStudyPopulation(plpData, outcomeId=oid,
                                                                        requireTimeAtRisk=T,
                                                                        minTimeAtRisk = 1,
                                                                        riskWindowStart=1,
                                                                        addExposureDaysToStart=F,
                                                                        riskWindowEnd=366,
                                                                        addExposureDaysToEnd=F)
        population_out <- population_out[population_out$outcomeCount!=0,]
        #join
        population <- rbind(population_out, population_non)
        
        if(!dir.exists(file.path(workFolder, 'Populations'))){dir.create(file.path(workFolder, 'Populations'))}
        write.csv(population, file=file.path(workFolder, 'populations',oid))
    }

    # add logging to say the popualtions are created

    return(TRUE)

}

