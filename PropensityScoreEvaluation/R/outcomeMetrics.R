 #' @export
calculateMetrics <- function(simulationResults, cohortMethodData, simulationProfile, stdDiffThreshold = .05, computeAll = TRUE) {
  settings = simulationResults$settings
  psLasso = psExpHdps = psBiasHdps = psRandom = merge(simulationResults$ps[c("rowId", "treatment")], simulationProfile$sData$XB[])
  psLasso$propensityScore = simulationResults$ps$lassoPropensityScore
  psExpHdps$propensityScore = simulationResults$ps$expHdpsPropensityScore
  psBiasHdps$propensityScore = simulationResults$ps$biasHdpsPropensityScore
  psRandom$propensityScore = simulationResults$ps$randomPropensityScore
  
  result = list(lasso = calculateMetricsHelper(simulationResults$estimatesLasso, cohortMethodData, settings, psLasso, stdDiffThreshold, computeAll),
                expHdps = calculateMetricsHelper(simulationResults$estimatesExpHdps, cohortMethodData, settings, psExpHdps, stdDiffThreshold, computeAll),
                biasHdps = calculateMetricsHelper(simulationResults$estimatesBiasHdps, cohortMethodData, settings, psBiasHdps, stdDiffThreshold, TRUE),
                random = calculateMetricsHelper(simulationResults$estimatesRandom, cohortMethodData, settings, psRandom, stdDiffThreshold, computeAll))
  result$lasso$overlap = simulationResults$overlaps$overlapLasso
  result$expHdps$overlap = simulationResults$overlaps$overlapExp
  result$biasHdps$overlap = simulationResults$overlaps$overlapBias
  result$random$overlap = simulationResults$overlaps$overlapRandom
  return(result)
}

calculateMetricsHelper <- function(estimates, cohortMethodData, settings, ps, stdDiffThreshold, computeAll) {
  if(is.null(estimates))return(NULL)
  trueEffectSize = settings$trueEffectSize
  good = which(!is.na(estimates$seLogRr))
  n = length(good)
  bias = mean(estimates$logRr[good]) - trueEffectSize
  #bias = exp(mean(estimates$logRr[good]))/exp(trueEffectSize) - 1
  sd = sd(estimates$logRr[good]) / sqrt(n)
  rmse = sqrt(bias^2+sd^2)
  coverage = length(which((estimates$logLb95[good] <= trueEffectSize) & (estimates$logUb95[good] >= trueEffectSize))) / n
  if (settings$stratify) population = stratifyByPs(ps, numberOfStrata = settings$numStrata)
  else population = matchOnPs(ps, maxRatio = settings$maxRatio)
  beforeHighStdDiff = -1
  afterHighStdDiff = -1
  xbMean = -1
  xbSD = -1
  
  if(computeAll) {
    balance = computeCovariateBalance(population, cohortMethodData)
    beforeHighStdDiff = length(which(abs(balance$beforeMatchingStdDiff) >= stdDiffThreshold))/nrow(balance)
    afterHighStdDiff = length(which(abs(balance$afterMatchingStdDiff) >= stdDiffThreshold))/nrow(balance)
    population = aggregate(population, by = list(population$stratumId, population$treatment), FUN = mean)
    population = population[order(population$stratumId,population$treatment),]
    xbDiff = population[population$treatment==1,]$xb - population[population$treatment==0,]$xb
    xbMean = mean(xbDiff)
    xbBase = mean(population[population$treatment==0,]$xb)
    xbSD = sd(xbDiff)
  }
  auc = computePsAuc(ps)
  return(list(bias = bias, sd = sd, rmse = rmse, coverage = coverage, auc = auc,
              beforeHighStdDiff = beforeHighStdDiff, afterHighStdDiff = afterHighStdDiff,
              xbMean = xbMean, xbSD = xbSD))
}

