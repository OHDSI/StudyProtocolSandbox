###BUILD VAE######
library(keras)

##Extract imagePath for building the model first

# connection<-DatabaseConnector::connect(connectionDetails)
# sql <- "SELECT im.image_filepath
# FROM @cdm_database_schema.Radiology_Image im
# JOIN @cdm_database_schema.Radiology_Occurrence oc
# ON im.radiology_occurrence_id = oc.radiology_occurrence_id
# WHERE radiology_phase_concept = '@radiology_phase_concept'
# {@cohort_id != -1} ? {AND im.person_id not in (SELECT subject_id from @cohort_table where cohort_definition_id = @exclude_cohort_id)}
# AND Image_type = '@image_type'
# AND phase_total_no >= @min_resolution_depth
# AND image_resolution_rows >= @min_resolution_width
# AND image_resolution_columns >= @min_resolution_hight
# AND oc.radiology_phase_concept_id =@radiology_phase_concept_id
# ;"
# sql <- SqlRender::renderSql(sql,
#                             cdm_database_schema = cdmDatabaseSchema,
#                             cohort_table = cohortTable,
#                             radiology_phase_concept_id = 0,
#                             radiology_phase_concept  = "Pre contrast",
#                             image_type = "PRIMARY",
#                             min_resolution_depth = 10,
#                             min_resolution_width = 256,
#                             min_resolution_hight = 256,
#                             exclude_cohort_id = -1)$sql
# sql <- SqlRender::translateSql(sql,
#                                targetDialect=connectionDetails$dbms)$sql
# imagePaths<-DatabaseConnector::querySql(connection, sql)

