estimates <- readRDS(file.path("data", "calibrated.rds"))
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
dbs <- unique(estimates$db)
methods <- unique(estimates[, c("method", "cer")])
strata <- as.character(unique(estimates$stratum))
strata <- strata[order(strata)]
strata <- c("All", strata)
analysisRef <- readRDS(file.path("data", "analysisRef.rds"))
trueRrs <- unique(estimates$targetEffectSize)
trueRrs <- trueRrs[order(trueRrs)]
trueRrs <- c("Overall", trueRrs)