#' @export
calculateMetrics1 <- function(simulationResults, cohortMethodData, simulationProfile, simulationSetup, balance=TRUE) {
  expHdps = NULL
  biasHdps = NULL
  beforeBalance = NULL
  settings = simulationResults$settings
  psLassoHDPS = simulationSetup$psLassoHDPS
  psLassoCDM = simulationSetup$psLassoCDM
  psLassoAll = simulationSetup$psLassoAll
  psExpCV = simulationSetup$psExpCV
  if (settings$nonePrior) {
    psExpHdps = simulationSetup$psExp
  }
  
  cohorts <- ff::as.ffdf(cohortMethodData$cohorts[, c("rowId", "treatment")])
  covariates <- cohortMethodData$covariates
  normFactors <- attr(cohortMethodData$covariates,"normFactors")
  if (!is.null(normFactors)){
    covariates <- ffbase::merge.ffdf(covariates, ff::as.ffdf(normFactors))
    covariates$covariateValue <- covariates$covariateValue * covariates$maxs
    covariates$maxs <- NULL
  }
  if (balance) {
    beforeBalance = computeBeforeCovariateBalance(cohorts, covariates)
    beforeBalance$stdDiff <- (beforeBalance$meanTreated - beforeBalance$meanComparator)/beforeBalance$sd
    beforeBalance = beforeBalance[,c("covariateId","stdDiff")]
  }
  
  outcomeModelCovariates = as.numeric(names(simulationProfile$outcomeModelCoefficients[simulationProfile$outcomeModelCoefficients!=0]))
  lassoHDPS = calculateMetricsHelper1(simulationResults$estimatesLassoHDPS, settings)
  lassoCDM = calculateMetricsHelper1(simulationResults$estimatesLassoCDM, settings)
  lassoAll = calculateMetricsHelper1(simulationResults$estimatesLassoAll, settings)
  expHdpsCV = calculateMetricsHelper1(simulationResults$estimatesExpHdpsCV, settings)
  biasHdpsCV = calculateMetricsHelper1(simulationResults$estimatesBiasHdpsCV, settings)
  if (settings$nonePrior) {
    expHdps = calculateMetricsHelper1(simulationResults$estimatesExpHdpsNone, settings)
    biasHdps = calculateMetricsHelper1(simulationResults$estimatesBiasHdpsNone, settings)
  }
  
  lassoHDPS1 = calculateMetricsHelper2(psLassoHDPS, settings, covariates, outcomeModelCovariates, balance)
  lassoCDM1 = calculateMetricsHelper2(psLassoCDM, settings, covariates, outcomeModelCovariates, balance)
  lassoAll1 = calculateMetricsHelper2(psLassoAll, settings, covariates, outcomeModelCovariates, balance)
  expHdpsCV1 = calculateMetricsHelper2(psExpCV, settings, covariates, outcomeModelCovariates, balance)
  if (settings$nonePrior) expHdps1 = calculateMetricsHelper2(psExpHdps, settings, covariates, outcomeModelCovariates, balance)
  
  f <- function(ps,cohorts,settings,covariates,outcomeModelCovariates, balance) {
    ps = data.frame(rowId = settings$rowId, propensityScore = ps)
    return(list(calculateMetricsHelper2(merge(ps,cohorts[,c("rowId","treatment")]),settings,covariates,outcomeModelCovariates,balance)))
  }
  
  biasHdpsCVList = sapply(simulationResults$psBiasCVList,f,cohorts,settings,covariates,outcomeModelCovariates,balance)
  if (settings$nonePrior) {
    biasHdpsList = sapply(simulationResults$psBiasNoneList,f,cohorts,settings,covariates,outcomeModelCovariates,balance)
  }
  
  lassoHDPS$auc = lassoHDPS1$auc
  lassoHDPS$overlap = lassoHDPS1$overlap
  lassoHDPS$afterBalance = lassoHDPS1$afterBalance
  lassoHDPS$utilized = lassoHDPS1$utilized
  
  lassoCDM$auc = lassoCDM1$auc
  lassoCDM$overlap = lassoCDM1$overlap
  lassoCDM$afterBalance = lassoCDM1$afterBalance
  lassoCDM$utilized = lassoCDM1$utilized
  
  lassoAll$auc = lassoAll1$auc
  lassoAll$overlap = lassoAll1$overlap
  lassoAll$afterBalance = lassoAll1$afterBalance
  lassoAll$utilized = lassoAll1$utilized
  
  expHdpsCV$auc = expHdpsCV1$auc
  expHdpsCV$overlap = expHdpsCV1$overlap
  expHdpsCV$afterBalance = expHdpsCV1$afterBalance
  expHdpsCV$utilized = expHdpsCV1$utilized
  
  biasHdpsCV$metrics = biasHdpsCVList
  
  if (settings$nonePrior) {
    expHdps$auc = expHdps1$auc
    expHdps$overlap = expHdps1$overlap
    expHdps$afterBalance = expHdps1$afterBalance
    expHdps$utilized = expHdps1$utilized
    biasHdps$metrics = biasHdpsList
  }
  
  return(list(lassoHDPS = lassoHDPS,
              lassoCDM = lassoCDM,
              lassoAll = lassoAll,
              expHdpsCV = expHdpsCV,
              expHdps = expHdps,
              biasHdpsCV = biasHdpsCV,
              biasHdps = biasHdps,
              beforeBalance = beforeBalance))
}

