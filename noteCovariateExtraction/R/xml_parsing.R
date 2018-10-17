#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param xmlList
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' xml_parsing()
xml_parsing <- function(xmlList){
    pattern_start <- as.vector(gregexpr('<[^/<>]+>[^<>]+<\\/[^<>]+>',xmlList)[[1]])
    pattern_length <- as.vector(attr(gregexpr('<[^/<>]+>[^<>]+<\\/[^<>]+>',xmlList)[[1]],'match.length'))
    pattern_end <- pattern_start+pattern_length-1
    
    xml_data = rep(NA,length(pattern_start))
    for(i in 1:length(pattern_start)){
        xml_data[i] <- substr(xmlList,pattern_start[i],pattern_end[i])
    }
    
    return(xml_data)
}
