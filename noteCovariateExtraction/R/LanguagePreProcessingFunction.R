#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param parsed_word_df
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' LanguagePreProcessingFunction()
LanguagePreProcessingFunction <- function(parsed_word_df){

    numCores <- parallel::detectCores() - 1

    myCluster <- parallel::makeCluster(numCores)

    #Need to FIX!! change it so that it can be set by the user.
    search_df <- parsed_word_df[parsed_word_df$`<MN>`=='현병력',]
    tag ='<TD>'
    
    xml_df <- search_df[tag]
    
    word_df <- data.frame('diagnosis' = parallel::parApply(myCluster,xml_df,1,Preprocessing_KOR),stringsAsFactors = F)
    doc.df <- data.frame('word' = word_df$diagnosis,'row_id' = search_df$L1,stringsAsFactors = F)

    parallel::stopCluster(myCluster)

    return(doc.df)

}
