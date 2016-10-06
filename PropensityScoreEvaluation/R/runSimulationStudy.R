#' Runs Simulation Study
#'
#' @description
#' This function runs a simulation to compare LASSO, exposure based hdps, and bias based hdps as propensity score methods
#'
#' @param cohortMethodData cohortMethodData object
#' @param confoundingScheme Type of unmeasured confounding to use for PS (0 = none; 1 = demographics; 2 = random proportion; 3 = demographics and random proportion)
#' @param confoundingProportion Proportion of covariates to hide from propensity score as unmeasured confounding
#' @param n Number of simulations to run (1 simulation = reroll outcomes)
#' @param trueBeta True effect size for exposure to simulate
#' @param outcomePrevalence Outcome prevalence to simulate; adjusts outcome baseline survival function to achieve
#' @param crossValidate Can turn off cross validation when fitting outcome models in beginning and fitting LASSO propensity score
#' @param hdpsFeatures TRUE = using HDPS features; FALSE = using FeatureExtraction features
#' @param ignoreCensoring Ignore censoring altogether; sets censoring process baseline survival function to 1
#' @param ignoreCensoringCovariates Ignore covariates effects on censoring process; only uses baseline function
#'
#' @return
#' Returns the following: \describe {
#' \item{trueOutcomeModel}{coefficients used for true outcome model}
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
#' \item{originalOutcomePrevalence}{original outcome prevalence before adjustment to desired outcome prevalence}}
#' @export
runSimulationStudy <- function(cohortMethodData, confoundingScheme = 0, confoundingProportion = 0.3, n = 10,
                               trueBeta = NULL, outcomePrevalence = NULL, crossValidate = TRUE, hdpsFeatures = FALSE,
                               ignoreCensoring = FALSE, ignoreCensoringCovariates = TRUE) {
  estimatesLasso = NULL
  estimatesExpHdps = NULL
  estimatesBiasHdps = NULL
  aucLasso = NULL
  aucExpHdps = NULL
  aucBiasHdps = NULL
  
  if (is.null(trueBeta)) {
    replaceBeta = FALSE
  } else {
    replaceBeta = TRUE
  }
  
  # create simulation profile
  simulationProfile = createCMDSimulationProfile(cohortMethodData,
                                                 replaceBeta = replaceBeta,
                                                 newBeta = trueBeta,
                                                 crossValidate = crossValidate)
  
  # set new outcome prevalence
  originalOutcomePrevalence = findOutcomePrevalence(simulationProfile$sData, simulationProfile$cData)
  if (!is.null(outcomePrevalence)) {
    if (ignoreCensoring) simulationProfile$cData$baseline = ff::as.ff(rep(1, length(simulationProfile$cData$baseline)))
    if (ignoreCensoringCovariates) simulationProfile$cData$XB$exb = ff::as.ff(rep(1, length(simulationProfile$cData$XB$exb)))
    fun <- function(d) {return(findOutcomePrevalence(simulationProfile$sData, simulationProfile$cData, d) - outcomePrevalence)}
    delta <- uniroot(fun, lower = 0, upper = 10000)$root
    simulationProfile$sData$baseline = simulationProfile$sData$baseline^delta
  }
  
  studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
                                    outcomeId = 3,
                                    firstExposureOnly = FALSE,
                                    washoutPeriod = 0,
                                    removeDuplicateSubjects = FALSE,
                                    removeSubjectsWithPriorOutcome = TRUE,
                                    minDaysAtRisk = 1,
                                    riskWindowStart = 0,
                                    addExposureDaysToStart = FALSE,
                                    riskWindowEnd = 30,
                                    addExposureDaysToEnd = TRUE)
  
  covariatesToDiscard = NULL
  if (confoundingScheme == 0) {
    covariatesToDiscard = NULL
  }
  if (confoundingScheme == 1) {
    covariatesToDiscard = cohortMethodData$covariateRef$covariateId[in.ff(cohortMethodData$covariateRef$analysisId, ff::as.ff(c(2,3,5,6)))]
  }
  if (confoundingScheme == 2) {
    covariatesToDiscard = ff::as.ff(sample(cohortMethodData$covariateRef$covariateId[], round(nrow(cohortMethodData$covariateRef)*(confoundingProportion))))
  }
  if (confoundingScheme == 3) {
    covariatesToDiscard = ff::as.ff(unique(c(cohortMethodData$covariateRef$covariateId[in.ff(cohortMethodData$covariateRef$analysisId, ff::as.ff(c(2,3,5,6)))],
                                             ff::as.ff(sample(cohortMethodData$covariateRef$covariateId[], round(nrow(cohortMethodData$covariateRef)*(confoundingProportion)))))))
  }
  
  # create lasso PS
  psLasso = createPs(removeCovariates(cohortMethodData, covariatesToDiscard), studyPop, prior = Cyclops::createPrior("laplace", exclude = c(), useCrossValidation = crossValidate))[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  aucLasso = computePsAuc(psLasso)
  strataLasso = matchOnPs(psLasso)
  # strataLasso = stratifyByPs(psLasso)
  
  # create hdps PS
  cmd = simulateCMD(simulationProfile$partialCMD, simulationProfile$sData, simulationProfile$cData, ignoreCensoring = ignoreCensoring)
  if (hdpsFeatures == TRUE) {
    hdpsExp = runHdps(cmd, useExpRank = TRUE)
    hdpsBias = runHdps(cmd, useExpRank = FALSE)
  } else {
    hdpsExp = runHdps1(cmd, useExpRank = TRUE)
    hdpsBias = runHdps1(cmd, useExpRank = FALSE)
  }
  psExp = createPs = createPs(cohortMethodData = removeCovariates(hdpsExp, covariatesToDiscard), population = studyPop, prior = createPrior(priorType = "none"),
                              control = createControl(maxIterations = 10000))[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  aucExpHdps = computePsAuc(psExp)
  strataExp = matchOnPs(psExp)
  # strataExp = stratifyByPs(psExp)
  
  psBiasPermanent = createPs(cohortMethodData = removeCovariates(hdpsBias, covariatesToDiscard), population = studyPop, prior = createPrior(priorType = "none"),
                             control = createControl(maxIterations = 10000))[c("rowId", "subjectId", "treatment", "propensityScore", "preferenceScore")]
  psBiasPermanent$propensityScore = 0
  psBiasPermanent$preferenceScore = 0
  
  for (i in 1:n) {
    cmd = simulateCMD(simulationProfile$partialCMD, simulationProfile$sData, simulationProfile$cData, ignoreCensoring = ignoreCensoring)
    if (hdpsFeatures == TRUE) {
      hdpsBias = runHdps(cmd, useExpRank = FALSE)
    } else {
      hdpsBias = runHdps1(cmd, useExpRank = FALSE)
    }
    
    studyPop <- createStudyPopulation(cohortMethodData = cmd,
                                      outcomeId = 3,
                                      firstExposureOnly = FALSE,
                                      washoutPeriod = 0,
                                      removeDuplicateSubjects = FALSE,
                                      removeSubjectsWithPriorOutcome = TRUE,
                                      minDaysAtRisk = 1,
                                      riskWindowStart = 0,
                                      addExposureDaysToStart = FALSE,
                                      riskWindowEnd = 30,
                                      addExposureDaysToEnd = TRUE)
    
    psBias = createPs(cohortMethodData = removeCovariates(hdpsBias, covariatesToDiscard), population = studyPop, prior = createPrior(priorType = "none"),
                      control = createControl(maxIterations = 10000))
    
    popLasso = merge(studyPop, strataLasso[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
    popExp = merge(studyPop, strataExp[,c("rowId", "propensityScore", "preferenceScore", "stratumId")])
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
  psBiasPermanent$propensityScore = psBiasPermanent$propensityScore / n
  psBiasPermanent$preferenceScore = psBiasPermanent$preferenceScore / n
  
  return(list(trueOutcomeModel = simulationProfile$sOutcomeModel$outcomeModelCoefficients,
              trueEffectSize = coef(simulationProfile$sOutcomeModel),
              estimatesLasso = estimatesLasso,
              estimatesExpHdps = estimatesExpHdps,
              estimatesBiasHdps = estimatesBiasHdps,
              aucLasso = aucLasso,
              aucExpHdps = aucExpHdps,
              aucBiasHdps = mean(aucBiasHdps),
              psLasso = psLasso,
              psExp = psExp,
              psBias = psBiasPermanent,
              originalOutcomePrevalence = originalOutcomePrevalence))
}