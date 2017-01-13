#' @export
calculateMetrics <- function(simulationResults, cohortMethodData, stdDiffThreshold = .05) {
  trueEffectSize = simulationResults$settings$trueEffectSize
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

#' @export
calculateMetricsList <- function(simulationStudies, cohortMethodData, stdDiffThreshold = .05) {
  settings = simulationStudies$settings
  I = length(settings$trueEffectSizeList)
  J = length(settings$outcomePrevalenceList)
  result = rep(list(rep(list(NA), J)), I)
  for (i in 1:I) {
    for (j in 1:J) {
        result[[i]][[j]] = calculateMetrics(simulationStudies$simulationStudies[[i]][[j]],
                                            cohortMethodData,
                                            stdDiffThreshold = .05)
    }
  }
  return(result)
}

graphMetrics <- function(metricsList, labels) {
  n = length(metricsList)
  f <- function(x)(combineFunction(x,function(x,y)c(x,y)))
  x = data.frame(
    Method = rep(names(metricsList[[1]]), n),
    RR = f(sapply(metricsList, function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias)))),
    sd = f(sapply(metricsList, function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd)))),
    rmse = f(sapply(metricsList, function(x)return(list(x$lasso$rmse, x$expHdps$rmse, x$biasHdps$rmse)))),
    coverage = f(sapply(metricsList, function(x)return(list(x$lasso$coverage, x$expHdps$coverage, x$biasHdps$coverage)))),
    auc = f(sapply(metricsList, function(x)return(list(x$lasso$auc, x$expHdps$auc, x$biasHdps$auc)))),
    afterHighStdDiff = f(sapply(metricsList, function(x)return(list(x$lasso$afterHighStdDiff, x$expHdps$afterHighStdDiff, x$biasHdps$afterHighStdDiff)))),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g1 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point()+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)
  g2 <- ggplot2::ggplot(x, ggplot2::aes(x = rmse, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 0.0)+ggplot2::facet_wrap(~labels,ncol=1)
  g3 <- ggplot2::ggplot(x, ggplot2::aes(x = coverage, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 1.0)+ggplot2::facet_wrap(~labels,ncol=1)
  g4 <- ggplot2::ggplot(x, ggplot2::aes(x = auc, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 1.0)+ggplot2::facet_wrap(~labels,ncol=1)
  g5 <- ggplot2::ggplot(x, ggplot2::aes(x = afterHighStdDiff, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 0.0)+ggplot2::facet_wrap(~labels,ncol=1)
  gridExtra::grid.arrange(g1, g2, g3, g4, g5, ncol=5)
}
