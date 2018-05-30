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
#' This function plots the results of T2D study.

plotT2DStudyResults <- function(results_path){
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
    ps <- grep("Ps",resFilesOutCome4tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToDpp4")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToDpp4")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToDpp4")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    pdf(file = paste(results_path, "bigToSulf_bigToDpp4_HbA1c7Good.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToDpp4 comparision ...",sep=""))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome4tcTwo <- resFilesOutCome4[tcTwo]
    ps <- grep("Ps",resFilesOutCome4tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToSulf_bigToThia_HbA1c7Good.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToThia comparision ..."))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome4tcThree <- resFilesOutCome4[tcThree]
    ps <- grep("Ps",resFilesOutCome4tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToDpp4",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToDpp4",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToDpp4",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToDpp4_bigToThia_HbA1c7Good.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToDpp4 and bigToThia comparision ..."))
  }
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 5 representing HbA1c <= 8%, represented as HbA1c8Moderate
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
    ps <- grep("Ps",resFilesOutCome5tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToDpp4")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToDpp4")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToDpp4")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    pdf(file = paste(results_path, "bigToSulf_bigToDpp4_HbA1c8Moderate.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToDpp4 comparision ..."))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome5tcTwo <- resFilesOutCome5[tcTwo]
    ps <- grep("Ps",resFilesOutCome5tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToSulf_bigToThia_HbA1c8Moderate.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToThia comparision ..."))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome5tcThree <- resFilesOutCome5[tcThree]
    ps <- grep("Ps",resFilesOutCome5tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToDpp4",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToDpp4",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToDpp4",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToDpp4_bigToThia_HbA1c8Moderate.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToDpp4 and bigToThia comparision ..."))
  }
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 6 representing MI, represented as MI
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
    ps <- grep("Ps",resFilesOutCome6tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome6tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome6tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome6tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToDpp4")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToDpp4")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToDpp4")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    pdf(file = paste(results_path, "bigToSulf_bigToDpp4_MI.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToDpp4 comparision ..."))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome6tcTwo <- resFilesOutCome6[tcTwo]
    ps <- grep("Ps",resFilesOutCome6tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome6tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome6tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome6tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToSulf_bigToThia_MI.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToThia comparision ..."))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome6tcThree <- resFilesOutCome6[tcThree]
    ps <- grep("Ps",resFilesOutCome6tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome6tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome6tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome6tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome6tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToDpp4",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToDpp4",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToDpp4",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToDpp4_bigToThia_MI.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToDpp4 and bigToThia comparision ..."))
  }
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 7 representing KD, represented as KD
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
    ps <- grep("Ps",resFilesOutCome7tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome7tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome7tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome7tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToDpp4")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToDpp4")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToDpp4")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    pdf(file = paste(results_path, "bigToSulf_bigToDpp4_KD.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToDpp4 comparision ..."))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome7tcTwo <- resFilesOutCome7[tcTwo]
    ps <- grep("Ps",resFilesOutCome7tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome7tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome7tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome7tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToSulf_bigToThia_KD.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToThia comparision ..."))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome7tcThree <- resFilesOutCome7[tcThree]
    ps <- grep("Ps",resFilesOutCome7tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome7tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome7tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome7tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome7tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToDpp4",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToDpp4",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToDpp4",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToDpp4_bigToThia_KD.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToDpp4 and bigToThia comparision ..."))
  }
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 8 representing ED, represented as ED
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
    ps <- grep("Ps",resFilesOutCome8tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome8tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome8tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome8tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToDpp4")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToDpp4")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToDpp4")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToDpp4")
    pdf(file = paste(results_path, "bigToSulf_bigToDpp4_ED.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToDpp4 comparision ..."))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome8tcTwo <- resFilesOutCome8[tcTwo]
    ps <- grep("Ps",resFilesOutCome8tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome8tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome8tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome8tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToSulf",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToSulf",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToSulf",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToSulf",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToSulf_bigToThia_ED.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToSulf and bigToThia comparision ..."))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome8tcThree <- resFilesOutCome8[tcThree]
    ps <- grep("Ps",resFilesOutCome8tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome8tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome8tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome8tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome8tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    finalAttDiag <- drawAttritionDiagram(matchedPop,
                                         treatmentLabel = "bigToDpp4",
                                         comparatorLabel = "bigToThia")
    psScoreBeforeMatching <- plotPs(psScore,
                                    scale = "preference",
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    psScoreAfterMatching <- plotPs(matchedPop,
                                   psScore,
                                   treatmentLabel = "bigToDpp4",
                                   comparatorLabel = "bigToThia")
    covariateBalance <- plotCovariateBalanceScatterPlot(balance)
    topCovariateBalance <- plotCovariateBalanceOfTopVariables(balance)
    kmPlotWithoutCI <- plotKaplanMeier(matchedPop,
                                       includeZero = FALSE,
                                       confidenceIntervals = FALSE,
                                       treatmentLabel = "bigToDpp4",
                                       comparatorLabel = "bigToThia")
    kmPlotWithCI <- plotKaplanMeier(matchedPop,
                                    includeZero = FALSE,
                                    confidenceIntervals = TRUE,
                                    treatmentLabel = "bigToDpp4",
                                    comparatorLabel = "bigToThia")
    pdf(file = paste(results_path, "bigToDpp4_bigToThia_ED.pdf",sep = ""))
    plot(finalAttDiag)
    plot(psScoreBeforeMatching)
    plot(psScoreAfterMatching)
    plot(covariateBalance)
    plot(topCovariateBalance)
    plot(kmPlotWithoutCI)
    plot(kmPlotWithCI)
    dev.off()
    remove(psScore,matchedPop,studyPop,balance,finalAttDiag,psScoreBeforeMatching,psScoreAfterMatching,covariateBalance,topCovariateBalance,kmPlotWithoutCI,kmPlotWithCI)
  }else
  {
    print(paste("Looks like you don't have results for bigToDpp4 and bigToThia comparision ..."))
  }
  #---------------------------------------------------------------------
  print(paste("Done ploting the results ... ",sep=""))
}
