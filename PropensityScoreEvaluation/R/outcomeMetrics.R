#' @export
calculateMetrics <- function(simulationResults, cohortMethodData, stdDiffThreshold = .05, allBalance=TRUE) {
  trueEffectSize = simulationResults$settings$trueEffectSize
  psLasso = psExpHdps = psBiasHdps = psRandom = simulationResults$ps[c("rowId", "treatment")]
  psLasso$propensityScore = simulationResults$ps$lassoPropensityScore
  psExpHdps$propensityScore = simulationResults$ps$expHdpsPropensityScore
  psBiasHdps$propensityScore = simulationResults$ps$biasHdpsPropensityScore
  psRandom$propensityScore = simulationResults$ps$randomPropensityScore
  
  return(list(lasso = calculateMetricsHelper(simulationResults$estimatesLasso, cohortMethodData, trueEffectSize, psLasso, stdDiffThreshold, allBalance),
              expHdps = calculateMetricsHelper(simulationResults$estimatesExpHdps, cohortMethodData, trueEffectSize, psExpHdps, stdDiffThreshold, allBalance),
              biasHdps = calculateMetricsHelper(simulationResults$estimatesBiasHdps, cohortMethodData, trueEffectSize, psBiasHdps, stdDiffThreshold, TRUE),
              random = calculateMetricsHelper(simulationResults$estimatesRandom, cohortMethodData, trueEffectSize, psRandom, stdDiffThreshold, allBalance)))
}

calculateMetricsHelper <- function(estimates, cohortMethodData, trueEffectSize, ps, stdDiffThreshold, doBalance) {
  if(is.null(estimates))return(NULL)
  good = which(abs(estimates$logRr)<10)
  n = length(good)
  #bias = mean(estimates$logRr[good]) - trueEffectSize
  bias = exp(mean(estimates$logRr[good]))/exp(trueEffectSize) - 1
  sd = sd(estimates$logRr[good]) / sqrt(n)
  rmse = sqrt(bias^2+sd^2)
  coverage = length(which((estimates$logLb95[good] <= trueEffectSize) & (estimates$logUb95[good] >= trueEffectSize))) / n
  population = matchOnPs(ps)
  beforeHighStdDiff = -1
  afterHighStdDiff = -1
  if(doBalance) {
    balance = computeCovariateBalance(population, cohortMethodData)
    beforeHighStdDiff = length(which(abs(balance$beforeMatchingStdDiff) >= stdDiffThreshold))/nrow(balance)
    afterHighStdDiff = length(which(abs(balance$afterMatchingStdDiff) >= stdDiffThreshold))/nrow(balance)
  }
  auc = computePsAuc(ps)
  return(list(bias = bias, sd = sd, rmse = rmse, coverage = coverage, auc = auc,
              beforeHighStdDiff = beforeHighStdDiff,
              afterHighStdDiff = afterHighStdDiff))
}

