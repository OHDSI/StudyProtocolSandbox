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
runSimulationStudy <- function(simulationProfile, simulationSetup, simulationRuns = 10,  
                               trueEffectSize = NULL, outcomePrevalence = NULL, hdpsFeatures,
                               ignoreCensoring = FALSE, ignoreCensoringCovariates = TRUE, threads = 10) {
  # Save ff state
  saveFfState <- options("fffinalizer")$ffinalizer
  options("fffinalizer" = "delete")
  
  partialCMD = simulationProfile$partialCMD
  covariatesToDiscard = simulationSetup$settings$covariatesToDiscard
  sampleRowIds = simulationSetup$settings$sampleRowIds
  
  studyPop = simulationProfile$studyPop
  
  if (!is.null(sampleRowIds)) {
    studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
  }

  estimatesLasso = NULL
  estimatesExpHdps = NULL
  estimatesBiasHdps = NULL
  aucLasso = NULL
  aucExpHdps = NULL
  aucBiasHdps = NULL
  
  psLasso = simulationSetup$psLasso
  aucLasso = computePsAuc(psLasso)
  strataLasso = matchOnPs(psLasso)
  # strataLasso = stratifyByPs(psLasso)
  
  if (is.null(trueEffectSize)) trueEffectSize = simulationProfile$observedEffectSize
  
  sData = simulationProfile$sData
  sData$XB = insertEffectSize(sData$XB, trueEffectSize, ff::as.ffdf(partialCMD$cohorts))
  cData = simulationProfile$cData
  if (ignoreCensoring) cData$baseline = ff::as.ff(rep(1, length(cData$baseline)))
  if (ignoreCensoringCovariates) cData$XB$exb = ff::as.ff(rep(1, nrow(cData$XB)))
  
  # set new outcome prevalence
  if (!is.null(outcomePrevalence)) {
    fun <- function(d) {return(findOutcomePrevalence(sData, cData, d) - outcomePrevalence)}
    delta <- uniroot(fun, lower = 0, upper = 10000)$root
    sData$baseline = sData$baseline^delta
  } else {
    outcomePrevalence = findOutcomePrevalence(sData, cData)
  }

  # create hdps PS
  cmd = simulateCMD(partialCMD, sData, cData)
  if (hdpsFeatures == TRUE) {
    hdpsExp = runHdps(cmd, useExpRank = TRUE)
    hdpsBias = runHdps(cmd, useExpRank = FALSE)
  } else {
    hdpsExp = runHdps1(cmd, useExpRank = TRUE)
    hdpsBias = runHdps1(cmd, useExpRank = FALSE)
  }
  psExp = createPs = createPs(cohortMethodData = removeCovariates(hdpsExp, covariatesToDiscard), population = studyPop, prior = createPrior(priorType = "none"),
                              control = createControl(maxIterations = 10000, threads = threads))[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  aucExpHdps = computePsAuc(psExp)
  strataExp = matchOnPs(psExp)
  # strataExp = stratifyByPs(psExp)
  
  psBiasPermanent = createPs(cohortMethodData = removeCovariates(hdpsBias, covariatesToDiscard), population = studyPop, prior = createPrior(priorType = "none"),
                             control = createControl(maxIterations = 10000, threads = threads))[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  psBiasPermanent$propensityScore = 0
  psBiasPermanent$preferenceScore = 0

  
  for (i in 1:simulationRuns) {
    cmd = simulateCMD(partialCMD, sData, cData)
    if (is.null(cmd$outcomes)) next
    if (hdpsFeatures == TRUE) {
      hdpsBias = runHdps(cmd, useExpRank = FALSE)
    } else {
      hdpsBias = runHdps1(cmd, useExpRank = FALSE)
    }
    
    studyPopNew = studyPop
    studyPopNew$daysToEvent = cmd$cohorts$newDaysToEvent[match(studyPopNew$rowId, cmd$cohorts$rowId)]
    studyPopNew$outcomeCount = cmd$cohorts$newOutcomeCount[match(studyPopNew$rowId, cmd$cohorts$rowId)]
    studyPopNew$survivalTime = cmd$cohorts$newSurvivalTime[match(studyPopNew$rowId, cmd$cohorts$rowId)]
    
    psBias = createPs(cohortMethodData = removeCovariates(hdpsBias, covariatesToDiscard), population = studyPopNew, prior = createPrior(priorType = "none"),
                      control = createControl(maxIterations = 10000, threads = threads))
    
    popLasso = merge(studyPopNew, strataLasso[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    popExp = merge(studyPopNew, strataExp[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    popBias = matchOnPs(psBias)
    # popBias = stratifyByPs(psBias)
    
    outcomeModelLasso <- fitOutcomeModel(population = popLasso,
                                         cohortMethodData = cmd,
                                         modelType = "cox",
                                         stratified = TRUE,
                                         useCovariates = FALSE)
    outcomeModelExp <- fitOutcomeModel(population = popExp,
                                       cohortMethodData = cmd,
                                       modelType = "cox",
                                       stratified = TRUE,
                                       useCovariates = FALSE)
    outcomeModelBias <- fitOutcomeModel(population = popBias,
                                        cohortMethodData = cmd,
                                        modelType = "cox",
                                        stratified = TRUE,
                                        useCovariates = FALSE)
    estimatesLasso = rbind(outcomeModelLasso$outcomeModelTreatmentEstimate, estimatesLasso)
    estimatesExpHdps = rbind(outcomeModelExp$outcomeModelTreatmentEstimate, estimatesExpHdps)
    estimatesBiasHdps = rbind(outcomeModelBias$outcomeModelTreatmentEstimate, estimatesBiasHdps)
    
    aucBiasHdps = c(computePsAuc(psBias), aucBiasHdps)
    psBiasPermanent$propensityScore = psBiasPermanent$propensityScore + psBias$propensityScore
    psBiasPermanent$preferenceScore = psBiasPermanent$preferenceScore + psBias$preferenceScore
  }
  psBiasPermanent$propensityScore = psBiasPermanent$propensityScore / simulationRuns
  psBiasPermanent$preferenceScore = psBiasPermanent$preferenceScore / simulationRuns
  
  ps = data.frame(rowId = psLasso$rowId, treatment = psLasso$treatment, lassoPropensityScore = psLasso$propensityScore,
                  expHdpsPropensityScore = psExp$propensityScore, biasHdpsPropensityScore = psBiasPermanent$propensityScore)
  
  settings = simulationSetup$settings
  settings$trueEffectSize = trueEffectSize
  settings$outcomePrevalence = settings$outcomePrevalence
  settings$simulationRuns = simulationRuns
  settings$hdpsFeatures = hdpsFeatures
  
  # Restore ff state
  options("fffinalizer" = saveFfState)
  
  return(list(settings = settings,
              estimatesLasso = estimatesLasso,
              estimatesExpHdps = estimatesExpHdps,
              estimatesBiasHdps = estimatesBiasHdps,
              ps = ps))
}

#' @export
setUpSimulation <- function(simulationProfile, useCrossValidation = TRUE, confoundingScheme = 0, confoundingProportion = NA, sampleSize = NA, threads = 10) {
  partialCMD = simulationProfile$partialCMD
  studyPop = simulationProfile$studyPop
  
  sampleRowIds = NULL
  if (!is.na(sampleSize)) {
    sampleRowIds = sample(studyPop$rowId, sampleSize)
    studyPop = studyPop[match(sampleRowIds, studyPop$rowId),]
  }
  
  covariatesToDiscard = NULL
  if (confoundingScheme == 0) {
    covariatesToDiscard = NULL
  }
  if (confoundingScheme == 1) {
    covariatesToDiscard = partialCMD$covariateRef$covariateId[in.ff(partialCMD$covariateRef$analysisId, ff::as.ff(c(2,3,5,6)))]
  }
  if (confoundingScheme == 2) {
    covariatesToDiscard = ff::as.ff(sample(partialCMD$covariateRef$covariateId[], round(nrow(partialCMD$covariateRef)*(confoundingProportion))))
  }
  if (confoundingScheme == 3) {
    covariatesToDiscard = ff::as.ff(unique(c(partialCMD$covariateRef$covariateId[in.ff(partialCMD$covariateRef$analysisId, ff::as.ff(c(2,3,5,6)))],
                                             ff::as.ff(sample(partialCMD$covariateRef$covariateId[], round(nrow(partialCMD$covariateRef)*(confoundingProportion)))))))
  }
  
  # create lasso PS
  psLasso = createPs(cohortMethodData = removeCovariates(partialCMD, covariatesToDiscard), 
                     population = studyPop, 
                     prior = Cyclops::createPrior("laplace", exclude = c(), useCrossValidation = useCrossValidation),
                     control = createControl(noiseLevel = "silent",
                                             cvType = "auto", 
                                             tolerance = 2e-07, 
                                             cvRepetitions = 10, 
                                             startingVariance = 0.01,
                                             threads = threads))[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  
  settings = list(confoundingScheme = confoundingScheme,
                  confoundingProportion = confoundingProportion,
                  covariatesToDiscard = covariatesToDiscard,
                  sampleSize = sampleSize,
                  sampleRowIds = sampleRowIds)
  
  return(list(settings = settings,
              psLasso = psLasso))
}

#' @export
setUpSimulations <- function(simulationProfile, confoundingSchemeList, confoundingProportionList, 
                             useCrossValidation = TRUE, sampleSizeList, outputFolder, threads = 10) {
  if (!file.exists(outputFolder)) dir.create(outputFolder)
  settings = list(confoundingSchemeList = confoundingSchemeList,
                  confoundingProportionList = confoundingProportionList,
                  sampleSizeList = sampleSizeList)
  saveRDS(settings, file = file.path(outputFolder, "settings.rds"))
  
  #results = list(settings = settings, simulationSetups = rep(list(rep(list(NA), length(trueEffectSizeList))), length(confoundingSchemeList)))
  for (i in 1:length(confoundingSchemeList)) {
    for (j in 1:length(sampleSizeList)) {
      temp = setUpSimulation(simulationProfile, confoundingScheme = confoundingSchemeList[[i]],
                             confoundingProportion = confoundingProportionList[[i]],
                             useCrossValidation = useCrossValidation, sampleSize = sampleSizeList[[j]], threads = threads)
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
}

#' @export
loadSimulationSetup <- function(file) {
  if (!file.exists(file))
    stop(paste("Cannot find folder", file))
  if (!file.info(file)$isdir)
    stop(paste("Not a folder", file))
  settings = readRDS(file.path(file, "settings.rds"))
  psLasso = readRDS(file.path(file, "psLasso.rds"))
  return(list(settings = settings,
              psLasso = psLasso))
}

#' @export
runSimulationStudies <- function(simulationProfile, simulationSetup = NULL, simulationRuns = 10, trueEffectSizeList, 
                                 outcomePrevalenceList, hdpsFeatures, simulationSetupFolder = NULL, outputFolder) {
  if (!file.exists(outputFolder)) dir.create(outputFolder)
  if (is.null(simulationSetup)) {
    simulationSetup = loadSimulationSetup(simulationSetupFolder)
  } else {
    simulationSetupFolder = ""
  }
  settings = simulationSetup$settings
  settings$trueEffectSizeList = trueEffectSizeList
  settings$outcomePrevalenceList = outcomePrevalenceList
  
  outputFolder = paste(outputFolder, "/", basename(simulationSetupFolder), sep = "")
  if (!file.exists(outputFolder)) dir.create(outputFolder)
  
  saveRDS(settings, file = file.path(outputFolder, "settings.rds"))
  
  results = list(settings = settings, simulationStudies = rep(list(rep(list(NA), length(outcomePrevalenceList))), length(trueEffectSizeList)))
  for (i in 1:length(trueEffectSizeList)) {
    for (j in 1:length(outcomePrevalenceList)) {
        temp = runSimulationStudy(simulationProfile, simulationSetup = simulationSetup, simulationRuns = simulationRuns, 
                                  trueEffectSize = trueEffectSizeList[[i]], outcomePrevalence = outcomePrevalenceList[[j]], hdpsFeatures = hdpsFeatures)
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
      simulationStudies[[i]][[j]] = loadSimulationStudy(file = file.path(file, paste(basename(file), "_t", i, "_o", j, ".rds", sep="")))
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
  ps = readRDS(file.path(file, "ps.rds"))
  result = list(settings = settings,
                estimatesLasso = estimatesLasso,
                estimatesExpHdps = estimatesExpHdps,
                estimatesBiasHdps = estimatesBiasHdps,
                ps = ps)
  return(result)
}