calculateMetricsHelper1 <- function(estimates, settings) {
  trueEffectSize = settings$trueEffectSize
  good = which(!is.na(estimates$seLogRr))
  n = length(good)
  bias = mean(estimates$logRr[good]) - trueEffectSize
  #bias = exp(mean(estimates$logRr[good]))/exp(trueEffectSize) - 1
  sd = sd(estimates$logRr[good]) / sqrt(n)
  rmse = sqrt(bias^2+sd^2)
  coverage = length(which((estimates$logLb95[good] <= trueEffectSize) & (estimates$logUb95[good] >= trueEffectSize))) / n
  return(list(bias = bias, sd = sd, rmse = rmse, coverage = coverage))
}

calculateMetricsHelper2 <- function(ps, settings, covariates, outcomeModelCovariates, balance) {
  auc = computePsAuc(ps)
  psModelCovariates = attributes(ps)$metaData$psModelCoef
  psModelCovariates = as.numeric(names(psModelCovariates[psModelCovariates!=0]))
  psModelCovariates = psModelCovariates[!is.na(psModelCovariates)]
  t = match(outcomeModelCovariates, psModelCovariates)
  overlap = length(which(!is.na(t)))/length(outcomeModelCovariates)
  afterBalance = NULL
  utilized = NULL
  if (balance) {
    if (settings$stratify) population = stratifyByPs(ps, numberOfStrata = settings$numStrata)
    else {
      if (settings$maximizeMatching) ps$treatment = 1 - ps$treatment
      population = matchOnPs(ps, maxRatio = settings$maxRatio)
      if (settings$maximizeMatching) population$treatment = 1 - population$treatment
    }
    afterBalance = computeAfterCovariateBalance(population, covariates)
    afterBalance$stdDiff <- (afterBalance$meanTreated - afterBalance$meanComparator)/afterBalance$sd
    afterBalance = afterBalance[,c("covariateId","stdDiff")]
    utilized = nrow(population)/nrow(ps)
  }
  return(list(auc = auc, overlap = overlap, afterBalance = afterBalance, utilized = utilized))
}

