#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param xmldf
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' Preprocessing_KOR()
Preprocessing_KOR <- function(xmldf){

    xmldf <- gsub('&#x0D;', " ", xmldf)
    xmldf <- gsub('&lt;', " ", xmldf)
    xmldf <- gsub('&gt;', " ", xmldf)
    xmldf <- gsub('&amp;', " ", xmldf)
    xmldf <- gsub('&quot;', " ", xmldf)

    xmldf <- gsub("[\\]","", xmldf)
    xmldf <- gsub("[\\+]|[\\{]|[\\}]|[\\(]|[\\)]|[\\<]|[\\>]"," ", xmldf)
    xmldf <- gsub("\\[","", xmldf)
    xmldf <- gsub("\\]","", xmldf)
    xmldf <- gsub("\\/","", xmldf)
    xmldf <- gsub("\\'"," ", xmldf)
    xmldf <- gsub('\\"'," ", xmldf)
    xmldf <- gsub("[~!@#$><%≥=^&×*-:●★¤]"," ", xmldf)

    xmldf <- gsub('“', " ", xmldf)
    xmldf <- gsub('”', " ", xmldf)
    xmldf <- gsub('‘', " ", xmldf)
    xmldf <- gsub('’', " ", xmldf)

    xmldf <-xmldf <- gsub(',', " ", xmldf)

    xmldf<- tolower(xmldf)

    xmldf <- gsub('[ㅏ-ㅣ]*','',xmldf)
    xmldf <- gsub('[ㄱ-ㅎ]*','',xmldf)

    #Spaces Hangul and English
    pos_start <- as.vector(gregexpr('[^가-힣 ]*[A-Za-z]+[^가-힣 ]*',xmldf)[[1]])
    pos_length <- as.vector(attr(gregexpr('[^가-힣 ]*[A-Za-z]+[^가-힣 ]*',xmldf)[[1]],'match.length'))
    pos_end <- pos_start+pos_length-1

    word_data <- c()
    if(length(pos_start) > 0){
        for(i in 1:length(pos_start)){
            word_data[i] <- substr(xmldf,pos_start[i],pos_end[i])
        }

        new_word_data <- paste("",toupper(word_data),"")

        for(i in 1:length(word_data)){
            xmldf <- sub(word_data[i],new_word_data[i],xmldf)
        }
    }
    xmldf<- tolower(xmldf)

    xmldf <- stringr::str_replace_all(xmldf,"[[:space:]]{1,}"," ")

    return(xmldf)
}
