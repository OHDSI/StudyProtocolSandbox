#' Custom createCoveriate Settings
#'
#' This function is Custom createCoveriate Settings.
#' @param doc.df
#' @keywordsa createCovariateSetting
#' @export
#' @examples
#' ExtractorFromDictionary()
ExtractorFromDictionary  <- function(doc.df){

    dictionary <- diction()
    colnames(dictionary) <- c('word')

    total_word <- unique(unlist(lapply(doc.df$word,FUN = find_word_num)))
    
    word_df <- data.frame('word' = c(total_word),stringsAsFactors = FALSE)
    
    #(1)Find the intersection of whole word and dictionary word
    merge_word <- as.vector(merge(word_df,dictionary,by.x = 'word')[,1])
    
    #2)Find the words that contain the word and the intersection of the dictionary and the word
    word_storage <- c()
    word_tmp_storage <- c()
    for(i in 1:length(merge_word)){
        
        word_tmp_storage <- c(word_tmp_storage,total_word[grep(merge_word[i],total_word)])
        if(i %% 10 == 0){
            word_storage <- c(word_storage,word_tmp_storage)
            word_tmp_storage <- c()
        }
    }

    #Find the intersection with a diagnosis (2), and combine the English words.
    diag_word_tmp_df <- data.frame(stringsAsFactors = F)
    diag_word_df <- data.frame(stringsAsFactors = F)
    for(i in 1:nrow(doc.df)){
        word <- strsplit(doc.df$'word'[i],' ')[[1]]
        
        eng_word <- gsub('[^a-zA-Z]','',word)
        eng_word[length(eng_word)+1] <- c("")
        only_eng <- eng_word[-which(eng_word == "")]
        only_eng <- unique(only_eng)
        
        
        diag_word <- c(intersect(word,word_storage),only_eng)
        
        diag_word_tmp_tmp_df <- data.frame('row_id' = rep(doc.df$row_id[i],length(diag_word)),'word' = diag_word,stringsAsFactors = F)
        
        
        diag_word_tmp_df <- rbind(diag_word_tmp_df,diag_word_tmp_tmp_df)
        if(i %% 100 == 0){
            diag_word_df <- rbind(diag_word_df,diag_word_tmp_df)
            diag_word_tmp_df <- data.frame(stringsAsFactors = F)
        }
    }
    diag_word_df <- rbind(diag_word_df,diag_word_tmp_df)
    
    return(diag_word_df)
}

