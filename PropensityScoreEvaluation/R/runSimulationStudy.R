#' Runs Simulation Study
#'
#' @description
#' This function runs a simulation to compare LASSO, exposure based hdps, and bias based hdps as propensity score methods
#'
#' @param simulationProfile simulationProfile object created by createCMDSimulationProfile function
#' @param studyPop Study population created by createStudyPopulation function
#' @param confoundingScheme Type of unmeasured confounding to use for PS (0 = none; 1 = demographics; 2 = random proportion; 3 = demographics and random proportion)
#' @param confoundingProportion Proportion of covariates to hide from propensity score as unmeasured confounding
#' @param simulationRuns Number of simulations to run (1 simulation = reroll outcomes)
#' @param trueEffectSize True effect size for exposure to simulate. If set to NULL keeps observed effect size from simulation profile
#' @param outcomePrevalence Outcome prevalence to simulate; adjusts outcome baseline survival function to achieve. If null keeps observed
#' @param hdpsFeatures TRUE = using HDPS features; FALSE = using FeatureExtraction features
#' @param ignoreCensoring Ignore censoring altogether; sets censoring process baseline survival function to 1
#' @param ignoreCensoringCovariates Ignore covariates effects on censoring process; only uses baseline function
#' @param threads Number of parallel threads to use
#'
#' @return
#' Returns the following: \describe{
#' \item{trueOutcomeModel}{the non-exposure oefficients used in the outcome generating model}
#' \item{trueEffectSize}{coefficient for exposure effect}
#' \item{estimatesLasso}{logRr, bound, and sd for LASSO estimate for each simulation}
#' \item{estimatesExpHdps}{logRr, bound, and sd for exposure based hdps}
#' \item{estimatesBiasHdps}{logRr, bound, and sd for bias based hdps}
#' \item{aucLasso}{auc for LASSO propensity score}
#' \item{aucExpHdps}{auc for exposure based hdps propensity score}
#' \item{aucBiasHdps}{auc for bias based hdps propensity score}
#' \item{psLasso}{propensity scores for subjects in study population for LASSO}
#' \item{psExp}{propensity scores for subjects in study population for exposure based hdps}
#' \item{psBias}{propensity scores for subjects in study population for bias based hdps; propensity and preference scores are averaged over simulation runs}
#' \item{outcomePrevalence}{outcome prevalence of simulation}}
#' @export
runSimulationStudy <- function(simulationProfile, simulationSetup, cohortMethodData, simulationRuns = 10,  
                               trueEffectSize = NA, outcomePrevalence = NA, hdpsFeatures, stratify=FALSE, discrete=FALSE,
                               ignoreCensoring = FALSE, threads = 10, fudge = .001, psPrior = NULL, maxRatio = 1, numStrata = 10,
                               useCovariates = FALSE) {
  # Save ff state
  saveFfState <- options("fffinalizer")$ffinalizer
  options("fffinalizer" = "delete")
  estimatesLasso = NULL
  estimatesExpHdps = NULL
  estimatesBiasHdps = NULL
  # estimatesRandom = NULL
  nonZeroOverlaps = NULL
  allOverlaps = NULL
  
  outcomeId = simulationProfile$outcomeId
  sData = simulationProfile$sData
  cData = simulationProfile$cData
  covariatesToDiscard = simulationSetup$settings$covariatesToDiscard
  sampleRowIds = simulationSetup$settings$sampleRowIds
  studyPop = simulationProfile$studyPop
  partialCMD = cohortMethodData
  covariates0 = as.numeric(names(simulationProfile$outcomeModelCoefficients[simulationProfile$outcomeModelCoefficients!=0]))
  if (is.null(psPrior)) psPrior = createPrior(priorType = "none")
  
  # modify confounding and sample size
  if(!is.na(covariatesToDiscard)) {
    partialCMD = removeCovariates(partialCMD, ff::as.ff(covariatesToDiscard))
  }
  
  if (is.na(sampleRowIds)) sampleRowIds = studyPop$rowId
  studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
  sData$XB = sData$XB[ffbase::ffmatch(ff::as.ff(sampleRowIds), sData$XB$rowId),]
  partialCMD = removeSubjects(partialCMD, sampleRowIds)

  # insert true effect size
  if (is.na(trueEffectSize)) trueEffectSize = simulationProfile$observedEffectSize
  sData$XB = insertEffectSize(sData$XB, trueEffectSize, ff::as.ffdf(partialCMD$cohorts))
  # ignore censoring
  if (ignoreCensoring) cData$baseline = ff::as.ff(rep(1, length(cData$baseline)))
  
  # set new outcome prevalence
  if (!is.na(outcomePrevalence)) {
    fun <- function(d) {return(findOutcomePrevalence(sData, cData, d) - outcomePrevalence)}
    delta <- uniroot(fun, lower = 0, upper = 10000)$root
    sData$baseline = sData$baseline^delta
  } else {
    outcomePrevalence = findOutcomePrevalence(sData, cData)
  }

  # create hdps PS
  cmd = simulateCMD(partialCMD, sData, cData, outcomeId, discrete = discrete)
  if (hdpsFeatures == TRUE) {
    hdps0 = runHdps(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = fudge)
  } else {
    hdps0 = runHdps1(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = fudge)
  }
  
  # handle propensity scores
  psLasso = simulationSetup$psLasso
  aucLasso = computePsAuc(psLasso)
  if (stratify) strataLasso=stratifyByPs(psLasso,numStrata) else strataLasso=matchOnPs(psLasso, maxRatio = maxRatio)
  
  # psRandom = psLasso
  # psRandom$propensityScore = runif(nrow(psRandom),0,1)
  # aucRandom = computePsAuc(psRandom)
  # if (stratify) strataRandom=stratifyByPs(psRandom,numStrata) else strataRandom=matchOnPs(psRandom, maxRatio = maxRatio)
  
  psExp = simulationSetup$psExp
  aucExpHdps = computePsAuc(psExp)
  if (stratify) strataExp=stratifyByPs(psExp,numStrata) else strataExp=matchOnPs(psExp, maxRatio = maxRatio)

  psBiasPermanent = psLasso
  psBiasPermanent$propensityScore = 0
  psBiasPermanent$preferenceScore = 0
  biasErrorCount = 0
  noOutcomeCount = 0
  
  for (i in 1:simulationRuns) {
    start <- Sys.time()
    writeLines(paste("Simulation: ", i))
    
    # simulate and calculate bias hdps outcomes
    while(TRUE) {
      cmd = simulateCMD(partialCMD, sData, cData, outcomeId = outcomeId, discrete = discrete)
      if (is.null(cmd$outcomes)) next
      if (hdpsFeatures == TRUE) {
        hdpsBias = runHdpsNewOutcomes(hdps0, cmd, useExpRank = FALSE)
      } else {
        hdpsBias = runHdps1NewOutcomes(hdps0, cmd, useExpRank = FALSE)
      }
      studyPopNew = studyPop
      studyPopNew$daysToEvent = cmd$cohorts$newDaysToEvent[match(studyPopNew$rowId, cmd$cohorts$rowId)]
      studyPopNew$outcomeCount = cmd$cohorts$newOutcomeCount[match(studyPopNew$rowId, cmd$cohorts$rowId)]
      studyPopNew$survivalTime = cmd$cohorts$newSurvivalTime[match(studyPopNew$rowId, cmd$cohorts$rowId)]
      
      # calculate outcomes for bias hdps
      psBias = createPs(cohortMethodData = hdpsBias, population = studyPopNew, prior = psPrior, stopOnError = FALSE)
      if (!is.null(attr(psBias, "metaData")$psError)) next
      else {
        if (stratify) popBias=stratifyByPs(psBias,numStrata) else popBias=matchOnPs(psBias,maxRatio = maxRatio)
        # bias
        outcomeModelBias  <- fitOutcomeModel(population = popBias,
                                             cohortMethodData = cmd,
                                             modelType = "cox",
                                             stratified = TRUE,
                                             useCovariates = useCovariates)
        estimatesBiasHdps = rbind(outcomeModelBias$outcomeModelTreatmentEstimate, estimatesBiasHdps)
        
        psBiasPermanent$propensityScore = psBiasPermanent$propensityScore + psBias$propensityScore
        psBiasPermanent$preferenceScore = psBiasPermanent$preferenceScore + psBias$preferenceScore
        
        # overlap
        covariatesBias = attributes(psBias)$metaData$psModelCoef
        covariatesBias = as.numeric(names(covariatesBias[covariatesBias!=0]))
        covariatesBias = covariatesBias[!is.na(covariatesBias)]
        t = match(covariates0, covariatesBias)
        nonZeroOverlaps = c(nonZeroOverlaps, length(which(!is.na(t))))
        
        covariatesBias = attributes(psBias)$metaData$psModelCoef
        covariatesBias = as.numeric(names(covariatesBias))
        covariatesBias = covariatesBias[!is.na(covariatesBias)]
        t = match(covariates0, covariatesBias)
        allOverlaps = c(allOverlaps, length(which(!is.na(t))))
        break
      }
    }
    
    # calculate outcomes for lasso
    popLasso = merge(studyPopNew, strataLasso[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    outcomeModelLasso <- fitOutcomeModel(population = popLasso,
                                         cohortMethodData = cmd,
                                         modelType = "cox",
                                         stratified = TRUE,
                                         useCovariates = useCovariates)
    estimatesLasso = rbind(outcomeModelLasso$outcomeModelTreatmentEstimate, estimatesLasso)
    
    # calculate outcomes for random
    # popRandom = merge(studyPopNew, strataRandom[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    # outcomeModelRandom <- fitOutcomeModel(population = popRandom,
    #                                       cohortMethodData = cmd,
    #                                       modelType = "cox",
    #                                       stratified = TRUE,
    #                                       useCovariates = useCovariates)
    # estimatesRandom = rbind(outcomeModelRandom$outcomeModelTreatmentEstimate, estimatesRandom)
    
    # calculate outcomes for exp hdps
    popExp = merge(studyPopNew, strataExp[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    outcomeModelExp <- fitOutcomeModel(population = popExp,
                                       cohortMethodData = cmd,
                                       modelType = "cox",
                                       stratified = TRUE,
                                       useCovariates = useCovariates)
    estimatesExpHdps = rbind(outcomeModelExp$outcomeModelTreatmentEstimate, estimatesExpHdps)
    
    delta <- Sys.time() - start
    writeLines(paste("run took", signif(delta, 3), attr(delta, "units")))
  }
  
  if (is.null(estimatesBiasHdps)) {
    psBiasPermanent$propensityScore <- NA
  } else {
    psBiasPermanent$propensityScore = psBiasPermanent$propensityScore / nrow(estimatesBiasHdps)
    psBiasPermanent$preferenceScore = psBiasPermanent$preferenceScore / nrow(estimatesBiasHdps)
  }
  
  ps = data.frame(rowId = psLasso$rowId, treatment = psLasso$treatment, lassoPropensityScore = psLasso$propensityScore,
                  expHdpsPropensityScore = psExp$propensityScore, biasHdpsPropensityScore = psBiasPermanent$propensityScore)
  # , randomPropensityScore = psRandom$propensityScore)
  
  settings = simulationSetup$settings
  settings$trueEffectSize = trueEffectSize
  settings$outcomePrevalence = outcomePrevalence
  settings$simulationRuns = simulationRuns
  settings$hdpsFeatures = hdpsFeatures
  settings$stratify = stratify
  settings$maxRatio = maxRatio
  settings$numStrata = numStrata
  settings$useCovariates = useCovariates
  
  # overlap stuff
  covariatesLasso = attributes(psLasso)$metaData$psModelCoef
  covariatesLasso = as.numeric(names(covariatesLasso[covariatesLasso!=0]))
  covariatesLasso = covariatesLasso[!is.na(covariatesLasso)]
  t = match(covariates0, covariatesLasso)
  overlapLasso = length(which(!is.na(t)))/length(covariates0)
  
  covariatesExp = attributes(psExp)$metaData$psModelCoef
  covariatesExp = as.numeric(names(covariatesExp[covariatesExp!=0]))
  covariatesExp = covariatesExp[!is.na(covariatesExp)]
  t = match(covariates0, covariatesExp)
  overlapExp = length(which(!is.na(t)))/length(covariates0)
  
  overlapBias = mean(nonZeroOverlaps)/length(covariates0)
  # overlapBiasAll = mean(allOverlaps)/length(covariates0)

  # Restore ff state
  options("fffinalizer" = saveFfState)
  
  return(list(settings = settings,
              estimatesLasso = estimatesLasso,
              estimatesExpHdps = estimatesExpHdps,
              estimatesBiasHdps = estimatesBiasHdps,
              # estimatesRandom = estimatesRandom,
              overlaps = list(overlapLasso = overlapLasso, overlapExp = overlapExp,
                              overlapBias = overlapBias, overlapRandom = 0),
              ps = ps))
}

#' @export
setUpSimulation <- function(simulationProfile, cohortMethodData, useCrossValidation = TRUE, confoundingProportion = NA, 
                            sampleSize = NA, threads = 10, hdpsFeatures, prior = NULL, outcomePrevalence = NA,
                            sampleRowIds = NA, covariatesToDiscard = NA) {
  studyPop = simulationProfile$studyPop
  outcomeId = simulationProfile$outcomeId
  preset = !is.na(covariatesToDiscard) || !is.na(sampleRowIds)
  if (is.null(prior)) prior = createPrior(priorType = "none")
  
  if (!preset) {
    while(TRUE) {
      test = testConvergence(cohortMethodData=cohortMethodData, simulationProfile=simulationProfile,  
                             confoundingProportion=confoundingProportion, sampleSize=sampleSize, 
                             hdpsFeatures=hdpsFeatures, runs = 1, prior = prior, outcomePrevalence = outcomePrevalence)
      covariatesToDiscard = test$covariatesToDiscard
      sampleRowIds = test$sampleRowIds
      if (!test$anyError) break
    }
  }
  cmd = cohortMethodData
  if (!is.na(sampleRowIds)) {
    studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
    cmd = removeSubjects(cmd, sampleRowIds)
  }
  if (!is.na(covariatesToDiscard)) {
    cmd = removeCovariates(cmd, ff::as.ff(covariatesToDiscard))
  }
  
  # create lasso PS
  psLasso = createPs(cohortMethodData = cmd, 
                     population = studyPop, 
                     prior = Cyclops::createPrior("laplace", exclude = c(), useCrossValidation = useCrossValidation),
                     control = createControl(noiseLevel = "silent",
                                             cvType = "auto", 
                                             tolerance = 2e-07, 
                                             cvRepetitions = 10, 
                                             startingVariance = 0.01,
                                             threads = threads))#[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  
  # create exposure hdps
  if (hdpsFeatures == TRUE) {
    hdps0 = runHdps(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = .01)
  } else {
    hdps0 = runHdps1(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = .01)
  }
  psExp = createPs(cohortMethodData = hdps0$cmd, population = studyPop, prior = prior, stopOnError = FALSE)
  
  settings = list(confoundingProportion = confoundingProportion,
                  covariatesToDiscard = covariatesToDiscard,
                  sampleSize = sampleSize,
                  sampleRowIds = sampleRowIds,
                  outcomeId = simulationProfile$outcomeId)
  
  return(list(settings = settings,
              psLasso = psLasso,
              psExp = psExp))
}

#' @export
nestedSetups <- function(simulationProfile, cohortMethodData, confoundingProportionList, sampleSizeList, hdpsFeatures, prior = NULL) {
  outcomeId = simulationProfile$outcomeId
  studyPop = simulationProfile$studyPop
  allRowIds = studyPop$rowId
  modelCovariates = as.numeric(names(simulationProfile$outcomeModelCoefficients))
  zeroCovariates = modelCovariates[which(simulationProfile$outcomeModelCoefficients==0)]
  nonzeroCovariates = modelCovariates[which(simulationProfile$outcomeModelCoefficients!=0)]
  n = length(zeroCovariates)
  m = length(nonzeroCovariates)
  
  sampleSizeList = sampleSizeList[order(sampleSizeList)]
  confoundingProportionList = confoundingProportionList[order(confoundingProportionList)]
  iSS = 0
  iCP = 0
  
  if (length(sampleSizeList[!is.na(sampleSizeList)])>0) iSS = which(sampleSizeList == max(sampleSizeList[!is.na(sampleSizeList)]))
  if (length(confoundingProportionList[!is.na(confoundingProportionList)])>0) iCP = which(confoundingProportionList == max(confoundingProportionList[!is.na(confoundingProportionList)]))
  
  sampleRowIdsList = rep(list(NA),length(sampleSizeList))
  covariatesToDiscardList = rep(list(NA),length(confoundingProportionList))
  covariatesToDiscardList1 = rep(list(NA),length(confoundingProportionList))
  
  while(TRUE) {
    if (iSS>0) {
      sampleRowIdsList[[iSS]] = sample(allRowIds, sampleSizeList[iSS])
      if (iSS>1) {
        for (i in (iSS-1):1) {
          sampleRowIdsList[[i]] = sample(sampleRowIdsList[[i+1]], sampleSizeList[i])
        }
      }
    }
    if (iCP>0) {
      p = confoundingProportionList[iCP]
      covariatesToDiscardList[[iCP]] = sample(zeroCovariates, ceiling(n*p))
      covariatesToDiscardList1[[iCP]] = sample(nonzeroCovariates, ceiling(m*p))
      if (iCP>1) {
        for (i in (iCP-1):1) {
          p = confoundingProportionList[i]
          covariatesToDiscardList[[i]] = sample(covariatesToDiscardList[[i+1]], ceiling(n*p))
          covariatesToDiscardList1[[i]] = sample(covariatesToDiscardList1[[i+1]], ceiling(m*p))
        }
      }
      for (i in 1:iCP) {
        covariatesToDiscardList[[i]] = c(covariatesToDiscardList[[i]],covariatesToDiscardList1[[i]])
      }
    }
    success = TRUE
    for (i in 0:(length(sampleSizeList)*length(confoundingProportionList)-1)) {
      writeLines(paste(i))
      j = i%/%length(sampleSizeList)+1
      k = i%%length(sampleSizeList)+1
      test = testConvergence(cohortMethodData=cohortMethodData, simulationProfile=simulationProfile,  
                             hdpsFeatures=hdpsFeatures, runs = 2, prior = prior, outcomePrevalence = .1,
                             covariatesToDiscard = covariatesToDiscardList[[j]], sampleRowIds = sampleRowIdsList[[k]])
      if (test$anyError) {
        success = FALSE
        break
      }
    }
    if (success) break
  }
  if (is.na(confoundingProportionList[length(confoundingProportionList)]&length(confoundingProportionList>0))) {
    for (i in (length(confoundingProportionList)-1):1) {
      confoundingProportionList[i+1] = confoundingProportionList[i]
      covariatesToDiscardList[[i+1]] = covariatesToDiscardList[[i]]
    }
    confoundingProportionList[1] = NA
    covariatesToDiscardList[[1]] = NA
  }
  
  return(list(covariatesToDiscardList = covariatesToDiscardList,
              sampleRowIdsList = sampleRowIdsList,
              confoundingProportionList = confoundingProportionList,
              sampleSizeList = sampleSizeList))
}

#' @export
setUpSimulations <- function(simulationProfile, cohortMethodData, confoundingProportionList, 
                             useCrossValidation = TRUE, sampleSizeList, outputFolder, threads = 10, hdpsFeatures) {
  if (!file.exists(outputFolder)) dir.create(outputFolder)
  settings = list(confoundingProportionList = confoundingProportionList,
                  sampleSizeList = sampleSizeList)
  saveRDS(settings, file = file.path(outputFolder, "settings.rds"))
  
  #results = list(settings = settings, simulationSetups = rep(list(rep(list(NA), length(trueEffectSizeList))), length(confoundingSchemeList)))
  for (i in 1:length(confoundingProportionList)) {
    for (j in 1:length(sampleSizeList)) {
      temp = setUpSimulation(simulationProfile, cohortMethodData,
                             confoundingProportion = confoundingProportionList[[i]],
                             useCrossValidation = useCrossValidation, sampleSize = sampleSizeList[[j]], threads = threads, hdpsFeatures = hdpsFeatures)
      #results$simulationStudies[[i]][[j]][[k]] = temp
      saveSimulationSetup(temp, file = file.path(outputFolder, paste("c", i, "_s", j, sep="")))
    }
  }
}

#' @export
saveSimulationSetup <- function(simulationSetup, file) {
  if (missing(simulationSetup))
    stop("Must specify simulationSetup")
  if (missing(file))
    stop("Must specify file")
  if (!file.exists(file)) dir.create(file)
  saveRDS(simulationSetup$settings, file = file.path(file, "settings.rds"))
  saveRDS(simulationSetup$psLasso, file = file.path(file, "psLasso.rds"))
  saveRDS(simulationSetup$psExp, file = file.path(file, "psExp.rds"))
}

#' @export
loadSimulationSetup <- function(file) {
  if (!file.exists(file))
    stop(paste("Cannot find folder", file))
  if (!file.info(file)$isdir)
    stop(paste("Not a folder", file))
  settings = readRDS(file.path(file, "settings.rds"))
  psLasso = readRDS(file.path(file, "psLasso.rds"))
  psExp = readRDS(file.path(file, "psExp.rds"))
  return(list(settings = settings,
              psLasso = psLasso,
              psExp = psExp))
}

#' @export
runSimulationStudies <- function(simulationProfile, cohortMethodData, simulationRuns = 10, trueEffectSizeList, 
                                 outcomePrevalenceList, hdpsFeatures, stratify=FALSE, discrete=FALSE, simulationSetupFolder = NULL, outputFolder, threads=10) {
  if (!file.exists(outputFolder)) dir.create(outputFolder)
  simulationSetup = loadSimulationSetup(simulationSetupFolder)
  
  settings = simulationSetup$settings
  settings$trueEffectSizeList = trueEffectSizeList
  settings$outcomePrevalenceList = outcomePrevalenceList
  
  outputFolder = paste(outputFolder, "/", basename(simulationSetupFolder), sep = "")
  if (!file.exists(outputFolder)) dir.create(outputFolder)
  
  saveRDS(settings, file = file.path(outputFolder, "settings.rds"))
  
  results = list(settings = settings, simulationStudies = rep(list(rep(list(NA), length(outcomePrevalenceList))), length(trueEffectSizeList)))
  for (i in 1:length(trueEffectSizeList)) {
    for (j in 1:length(outcomePrevalenceList)) {
        temp = runSimulationStudy(simulationProfile = simulationProfile, simulationSetup = simulationSetup, cohortMethodData = cohortMethodData, simulationRuns = simulationRuns, 
                                  trueEffectSize = trueEffectSizeList[[i]], outcomePrevalence = outcomePrevalenceList[[j]], hdpsFeatures = hdpsFeatures,
                                  stratify = stratify, discrete = discrete, threads = threads)
        results$simulationStudies[[i]][[j]] = temp
        saveSimulationStudy(temp, file = file.path(outputFolder, paste(basename(simulationSetupFolder), "_t", i, "_o", j, sep="")))
      }
  }
  return(results)
}

#' @export
loadSimulationStudies <- function(file) {
  if (!file.exists(file))
    stop(paste("Cannot find folder", file))
  if (!file.info(file)$isdir)
    stop(paste("Not a folder", file))
  settings = readRDS(file.path(file, "settings.rds"))
  I = length(settings$trueEffectSizeList)
  J = length(settings$outcomePrevalenceList)
  
  simulationStudies = rep(list(rep(list(NA), J)), I)
  
  for (i in 1:I) {
    for (j in 1:J) {
      simulationStudies[[i]][[j]] = loadSimulationStudy(file = file.path(file, paste(basename(file), "_t", i, "_o", j, sep="")))
    }
  }
  
  return(list(settings = settings,
              simulationStudies = simulationStudies))
}

#' @export
saveSimulationStudy <- function(simulationStudy, file) {
  if (missing(simulationStudy))
    stop("Must specify simulationStudy")
  if (missing(file))
    stop("Must specify file")
  if (!file.exists(file)) dir.create(file)
  saveRDS(simulationStudy$settings, file = file.path(file, "settings.rds"))
  saveRDS(simulationStudy$estimatesLasso, file = file.path(file, "estimatesLasso.rds"))
  saveRDS(simulationStudy$estimatesExpHdps, file = file.path(file, "estimatesExpHdps.rds"))
  saveRDS(simulationStudy$estimatesBiasHdps, file = file.path(file, "estimatesBiasHdps.rds"))
  saveRDS(simulationStudy$estimatesRandom, file = file.path(file, "estimatesRandom.rds"))
  saveRDS(simulationStudy$overlaps, file = file.path(file, "overlaps.rds"))
  saveRDS(simulationStudy$ps, file = file.path(file, "ps.rds"))
}

#' @export
loadSimulationStudy <- function(file, readOnly = TRUE) {
  if (!file.exists(file))
    stop(paste("Cannot find folder", file))
  if (!file.info(file)$isdir)
    stop(paste("Not a folder", file))
  settings = readRDS(file.path(file, "settings.rds"))
  estimatesLasso = readRDS(file.path(file, "estimatesLasso.rds"))
  estimatesExpHdps = readRDS(file.path(file, "estimatesExpHdps.rds"))
  estimatesBiasHdps = readRDS(file.path(file, "estimatesBiasHdps.rds"))
  estimatesRandom = readRDS(file.path(file, "estimatesRandom.rds"))
  overlaps = readRDS(file.path(file, "overlaps.rds"))
  ps = readRDS(file.path(file, "ps.rds"))
  result = list(settings = settings,
                estimatesLasso = estimatesLasso,
                estimatesExpHdps = estimatesExpHdps,
                estimatesBiasHdps = estimatesBiasHdps,
                estimatesRandom = estimatesRandom,
                overlaps = overlaps,
                ps = ps)
  return(result)
}

#' @export
testConvergence <- function(cohortMethodData, simulationProfile, confoundingProportion=NA, sampleSize=NA, hdpsFeatures, 
                            runs = 1, prior = NULL, outcomePrevalence = NA, covariatesToDiscard = NA, sampleRowIds = NA) {
  studyPop = simulationProfile$studyPop
  outcomeId = simulationProfile$outcomeId
  modelCovariates = as.numeric(names(simulationProfile$outcomeModelCoefficients))
  zeroCovariates = modelCovariates[which(simulationProfile$outcomeModelCoefficients==0)]
  nonzeroCovariates = modelCovariates[which(simulationProfile$outcomeModelCoefficients!=0)]
  n = length(zeroCovariates)
  m = length(nonzeroCovariates)
  expHdpsError = 0
  biasHdpsError = 0
  preset = !is.na(covariatesToDiscard) || !is.na(sampleRowIds)
  if(is.null(prior)) prior = createPrior(priorType = "none")
  
  if (!is.na(outcomePrevalence)) {
    sData = simulationProfile$sData
    cData = simulationProfile$cData
    fun <- function(d) {return(findOutcomePrevalence(sData, cData, d) - outcomePrevalence)}
    delta <- uniroot(fun, lower = 0, upper = 10000)$root
    sData$baseline = sData$baseline^delta
    cohortMethodData = simulateCMD(cohortMethodData, sData, cData, outcomeId)
  }
  
  for (i in 1:runs) {
    cmd = cohortMethodData
    if (!preset) {
      if (!is.na(sampleSize)) {
        sampleRowIds = sample(studyPop$rowId, sampleSize)
        sampleRowIds = sampleRowIds[order(sampleRowIds)]
      }
      if(!is.na(confoundingProportion)) {
        covariatesToDiscard = c(sample(zeroCovariates, ceiling(n*confoundingProportion)), sample(nonzeroCovariates, ceiling(m*confoundingProportion)))
      }
    }
    
    studyPop1 = studyPop
    if (!is.na(sampleRowIds)) {
      studyPop1 = studyPop[match(sampleRowIds, studyPop$rowId),]
      cmd = removeSubjects(cohortMethodData, sampleRowIds)
    }
    if (!is.na(covariatesToDiscard)) cmd = removeCovariates(cmd, ff::as.ff(covariatesToDiscard))
    
    if (hdpsFeatures == TRUE) {
      hdps0 = runHdps(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = .01)
      hdpsBias = runHdpsNewOutcomes(hdps0, cmd, useExpRank = FALSE)
    } else {
      hdps0 = runHdps1(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = .01)
      hdpsBias = runHdps1NewOutcomes(hdps0, cmd, useExpRank = FALSE)
    }
    
    psExp = createPs(cohortMethodData = hdps0$cmd, population = studyPop1, prior = prior, stopOnError = FALSE)
    if(!is.null(attr(psExp, "metaData")$psError)){
      expHdpsError = expHdpsError+1
    }
    
    psBias = createPs(cohortMethodData = hdpsBias, population = studyPop1, prior = prior, stopOnError = FALSE)
    if(!is.null(attr(psBias, "metaData")$psError)){
      biasHdpsError = biasHdpsError+1
    }
  }
  
  return(list(expHdpsError = expHdpsError,
              biasHdpsError = biasHdpsError,
              covariatesToDiscard = covariatesToDiscard,
              sampleRowIds = sampleRowIds,
              psExp = psExp,
              psBias = psBias,
              anyError = !(expHdpsError==0 & biasHdpsError==0)))
}