calculateMetricsList1 <- function(inFolder, cohortMethodData, simulationProfile, dimensions) {
  result = rep(list(rep(list(rep(list(rep(list(NA), dimensions[4])), dimensions[3])), dimensions[2])), dimensions[1])
  counter = 1
  for (i in 1:dimensions[1]) {
    for (j in 1:dimensions[2]) {
      for (k in 1:dimensions[3]) {
        for (l in 1:dimensions[4]) {
          writeLines(paste("count:",counter))
          counter = counter+1
          computeAll = k==1&l==1
          #simulationStudy = loadSimulationStudy(file.path(inFolder, paste("c",i,"_s",j,"_t",k,"_o",l,sep="")))
          simulationStudy = readRDS(file.path(inFolder, paste("c",i,"_s",j,"_t",k,"_o",l,".rds",sep="")))
          metric = calculateMetrics(simulationStudy, cohortMethodData, simulationProfile, stdDiffThreshold = .05, computeAll)
          if (!computeAll) {
            metric$lasso$beforeHighStdDiff = result[[i]][[j]][[1]][[1]]$lasso$beforeHighStdDiff
            metric$lasso$afterHighStdDiff = result[[i]][[j]][[1]][[1]]$lasso$afterHighStdDiff
            metric$lasso$xbMean = result[[i]][[j]][[1]][[1]]$lasso$xbMean
            metric$lasso$xbSD = result[[i]][[j]][[1]][[1]]$lasso$xbSD
            
            metric$expHdps$beforeHighStdDiff = result[[i]][[j]][[1]][[1]]$expHdps$beforeHighStdDiff
            metric$expHdps$afterHighStdDiff = result[[i]][[j]][[1]][[1]]$expHdps$afterHighStdDiff
            metric$expHdps$xbMean = result[[i]][[j]][[1]][[1]]$expHdps$xbMean
            metric$expHdps$xbSD = result[[i]][[j]][[1]][[1]]$expHdps$xbSD
            
            metric$random$beforeHighStdDiff = result[[i]][[j]][[1]][[1]]$random$beforeHighStdDiff
            metric$random$afterHighStdDiff = result[[i]][[j]][[1]][[1]]$random$afterHighStdDiff
            metric$random$xbMean = result[[i]][[j]][[1]][[1]]$random$xbMean
            metric$random$xbSD = result[[i]][[j]][[1]][[1]]$random$xbSD
          }
          result[[i]][[j]][[k]][[l]] = metric
        }
      }
    }
  }
  return(result)
}

graphMetrics <- function(metrics, labels, o) {
  metricsList = list(metrics[[1]][[o]],metrics[[2]][[o]],metrics[[3]][[o]],metrics[[4]][[o]])
  n = 4
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

graphMetrics1 <- function(metrics, labels, lim) {
  n = 4
  f <- function(x)(combineFunction(x,function(x,y)c(x,y)))
  f1 <- function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias))
  f2 <- function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd))
  #f1 <- function(x)return(list(x$lasso$bias, -5, x$biasHdps$bias))
  #f2 <- function(x)return(list(x$lasso$sd, 0, x$biasHdps$sd))
  methods = c("lasso", "expHdps", "biasHdps")
  metricsList = list(metrics[[1]][[1]],metrics[[2]][[1]],metrics[[3]][[1]],metrics[[4]][[1]])
  x = data.frame(
    Method = rep(methods, n),
    RR = f(sapply(metricsList, f1)),
    sd = f(sapply(metricsList, f2)),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g1 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-lim, lim)
  
  metricsList = list(metrics[[1]][[2]],metrics[[2]][[2]],metrics[[3]][[2]],metrics[[4]][[2]])
  x = data.frame(
    Method = rep(methods, n),
    RR = f(sapply(metricsList, f1)),
    sd = f(sapply(metricsList, f2)),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g2 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-lim, lim)
  
  metricsList = list(metrics[[1]][[3]],metrics[[2]][[3]],metrics[[3]][[3]],metrics[[4]][[3]])
  x = data.frame(
    Method = rep(methods, n),
    RR = f(sapply(metricsList, f1)),
    sd = f(sapply(metricsList, f2)),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g3 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-lim, lim)
  
  
  metricsList = list(metrics[[1]][[4]],metrics[[2]][[4]],metrics[[3]][[4]],metrics[[4]][[4]])
  x = data.frame(
    Method = rep(methods, n),
    RR = f(sapply(metricsList, f1)),
    sd = f(sapply(metricsList, f2)),
    labels = f(sapply(labels, function(x)rep(x,3)))
  )
  g4 <- ggplot2::ggplot(x, ggplot2::aes(x = RR, xmin = RR-sd, xmax = RR+sd, y = Method))+ ggplot2::geom_point(size=3)+ ggplot2::geom_segment(ggplot2::aes(x = RR-sd, xend = RR+sd, y = Method, yend=Method))+ ggplot2::geom_vline(xintercept = 0.0)+ ggplot2::facet_wrap(~labels,ncol=1)+ xlim(-lim, lim)
  
  gridExtra::grid.arrange(g1, g2, g3, g4, ncol=4)
}

