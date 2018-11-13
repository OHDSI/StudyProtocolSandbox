#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param covariate_id
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' Preprocessing_KOR()
Preprocessing_KOR <- function(covariate_id){

    covariate_id <- gsub('<[^<>]*>',' ',covariate_id) #Remove Tag
    #Remove html special characters
    covariate_id <- gsub('&#x0D;', " ", covariate_id)
    covariate_id <- gsub('&lt;', " ", covariate_id)
    covariate_id <- gsub('&gt;', " ", covariate_id)
    covariate_id <- gsub('&amp;', " ", covariate_id)
    covariate_id <- gsub('&quot;', " ", covariate_id)

    #remove hangle typo
    covariate_id <- gsub('[ㅏ-ㅣ]*','',covariate_id)
    covariate_id <- gsub('[ㄱ-ㅎ]*','',covariate_id)

    #Only Korean and English are left. (remove special characters)
    covariate_id <- gsub('[^가-힣a-zA-Z]',' ',covariate_id)

    #The spacing is only once
    covariate_id <- stringr::str_replace_all(covariate_id,"[[:space:]]{1,}"," ")

    #str to vec
    covariate_id <- strsplit(covariate_id,' ')

    #Unique value. (Frequency is not taken into account.)
    covariate_id <- unique.default(sapply(covariate_id, unique))

    return(covariate_id)
}
