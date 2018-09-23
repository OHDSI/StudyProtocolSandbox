# @file functions
#
# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of:
#  ----------------------------------------------
#  DiabetesTxPath
#  ----------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Stanford University Center for Biomedical Informatics - Shah Lab
# @author Rohit Vashisht
#
#' @title
#' runCompleteStudy
#'
#' @author
#' Rohit Vashisht
#'
#' @details
#' This function can be used to perform the DiabetesTxPathway analysis end-to-end. Just supply the
#' details and leave it running overnight. Please note the function will perform analysis if there are
#' atleast 250 patients for each of the drug group considered in the study.
#'
#' @param connectionDetails       The connection details of the database.
#' @param cdmDatabaseSchema       The cdm database schema
#' @param resultsDatabaseSchema   The results datavase schema
#' @param cdmVersion              The cdm version, should be 5 only
#'
#' @export
runCompleteStudy <- function(connectionDetails = connectionDetails,
                             cdmDatabaseSchema = cdmDatabaseSchema,
                             resultsDatabaseSchema = resultsDatabaseSchema,
                             cdmVersion = cdmVersion,
                             results_path = results_path,
                             maxCores = maxCores) {
  print(paste("Running the study for main outcomes",sep=""))
  #Run the study for T2D outcomes ...
  runT2DOutcomeStudy(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     resultsDatabaseSchema = resultsDatabaseSchema,
                     cdmVersion = cdmVersion,
                     results_path = results_path,
                     maxCores = maxCores)
  print(paste("Plotting the study results ... ",sep=""))
  #Plot the study results ...
  plotT2DStudyResults(results_path)
  #get age and gender
  print(paste("Getting the age and gender information ... ",sep=""))
  getAgeGender(results_path = results_path)
  #get HbA1c States for all the comparisions
  print(paste("Getting HbA1c Stats",sep=""))
  getHbA1cStat(results_path = results_path)
  print(paste("Study is finished - Thank You Very Much for Your Time ... ",sep=""))
}
