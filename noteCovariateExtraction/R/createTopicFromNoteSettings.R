#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param useTopicFromNote use = TURE, not use = FALSE
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' createTopicFromNoteSettings()
createTopicFromNoteSettings <- function(useTopicFromNote = TRUE,
                                        noteConceptId = noteConceptId,
                                        useDictionary=TRUE,
                                        selectDictionary = c('KOR'),
                                        useTextToVec = FALSE,
                                        useTopicModeling=FALSE,
                                        numberOfTopics=10L,
                                        useGloVe = FALSE,
                                        LatentDimensionForGlove = 100L,
                                        useAutoencoder=FALSE,
                                        LatentDimensionForAutoEncoder = 100L,
                                        sampleSize=-1){
    if(sum(useDictionary) == 0){
        stop('Not implemented.')
    }
    else{
        if (sum (useTextToVec,useTopicModeling,useGloVe,useAutoencoder) != 1 ) {
            stop("Choose only one among useTextToVec,useTopicModeling,useGloVe,useAutoencoder")
        }
        else{
            covariateSettings <- list(useTopicFromNote = useTopicFromNote,
                                      noteConceptId = noteConceptId,
                                      useDictionary=useDictionary,
                                      selectDictionary=selectDictionary,
                                      useTextToVec=useTextToVec,
                                      useTopicModeling=useTopicModeling,
                                      numberOfTopics = numberOfTopics,
                                      useGloVe=useGloVe,
                                      useAutoencoder=useAutoencoder,
                                      sampleSize=sampleSize)
            attr(covariateSettings,'fun') <- 'getTopicFromNoteSettings'
            class(covariateSettings) <- 'covariateSettings'
            return(covariateSettings)
        }
    }
}



