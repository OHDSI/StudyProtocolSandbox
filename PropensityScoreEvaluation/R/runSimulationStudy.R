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
                               trueEffectSize = NULL, outcomePrevalence = NULL, hdpsFeatures, stratify=FALSE, discrete=FALSE,
                               ignoreCensoring = FALSE, threads = 10, fudge = .001) {
  # Save ff state
  saveFfState <- options("fffinalizer")$ffinalizer
  options("fffinalizer" = "delete")
  estimatesLasso = NULL
  estimatesExpHdps = NULL
  estimatesBiasHdps = NULL
  estimatesRandom = NULL
  aucLasso = NULL
  aucExpHdps = NULL
  aucBiasHdps = NULL
  aucRandom = NULL
  
  outcomeId = simulationProfile$outcomeId
  sData = simulationProfile$sData
  cData = simulationProfile$cData
  covariatesToDiscard = simulationSetup$settings$covariatesToDiscard
  sampleRowIds = simulationSetup$settings$sampleRowIds
  studyPop = simulationProfile$studyPop
  partialCMD = cohortMethodData
  
  # modify confounding and sample size
  if(!is.null(covariatesToDiscard)) {
    partialCMD = removeCovariates(partialCMD, ff::as.ff(covariatesToDiscard))
  }
  
  if (!is.null(sampleRowIds)) {
    studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
    sData$XB = sData$XB[ffbase::ffmatch(ff::as.ff(sampleRowIds), sData$XB$rowId),]
    partialCMD = removeSubjects(partialCMD, sampleRowIds)
  }

  # insert true effect size
  if (is.null(trueEffectSize)) trueEffectSize = simulationProfile$observedEffectSize
  sData$XB = insertEffectSize(sData$XB, trueEffectSize, ff::as.ffdf(partialCMD$cohorts))
  # ignore censoring
  if (ignoreCensoring) cData$baseline = ff::as.ff(rep(1, length(cData$baseline)))
  
  # set new outcome prevalence
  if (!is.null(outcomePrevalence)) {
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
  if (stratify) strataLasso=stratifyByPs(psLasso,10) else strataLasso=matchOnPs(psLasso)
  
  psRandom = psLasso
  psRandom$propensityScore = runif(nrow(psRandom),0,1)
  aucRandom = computePsAuc(psRandom)
  if (stratify) strataRandom=stratifyByPs(psRandom,10) else strataRandom=matchOnPs(psRandom)
  
  psExp = simulationSetup$psExp
  aucExpHdps = computePsAuc(psExp)
  if (stratify) strataExp=stratifyByPs(psExp,10) else strataExp=matchOnPs(psExp)

  psBiasPermanent = psLasso
  psBiasPermanent$propensityScore = 0
  psBiasPermanent$preferenceScore = 0
  biasErrorCount = 0
  noOutcomeCount = 0

  for (i in 1:simulationRuns) {
    start <- Sys.time()
    writeLines(paste("Simulation: ", i))
    cmd = simulateCMD(partialCMD, sData, cData, outcomeId = outcomeId, discrete = discrete)
    if (is.null(cmd$outcomes)) {
      noOutcomeCount = noOutcomeCount+1
      writeLines("error: no outcomes simulated")
      next
    }
    if (hdpsFeatures == TRUE) {
      hdpsBias = runHdpsNewOutcomes(hdps0, cmd, useExpRank = FALSE)
    } else {
      hdpsBias = runHdps1NewOutcomes(hdps0, cmd, useExpRank = FALSE)
    }
    
    studyPopNew = studyPop
    studyPopNew$daysToEvent = cmd$cohorts$newDaysToEvent[match(studyPopNew$rowId, cmd$cohorts$rowId)]
    studyPopNew$outcomeCount = cmd$cohorts$newOutcomeCount[match(studyPopNew$rowId, cmd$cohorts$rowId)]
    studyPopNew$survivalTime = cmd$cohorts$newSurvivalTime[match(studyPopNew$rowId, cmd$cohorts$rowId)]
    
    # calculate outcomes for lasso
    popLasso = merge(studyPopNew, strataLasso[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    outcomeModelLasso <- fitOutcomeModel(population = popLasso,
                                         cohortMethodData = cmd,
                                         modelType = "cox",
                                         stratified = TRUE,
                                         useCovariates = FALSE)
    estimatesLasso = rbind(outcomeModelLasso$outcomeModelTreatmentEstimate, estimatesLasso)
    
    # calculate outcomes for random
    popRandom = merge(studyPopNew, strataRandom[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    outcomeModelRandom <- fitOutcomeModel(population = popRandom,
                                          cohortMethodData = cmd,
                                          modelType = "cox",
                                          stratified = TRUE,
                                          useCovariates = FALSE)
    estimatesRandom = rbind(outcomeModelRandom$outcomeModelTreatmentEstimate, estimatesRandom)
    
    # calculate outcomes for exp hdps
    popExp = merge(studyPopNew, strataExp[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    outcomeModelExp <- fitOutcomeModel(population = popExp,
                                       cohortMethodData = cmd,
                                       modelType = "cox",
                                       stratified = TRUE,
                                       useCovariates = FALSE)
    estimatesExpHdps = rbind(outcomeModelExp$outcomeModelTreatmentEstimate, estimatesExpHdps)
    
    # calculate outcomes for bias hdps
    psBias = createPs(cohortMethodData = hdpsBias, population = studyPopNew, prior = createPrior(priorType = "none"), stopOnError = FALSE)
    
    if(is.null(attr(psBias, "metaData")$psError)){
      if (stratify) popBias=stratifyByPs(psBias,10) else popBias=matchOnPs(psBias)
      outcomeModelBias  <- fitOutcomeModel(population = popBias,
                                          cohortMethodData = cmd,
                                          modelType = "cox",
                                          stratified = TRUE,
                                          useCovariates = FALSE)
      estimatesBiasHdps = rbind(outcomeModelBias$outcomeModelTreatmentEstimate, estimatesBiasHdps)
      
      aucBiasHdps = c(computePsAuc(psBias), aucBiasHdps)
      psBiasPermanent$propensityScore = psBiasPermanent$propensityScore + psBias$propensityScore
      psBiasPermanent$preferenceScore = psBiasPermanent$preferenceScore + psBias$preferenceScore
    } else {
      writeLines(paste("bias based hdps propensity score error:", attr(psBias, "metaData")$psError))
      biasErrorCount = biasErrorCount+1
    }
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
                  expHdpsPropensityScore = psExp$propensityScore, biasHdpsPropensityScore = psBiasPermanent$propensityScore,
                  randomPropensityScore = psRandom$propensityScore)
  
  settings = simulationSetup$settings
  settings$trueEffectSize = trueEffectSize
  settings$outcomePrevalence = outcomePrevalence
  settings$simulationRuns = simulationRuns
  settings$hdpsFeatures = hdpsFeatures
  
  # Restore ff state
  options("fffinalizer" = saveFfState)
  
  return(list(settings = settings,
              estimatesLasso = estimatesLasso,
              estimatesExpHdps = estimatesExpHdps,
              estimatesBiasHdps = estimatesBiasHdps,
              estimatesRandom = estimatesRandom,
              biasErrorCount = biasErrorCount,
              noOutcomeCount = noOutcomeCount,
              ps = ps))
}

#' @export
setUpSimulation <- function(simulationProfile, cohortMethodData, useCrossValidation = TRUE, confoundingProportion = NA, sampleSize = NA, threads = 10, hdpsFeatures) {
  studyPop = simulationProfile$studyPop
  
  expHdpsError = 1
  biasHdpsError = 1
  covariatesToDiscard = NULL
  sampleRowIds = NULL
  while((expHdpsError==1) | (biasHdpsError==1)) {
    test = testConvergence(cohortMethodData=cohortMethodData, simulationProfile=simulationProfile,  
                           confoundingProportion=confoundingProportion, sampleSize=sampleSize, hdpsFeatures=hdpsFeatures, runs = 1)
    expHdpsError = test$expHdpsError
    biasHdpsError = test$biasHdpsError
    covariatesToDiscard = test$covariatesToDiscard
    sampleRowIds = test$sampleRowIds
  }
  if (!is.null(sampleRowIds)) {
    studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
    cohortMethodData = removeSubjects(cohortMethodData, sampleRowIds)
  }
  if (!is.null(covariatesToDiscard)) {
    cohortMethodData = removeCovariates(cohortMethodData, ff::as.ff(covariatesToDiscard))
  }
  
  # create lasso PS
  psLasso = createPs(cohortMethodData = cohortMethodData, 
                     population = studyPop, 
                     prior = Cyclops::createPrior("laplace", exclude = c(), useCrossValidation = useCrossValidation),
                     control = createControl(noiseLevel = "silent",
                                             cvType = "auto", 
                                             tolerance = 2e-07, 
                                             cvRepetitions = 10, 
                                             startingVariance = 0.01,
                                             threads = threads))#[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  
  settings = list(confoundingProportion = confoundingProportion,
                  covariatesToDiscard = covariatesToDiscard,
                  sampleSize = sampleSize,
                  sampleRowIds = sampleRowIds,
                  outcomeId = simulationProfile$outcomeId)
  
  return(list(settings = settings,
              psLasso = psLasso,
              psExp = test$psExp))
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
  saveRDS(simulationStudy$biasErrorCount, file = file.path(file, "biasErrorCount.rds"))
  saveRDS(simulationStudy$noOutcomeCount, file = file.path(file, "noOutcomeCount.rds"))
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
  biasErrorCount = readRDS(file.path(file, "biasErrorCount.rds"))
  noOutcomeCount = readRDS(file.path(file, "noOutcomeCount.rds"))
  ps = readRDS(file.path(file, "ps.rds"))
  result = list(settings = settings,
                estimatesLasso = estimatesLasso,
                estimatesExpHdps = estimatesExpHdps,
                estimatesBiasHdps = estimatesBiasHdps,
                estimatesRandom = estimatesRandom,
                biasErrorCount = biasErrorCount,
                noOutcomeCount = noOutcomeCount,
                ps = ps)
  return(result)
}

#' @export
testConvergence <- function(cohortMethodData, simulationProfile, confoundingProportion=NA, sampleSize=NA, hdpsFeatures, runs = 1) {
  studyPop = simulationProfile$studyPop
  outcomeId = simulationProfile$outcomeId
  modelCovariates = as.numeric(names(simulationProfile$outcomeModelCoefficients))
  zeroCovariates = modelCovariates[which(modelCovariates==0)]
  nonzeroCovariates = modelCovariates[which(modelCovariates!=0)]
  n = length(zeroCovariates)
  m = length(nonzeroCovariates)
  expHdpsError = 0
  biasHdpsError = 0
  sampleRowIds = NULL
  covariatesToDiscard = NULL
  
  for (i in 1:runs) {
    cmd = cohortMethodData
    if (!is.na(sampleSize)) {
      sampleRowIds = sample(studyPop$rowId, sampleSize)
      sampleRowIds = sampleRowIds[order(sampleRowIds)]
      studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
      cmd = removeSubjects(cohortMethodData, sampleRowIds)
    }
    if(!is.na(confoundingProportion)) {
      covariatesToDiscard = c(sample(zeroCovariates, ceiling(n*confoundingProportion)), sample(nonzeroCovariates, ceiling(m*confoundingProportion)))
      cmd = removeCovariates(cmd, ff::as.ff(covariatesToDiscard))
    }
    
    if (hdpsFeatures == TRUE) {
      hdps0 = runHdps(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = .01)
      hdpsBias = runHdpsNewOutcomes(hdps0, cmd, useExpRank = FALSE)
    } else {
      hdps0 = runHdps1(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = .01)
      hdpsBias = runHdps1NewOutcomes(hdps0, cmd, useExpRank = FALSE)
    }
    
    psExp = createPs(cohortMethodData = hdps0$cmd, population = studyPop, prior = createPrior(priorType = "none"), stopOnError = FALSE)
    if(!is.null(attr(psExp, "metaData")$psError)){
      expHdpsError = expHdpsError+1
    }
    
    psBias = createPs(cohortMethodData = hdpsBias, population = studyPop, prior = createPrior(priorType = "none"), stopOnError = FALSE)
    if(!is.null(attr(psBias, "metaData")$psError)){
      biasHdpsError = biasHdpsError+1
    }
  }
  
  return(list(expHdpsError = expHdpsError,
              biasHdpsError = biasHdpsError,
              covariatesToDiscard = covariatesToDiscard,
              sampleRowIds = sampleRowIds,
              psExp = psExp,
              psBias = psBias))
}

