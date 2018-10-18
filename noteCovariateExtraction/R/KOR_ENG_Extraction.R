#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param rawcovariate_id
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' EngWordExtraction()
EngWordExtraction <- function(rawcovariate_id){

    #Divide English and Hangul
    eng_word <- gsub('[^a-zA-Z]','',rawcovariate_id)
    eng_word[length(eng_word)+1] <- c("")
    only_eng <- eng_word[-which(eng_word == "")]
    only_eng <- unique(only_eng)

    han_eng <- setdiff(rawcovariate_id,only_eng)

    kor_word <- gsub('[^가-힣]','',han_eng)
    kor_word[length(kor_word)+1] <- c("")
    only_kor <- kor_word[-which(kor_word == "")]
    only_kor <- unique(only_kor)

    word_list <- list('ENG' = only_eng, 'KOR' = only_kor)

    return(word_list)
}