buildRadiologyVae<-function(dataPaths=imagePaths, vaeValidationSplit= 0.2, vaeBatchSize = 100L,
                            vaeLatentDim = 30L, vaeIntermediateDim = 2048L,
                            vaeEpoch = 500L, vaeEpislonStd = 1.0, dimensionOfTarget = 2,
                            dataFolder = "/Users/chan/data",
                            originalDimension=c(64,64),
                            ROI2D=list(c(3:62),c(3:62)),
                            MaxLimitUnit = 1500,
                            samplingGenerator=FALSE){
        if (dimensionOfTarget!=2) stop ("Currently only dimesion of Target =2 is avaiablbe")
        originalDim<-length(ROI2D[[1]])*length(ROI2D[[2]])
        K <- keras::backend()
        x <- keras::layer_input (shape =originalDim)
        h <- keras::layer_dense (x, vaeIntermediateDim, activation = 'relu')
        z_mean <- keras::layer_dense(h, vaeLatentDim)
        z_log_var <- keras::layer_dense(h, vaeLatentDim)

        sampling<- function(arg){
                z_mean <- arg[,1:vaeLatentDim]
                z_log_var <- arg[, (vaeLatentDim+1):(2*vaeLatentDim)]

                epsilon <- keras::k_random_normal(
                        shape = c(keras::k_shape(z_mean)[[1]]),
                        mean = 0.,
                        stddev = vaeEpislonStd
                )

                z_mean + keras::k_exp(z_log_var/2)*epsilon
        }

        z <- keras::layer_concatenate(list(z_mean, z_log_var)) %>%
                keras::layer_lambda(sampling)

        #we instantiate these layers separately so as to reuse them later
        decoder_h <- keras::layer_dense(units = vaeIntermediateDim, activation = 'relu')
        decoder_mean <- keras::layer_dense (units = originalDim, activation = 'sigmoid')
        h_decoded <- decoder_h (z)
        x_decoded_mean <- decoder_mean(h_decoded)

        #end-to-end autoencoder
        vae <- keras::keras_model (x,x_decoded_mean)
        #encoder, from inputs to latent space
        encoder <- keras::keras_model(x, z_mean)

        #generator, from latent space to reconstruted inputs
        decoder_input <- keras::layer_input (shape = vaeLatentDim)
        h_decoded_2 <- decoder_h(decoder_input)
        x_decoded_mean_2 <- decoder_mean(h_decoded_2)
        generator <- keras::keras_model (decoder_input, x_decoded_mean_2)

        vae_loss <- function(x, x_decoded_mean){
                xent_loss <- (originalDim/1.0)* keras::loss_binary_crossentropy(x, x_decoded_mean)
                k1_loss <- -0.5 * keras::k_mean(1 + z_log_var - keras::k_square(z_mean) - keras::k_exp(z_log_var), axis = -1L)
                xent_loss + k1_loss
        }
        #if (!is.null(dataValidation)) dataValidation<-list(dataValidation,dataValidation)
        vaeEarlyStopping=keras::callback_early_stopping(monitor = "val_loss", patience=10,mode="auto",min_delta = 1e-1)
        vae %>% keras::compile (optimizer = "rmsprop", loss = vae_loss)

        #Paths for data
        actualPaths<-apply(imagePaths,1,function(x) file.path(dataFolder, x))

        if(samplingGenerator){
                #validation data
                valIndex<-sample(seq(actualPaths),length(actualPaths)*vaeValidationSplit )
                valImages<-lapply(as.array(actualPaths[valIndex]),function(x){
                        try(
                                {x<-oro.dicom::dicom2nifti(oro.dicom::readDICOM(x, verbose = FALSE))
                                x<-EBImage::resize(x,w=originalDimension[1],h=originalDimension[2] )[ROI2D[[1]],ROI2D[[2]] ]
                                },
                                silent = T
                        )
                })
                valImages<-array(unlist(valImages), dim=c(originalDimension,length(valImages)))
                valImages <-valImages %>% apply(3, as.numeric) %>% t()
                ##Regularization the data with the max##
                #imageMaxUnit<-valImages[which.max(valImages)]
                valImages<-valImages/MaxLimitUnit

                sampling_generator<-function(dataPath, batchSize,MaxLimitUnit){
                        function(){
                                #gc()
                                index<-sample(length(dataPath), batchSize, replace=FALSE)
                                data.mat<-as.array(dataPath[index])
                                images<-lapply(data.mat,function(x) {
                                        try(
                                                {x<-oro.dicom::dicom2nifti(oro.dicom::readDICOM(x, verbose = FALSE))
                                                x<-EBImage::resize(x,w=originalDimension[1],h=originalDimension[2] ) [ROI2D[[1]],ROI2D[[2]] ]
                                                },silent =T
                                        )
                                })
                                images<-array(unlist(images), dim=c(ROI2D[[1]],ROI2D[[2]],length(images)))
                                images <- images %>% apply(3, as.numeric) %>% t()
                                images<-images/MaxLimitUnit
                                list(images,images)
                        }
                }

                vae %>% keras::fit_generator (
                        sampling_generator(actualPaths[-valIndex],vaeBatchSize,MaxLimitUnit),
                        steps_per_epoch=length(actualPaths[-valIndex])/vaeBatchSize
                        ,epochs = vaeEpoch
                        ,validation_data = list(valImages,valImages)
                        ,callbacks = list(vaeEarlyStopping)
                )
        }else{
                data.mat<-as.array(actualPaths)
                images<-lapply(data.mat,function(x) {
                        try(
                                {x<-oro.dicom::dicom2nifti(oro.dicom::readDICOM(x, verbose = FALSE))
                                x<-EBImage::resize(x,w=originalDimension[1],h=originalDimension[2] ) [ROI2D[[1]],ROI2D[[2]] ]
                                },silent =T
                        )
                })
                images<-array(unlist(images), dim=c(length(ROI2D[[1]]),length(ROI2D[[2]]),length(images)))
                images <- images %>% apply(3, as.numeric) %>% t()

                #saveRDS(images,file.path(dataFolder,"image64.rds"))
                #images<-readRDS(file.path(dataFolder,"image.rds"))
                #imageMaxUnit<-images[which.max(images)]
                #images<-images*imageMaxUnit
                images[is.na(images)]<-0
                images<-ifelse(images>MaxLimitUnit,0,images)
                images<-images/MaxLimitUnit

                vae %>% fit(
                        images, images,
                        shuffle = TRUE,
                        epochs = 500,#vaeEpoch,
                        batch_size = vaeBatchSize,
                        validation_split =vaeValidationSplit,
                        callbacks = list(vaeEarlyStopping)
                )
        }

        return (list (vae=vae,encoder=encoder,MaxLimitUnit=MaxLimitUnit,vaeBatchSize=vaeBatchSize,vaeLatentDim=vaeLatentDim))
}
VAE<-buildRadiologyVae()

#saveRDS(prebuiltEncoder,file.path(dataFolder,"prebuiltEncoder.rds"))

# sample<-images[1:30,]
# imageMaxUnit=1500
# sample_image<-keras::array_reshape(sample, dim = c(30,length(ROI2D[[1]]),length(ROI2D[[2]])))
# sample_image<-sample_image*1500
# dim(sample_image)
#
# predicted<-predict(vae,sample,batch_size = 100)
# reshaped_image<-keras::array_reshape(predicted, dim = c(30,length(ROI2D[[1]]),length(ROI2D[[2]])))
# reshaped_image<-reshaped_image*imageMaxUnit
#
# papayar::papaya(oro.nifti::as.nifti(sample_image[20,,]))
# papayar::papaya(oro.nifti::as.nifti(reshaped_image[20,,]))
#
# papayar::papaya(oro.nifti::as.nifti(sample_image[2,,]))
# papayar::papaya(oro.nifti::as.nifti(reshaped_image[2,,]))

