#' @export
calculateMetrics <- function(simulationResults, cohortMethodData, stdDiffThreshold = .05) {
  trueEffectSize = simulationResults$trueEffectSize
  return(list(lasso = calculateMetricsHelper(simulationResults$estimatesLasso, cohortMethodData, trueEffectSize, simulationResults$aucLasso, simulationResults$psLasso, stdDiffThreshold),
              expHdps = calculateMetricsHelper(simulationResults$estimatesExpHdps, cohortMethodData, trueEffectSize, simulationResults$aucExpHdps, simulationResults$psExp, stdDiffThreshold),
              biasHdps = calculateMetricsHelper(simulationResults$estimatesBiasHdps, cohortMethodData, trueEffectSize, simulationResults$aucBiasHdps, simulationResults$psBias, stdDiffThreshold)))
}

calculateMetricsHelper <- function(estimates, cohortMethodData, trueEffectSize, auc, ps, stdDiffThreshold) {
  bias = mean(estimates$logRr) - trueEffectSize
  sd = sd(estimates$logRr)
  rmse = sqrt(bias^2+sd^2)
  coverage = length(which((estimates$logLb95 <= trueEffectSize) & (estimates$logUb95 >= trueEffectSize))) / nrow(estimates)
  population = matchOnPs(ps)
  balance = computeCovariateBalance(population, cohortMethodData)
  beforeHighStdDiff = length(which(balance$beforeMatchingStdDiff >= stdDiffThreshold))/nrow(balance)
  afterHighStdDiff = length(which(balance$afterMatchingStdDiff >= stdDiffThreshold))/nrow(balance)
  return(list(bias = bias, sd = sd, rmse = rmse, coverage = coverage, auc = auc, beforeHighStdDiff = beforeHighStdDiff, afterHighStdDiff = afterHighStdDiff))
}