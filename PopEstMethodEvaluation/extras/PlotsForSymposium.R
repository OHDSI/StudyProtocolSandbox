exportFolder <- "C:/Users/mschuemi/Git/StudyProtocolSandbox/PopEstMethodEvaluation/inst/shinyApps/MethodEvalViewer/data"
estimates <- read.csv(file.path(exportFolder, "calibrated.csv"))
estimates$trueEffectSize[estimates$firstExposureOnly] <- estimates$trueEffectSizeFirstExposure[estimates$firstExposureOnly]
z <- estimates$logRr/estimates$seLogRr
estimates$p <- 2 * pmin(pnorm(z), 1 - pnorm(z))
idx <- is.na(estimates$logRr) | is.infinite(estimates$logRr) | is.na(estimates$seLogRr) | is.infinite(estimates$seLogRr)
estimates$logRr[idx] <- 0
estimates$seLogRr[idx] <- 999
estimates$ci95lb[idx] <- 0
estimates$ci95ub[idx] <- 999
estimates$p[idx] <- 1
idx <- is.na(estimates$calLogRr) | is.infinite(estimates$calLogRr) | is.na(estimates$calSeLogRr) | is.infinite(estimates$calSeLogRr)
estimates$calLogRr[idx] <- 0
estimates$calSeLogRr[idx] <- 999
estimates$calCi95lb[idx] <- 0
estimates$calCi95ub[idx] <- 999
estimates$calP[is.na(estimates$calP)] <- 1
analysisRef <- read.csv(file.path(exportFolder, "AnalysisRef.csv"))

# Filter by MDRR
subset <- estimates[!is.na(estimates$mdrrTarget) & estimates$mdrrTarget < 1.25, ]

# Control counts:
combis <- unique(subset[, c("targetId", "comparatorId", "oldOutcomeId", "targetEffectSize")])
ncCount <- sum(combis$targetEffectSize == 1)
pcCount <- sum(combis$targetEffectSize != 1)
writeLines(paste0("Metrics based on ", ncCount, " negative and ", pcCount, " positive controls"))

# Compute metrics:
combis <- unique(subset[, c("method", "analysisId")])
computeMetrics <- function(i) {
    forEval <- subset[subset$method == combis$method[i] & subset$analysisId == combis$analysisId[i], ]
    roc <- pROC::roc(forEval$targetEffectSize > 1, forEval$logRr, algorithm = 3)
    auc <- round(pROC::auc(roc), 2)
    # mse <- round(mean((forEval$logRr - log(forEval$targetEffectSize))^2), 2)
    mse <- round(mean((forEval$logRr - log(forEval$trueEffectSize))^2), 2)
    # coverage <- round(mean(forEval$ci95lb < forEval$targetEffectSize & forEval$ci95ub > forEval$targetEffectSize), 2)
    coverage <- round(mean(forEval$ci95lb < forEval$trueEffectSize & forEval$ci95ub > forEval$trueEffectSize), 2)
    meanP <- round(mean(1/(forEval$seLogRr^2)), 2)
    type1 <- round(mean(forEval$p[forEval$targetEffectSize == 1] < 0.05), 2)
    type2 <- round(mean(forEval$p[forEval$targetEffectSize > 1] >= 0.05), 2)
    missing <- round(mean(forEval$seLogRr == 999), 2)
    return(c(auc = auc, coverage = coverage, meanP = meanP, mse = mse, type1 = type1, type2 = type2, missing = missing))
}
combis <- cbind(combis, as.data.frame(t(sapply(1:nrow(combis), computeMetrics))))
table <- merge(combis, analysisRef)
table$json <- NULL
write.csv(table, file.path(exportFolder, "MetricsTable.csv"), row.names = FALSE)
