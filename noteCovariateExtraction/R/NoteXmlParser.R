#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param rowid,covariatesvalue
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' NoteXmlParser()
NoteXmlParser <- function(rowid,covariatesid){
    #Create Cluster
    numCores <- parallel::detectCores() - 1
    myCluster <- parallel::makeCluster(numCores)

    #Only the last tag is left.
    diagnosis_list <- parallel::parLapply(cl = myCluster, X = covariatesid, fun = xml_parsing)

    #Construct a list by semantic area per diagnosis
    parsed_word_list <- parallel::parLapply(cl = myCluster, X = diagnosis_list, fun = diag_processing)
    names(parsed_word_list) <- rowid[1:length(rowid)]

    #To be based on the list with the most tags
    max_val <- 0
    for(i in 1:length(parsed_word_list)){
        tmp_val <- length(parsed_word_list[[i]])
        if(tmp_val > max_val){
            max_list_location <- i
            max_val = tmp_val
        }
    }
    #if TAG length difference, remove diagnosis
    for(i in length(parsed_word_list):1){
        if(length(parsed_word_list[[i]]) != max_val){
            # tag_name <- c(setdiff(names(parsed_word_list[[max_list_location]]),names(parsed_word_list[[i]])))
            # length(parsed_word_list[[i]][[1]])
            # tag_name
            parsed_word_list <- parsed_word_list[-i]
        }
    }

    #list to dataframe
    parsed_word_df <- reshape2::melt(data = parsed_word_list,names(parsed_word_list[[max_list_location]]))
    parsed_word_df$L1 <- as.numeric(parsed_word_df$L1)

    #Stop the cluster.
    parallel::stopCluster(myCluster)

    return(parsed_word_df)
}
