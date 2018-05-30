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
#' getAgeGender
#'
#' @author
#' Rohit Vashisht
#'
#' @details
#' This function can be used to compute the age and gender of patients for each outcome and for each treatment and
#' comparator cohort.
getAgeGender <- function(results_path){
  print(paste("Plotting all the results. This might take few minutes ... "))
  resFiles <- list.files(paste(results_path,"/deleteMeBeforeSharing/",sep=""))
  #---------------------------------------------------------------------
  #For outCome 4 representing HbA1c <= 7%, represented as HbA1c7Good
  x <- grep("_o4.rds",resFiles)
  resFilesOutCome4 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome4)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome4)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome4)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome4tcOne <- resFilesOutCome4[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome4tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c2",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToDpp4_HbA1c7Good.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToDpp4_HbA1c7Good.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToDpp4 comparision ...",sep=""))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome4tcTwo <- resFilesOutCome4[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome4tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToThia_HbA1c7Good.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToThia_HbA1c7Good.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToThia comparision ...",sep=""))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome4tcThree <- resFilesOutCome4[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome4tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t2_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToDpp4_bigToThia_HbA1c7Good.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToDpp4_bigToThia_HbA1c7Good.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToDpp4 versus bigToThia comparision ...",sep=""))
  }
  #----------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 5 representing HbA1c <= 8%, represented as HbA1c8Moderate
  remove(x)
  x <- grep("_o5.rds",resFiles)
  resFilesOutCome5 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome5)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome5)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome5)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome5tcOne <- resFilesOutCome5[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome5tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c2",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToDpp4_HbA1c8Moderate.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToDpp4_HbA1c8Moderate.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToDpp4 comparision ...",sep=""))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome5tcTwo <- resFilesOutCome5[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome5tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToThia_HbA1c8Moderate.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToThia_HbA1c8Moderate.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToThia comparision ...",sep=""))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome5tcThree <- resFilesOutCome5[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome5tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t2_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToDpp4_bigToThia_HbA1c8Moderate.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToDpp4_bigToThia_HbA1c8Moderate.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToDpp4 versus bigToThia comparision ...",sep=""))
  }
  #----------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 6 representing MI, represented as MI
  remove(x)
  x <- grep("_o6.rds",resFiles)
  resFilesOutCome6 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome6)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome6)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome6)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome6tcOne <- resFilesOutCome6[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome6tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome6tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome6tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome6tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c2",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToDpp4_MI.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToDpp4_MI.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToDpp4 comparision ...",sep=""))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome6tcTwo <- resFilesOutCome6[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome6tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome6tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome6tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome6tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToThia_MI.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToThia_MI.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToThia comparision ...",sep=""))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome6tcThree <- resFilesOutCome6[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome6tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome6tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome6tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome6tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t2_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToDpp4_bigToThia_MI.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToDpp4_bigToThia_MI.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToDpp4 versus bigToThia comparision ...",sep=""))
  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #For outCome 7 representing KD, represented as KD
  remove(x)
  x <- grep("_o7.rds",resFiles)
  resFilesOutCome7 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome7)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome7)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome7)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome7tcOne <- resFilesOutCome7[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome7tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome7tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome7tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome7tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c2",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToDpp4_KD.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToDpp4_KD.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToDpp4 comparision ...",sep=""))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome7tcTwo <- resFilesOutCome7[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome7tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome7tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome7tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome7tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToThia_KD.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToThia_KD.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToThia comparision ...",sep=""))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome7tcThree <- resFilesOutCome7[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome7tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome7tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome7tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome7tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t2_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToDpp4_bigToThia_KD.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToDpp4_bigToThia_KD.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToDpp4 versus bigToThia comparision ...",sep=""))
  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #For outCome 8 representing ED, represented as ED
  remove(x)
  x <- grep("_o8.rds",resFiles)
  resFilesOutCome8 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome8)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome8)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome8)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome8tcOne <- resFilesOutCome8[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome8tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome8tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome8tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome8tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c2",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToDpp4_ED.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToDpp4_ED.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToDpp4 comparision ...",sep=""))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome8tcTwo <- resFilesOutCome8[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome8tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome8tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome8tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome8tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t1_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToSulf_bigToThia_ED.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToSulf_bigToThia_ED.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToSulf versus bigToThia comparision ...",sep=""))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome8tcThree <- resFilesOutCome8[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome8tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome8tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome8tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome8tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    loadCohortMethodData(paste(results_path,"deleteMeBeforeSharing/CmData_l1_t2_c3",sep=""))
    # getting age gender information for all the patients before and after matching.
    if (!is.null(cohortMethodData$metaData$deletedCovariateIds)) {
      idx <- is.na(ffbase::ffmatch(cohortMethodData$covariateRef$covariateId,
                                   ff::as.ff(cohortMethodData$metaData$deletedCovariateIds)))
      removedCovars <- ff::as.ram(cohortMethodData$covariateRef[ffbase::ffwhich(idx, idx == FALSE),
                                                                ])
      # Age before matching.
      ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
      ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                      countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                      countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                      fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                      fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageBeforeMatching$countTreated[1]/ageBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageBeforeMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageBeforeMatching <- rbind(ageBeforeMatching, removedAgeGroup)
      }
      ageBeforeMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageBeforeMatching$group))
      ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
      ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
      ageBeforeMatching$start <- NULL
      # Age after matching ...
      ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
      ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                     countTreated = ageAfterMatching$afterMatchingSumTreated,
                                     countComparator = ageAfterMatching$afterMatchingSumComparator,
                                     fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                     fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
      # Add removed age group (if any):
      removedAgeGroup <- removedCovars[grep("age group:", removedCovars$covariateName), ]
      if (nrow(removedAgeGroup) == 1) {
        totalTreated <- ageAfterMatching$countTreated[1]/ageAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(ageAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(ageAfterMatching$fractionComparator)
        removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                      countTreated = round(missingFractionTreated *
                                                             totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        ageAfterMatching <- rbind(ageAfterMatching, removedAgeGroup)
      }
      ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
      ageAfterMatching$start <- as.integer(ageAfterMatching$start)
      ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
      ageAfterMatching$start <- NULL
      ## gender before matching
      genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderBeforeMatching$covariateName)
      if (length(x) == 0) {
        genderBeforeMatching <- genderBeforeMatching
      } else {
        genderBeforeMatching <- genderBeforeMatching[-x, ]
      }
      remove(x)
      genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                         countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                         countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                         fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                         fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderBeforeMatching$countTreated[1]/genderBeforeMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderBeforeMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderBeforeMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderBeforeMatching <- rbind(genderBeforeMatching, removedGender)
      }
      genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
      # Gender After Matching
      genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
      x <- grep("during 365d", genderAfterMatching$covariateName)
      if (length(x) == 0) {
        genderAfterMatching <- genderAfterMatching
      } else {
        genderAfterMatching <- genderAfterMatching[-x, ]
      }
      remove(x)
      genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                        countTreated = genderAfterMatching$afterMatchingSumTreated,
                                        countComparator = genderAfterMatching$afterMatchingSumComparator,
                                        fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                        fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
      # Add removed gender (if any):
      removedGender <- removedCovars[grep("gender", removedCovars$covariateName), ]
      if (nrow(removedGender) == 1) {
        totalTreated <- genderAfterMatching$countTreated[1]/genderAfterMatching$fractionTreated[1]
        missingFractionTreated <- 1 - sum(genderAfterMatching$fractionTreated)
        missingFractionComparator <- 1 - sum(genderAfterMatching$fractionComparator)
        removedGender <- data.frame(group = removedGender$covariateName,
                                    countTreated = round(missingFractionTreated *
                                                           totalTreated), countComparator = round(missingFractionComparator * totalTreated), fractionTreated = missingFractionTreated, fractionComparator = missingFractionComparator)
        genderAfterMatching <- rbind(genderAfterMatching, removedGender)
      }
      genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
    } else {
      x <- grep("age group:", balance$covariateName)
      if (length(x) != 0) {
        # Before Matching
        ageBeforeMatching <- balance[grep("age group:", balance$covariateName), ]
        ageBeforeMatching <- data.frame(group = ageBeforeMatching$covariateName,
                                        countTreated = ageBeforeMatching$beforeMatchingSumTreated,
                                        countComparator = ageBeforeMatching$beforeMatchingSumComparator,
                                        fractionTreated = ageBeforeMatching$beforeMatchingMeanTreated,
                                        fractionComparator = ageBeforeMatching$beforeMatchingMeanComparator)
        ageBeforeMatching$start <- gsub("age group: ",
                                        "",
                                        gsub("-.*$", "", ageBeforeMatching$group))
        ageBeforeMatching$start <- as.integer(ageBeforeMatching$start)
        ageBeforeMatching <- ageBeforeMatching[order(ageBeforeMatching$start), ]
        ageBeforeMatching$start <- NULL
        # after matching
        ageAfterMatching <- balance[grep("age group:", balance$covariateName), ]
        ageAfterMatching <- data.frame(group = ageAfterMatching$covariateName,
                                       countTreated = ageAfterMatching$afterMatchingSumTreated,
                                       countComparator = ageAfterMatching$afterMatchingSumComparator,
                                       fractionTreated = ageAfterMatching$afterMatchingMeanTreated,
                                       fractionComparator = ageAfterMatching$afterMatchingMeanComparator)
        ageAfterMatching$start <- gsub("age group: ", "", gsub("-.*$", "", ageAfterMatching$group))
        ageAfterMatching$start <- as.integer(ageAfterMatching$start)
        ageAfterMatching <- ageAfterMatching[order(ageAfterMatching$start), ]
        ageAfterMatching$start <- NULL
      } else {
        ageBeforeMatching <- data.frame(NA)
        ageAfterMatching <- data.frame(NA)
      }
      r <- grep("gender", balance$covariateName)
      if (length(r) != 0) {
        # Before Matching
        genderBeforeMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderBeforeMatching$covariateName)
        if (length(x) == 0) {
          genderBeforeMatching <- genderBeforeMatching
        } else {
          genderBeforeMatching <- genderBeforeMatching[-x, ]
        }
        remove(x)
        genderBeforeMatching <- data.frame(group = genderBeforeMatching$covariateName,
                                           countTreated = genderBeforeMatching$beforeMatchingSumTreated,
                                           countComparator = genderBeforeMatching$beforeMatchingSumComparator,
                                           fractionTreated = genderBeforeMatching$beforeMatchingMeanTreated,
                                           fractionComparator = genderBeforeMatching$beforeMatchingMeanComparator)
        genderBeforeMatching$group <- gsub("gender = ", "", genderBeforeMatching$group)
        # gender after matching
        genderAfterMatching <- balance[grep("gender", balance$covariateName), ]
        x <- grep("during 365d", genderAfterMatching$covariateName)
        if (length(x) == 0) {
          genderAfterMatching <- genderAfterMatching
        } else {
          genderAfterMatching <- genderAfterMatching[-x, ]
        }
        remove(x)
        genderAfterMatching <- data.frame(group = genderAfterMatching$covariateName,
                                          countTreated = genderAfterMatching$afterMatchingSumTreated,
                                          countComparator = genderAfterMatching$afterMatchingSumComparator,
                                          fractionTreated = genderAfterMatching$afterMatchingMeanTreated,
                                          fractionComparator = genderAfterMatching$afterMatchingMeanComparator)
        genderAfterMatching$group <- gsub("gender = ", "", genderAfterMatching$group)
      } else {
        genderBeforeMatching <- data.frame(NA)
        genderAfterMatching <- data.frame(NA)
      }
    }
    ageBeforeMatching$matching <- c("Before")
    ageAfterMatching$matching <- c("After")
    ageDat <- rbind(ageBeforeMatching,ageAfterMatching)
    write.csv(ageDat, file = paste(results_path,"age_bigToDpp4_bigToThia_ED.csv",sep=""))
    remove(ageBeforeMatching,ageAfterMatching,ageDat)
    genderBeforeMatching$matching <- c("Before")
    genderAfterMatching$matching <- c("After")
    genderDat <- rbind(genderBeforeMatching,genderAfterMatching)
    write.csv(genderDat, file = paste(results_path,"gender_bigToDpp4_bigToThia_ED.csv",sep=""))
    remove(genderBeforeMatching,genderAfterMatching,genderDat)
    remove(psScore, matchedPop, studyPop, balance, cohortMethodData, cohortMethodDataFolder)
  }else
  {
    print(paste("You don't seems to have results for bigToDpp4 versus bigToThia comparision ...",sep=""))
  }
  #----------------------------------------------------------------------
  print(paste("Done computing age and gender ... ",sep=""))
}
