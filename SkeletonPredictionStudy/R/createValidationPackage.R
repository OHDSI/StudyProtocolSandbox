createValidationPackage <- function(modelFolder, 
                                    outputFolder,
                                    minCellCount = 5,
                                    databaseName = 'sharable name of development data',
                                    jsonSettings,
                                    analysisIds = NULL, 
                                    cohortVariableSetting = NULL){
  
  # json needs to contain the cohort details and packagename
  ensure_installed("Hydra")
  if(!is_installed("Hydra", version = '0.0.8')){
    warning('Hydra need to be updated to use custom cohort covariates')
  }
  Hydra::hydrate(specifications = jsonSettings, 
                 outputFolder=outputFolder)
  
  transportPlpModels(analysesDir = modelFolder,
                     minCellCount = minCellCount,
                     databaseName = databaseName,
                     outputDir = file.path(outputFolder,"inst/plp_models"),
                     analysisIds = analysisIds,
                     cohortVariableSetting = cohortVariableSetting)
  
  transportCohort(packageName = "SkeletonPredictionStudy",
                  outputDir = file.path(outputFolder,"inst"))
  
  return(TRUE)
  
}

transportPlpModels <- function(analysesDir,
                               minCellCount = 5,
                               databaseName = 'sharable name of development data',
                               outputDir = "./inst/plp_models",
                               analysisIds = NULL,
                               cohortVariableSetting){
  
  files <- dir(analysesDir, recursive = F, full.names = F)
  files <- files[grep('Analysis_', files)]
  
  if(!is.null(analysisIds)){
    #restricting to analysisIds
    files <- files[gsub('Analysis_','',files)%in%analysisIds]
  }
  
  filesIn <- file.path(analysesDir, files , 'plpResult')
  filesOut <- file.path(outputDir, files, 'plpResult')
  
  cohortCovs <- c()
  for(i in 1:length(filesIn)){
    if(file.exists(filesIn[i])){
      plpResult <- PatientLevelPrediction::loadPlpResult(filesIn[i])
      PatientLevelPrediction::transportPlp(plpResult,
                                           modelName= files[i], dataName=databaseName,
                                           outputFolder = filesOut[i],
                                           n=minCellCount,
                                           includeEvaluationStatistics=T,
                                           includeThresholdSummary=T, includeDemographicSummary=T,
                                           includeCalibrationSummary =T, includePredictionDistribution=T,
                                           includeCovariateSummary=T, save=T)
      
      tempCohortCovs <- plpResult$covariateSummary$covariateId[plpResult$covariateSummary$analysisId == 456 & plpResult$covariateSummary$covariateValue !=0]
      if(length(tempCohortCovs)!=0){
        cohortCovs <- c(cohortCovs, tempCohortCovs)
      }
    }
    
  }
  
  if(length(cohortCovs)>0 & !is.null(cohortVariableSetting)){
    # move the custom cohort covariates
    pathToCustom <- system.file("settings", cohortVariableSetting, package = "SkeletonPredictionStudy")
    cohortVarsToCreate <- utils::read.csv(pathToCustom)
    temp <- cohortVarsToCreate$cohortId*1000+456
    write.csv(cohortVarsToCreate[temp%in%cohortCovs,], 
              file.path(gsub('plp_models','settings', outputDir),'cohortVariableSetting.csv'), 
              row.names = F)
  }
  
}


transportCohort <- function(packageName = "SkeletonPredictionStudy",
                            outputDir = "./inst"){
  
  cohortLocation <- system.file("cohorts",package = packageName)
  cohortFiles <- dir(cohortLocation, recursive = F, full.names = F)
  if(!dir.exists(file.path(outputDir,'cohorts'))){dir.create(file.path(outputDir,'cohorts'), recursive = T)}
  file.copy(file.path(cohortLocation, cohortFiles), file.path(outputDir,'cohorts',cohortFiles), 
            overwrite = TRUE)
  sqlLocation <- system.file("sql","sql_server",package = packageName)
  sqlFiles <- dir(sqlLocation, recursive = F, full.names = F)
  if(!dir.exists(file.path(outputDir,'sql','sql_server'))){dir.create(file.path(outputDir,'sql','sql_server'), recursive = T)}
  file.copy(file.path(sqlLocation,sqlFiles), 
            file.path(outputDir,'sql','sql_server', sqlFiles), overwrite = TRUE )
  
  return(TRUE)
}



# Borrowed from devtools: https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L44
is_installed <- function (pkg, version = 0) {
  installed_version <- tryCatch(utils::packageVersion(pkg), 
                                error = function(e) NA)
  !is.na(installed_version) && installed_version >= version
}

# Borrowed and adapted from devtools: https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L74
ensure_installed <- function(pkg) {
  if (!is_installed(pkg)) {
    msg <- paste0(sQuote(pkg), " must be installed for this functionality.")
    if (interactive()) {
      message(msg, "\nWould you like to install it?")
      if (utils::menu(c("Yes", "No")) == 1) {
        if(pkg%in%c('Hydra')){
          devtools::install_github(paste0('OHDSI/',pkg))
        }else{
          utils::install.packages(pkg)
        }
      } else {
        stop(msg, call. = FALSE)
      }
    } else {
      stop(msg, call. = FALSE)
    }
  }
}
