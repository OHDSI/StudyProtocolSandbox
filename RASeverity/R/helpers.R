# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of Existing Stroke Risk External Valiation study
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


#==========================
#  Implement the RA severity model
#==========================

#' Applies an exisitng RA severity model to predict risk of severity in 90 days
#'
#' @details
#' This will run and evaluate the exisitng RA 90 day severity plpModel
#'
#' @param plpData           A list containing the covariate data and outcome cohort if performance evaluation is wanted
#' @param population        The population of people to do the prediction on
#' @param calculatePerformance  If the outcome cohort is in plpData, setting this to true will evaluate the model using the outcome cohort to identify who is severe in the population
#'
#' @return
#' A list with the performance and plots
#'
#' @export
applyRASeverity90Risk <- function(plpData,
                                  population,
                                  calculatePerformance=F){

  plpResult <- loadPlpResult(sys.file('plp_models/existingModel/raseverity90', package='RASeverity'))
  writeLines('Implementing Developed 90 day prediction of severe RA')
  result <- PatientLevelPrediction::applyModel(population = population,
                                               plpData = plpData,
                                               plpModel = plpResult$model,
                                               calculatePerformance = calculatePerformance)
  return(result)
}

#' Applies an exisitng RA severity model to predict risk of severity in 730 days
#'
#' @details
#' This will run and evaluate the exisitng RA 730 day severity plpModel
#'
#' @param plpData           A list containing the covariate data and outcome cohort if performance evaluation is wanted
#' @param population        The population of people to do the prediction on
#' @param calculatePerformance  If the outcome cohort is in plpData, setting this to true will evaluate the model using the outcome cohort to identify who is severe in the population
#'
#' @return
#' A list with the performance and plots
#'
#' @export
applyRASeverity730Risk <- function(plpData,
                                  population,
                                  calculatePerformance=F){

  plpResult <- loadPlpResult(sys.file('plp_models/existingModel/raseverity730', package='RASeverity'))
  writeLines('Implementing Developed 730 day prediction of severe RA')
  result <- PatientLevelPrediction::applyModel(population = population,
                                               plpData = plpData,
                                               plpModel = plpResult$model,
                                               calculatePerformance = calculatePerformance)
  return(result)
}


# add function to externally validate the models:

#' Create a custom covariate corresponding to the predicted risk of severe RA in the next 90 or 730 days
#'
#' @details
#' This will create the functions for a custom covariate corresponding to the risk of severe RA
#'
#' @param connectioDetails The connections details for connecting to the CDM
#'
#' @return
#' Two functions ...
#'
#' @export
createRASeverityCovariateSetting <- function(){

}



#' Checks the plp package is installed sufficiently for the network study and does other checks if needed
#'
#' @details
#' This will check that the network study dependancies work
#'
#' @param connectioDetails The connections details for connecting to the CDM
#'
#' @return
#' A number (a value other than 1 means an issue with the install)
#'
#' @export

checkInstall <- function(connectionDetails=NULL){
  result <- checkPlpInstallation(connectionDetails=connectionDetails,
                       python=F)
  return(result)
}
