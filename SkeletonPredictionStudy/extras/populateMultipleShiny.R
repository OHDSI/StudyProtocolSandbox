# code to do shiny combining results
populateMultipleShinyApp <- function(shinyDirectory,
                             resultDirectory,
                             minCellCount = 10,
                             databaseName = 'sharable name of development data'){

  #check inputs
  if(missing(shinyDirectory)){
    shinyDirectory <- system.file("shiny", "PLPViewer", package = "SkeletonPredictionStudy")
  }
  if(missing(resultDirectory)){
    stop('Need to enter the resultDirectory')
  }


    for(i in 1:length(resultDirectory)){
      if(!dir.exists(resultDirectory[i])){
        stop(paste('resultDirectory ',i,' does not exist'))
      }
    }

  outputDirectory <- file.path(shinyDirectory,'data')

  # create the shiny data folder
  if(!dir.exists(outputDirectory)){
    dir.create(outputDirectory, recursive = T)
  }


  # need to edit settings ...
  files <- c()
  for(i in 1:length(resultDirectory)){
  # copy the settings csv
  file <- utils::read.csv(file.path(resultDirectory[i],'settings.csv'))
  file$analysisId <- 1000*as.double(file$analysisId)+i
  files <- rbind(files, file)
  }
  utils::write.csv(files, file.path(outputDirectory,'settings.csv'), row.names = F)

  for(i in 1:length(resultDirectory)){
  # copy each analysis as a rds file and copy the log
  files <- dir(resultDirectory[i], full.names = F)
  files <- files[grep('Analysis', files)]
  for(file in files){

    if(!dir.exists(file.path(outputDirectory,paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)))){
      dir.create(file.path(outputDirectory,paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)))
    }

    if(dir.exists(file.path(resultDirectory[i],file, 'plpResult'))){
      res <- PatientLevelPrediction::loadPlpResult(file.path(resultDirectory[i],file, 'plpResult'))
      res <- PatientLevelPrediction::transportPlp(res, n= minCellCount,
                                                  save = F, dataName = databaseName[i])

      res$covariateSummary <- res$covariateSummary[res$covariateSummary$covariateValue!=0,]
      covSet <- res$model$metaData$call$covariateSettings
      res$model$metaData <- NULL
      res$model$metaData$call$covariateSettings <- covSet
      res$model$predict <- NULL
      if(!is.null(res$performanceEvaluation$evaluationStatistics)){
      res$performanceEvaluation$evaluationStatistics[,1] <- paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)
      } else{
        writeLines(paste0(resultDirectory[i],file, '-ev'))
      }
      if(!is.null(res$performanceEvaluation$thresholdSummary)){
      res$performanceEvaluation$thresholdSummary[,1] <- paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)
      }else{
        writeLines(paste0(resultDirectory[i],file, '-thres'))
      }
      if(!is.null(res$performanceEvaluation$demographicSummary)){
      res$performanceEvaluation$demographicSummary[,1] <- paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)
      } else{
        writeLines(paste0(resultDirectory[i],file, '-dem'))
      }
      if(!is.null(res$performanceEvaluation$calibrationSummary)){
      res$performanceEvaluation$calibrationSummary[,1] <- paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)
      }else{
        writeLines(paste0(resultDirectory[i],file, '-cal'))
      }
      if(!is.null(res$performanceEvaluation$predictionDistribution)){
      res$performanceEvaluation$predictionDistribution[,1] <- paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i)
      }else{
        writeLines(paste0(resultDirectory[i],file, '-dist'))
      }
      saveRDS(res, file.path(outputDirectory,paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i), 'plpResult.rds'))
    }
    if(file.exists(file.path(resultDirectory[i],file, 'plpLog.txt'))){
      file.copy(from = file.path(resultDirectory[i],file, 'plpLog.txt'),
                to = file.path(outputDirectory,paste0('Analysis_',1000*as.double(gsub('Analysis_','',file))+i), 'plpLog.txt'))
    }
  }
  }



  for(i in 1:length(resultDirectory)){
  # copy any validation results
  if(dir.exists(file.path(resultDirectory[i],'Validation'))){
    valFolders <-  dir(file.path(resultDirectory[i],'Validation'), full.names = F)

    if(length(valFolders)>0){
      # move each of the validation rds
      for(valFolder in valFolders){

        # get the analysisIds
        valSubfolders <- dir(file.path(resultDirectory[i],'Validation',valFolder), full.names = F)
        if(length(valSubfolders)!=0){
          for(valSubfolder in valSubfolders ){
            valSubfolderUpdate <- paste0('Analysis_', as.double(gsub('Analysis_','', valSubfolder))*1000+i)
            valOut <- file.path(valFolder,valSubfolderUpdate)
            valOutOld <- file.path(valFolder,valSubfolder)
            if(!dir.exists(file.path(outputDirectory,'Validation',valOut))){
              dir.create(file.path(outputDirectory,'Validation',valOut), recursive = T)
            }


            if(file.exists(file.path(resultDirectory[i],'Validation',valOutOld, 'validationResult.rds'))){
              res <- readRDS(file.path(resultDirectory[i],'Validation',valOutOld, 'validationResult.rds'))
              res <- PatientLevelPrediction::transportPlp(res, n= minCellCount,
                                                          save = F, dataName = databaseName[i])
              res$covariateSummary <- res$covariateSummary[res$covariateSummary$covariateValue!=0,]
              saveRDS(res, file.path(outputDirectory,'Validation',valOut, 'validationResult.rds'))
            }
          }
        }

      }

    }

  }
  }

  return(outputDirectory)

}

# example to run to combine results of 4 different databases into omne shiny app:
populateMultipleShinyApp(shinyDirectory ='C:/myStudy/ShinyApp',
                                     resultDirectory = c('C:/myStudy/database1',
                                                         'C:/myStudy/database2',
                                                         'C:/myStudy/database3',
                                                         'C:/myStudy/sdatabase4'),
                                     minCellCount = 0,
                                     databaseName = c('name for database1','database 2 name','database3','database 4'))
