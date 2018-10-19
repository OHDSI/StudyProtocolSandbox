#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @connection connection,oracleTempSchema,cdmDatabaseSchema,cohortTable,cohortId,cdmVersion,rowIdField,covariateSettings,aggregated
#' @oracleTempSchema createCovariateSetting
#' @cdmDatabaseSchema
#' @cohortTable
#' @cohortId
#' @cdmVersion
#' @rowIdField
#' @noteConceptId
#' @covariateSettings
#' @aggregated
#' getTopicFromNoteSettings()
getTopicFromNoteSettings <- function(connection,
                                     oracleTempSchema = NULL,
                                     cdmDatabaseSchema,
                                     cohortTable = "cohort",
                                     cohortId = -1,
                                     cdmVersion = "5",
                                     rowIdField = "subject_id",
                                     #noteConceptId = noteConceptId,
                                     covariateSettings,
                                     aggregated = FALSE){

    writeLines('Constructing TopicFromNote')
    if (covariateSettings$useTopicFromNote == FALSE) {
        return(NULL)
    }
    if (covariateSettings$useDictionary == TRUE){
        #SQL query should be revised to extract only the latest record
        #SQL to construct the covariate:
        sql <- paste(
            'SELECT',
            '{@sampleSize != -1} ? {TOP @sampleSize}',
            " @row_id_field AS row_id,",
            'n.NOTE_TEXT AS covariate_id,',
            '1 AS covariate_value',
            'FROM @cdm_database_schema.NOTE n',
            'JOIN @cohort_table c',
            'ON n.person_id = c.subject_id',
            'AND n.NOTE_DATE = c.COHORT_START_DATE',
            'WHERE NOTE_TYPE_CONCEPT_ID = @note_concept_id',
            '{@cohort_id != -1} ? {AND cohort_definition_id = @cohort_id}'
            )

        sql <- SqlRender::renderSql(sql,
                                    cohort_table = cohortTable,
                                    cohort_id = cohortId,
                                    note_concept_id = covariateSettings$noteConceptId,
                                    row_id_field = rowIdField,
                                    sampleSize=covariateSettings$sampleSize,
                                    cdm_database_schema = cdmDatabaseSchema)$sql
        sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql

        # Retrieve the covariate:
        rawCovariates <- DatabaseConnector::querySql.ffdf(connection, sql)
        colnames(rawCovariates)<-tolower(colnames(rawCovariates))

        ########################

        #ff in list #because Characters can not be inserted into the ff package.
        rawcovariate_id <- ff::ffapply(x[i1:i2],X= rawCovariates$covariate_id, RETURN=TRUE, CFUN="list", AFUN = notePreprocessing)

        #Create a new dictionary by finding the intersection of all words and dictionaries, Limit: Not recognized if only compound words are found
        # The kor_dictionary_db is built-in.
        if('KOR' %in% covariateSettings$selectDictionary){
            dictionary_kor <- intersect(as.vector(kor_dictionary_db[,1]),unique(unlist(rawcovariate_id)))
        }
        if('ENG' %in% covariateSettings$selectDictionary){
            stop('ENG is not implement')
            #dictionary_eng <- intersect(as.vector(eng_dictionary_db[,1]),unique(unlist(rawcovariate_id)))
        }
        # if('Other' %in% covariateSettings$selectDictionary){
        #     dictionary_Other <- intersect(as.vector(Other_dictionary_db[,1]),unique(unlist(rawcovariate_id)))
        # }

        names(rawcovariate_id) <- 'word'
        #In the case of Hangul
        rawcovariate_id <- lapply(rawcovariate_id$'word', medicalTermExtraction)

        covariate_id <- list()
        #Compare dictionary with two language
        if(sum(covariateSettings$selectDictionary %in% covariateSettings$implementLanguage) == 2){

            ##Compared with Other and English dictionary
            # for(i in 1:length(rawcovariate_id)){
            #     covariate_id[[i]] <- c(intersect(rawcovariate_id[[i]]$Other,dictionary_Other),intersect(rawcovariate_id[[i]]$ENG,dictionary_eng))
            # }
        }

        #Compare dictionary with one language
        else{
            ##Compared with Other language EX)KOR
            #EX) KOR
            if(covariateSettings$selectDictionary == 'KOR'){
                for(i in 1:length(rawcovariate_id)){
                    covariate_id[[i]] <- c(intersect(rawcovariate_id[[i]]$KOR,dictionary_kor),rawcovariate_id[[i]]$ENG)
                }
            }
            else if (covariateSettings$selectDictionary == 'Other'){
                # for(i in 1:length(rawcovariate_id)){
                #     covariate_id[[i]] <- c(intersect(rawcovariate_id[[i]]$Other,dictionary_kor),rawcovariate_id[[i]]$ENG)
                # }
            }

            ##Compared with Only English
            else if(covariateSettings$selectDictionary == 'ENG'){
                # for(i in 1:length(rawcovariate_id)){
                #     covariate_id[[i]] <- c(intersect(rawcovariate_id[[i]]$ENG,dictionary_eng))
                # }
            }
        }

        #Configuring covariate
        names(covariate_id) <- rawCovariates$row_id[1:length(rawCovariates$row_id)]

        covariates <- reshape2::melt(data = covariate_id)
        colnames(covariates) <- c('covariateId','rowId')
        covariates$rowId <- as.numeric(covariates$rowId)
        covariateValue <- rep(1,nrow(covariates))

        covariates <- cbind(covariates,covariateValue)

        #####################################

        covariateId.factor<-as.factor(covariates$covariateId)

        #rowIds<-levels(as.factor(covariates$rowId))
        if(covariateSettings$useTextToVec == TRUE){
            ##Text2Vec
            covariates$covariateId<-as.numeric(paste0(9999,as.numeric(covariateId.factor)))
            covariates<-ff::as.ffdf(covariates)

            covariateRef  <- data.frame(covariateId = as.numeric(paste0(9999,seq(levels(covariateId.factor)) )),
                                        covariateName = paste0("NOTE-",levels(covariateId.factor)),
                                        analysisId = 0,
                                        conceptId = 0)
            covariateRef <- ff::as.ffdf(covariateRef)
        }

        if(covariateSettings$useTopicModeling == TRUE){
            covariates$covariateId<-as.numeric(as.factor(covariates$covariateId))

            data <- Matrix::sparseMatrix(i=covariates$rowId,
                                         j=covariates$covariateId,
                                         x=covariates$covariateValue, #add 0.1 to avoid to treated as binary values
                                         dims=c(max(covariates$rowId), max(covariates$covariateId))) # edit this to max(map$newIds)

            colnames(data) <- as.numeric(paste0(9999,seq(levels(covariateId.factor)) ))

            ##Topic Modeling
            lda_model = text2vec::LDA$new(n_topics = covariateSettings$numberOfTopics, doc_topic_prior = 0.1, topic_word_prior = 0.01)
            doc_topic_distr = lda_model$fit_transform(x = data, n_iter = 1000,
                                                        convergence_tol = 0.001, n_check_convergence = 25,
                                                        progressbar = FALSE)

            doc_topic_distr_df <- data.frame(doc_topic_distr)

            covariateIds<-as.numeric(paste0(9999,as.numeric(1:length(doc_topic_distr_df))))
            colnames(doc_topic_distr_df)<-covariateIds
            doc_topic_distr_df$rowId<- seq(max(covariates$rowId))

            covariates<-reshape2::melt(doc_topic_distr_df,id.var = "rowId",
                                               variable.name="covariateId",
                                               value.name = "covariateValue")
            covariates$covariateId<-as.numeric(as.character(covariates$covariateId))
            covariates<-covariates[covariates$covariateValue!=0,]
            covariates<-ff::as.ffdf(covariates)
            ##need to remove 0
            covariateRef  <- data.frame(covariateId = covariateIds,
                                        covariateName = paste0("Topic",covariateIds),
                                        analysisId = 0,
                                        conceptId = 0)
            covariateRef <- ff::as.ffdf(covariateRef)
        }

        if(covariateSettings$useGloVe == TRUE){
            stop("useGlove has not not supported yet")
        }

        if(covariateSettings$useAutoencoder == TRUE){
            stop("useAutoencoder has not not supported yet")
        }

        # Construct analysis reference:
        analysisRef <- data.frame(analysisId = 0,
                                  analysisName = "Features from Note",
                                  domainId = "Note",
                                  startDay = 0,
                                  endDay = 0,
                                  isBinary = "N",
                                  missingMeansZero = "Y")
        analysisRef <- ff::as.ffdf(analysisRef)
    }

    if (aggregated)
        stop("Aggregation not supported")

    # Construct analysis reference:
    metaData <- list(sql = sql, call = match.call())
    result <- list(covariates = covariates,
                   covariateRef = covariateRef,
                   analysisRef = analysisRef,
                   metaData = metaData)
    class(result) <- "covariateData"
    return(result)

}
