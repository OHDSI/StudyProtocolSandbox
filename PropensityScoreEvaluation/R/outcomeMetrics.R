#' @export
calculateMetrics <- function(simulationResults, cohortMethodData, stdDiffThreshold = .05) {
  trueEffectSize = simulationResults$trueEffectSize
  psLasso = psExpHdps = psBiasHdps = simulationResults$ps[c("rowId", "treatment")]
  psLasso$propensityScore = simulationResults$ps$lassoPropensityScore
  psExpHdps$propensityScore = simulationResults$ps$expHdpsPropensityScore
  psBiasHdps$propensityScore = simulationResults$ps$biasHdpsPropensityScore
  
  return(list(lasso = calculateMetricsHelper(simulationResults$estimatesLasso, cohortMethodData, trueEffectSize, psLasso, stdDiffThreshold),
              expHdps = calculateMetricsHelper(simulationResults$estimatesExpHdps, cohortMethodData, trueEffectSize, psExpHdps, stdDiffThreshold),
              biasHdps = calculateMetricsHelper(simulationResults$estimatesBiasHdps, cohortMethodData, trueEffectSize, psBiasHdps, stdDiffThreshold)))
}

calculateMetricsHelper <- function(estimates, cohortMethodData, trueEffectSize, ps, stdDiffThreshold) {
  bias = mean(estimates$logRr) - trueEffectSize
  sd = sd(estimates$logRr)
  rmse = sqrt(bias^2+sd^2)
  coverage = length(which((estimates$logLb95 <= trueEffectSize) & (estimates$logUb95 >= trueEffectSize))) / nrow(estimates)
  population = matchOnPs(ps)
  balance = computeCovariateBalance(population, cohortMethodData)
  beforeHighStdDiff = length(which(abs(balance$beforeMatchingStdDiff) >= stdDiffThreshold))/nrow(balance)
  afterHighStdDiff = length(which(abs(balance$afterMatchingStdDiff) >= stdDiffThreshold))/nrow(balance)
  auc = computePsAuc(ps)
  return(list(bias = bias, sd = sd, rmse = rmse, coverage = coverage, auc = auc, beforeHighStdDiff = beforeHighStdDiff, afterHighStdDiff = afterHighStdDiff))
}