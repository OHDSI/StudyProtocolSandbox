main <- function(connectionDetails,
                 databaseName,
                 cdmDatabaseSchema,
                 cohortDatabaseSchema,
                 oracleTempSchema = NULL,
                 outputLocation,
                 cohortTable,
                 createCohorts = F,
                 runAtria = F,
                 runFramingham = F,
                 runChads2 = F,
                 runChads2Vas = F,
                 runQstroke = F,
                 summariseResults = F,
                 packageResults = F,
                 N=10){

  #createCohort
  if(createCohorts){
    createCohorts(connectionDetails = connectionDetails,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable,
                  oracleTempSchema = oracleTempSchema,
                  outputFolder = outputLocation)

  }

  writeLines('Loading settings')
  settingsCsv <- system.file("settings", "settings.csv", package = "ExistingStrokeRiskExternalValidation")
  settings <- read.csv(settingsCsv)

  exclude <- c()
  if(!runAtria){
    exclude <- c(exclude, which(settings$model=='atriaStrokeModel'))
  }
  if(!runFramingham){
    exclude <- c(exclude, which(settings$model=='framinghamModel'))
  }
  if(!runChads2){
    exclude <- c(exclude, which(settings$model=='chads2Model'))
  }
  if(!runChads2Vas){
    exclude <- c(exclude, which(settings$model=='chads2vasModel'))
  }
  if(!runQstroke){
    exclude <- c(exclude, which(settings$model=='qstrokeModel'))
  }

  settings <- settings[!(1:length(settings$model))%in%exclude,]

  if(nrow(settings)>0){
    for(i in 1:nrow(settings )){
      setting <- settings[i,]
      outLoc <- file.path(outputLocation, paste0('Analysis_',setting$analysisId))
      if(!dir.exists(outLoc)){
        dir.create(outLoc, recursive = T)
      }
      if(!file.exists(file.path(outLoc,'plpResult'))){
        writeLines(paste0('Running analysis ', setting$analysisId,'- ',setting$description))
        modelSetting <- list(connectionDetails, cdmDatabaseSchema,
                             oracleTempSchema = oracleTempSchema,
                             cohortDatabaseSchema = cohortDatabaseSchema,
                             outcomeDatabaseSchema = cohortDatabaseSchema,
                             cohortTable = cohortTable,
                             outcomeTable = cohortTable,
                             cohortId = setting$targetId,
                             outcomeId = setting$outcomeId,
                             removePriorOutcome=T,
                             riskWindowStart = setting$riskStartDay,
                             riskWindowEnd = setting$riskEndDay,
                             addExposureDaysToEnd = setting$addExposureToEnd,
                             requireTimeAtRisk = T,
                             minTimeAtRisk = 364,
                             includeAllOutcomes = T)

        result <- tryCatch(do.call(as.character(setting$model), modelSetting),
                           error = function(e){writeLines(paste0(e)); return(NULL)})
        if(!is.null(result)){
          PatientLevelPrediction::savePlpResult(result, file.path(outLoc,'plpResult'))
        }
      }}
  }

  if(summariseResults==T){
    summary <- c()
    folders <- list.dirs(path = outputLocation, recursive = F, full.names = T)
    folders <- folders[grep('Analysis_', folders)]
    for(loc in folders){
      if(dir.exists(file.path(loc,'plpResult'))){
        result <- PatientLevelPrediction::loadPlpResult(file.path(loc,'plpResult'))
        resSum <- as.data.frame(result$performanceEvaluation$evaluationStatistics)
        resSum <- resSum[resSum$Metric %in% c('populationSize','outcomeCount','AUC','AUC.auc','AUC.auc_lb95ci','AUC.auc_ub95ci'), c('Metric','Value')]
        resSum$Metric <- as.character(resSum$Metric)
        resSum$Metric[resSum$Metric=='AUC.auc'] <- 'AUC'
        resSum$analysisId <- strsplit(loc,'_')[[1]][2]
        summary <- rbind(summary, resSum)
      }
    }

    if(length(summary)!=0){
      summary <- reshape2::dcast(summary, analysisId ~ Metric, value.var = 'Value')
      summary <- merge(settings, summary, by='analysisId', all.x=T)
      write.csv(summary,file.path(outputLocation,'resultSummary.csv'))} else{
        writeLines('No results to summarize...')
      }
  }

  if(packageResults){
    packageResults(outputFolder = outputLocation,
                   dbName = databaseName,
                   minCellCount = N)
  }

}