#' @export
graphMetrics2 <- function(metrics, id) {
  n = 16
  f <- function(x)(combineFunction(x,function(x,y)c(x,y)))
  f1 <- function(x)return(list(x$lasso$bias, x$expHdps$bias, x$biasHdps$bias))
  f2 <- function(x)return(list(x$lasso$sd, x$expHdps$sd, x$biasHdps$sd))
  f3 <- function(x)return(list(x$lasso$rmse, x$expHdps$rmse, x$biasHdps$rmse))
  f4 <- function(x)return(list(x$lasso$coverage, x$expHdps$coverage, x$biasHdps$coverage))
  f5 <- function(x)return(list(x$lasso$auc, x$expHdps$auc, x$biasHdps$auc))
  f6 <- function(x)return(list(x$lasso$afterHighStdDiff, x$expHdps$afterHighStdDiff, x$biasHdps$afterHighStdDiff))
  f7 <- function(x)return(list(x$lasso$xbMean, x$expHdps$xbMean, x$biasHdps$xbMean))
  f8 <- function(x)return(list(x$lasso$xbSD, x$expHdps$xbSD ,x$biasHdps$xbSD))
  f9 <- function(x)return(list(sqrt(x$lasso$xbMean^2+x$lasso$xbSD^2), sqrt(x$expHdps$xbMean^2+x$expHdps$xbSD^2), sqrt(x$biasHdps$xbMean^2+x$biasHdps$xbSD^2)))
  f10 <- function(x)return(list(x$lasso$overlap, x$expHdps$overlap, x$biasHdps$overlap))
  
  params = f(sapply(c(1:16),function(x)return(list(x-0.15,x,x+0.15))))
  method = c("lasso","exp","bias")
  
  titles = c("C-0% , S-5k", "C-0% , S-10k", "C-0% , S-71k",
             "C-10%, S-5k", "C-10%, S-10k", "C-10%, S-71k",
             "C-50%, S-5k", "C-50%, S-10k", "C-50%, S-71k")
  
  createX <- function(col) {
    x = list(col[[1]][[1]],col[[2]][[1]],col[[3]][[1]],col[[4]][[1]],
             col[[1]][[2]],col[[2]][[2]],col[[3]][[2]],col[[4]][[2]],
             col[[1]][[3]],col[[2]][[3]],col[[3]][[3]],col[[4]][[3]],
             col[[1]][[4]],col[[2]][[4]],col[[3]][[4]],col[[4]][[4]])
    return(data.frame(params = params,
                      RR = f(sapply(x, f1)),
                      sd = f(sapply(x, f2)),
                      rmse = f(sapply(x,f3)),
                      cov = f(sapply(x,f4)),
                      auc = f(sapply(x,f5)),
                      stDiff = f(sapply(x,f6)),
                      xbMean = f(sapply(x,f7)),
                      xbSD = f(sapply(x,f8)),
                      xbRmse = f(sapply(x,f9)),
                      overlap = f(sapply(x,f10)),
                      method = rep(method,16)))
  }
  
  ylabels = c("t1_o1","t2_o1","t3_o1","t4_o1","t1_o2","t2_o2","t3_o2","t4_o2",
              "t1_o3","t2_o3","t3_o3","t4_o3","t1_o4","t2_o4","t3_o4","t4_o4")
  
  plot1 <- function(df){
    xlim0 = min(df$RR-df$sd)
    xlim1 = max(df$RR+df$sd)
    return(ggplot(df,aes(x=RR,xmin=RR-sd,xmax=RR+sd,y=params))+geom_point(aes(shape = method,color=method))+geom_segment(aes(x=RR-sd,xend=RR+sd,y=params,yend=params),size=.25)+scale_y_continuous(breaks=c(1:16),labels=ylabels)+geom_vline(xintercept = 0.0)+xlim(min(0,xlim0),max(0,xlim1)))
  }
  
  plot2 <- function(df) {
    xlim1 = max(df$rmse)
    return(ggplot(df,aes(x=rmse,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels)+geom_vline(xintercept = 0.0)+xlim(0,xlim1))
  }
  
  plot3 <- function(df) {
    return(ggplot(df,aes(x=cov,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels)+geom_vline(xintercept = 1.0))
  }
  
  plot4 <- function(df) {
    return(ggplot(df,aes(x=auc,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels)+geom_vline(xintercept = 1.0))
  }
  
  plot5 <- function(df) {
    return(ggplot(df,aes(x=stDiff,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels)+geom_vline(xintercept = 0.0))
  } 
  
  plot6 <- function(df) {
    return(ggplot(df,aes(x=xbMean,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels)+geom_vline(xintercept = 0.0))
  }
  
  plot7 <- function(df) {
    return(ggplot(df,aes(x=xbSD,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels))
  }
  
  plot8 <- function(df) {
    return(ggplot(df,aes(x=xbRmse,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels))
  }
  
  plot9 <- function(df) {
    return(ggplot(df,aes(x=overlap,y=params))+geom_point(aes(shape = method,color=method))+scale_y_continuous(breaks=c(1:16),labels=ylabels)+xlim(0,1))
  }
  
  if (id==1) plotFunc = plot1
  if (id==2) plotFunc = plot2
  if (id==3) plotFunc = plot3
  if (id==4) plotFunc = plot4
  if (id==5) plotFunc = plot5
  if (id==6) plotFunc = plot6
  if (id==7) plotFunc = plot7
  if (id==8) plotFunc = plot8
  if (id==9) plotFunc = plot9
  
  x = createX(metrics[[1]][[1]])
  g1 <- plotFunc(x) + ggplot2::ggtitle(titles[1])+theme(legend.position="none")#+theme(legend.justification=c(1,1), legend.position=c(1,1))
  x = createX(metrics[[1]][[2]])
  g2 <- plotFunc(x) + ggplot2::ggtitle(titles[2])+theme(legend.position="none")
  x = createX(metrics[[1]][[3]])
  g3 <- plotFunc(x) + ggplot2::ggtitle(titles[3])+theme(legend.position="none")
  x = createX(metrics[[2]][[1]])
  g4 <- plotFunc(x) + ggplot2::ggtitle(titles[4])+theme(legend.position="none")
  x = createX(metrics[[2]][[2]])
  g5 <- plotFunc(x) + ggplot2::ggtitle(titles[5])+theme(legend.position="none")
  x = createX(metrics[[2]][[3]])
  g6 <- plotFunc(x) + ggplot2::ggtitle(titles[6])+theme(legend.position="none")
  x = createX(metrics[[3]][[1]])
  g7 <- plotFunc(x) + ggplot2::ggtitle(titles[7])+theme(legend.position="none")
  x = createX(metrics[[3]][[2]])
  g8 <- plotFunc(x) + ggplot2::ggtitle(titles[8])+theme(legend.position="none")
  x = createX(metrics[[3]][[3]])
  g9 <- plotFunc(x) + ggplot2::ggtitle(titles[9])+theme(legend.position="none")
  gridExtra::grid.arrange(g1, g2, g3, g4, g5, g6, g7, g8, g9, ncol=3)
}