CreateRadiologyCovariateSettings<-function(useRadiology = TRUE,
                                           dataFolder = "/Users/chan/data",
                                           radiology_protocol_concept_id = 3002086,
                                           radiology_phase_concept="Pre Contrast",
                                           image_type="PRIMARY",
                                           prebuiltEncoder = NULL,
                                           MaxLimitUnit = 1500,
                                           vaeBatchSize = 100,
                                           vaeLatentDim = 30,
                                           encoderBatchSize = 100,
                                           minResolutionWidth = 64,
                                           minResolutionHight = 64,
                                           minResolutionDepth = 10,
                                           ROI2D = list(c(3:62),c(3:62)),
                                           samplingDepth = c(3,5,7),
                                           trainVae=FALSE
                                           ){
        covariateSettings<-list(useRadiology=useRadiology,
                                dataFolder=dataFolder,
                                radiology_protocol_concept_id = radiology_protocol_concept_id,
                                radiology_phase_concept = radiology_phase_concept,
                                image_type = image_type,
                                prebuiltEncoder = prebuiltEncoder,
                                MaxLimitUnit = MaxLimitUnit,
                                vaeLatentDim = vaeLatentDim,
                                encoderBatchSize = encoderBatchSize,
                                minResolutionWidth = minResolutionWidth,
                                minResolutionHight = minResolutionHight,
                                minResolutionDepth = minResolutionDepth,
                                ROI2D = ROI2D,
                                samplingDepth = samplingDepth,
                                trainVae= trainVae)
        attr(covariateSettings, "fun")<-"getDbRadiologyCovariateData"
        class(covariateSettings) <- "covariateSettings"
        return(covariateSettings)
}
getDbRadiologyCovariateData<-function(connection,
                                      oracleTempSchema = NULL,
                                      cdmDatabaseSchema,
                                      cohortTable = "#cohort_person",
                                      cohortId = 9090,
                                      cdmVersion = "5",
                                      rowIdField = "subject_id",
                                      covariateSettings,
                                      aggregated = FALSE) {
        writeLines("Constructing radiology covariates")
        if(covariateSettings$useRadiology == FALSE){
                return (NULL)
        }

        if (aggregated){
                stop("Aggregation not supported")
        }

        if (is.null(covariateSettings$prebuiltEncoder)){
                stop("Currently prebuiltEncoder should be prepared")
        }

        if(covariateSettings$trainVae) {
                stop("Currently VAE training is not supported inside the function")
        }
        encoder<-covariateSettings$prebuiltEncoder
        MaxLimitUnit<-covariateSettings$MaxLimitUnit
        encoderBatchSize<-covariateSettings$encoderBatchSize
        vaeLatentDim<-covariateSettings$vaeLatentDim
        dataFolder<-covariateSettings$dataFolder
        samplingDepth<-covariateSettings$samplingDepth
        #fetch the paths of images
        #need to modify to include date criteria
        sql <- "SELECT @row_id_field as row_id, im.image_no, im.phase_total_no, image_filepath
        FROM @cohort_table c
        JOIN @cdm_database_schema.Radiology_Image im
        ON c.subject_id = im.person_id
        WHERE radiology_phase_concept = '@radiology_phase_concept'
          {@cohort_id != -1} ? {AND cohort_definition_id = @cohort_id}
          AND Image_type = '@image_type'
          AND phase_total_no >= @min_resolution_depth
          AND image_resolution_rows >= @min_resolution_width
          AND image_resolution_columns >= @min_resolution_hight
          AND radiology_occurrence_id in (SELECT radiology_occurrence_id FROM @cdm_database_schema.radiology_occurrence
                                          WHERE radiology_protocol_concept_id=@radiology_protocol_concept_id);"
        sql <- SqlRender::renderSql(sql,
                                    row_id_field = rowIdField,
                                    cdm_database_schema = cdmDatabaseSchema,
                                    cohort_table = cohortTable,
                                    radiology_protocol_concept_id = covariateSettings$radiology_protocol_concept_id,
                                    radiology_phase_concept  = covariateSettings$radiology_phase_concept,
                                    image_type = covariateSettings$image_type,
                                    min_resolution_depth = covariateSettings$minResolutionDepth,
                                    min_resolution_width = covariateSettings$minResolutionWidth,
                                    min_resolution_hight = covariateSettings$minResolutionHight,
                                    cohort_id = cohortId)$sql
        sql <- SqlRender::translateSql(sql,
                                       targetDialect=connectionDetails$dbms)$sql
        covariatePath<-DatabaseConnector::querySql(connection, sql)
        colnames(covariatePath)<-SqlRender::snakeCaseToCamelCase(colnames(covariatePath))

        #subset images from the sampling Depth
        phaseIndDf<-data.frame()
        for (totalNo in unique(covariatePath$phaseTotalNo)){
                phaseInd<-round(seq(from = totalNo / covariateSettings$minResolutionDepth, to = totalNo, by = totalNo / covariateSettings$minResolutionDepth )[covariateSettings$samplingDepth],0)
                df<-data.frame(phaseTotalNo=totalNo,imageNo=phaseInd )
                phaseIndDf<-rbind(phaseIndDf,df)
        }
        imagePaths<-merge(covariatePath,phaseIndDf, by=c("phaseTotalNo","imageNo"), all.x = FALSE, all.y= FALSE )
        #add the root path
        actualPaths<-aggregate(imagePaths$imageFilepath,by = list(imagePaths$rowId), function(x){paste0(file.path(dataFolder,x),collapse=";")})
        colnames(actualPaths)<-c("rowId","imagePaths")
        #Load the radiology data
        images<-lapply(actualPaths$imagePaths,function(x) {
                try(
                        {x<-strsplit(x,";")
                        x<-oro.dicom::dicom2nifti(oro.dicom::readDICOM(x[[1]], verbose = FALSE))
                        if(length(dim(x))==2){x<-EBImage::resize(x,w=covariateSettings$minResolutionWidth,h=covariateSettings$minResolutionHight) [covariateSettings$ROI2D[[1]],covariateSettings$ROI2D[[2]]]
                        }
                        if(length(dim(x))==3){x<-EBImage::resize(x,w=covariateSettings$minResolutionWidth,h=covariateSettings$minResolutionHight) [covariateSettings$ROI2D[[1]],covariateSettings$ROI2D[[2]], ]
                        }
                        },silent =T
                )
        })
        print("half done")

        images<-lapply(images, function(x){
                #resize the data width x height->one dimension
                x[is.na(x)]<-0
                x<-apply(x, 3, as.numeric)

                x<-ifelse(x>MaxLimitUnit,0,x)
                x<-x/MaxLimitUnit
                x<-aperm(x,c(2,1)) #x<-aperm(x,c(2,1))
                x<-predict(encoder,x,batch_size = encoderBatchSize)
                #y<-predict(vae,x,batch_size = encoderBatchSize)
        })
        images<-array(unlist(images), dim=c(vaeLatentDim*length(covariateSettings$samplingDepth), length(images)))
        images<-data.frame(aperm(images,c(2,1)))
        #make covariate IDs
        covariateIds= as.numeric(paste0(88888,rep(samplingDepth,vaeLatentDim),rep(seq(vaeLatentDim),each=length(samplingDepth) )))
        #covariateIds= as.numeric(paste0(88888,rep(samplingDepth,each=latentDim)))
        colnames(images)=covariateIds

        #make row Id
        images$rowId<-actualPaths$rowId
        covariates<-reshape2::melt(images,id.var = "rowId",
                                   variable.name="covariateId",
                                   value.name = "covariateValue")
        covariates$covariateId<-as.numeric(as.character(covariates$covariateId))
        covariates<-ff::as.ffdf(covariates)



        covariateRef<-data.frame(covariateId = covariateIds,
                                 covariateName = paste("Rad",paste0(rep(samplingDepth,vaeLatentDim),"th slice",rep(seq(vaeLatentDim),each=length(samplingDepth) )) ),
                                 analysisId = 88888,
                                 conceptId = 0
                                 )
        covariateRef = ff::as.ffdf(covariateRef)
        analysisRef <- data.frame(analysisId = 88888,
                                  analysisName = "Radiology Features",
                                  domainId = "Radiology",
                                  startDay = 0,
                                  endDay = 0,
                                  isBinary = "N",
                                  missingMeansZero = "Y")
        analysisRef<-ff::as.ffdf(analysisRef)

        #Contruct analysis reference:
        meataData <- list(sql = sql, call = match.call())
        result <- list(covariates = covariates,
                       covariateRef = covariateRef,
                       analysisRef = analysisRef,
                       meataData = meataData)
        class(result) = "covariateData"
        return(result)
}
