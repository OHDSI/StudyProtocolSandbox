#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param diag_list
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' diag_processing()
diag_processing <- function(diag_list){
    
    tag_vector  <- as.vector(regexpr('>',diag_list))
    text_vector <- as.vector(regexpr('</',diag_list))
    
    tag_data_vector <- substr(diag_list,1,tag_vector)
    text_data_vector <- substr(diag_list,tag_vector+1,text_vector-1)
    
    first_tag_vector <- as.vector(regexpr(tag_data_vector[1],tag_data_vector))
    
    data =c()
    for (i in 1:length(first_tag_vector)){
        if (first_tag_vector[i] == 1){
            data[i] <- i
        }
    }
    
    data <- data[!is.na(data)]
    
    data[length(data)+1] <- length(first_tag_vector)+1
    
    df <- data.frame(stringsAsFactors = FALSE)
    for (i in unique(tag_data_vector)){
        df[i] <- character(0)
    }
    
    cnt <- 1
    for (i in 1:(length(data)-1)){
        val <- (data[i+1])-(data[i])
        for (k in 1:val){
            df[i,tag_data_vector[cnt]] <- text_data_vector[cnt]
            cnt <- cnt+1
        }
    }
    
    return(df)
}