#' @export
calculateMetricsList <- function(simulationStudies, cohortMethodData, stdDiffThreshold = .05, dimensions) {
  #settings = simulationStudies$settings
  #I = length(settings$trueEffectSizeList)
  #J = length(settings$outcomePrevalenceList)
  I = dimensions[1]
  J = dimensions[2]
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

calculateMetricsList1 <- function(inFolder, cohortMethodData, dimensions) {
  result = rep(list(rep(list(rep(list(rep(list(NA), dimensions[4])), dimensions[3])), dimensions[2])), dimensions[1])
  counter = 1
  for (i in 1:dimensions[1]) {
    for (j in 1:dimensions[2]) {
      for (k in 1:dimensions[3]) {
        for (l in 1:dimensions[4]) {
          writeLines(paste("count:",counter))
          counter = counter+1
          allBalance = k==1&l==1
          simulationStudy = loadSimulationStudy(file.path(inFolder, paste("c",i,"_s",j,"_t",k,"_o",l,sep="")))
          metric = calculateMetrics(simulationStudy, cohortMethodData, stdDiffThreshold = .05, allBalance)
          if (!allBalance) {
            metric$lasso$beforeHighStdDiff = result[[i]][[j]][[1]][[1]]$lasso$beforeHighStdDiff
            metric$lasso$afterHighStdDiff = result[[i]][[j]][[1]][[1]]$lasso$afterHighStdDiff
            metric$expHdps$beforeHighStdDiff = result[[i]][[j]][[1]][[1]]$expHdps$beforeHighStdDiff
            metric$expHdps$afterHighStdDiff = result[[i]][[j]][[1]][[1]]$expHdps$afterHighStdDiff
            metric$random$beforeHighStdDiff = result[[i]][[j]][[1]][[1]]$random$beforeHighStdDiff
            metric$random$afterHighStdDiff = result[[i]][[j]][[1]][[1]]$random$afterHighStdDiff
          }
          result[[i]][[j]][[k]][[l]] = metric
        }
      }
    }
  }
  return(result)
}

graphMetrics <- function(metricsList, labels) {
  n = length(metricsList)
  f <- function(x)(combineFunction(x,function(x,y)c(x,y)))
  x = data.frame(
    Method = rep(names(metricsList[[1]])[1:3], n),
    RR = f(sapply(metricsList, function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias)))),
    sd = f(sapply(metricsList, function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd)))),
    rmse = f(sapply(metricsList, function(x)return(list(x$lasso$rmse, x$expHdps$rmse, x$biasHdps$rmse)))),
    coverage = f(sapply(metricsList, function(x)return(list(x$lasso$coverage, x$expHdps$coverage, x$biasHdps$coverage)))),
    auc = f(sapply(metricsList, function(x)return(list(x$lasso$auc, x$expHdps$auc, x$biasHdps$auc)))),
    afterHighStdDiff = f(sapply(metricsList, function(x)return(list(x$lasso$afterHighStdDiff, x$expHdps$afterHighStdDiff, x$biasHdps$afterHighStdDiff)))),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g1 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)
  g2 <- ggplot2::ggplot(x, ggplot2::aes(x = rmse, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 0.0)+ggplot2::facet_wrap(~labels,ncol=1)
  g3 <- ggplot2::ggplot(x, ggplot2::aes(x = coverage, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 1.0)+ggplot2::facet_wrap(~labels,ncol=1)
  g4 <- ggplot2::ggplot(x, ggplot2::aes(x = auc, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 1.0)+ggplot2::facet_wrap(~labels,ncol=1)
  g5 <- ggplot2::ggplot(x, ggplot2::aes(x = afterHighStdDiff, y = Method))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept = 0.0)+ggplot2::facet_wrap(~labels,ncol=1)
  gridExtra::grid.arrange(g1, g2, g3, g4, g5, ncol=5)
}

overlap <- function(simulationProfile, cohortMethodData, trueEffectSize, outcomePrevalence, hdpsFeatures) {
  partialCMD = cohortMethodData
  outcomeId = simulationProfile$outcomeId
  covariatesToDiscard = NULL
  sampleRowIds = NULL
  
  studyPop = simulationProfile$studyPop
  
  estimatesLasso = NULL
  estimatesExpHdps = NULL
  estimatesBiasHdps = NULL
  aucLasso = NULL
  aucExpHdps = NULL
  aucBiasHdps = NULL
  
  sData = simulationProfile$sData
  sData$XB = insertEffectSize(sData$XB, trueEffectSize, ff::as.ffdf(partialCMD$cohorts))
  cData = simulationProfile$cData
  cData$XB$exb = ff::as.ff(rep(1, nrow(cData$XB)))
  
  fun <- function(d) {return(findOutcomePrevalence(sData, cData, d) - outcomePrevalence)}
  delta <- uniroot(fun, lower = 0, upper = 10000)$root
  sData$baseline = sData$baseline^delta
  
  # create hdps PS
  cmd = simulateCMD(partialCMD, sData, cData, outcomeId)
  if (hdpsFeatures == TRUE) {
    hdps0 = runHdps(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = fudge)
    hdpsBias = runHdpsNewOutcomes(hdps0, cmd, useExpRank = FALSE)
  } else {
    hdps0 = runHdps1(cmd, outcomeId = outcomeId, useExpRank = TRUE, fudge = fudge)
    hdpsBias = runHdps1NewOutcomes(hdps0, cmd, useExpRank = FALSE)
  }
  
  features1 = as.numeric(names(which(simulationProfile$sOutcomeModelCoefficients!=0)))
  features2 = hdps0$cmd$covariateRef$covariateId[1:500]
  features3 = hdpsBias$covariateRef$covariateId[1:500]
  
  return(list(realSize = length(features1),
         expOverlap = length(which(features1 %in% features2))/length(features1),
         biasOverlap = length(which(features1 %in% features3))/length(features1)))
}

graphMetrics1 <- function(metrics, labels) {
  n = 4
  f <- function(x)(combineFunction(x,function(x,y)c(x,y)))
  metricsList = list(metrics[[1]][[1]],metrics[[2]][[1]],metrics[[3]][[1]],metrics[[4]][[1]])
  x = data.frame(
    Method = rep(names(metricsList[[1]])[1:3], n),
    RR = f(sapply(metricsList, function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias)))),
    sd = f(sapply(metricsList, function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd)))),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g1 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-.05, .05)
  
  metricsList = list(metrics[[1]][[2]],metrics[[2]][[2]],metrics[[3]][[2]],metrics[[4]][[2]])
  x = data.frame(
    Method = rep(names(metricsList[[1]])[1:3], n),
    RR = f(sapply(metricsList, function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias)))),
    sd = f(sapply(metricsList, function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd)))),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g2 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-.05, .05)
  
  metricsList = list(metrics[[1]][[3]],metrics[[2]][[3]],metrics[[3]][[3]],metrics[[4]][[3]])
  x = data.frame(
    Method = rep(names(metricsList[[1]])[1:3], n),
    RR = f(sapply(metricsList, function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias)))),
    sd = f(sapply(metricsList, function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd)))),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g3 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-.05, .05)
  
  
  metricsList = list(metrics[[1]][[4]],metrics[[2]][[4]],metrics[[3]][[4]],metrics[[4]][[4]])
  x = data.frame(
    Method = rep(names(metricsList[[1]])[1:3], n),
    RR = f(sapply(metricsList, function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias)))),
    sd = f(sapply(metricsList, function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd)))),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g4 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-.05, .05)
  
  gridExtra::grid.arrange(g1, g2, g3, g4, ncol=4)
}