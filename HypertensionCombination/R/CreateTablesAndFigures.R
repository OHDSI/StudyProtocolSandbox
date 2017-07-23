createTableAndFigures<-function(exportFolder, cmOutputFolder){
    outcomeReference <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))
    analysisSummary <- read.csv(file.path(exportFolder, "MainResults.csv"))
    
    tablesAndFiguresFolder <- file.path(exportFolder, "tablesAndFigures")
    MainresultFolder<-file.path(exportFolder, "Mainresult")
    
    if (!file.exists(tablesAndFiguresFolder))
        dir.create(tablesAndFiguresFolder)
    
    if (!file.exists(MainresultFolder))
        dir.create(MainresultFolder)
    
    negControlCohortIds <- c(378424, 4004352, 4280726, 133141, 137053, 140480, 380731,
                             381581, 75344,  80809, 376415,  4224118, 4253054, 437409, 199067, 434272, 373478, 140641, 139099,
                             4142905, 195862, 4271016, 375552, 380038, 135473, 138102, 29735, 4153877, 74396, 134870, 74855,
                             200169, 194997,  192367, 4267582, 434872, 4329707, 4288544, 198075)
    # Calibrate p-values and draw calibration plots:
    
    for (analysisId in unique(analysisSummary$analysisId)) {
        negControlSubset <- analysisSummary[analysisSummary$analysisId == analysisId & analysisSummary$outcomeId %in%
                                              negControlCohortIds, ]
        negControlSubset <- negControlSubset[!is.na(negControlSubset$logRr) & negControlSubset$logRr !=
                                               0, ]
        if (nrow(negControlSubset) > 10) {
          null <- EmpiricalCalibration::fitMcmcNull(negControlSubset$logRr, negControlSubset$seLogRr)
          subset <- analysisSummary[analysisSummary$analysisId == analysisId, ]
          calibratedP <- EmpiricalCalibration::calibrateP(null, subset$logRr, subset$seLogRr)
          subset$calibratedP <- calibratedP$p
          subset$calibratedP_lb95ci <- calibratedP$lb95ci
          subset$calibratedP_ub95ci <- calibratedP$ub95ci
          mcmc <- attr(null, "mcmc")
          subset$null_mean <- mean(mcmc$chain[, 1])
          subset$null_sd <- 1/sqrt(mean(mcmc$chain[, 2]))
          analysisSummary$calibratedP[analysisSummary$analysisId == analysisId] <- subset$calibratedP
          analysisSummary$calibratedP_lb95ci[analysisSummary$analysisId == analysisId] <- subset$calibratedP_lb95ci
          analysisSummary$calibratedP_ub95ci[analysisSummary$analysisId == analysisId] <- subset$calibratedP_ub95ci
          analysisSummary$null_mean[analysisSummary$analysisId == analysisId] <- subset$null_mean
          analysisSummary$null_sd[analysisSummary$analysisId == analysisId] <- subset$null_sd
          
          EmpiricalCalibration::plotCalibration(negControlSubset$logRr,
                                                negControlSubset$seLogRr,
                                                fileName = file.path(tablesAndFiguresFolder,
                                                                 paste0("Cal_a", analysisId, ".png")))
          EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                      negControlSubset$seLogRr,
                                                      fileName = file.path(tablesAndFiguresFolder,
                                                                           paste0("CalEffectNoHoi_a", analysisId, ".png")))
          hoi <- analysisSummary[analysisSummary$analysisId == analysisId & !(analysisSummary$outcomeId %in%
                                                                                negControlCohortIds), ]
          
          EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                      negControlSubset$seLogRr,
                                                      hoi$logRr,
                                                      hoi$seLogRr,
                                                      fileName = file.path(tablesAndFiguresFolder,
                                                                           paste0("CalEffect_a", analysisId, ".png")))
          
          
          EmpiricalCalibration::plotCalibrationEffect(negControlSubset$logRr,
                                                      negControlSubset$seLogRr,
                                                      hoi$logRr,
                                                      hoi$seLogRr,
                                                      showCis = TRUE,
                                                      fileName = file.path(tablesAndFiguresFolder,
                                                                           paste0("CalEffectCi_a", analysisId, ".png")))
        }
      }
      write.csv(analysisSummary, file.path(tablesAndFiguresFolder,
                                           "EmpiricalCalibration.csv"), row.names = FALSE)
    
    # Balance plots:
    #  balance <- read.csv(file.path(exportFolder, "Balance1On1Matching.csv"))
    #  CohortMethod::plotCovariateBalanceScatterPlot(balance,
    #                                                fileName = file.path(tablesAndFiguresFolder,
    #                                                                     "BalanceScatterPlot1On1Matching.png"))
    #  CohortMethod::plotCovariateBalanceOfTopVariables(balance,
    #                                                   fileName = file.path(tablesAndFiguresFolder,
    #                                                                        "BalanceTopVariables1On1Matching.png"))
    for(i in 1:length(outcomeReference$analysisId)){
        
        idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
        balance <- read.csv(file.path(exportFolder, paste0("Balance",idx,".csv")))
        
        
        
        CohortMethod::plotCovariateBalanceScatterPlot(balance,
                                                          fileName = file.path(tablesAndFiguresFolder,
                                                                               paste0("BalanceScatterPlot",idx,".png")))
        CohortMethod::plotCovariateBalanceOfTopVariables(balance,
                                                             fileName = file.path(tablesAndFiguresFolder,
                                                                                  paste0("BalanceTopVariables",idx,".png")))
        
    }
    
    ### Population characteristics table
    #  balance <- read.csv(file.path(exportFolder, "BalanceVarRatioMatching.csv"))
    #  ## Age
    #  age <- balance[grep("Age group:", balance$covariateName), ]
    #  age <- data.frame(group = age$covariateName,
    #                    countTreated = age$beforeMatchingSumTreated,
    #                    countComparator = age$beforeMatchingSumComparator,
    #                    fractionTreated = age$beforeMatchingMeanTreated,
    #                    fractionComparator = age$beforeMatchingMeanComparator)
    #  
    #  # Add removed age group (if any):
    #  removedCovars <- read.csv(file.path(exportFolder, "RemovedCovars.csv"))
    #  removedAgeGroup <- removedCovars[grep("Age group:", removedCovars$covariateName), ]
    #  if (nrow(removedAgeGroup) == 1) {
    #    totalTreated <- age$countTreated[1] / age$fractionTreated[1]
    #    missingFractionTreated <- 1 - sum(age$fractionTreated)
    #    missingFractionComparator <- 1 - sum(age$fractionComparator)
    #    removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
    #                                  countTreated = round(missingFractionTreated * totalTreated),
    #                                  countComparator = round(missingFractionComparator * totalTreated),
    #                                  fractionTreated = missingFractionTreated,
    #                                  fractionComparator = missingFractionComparator)
    #    age <- rbind(age, removedAgeGroup)
    #  }
    #  age$start <- gsub("Age group: ", "", gsub("-.*$", "", age$group))
    #  age$start <- as.integer(age$start)
    #  age <- age[order(age$start), ]
    #  age$start <- NULL
    #  
    #  ## Gender
    #  gender <- balance[grep("Gender", balance$covariateName), ]
    #  gender <- data.frame(group = gender$covariateName,
    #                       countTreated = gender$beforeMatchingSumTreated,
    #                       countComparator = gender$beforeMatchingSumComparator,
    #                       fractionTreated = gender$beforeMatchingMeanTreated,
    #                       fractionComparator = gender$beforeMatchingMeanComparator)
    #  # Add removed gender (if any):
    #  removedGender <- removedCovars[grep("Gender", removedCovars$covariateName), ]
    #  if (nrow(removedGender) == 1) {
    #    totalTreated <- gender$countTreated[1] / gender$fractionTreated[1]
    #    missingFractionTreated <- 1 - sum(gender$fractionTreated)
    #    missingFractionComparator <- 1 - sum(gender$fractionComparator)
    #    removedGender <- data.frame(group = removedGender$covariateName,
    #                                countTreated = round(missingFractionTreated * totalTreated),
    #                                countComparator = round(missingFractionComparator * totalTreated),
    #                                fractionTreated = missingFractionTreated,
    #                                fractionComparator = missingFractionComparator)
    #    gender <- rbind(gender, removedGender)
    #  }
    #  gender$group <- gsub("Gender = ", "", gender$group)
    #  
    #  ## Calendar year
    #  year <- balance[grep("Index year", balance$covariateName), ]
    #  year <- data.frame(group = year$covariateName,
    #                     countTreated = year$beforeMatchingSumTreated,
    #                     countComparator = year$beforeMatchingSumComparator,
    #                     fractionTreated = year$beforeMatchingMeanTreated,
    #                     fractionComparator = year$beforeMatchingMeanComparator)
    #  # Add removed year (if any):
    #  removedYear <- removedCovars[grep("Index year", removedCovars$covariateName), ]
    #  if (nrow(removedYear) == 1) {
    #    totalTreated <- year$countTreated[1] / year$fractionTreated[1]
    #    missingFractionTreated <- 1 - sum(year$fractionTreated)
    #    missingFractionComparator <- 1 - sum(year$fractionComparator)
    #    removedYear <- data.frame(group = removedYear$covariateName,
    #                              countTreated = round(missingFractionTreated * totalTreated),
    #                              countComparator = round(missingFractionComparator * totalTreated),
    #                              fractionTreated = missingFractionTreated,
    #                              fractionComparator = missingFractionComparator)
    #    year <- rbind(year, removedYear)
    #  }
    #  year$group <- gsub("Index year: ", "", year$group)
    #  year <- year[order(year$group), ]
    #  
    #  table <- rbind(age, gender, year)
    #  write.csv(table, file.path(tablesAndFiguresFolder, "PopChar.csv"), row.names = FALSE)
    
    for(i in 1:length(outcomeReference$analysisId)){
        
        idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
        balance <- read.csv(file.path(exportFolder, paste0("Balance",idx,".csv")))
        attrition <- read.csv(file.path(exportFolder, paste0("AttritionTable",idx,".csv")))
        removedCovars <- read.csv(file.path(exportFolder, paste0("RemovedCovars",idx,".csv")))
        ## Age
        
        age <- balance[grep("Age group:", balance$covariateName), ]
        age <- data.frame(group = age$covariateName,
                          beforecountTreated = age$beforeMatchingSumTreated,
                          beforecountComparator = age$beforeMatchingSumComparator,
                          beforefractionTreated = age$beforeMatchingMeanTreated,
                          beforefractionComparator = age$beforeMatchingMeanComparator,
                          aftercountTreated = age$afterMatchingSumTreated,
                          aftercountComparator = age$afterMatchingSumComparator,
                          afterfractionTreated = age$afterMatchingMeanTreated,
                          afterfractionComparator = age$afterMatchingMeanComparator
        )
        
        # Add removed age group (if any):
        
        removedAgeGroup <- removedCovars[grep("Age group:", removedCovars$covariateName), ]
        try(
            if (nrow(removedAgeGroup) == 1) {
                beforetotalTreated <- age$beforecountTreated[1] / age$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(age$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(age$beforefractionComparator)
                
                aftertotalTreated <- age$aftercountTreated[1] / age$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(age$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(age$afterfractionComparator)
                
                removedAgeGroup <- data.frame(group = removedAgeGroup$covariateName,
                                              beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                              beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                              beforefractionTreated = beforemissingFractionTreated,
                                              beforefractionComparator = beforemissingFractionComparator,
                                              aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                              aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                              afterfractionTreated = aftermissingFractionTreated,
                                              afterfractionComparator = aftermissingFractionComparator)
                age <- rbind(age, removedAgeGroup)
            }
        )
        age$start <- gsub("Age group: ", "", gsub("-.*$", "", age$group))
        age$start <- as.integer(age$start)
        age <- age[order(age$start), ]
        age$start <- NULL
        
        ## Gender
        gender <- balance[grep("Gender", balance$covariateName), ]
        gender <- data.frame(group = gender$covariateName,
                             beforecountTreated = gender$beforeMatchingSumTreated,
                             beforecountComparator = gender$beforeMatchingSumComparator,
                             beforefractionTreated = gender$beforeMatchingMeanTreated,
                             beforefractionComparator = gender$beforeMatchingMeanComparator,
                             aftercountTreated = gender$afterMatchingSumTreated,
                             aftercountComparator = gender$afterMatchingSumComparator,
                             afterfractionTreated = gender$afterMatchingMeanTreated,
                             afterfractionComparator = gender$afterMatchingMeanComparator)
        # Add removed gender (if any):
        removedGender <- removedCovars[grep("Gender", removedCovars$covariateName), ]
        try(
            if (nrow(removedGender) == 1) {
                beforetotalTreated <- gender$beforecountTreated[1] / gender$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(gender$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(gender$beforefractionComparator)
                
                aftertotalTreated <- age$aftercountTreated[1] / gender$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(gender$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(gender$afterfractionComparator)
                
                removedGender <- data.frame(group = removedGender$covariateName,
                                            beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                            beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                            beforefractionTreated = beforemissingFractionTreated,
                                            beforefractionComparator = beforemissingFractionComparator,
                                            aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                            aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                            afterfractionTreated = aftermissingFractionTreated,
                                            afterfractionComparator = aftermissingFractionComparator)
                gender <- rbind(gender, removedGender)
            }
        )
        gender$group <- gsub("Gender = ", "", gender$group)
        
        ## Calendar year
        year <- balance[grep("Index year", balance$covariateName), ]
        
        year <- data.frame(group = year$covariateName,
                           beforecountTreated = year$beforeMatchingSumTreated,
                           beforecountComparator = year$beforeMatchingSumComparator,
                           beforefractionTreated = year$beforeMatchingMeanTreated,
                           beforefractionComparator = year$beforeMatchingMeanComparator,
                           aftercountTreated = year$afterMatchingSumTreated,
                           aftercountComparator = year$afterMatchingSumComparator,
                           afterfractionTreated = year$afterMatchingMeanTreated,
                           afterfractionComparator = year$afterMatchingMeanComparator)
        
        # Add removed year (if any):
        removedYear <- removedCovars[grep("Index year", removedCovars$covariateName), ]
        try(
            if (nrow(removedYear) == 1) {
                beforetotalTreated <- year$beforecountTreated[1] / year$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(year$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(year$beforefractionComparator)
                
                aftertotalTreated <- year$aftercountTreated[1] / year$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(year$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(year$afterfractionComparator)
                
                removedYear <- data.frame(group = removedYear$covariateName,
                                          beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                          beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                          beforefractionTreated = beforemissingFractionTreated,
                                          beforefractionComparator = beforemissingFractionComparator,
                                          aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                          aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                          afterfractionTreated = aftermissingFractionTreated,
                                          afterfractionComparator = aftermissingFractionComparator)
                year <- rbind(year, removedYear)
            }
        )
        year$group <- gsub("Index year: ", "", year$group)
        year <- year[order(year$group), ]
        
        table <- rbind(age, gender, year)
        write.csv(table, file.path(tablesAndFiguresFolder, paste0("PopChar",idx,".csv")), row.names = FALSE)

    }
    
    for(i in 1:length(outcomeReference$analysisId)){
        
        idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
        balance <- read.csv(file.path(exportFolder, paste0("Balance",idx,".csv")))
        attrition <- read.csv(file.path(exportFolder, paste0("AttritionTable",idx,".csv")))
        removedCovars <- read.csv(file.path(exportFolder, paste0("RemovedCovars",idx,".csv")))
        ## DM
        
        dm <- balance[grepl("201826-Type 2 diabetes mellitus", balance$covariateName), ]
        dm <- data.frame(group = dm$covariateName,
                         beforecountTreated = dm$beforeMatchingSumTreated,
                         beforecountComparator = dm$beforeMatchingSumComparator,
                         beforefractionTreated = dm$beforeMatchingMeanTreated,
                         beforefractionComparator = dm$beforeMatchingMeanComparator,
                         aftercountTreated = dm$afterMatchingSumTreated,
                         aftercountComparator = dm$afterMatchingSumComparator,
                         afterfractionTreated = dm$afterMatchingMeanTreated,
                         afterfractionComparator = dm$afterMatchingMeanComparator,
                         beforeMatchingStdDiff = dm$beforeMatchingStdDiff,
                         afterMatchingStdDiff = dm$afterMatchingStdDiff
        )
        
        # Add removed dm group (if any):
        removeddmGroup <- removedCovars[grep("201826-Type 2 diabetes mellitus", removedCovars$covariateName), ]
        try(
            if (nrow(removeddmGroup) == 1) {
                beforetotalTreated <- dm$beforecountTreated[1] / dm$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(dm$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(dm$beforefractionComparator)
                
                aftertotalTreated <- dm$aftercountTreated[1] / dm$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(dm$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(dm$afterfractionComparator)
                
                removeddmGroup <- data.frame(group = removeddmGroup$covariateName,
                                             beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                             beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                             beforefractionTreated = beforemissingFractionTreated,
                                             beforefractionComparator = beforemissingFractionComparator,
                                             aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                             aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                             afterfractionTreated = aftermissingFractionTreated,
                                             afterfractionComparator = aftermissingFractionComparator,
                                             beforeMatchingStdDiff = NULL,
                                             afterMatchingStdDiff = NULL)
                dm <- rbind(dm, removeddmGroup)
            }
        )
        
        ##ckd
        
        ckd <- balance[grepl("[cC]hronic kidney disease", balance$covariateName)|grepl("[cC]hronic renal impairment", balance$covariateName), ]
        ckd <- data.frame(group = ckd$covariateName,
                          beforecountTreated = ckd$beforeMatchingSumTreated,
                          beforecountComparator = ckd$beforeMatchingSumComparator,
                          beforefractionTreated = ckd$beforeMatchingMeanTreated,
                          beforefractionComparator = ckd$beforeMatchingMeanComparator,
                          aftercountTreated = ckd$afterMatchingSumTreated,
                          aftercountComparator = ckd$afterMatchingSumComparator,
                          afterfractionTreated = ckd$afterMatchingMeanTreated,
                          afterfractionComparator = ckd$afterMatchingMeanComparator,
                          beforeMatchingStdDiff = ckd$beforeMatchingStdDiff,
                          afterMatchingStdDiff = ckd$afterMatchingStdDiff
        )
        
        # Add removed ckd group (if any):
        removedckdGroup <- removedCovars[grepl("[cC]hronic kidney disease", removedCovars$covariateName)|grepl("[cC]hronic renal impairment", removedCovars$covariateName), ]
        try(
            if (nrow(removedckdGroup) == 1) {
                beforetotalTreated <- ckd$beforecountTreated[1] / ckd$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(ckd$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(ckd$beforefractionComparator)
                
                aftertotalTreated <- ckd$aftercountTreated[1] / ckd$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(ckd$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(ckd$afterfractionComparator)
                
                removedckdGroup <- data.frame(group = removedckdGroup$covariateName,
                                              beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                              beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                              beforefractionTreated = beforemissingFractionTreated,
                                              beforefractionComparator = beforemissingFractionComparator,
                                              aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                              aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                              afterfractionTreated = aftermissingFractionTreated,
                                              afterfractionComparator = aftermissingFractionComparator,
                                              beforeMatchingStdDiff = NULL,
                                              afterMatchingStdDiff = NULL)
                ckd <- rbind(ckd, removedckdGroup)
            }
        )
        
        #statin
        statin <- balance[grepl("[Ss]tatin", balance$covariateName), ]
        statin <- data.frame(group = statin$covariateName,
                             beforecountTreated = statin$beforeMatchingSumTreated,
                             beforecountComparator = statin$beforeMatchingSumComparator,
                             beforefractionTreated = statin$beforeMatchingMeanTreated,
                             beforefractionComparator = statin$beforeMatchingMeanComparator,
                             aftercountTreated = statin$afterMatchingSumTreated,
                             aftercountComparator = statin$afterMatchingSumComparator,
                             afterfractionTreated = statin$afterMatchingMeanTreated,
                             afterfractionComparator = statin$afterMatchingMeanComparator,
                             beforeMatchingStdDiff = statin$beforeMatchingStdDiff,
                             afterMatchingStdDiff = statin$afterMatchingStdDiff
        )
        
        # Add removed statin group (if any):
        removedstatinGroup <- removedCovars[grep("[Ss]tatin", removedCovars$covariateName), ]
        try(
            if (nrow(removedstatinGroup) == 1) {
                beforetotalTreated <- statin$beforecountTreated[1] / statin$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(statin$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(statin$beforefractionComparator)
                
                aftertotalTreated <- statin$aftercountTreated[1] / statin$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(statin$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(statin$afterfractionComparator)
                
                removedstatinGroup <- data.frame(group = removedstatinGroup$covariateName,
                                                 beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                                 beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                                 beforefractionTreated = beforemissingFractionTreated,
                                                 beforefractionComparator = beforemissingFractionComparator,
                                                 aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                                 aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                                 afterfractionTreated = aftermissingFractionTreated,
                                                 afterfractionComparator = aftermissingFractionComparator,
                                                 beforeMatchingStdDiff = NULL,
                                                 afterMatchingStdDiff = NULL)
                statin <- rbind(statin, removedstatinGroup)
            }
        )
        
        ##charlson index
        charlson <- balance[grepl("[cC]harlson", balance$covariateName), ]
        charlson <- data.frame(group = charlson$covariateName,
                               beforecountTreated = charlson$beforeMatchingSumTreated,
                               beforecountComparator = charlson$beforeMatchingSumComparator,
                               beforefractionTreated = charlson$beforeMatchingMeanTreated,
                               beforefractionComparator = charlson$beforeMatchingMeanComparator,
                               aftercountTreated = charlson$afterMatchingSumTreated,
                               aftercountComparator = charlson$afterMatchingSumComparator,
                               afterfractionTreated = charlson$afterMatchingMeanTreated,
                               afterfractionComparator = charlson$afterMatchingMeanComparator,
                               beforeMatchingStdDiff = charlson$beforeMatchingStdDiff,
                               afterMatchingStdDiff = charlson$afterMatchingStdDiff
        )
        
        # Add removed charlson group (if any):
        removedcharlsonGroup <- removedCovars[grep("[cC]harlson", removedCovars$covariateName), ]
        try(
            if (nrow(removedcharlsonGroup) == 1) {
                beforetotalTreated <- charlson$beforecountTreated[1] / charlson$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(charlson$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(charlson$beforefractionComparator)
                
                aftertotalTreated <- charlson$aftercountTreated[1] / charlson$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(charlson$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(charlson$afterfractionComparator)
                
                removedcharlsonGroup <- data.frame(group = removedcharlsonGroup$covariateName,
                                                   beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                                   beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                                   beforefractionTreated = beforemissingFractionTreated,
                                                   beforefractionComparator = beforemissingFractionComparator,
                                                   aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                                   aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                                   afterfractionTreated = aftermissingFractionTreated,
                                                   afterfractionComparator = aftermissingFractionComparator,
                                                   beforeMatchingStdDiff = NULL,
                                                   afterMatchingStdDiff = NULL)
                charlson <- rbind(charlson, removedcharlsonGroup)
            }
        )
        
        ##dcsi
        dcsi <- balance[grepl("[dD][cC][sS][iI]", balance$covariateName), ]
        dcsi <- data.frame(group = dcsi$covariateName,
                           beforecountTreated = dcsi$beforeMatchingSumTreated,
                           beforecountComparator = dcsi$beforeMatchingSumComparator,
                           beforefractionTreated = dcsi$beforeMatchingMeanTreated,
                           beforefractionComparator = dcsi$beforeMatchingMeanComparator,
                           aftercountTreated = dcsi$afterMatchingSumTreated,
                           aftercountComparator = dcsi$afterMatchingSumComparator,
                           afterfractionTreated = dcsi$afterMatchingMeanTreated,
                           afterfractionComparator = dcsi$afterMatchingMeanComparator,
                           beforeMatchingStdDiff = dcsi$beforeMatchingStdDiff,
                           afterMatchingStdDiff = dcsi$afterMatchingStdDiff
        )
        
        # Add removed dcsi group (if any):
        removeddcsiGroup <- removedCovars[grep("[dD][cC][sS][iI]", removedCovars$covariateName), ]
        try(
            if (nrow(removeddcsiGroup) == 1) {
                beforetotalTreated <- dcsi$beforecountTreated[1] / dcsi$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(dcsi$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(dcsi$beforefractionComparator)
                
                aftertotalTreated <- dcsi$aftercountTreated[1] / dcsi$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(dcsi$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(dcsi$afterfractionComparator)
                
                removeddcsiGroup <- data.frame(group = removeddcsiGroup$covariateName,
                                               beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                               beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                               beforefractionTreated = beforemissingFractionTreated,
                                               beforefractionComparator = beforemissingFractionComparator,
                                               aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                               aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                               afterfractionTreated = aftermissingFractionTreated,
                                               afterfractionComparator = aftermissingFractionComparator,
                                               beforeMatchingStdDiff = NULL,
                                               afterMatchingStdDiff = NULL)
                dcsi <- rbind(dcsi, removeddcsiGroup)
            }
        )
        
        
        
        ##AF
        af <- balance[grepl("[Aa]trial fibrillation", balance$covariateName), ]
        af <- data.frame(group = af$covariateName,
                         beforecountTreated = af$beforeMatchingSumTreated,
                         beforecountComparator = af$beforeMatchingSumComparator,
                         beforefractionTreated = af$beforeMatchingMeanTreated,
                         beforefractionComparator = af$beforeMatchingMeanComparator,
                         aftercountTreated = af$afterMatchingSumTreated,
                         aftercountComparator = af$afterMatchingSumComparator,
                         afterfractionTreated = af$afterMatchingMeanTreated,
                         afterfractionComparator = af$afterMatchingMeanComparator,
                         beforeMatchingStdDiff = af$beforeMatchingStdDiff,
                         afterMatchingStdDiff = af$afterMatchingStdDiff
        )
        
        # Add removed af group (if any):
        removedafGroup <- removedCovars[grep("[Aa]trial fibrillation", removedCovars$covariateName), ]
        try(
            if (nrow(removedafGroup) == 1) {
                beforetotalTreated <- af$beforecountTreated[1] / af$beforefractionTreated[1]
                beforemissingFractionTreated <- 1 - sum(af$beforefractionTreated)
                beforemissingFractionComparator <- 1 - sum(af$beforefractionComparator)
                
                aftertotalTreated <- af$aftercountTreated[1] / af$afterfractionTreated[1]
                aftermissingFractionTreated <- 1 - sum(af$afterfractionTreated)
                aftermissingFractionComparator <- 1 - sum(af$afterfractionComparator)
                
                removedafGroup <- data.frame(group = removedafGroup$covariateName,
                                             beforecountTreated = round(beforemissingFractionTreated * beforetotalTreated),
                                             beforecountComparator = round(beforemissingFractionComparator * beforetotalTreated),
                                             beforefractionTreated = beforemissingFractionTreated,
                                             beforefractionComparator = beforemissingFractionComparator,
                                             aftercountTreated = round(aftermissingFractionTreated * aftertotalTreated),
                                             aftercountComparator = round(aftermissingFractionComparator * aftertotalTreated),
                                             afterfractionTreated = aftermissingFractionTreated,
                                             afterfractionComparator = aftermissingFractionComparator,
                                             beforeMatchingStdDiff = NULL,
                                             afterMatchingStdDiff = NULL)
                af <- rbind(af, removedafGroup)
            }
        )
        
        table <- rbind(dm, ckd, af,charlson, dcsi, statin)
        write.csv(table, file.path(tablesAndFiguresFolder, paste0("PopComor",idx,".csv")), row.names = FALSE)

    }
    
    
    
    ### Attrition diagrams
    #  attrition <- read.csv(file.path(exportFolder, "Attrition1On1Matching.csv"))
    #  object <- list()
    #  attr(object, "metaData") <- list(attrition = attrition)
    #  CohortMethod::drawAttritionDiagram(object, fileName = file.path(tablesAndFiguresFolder, "Attr1On1Matching.png"))
    #  
    #  attrition <- read.csv(file.path(exportFolder, "AttritionVarRatioMatching.csv"))
    #  object <- list()
    #  attr(object, "metaData") <- list(attrition = attrition)
    #  CohortMethod::drawAttritionDiagram(object, fileName = file.path(tablesAndFiguresFolder, "AttrVarRatioMatching.png"))
    
    for(i in 1:length(outcomeReference$analysisId)){
        idx<-paste0("_a",outcomeReference$analysisId[i],"_t",outcomeReference$targetId[i],"_c",outcomeReference$comparatorId[i],"_o",outcomeReference$outcomeId[i])
        attrition <- read.csv(file.path(exportFolder, paste0("AttritionTable",idx,".csv")))
        object <- list()
        attr(object, "metaData") <- list(attrition = attrition)
        CohortMethod::drawAttritionDiagram(object, fileName = file.path(tablesAndFiguresFolder, paste0("Attrition",idx,".png")))
        

    }
    
	### Add all to zip file ###
    #zipName <- file.path(tablesAndFiguresFolder, "TablesAndFigures.zip")
    #OhdsiSharing::compressFolder(tablesAndFiguresFolder, zipName)
    #writeLines(paste("\nTablesAndFigures are ready for sharing at:", zipName))
	writeLines(paste("\nTablesAndFigures are ready for sharing at:", tablesAndFiguresFolder))
}