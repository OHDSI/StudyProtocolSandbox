#' @name make_group_by_kb
#' @description Create a knowledge base that relates medical events to an ANCESTOR CONCEPT using the Athena concept table.
#' @param kb3_path path to kb-xxx3.csv file that you want to use to group medical events by
#' @param concept Athena concept table. This table is vital for all functions in this package
#' @return data.frame with the following columns: CONCEPT_ID, CONCEPT_NAME, ANCESTOR_CONCEPT_ID, ANCESTOR_CONCEPT_NAME, VOCABULARY_ID,
#' CONCEPT_CLASS_ID, CONCEPT_CODE
#' @export

make_group_by_kb <- function(kb3_path, concept)
{
  colnames(concept) %<>% toupper()
  kb3 <- readr::read_csv(kb3_path)
  kb3a <-kb3 %>% dplyr::left_join(dplyr::select(concept,CONCEPT_ID, CONCEPT_NAME, VOCABULARY_ID, CONCEPT_CODE), by= 'CONCEPT_ID')
  kb2 <- kb3a %>% dplyr::left_join(dplyr::select(concept, CONCEPT_ID, ANCESTOR_CONCEPT_NAME = CONCEPT_NAME, CONCEPT_CLASS_ID), by = c('ANCESTOR_CONCEPT_ID'= 'CONCEPT_ID'))
  kb2 %<>% dplyr::select(CONCEPT_ID, CONCEPT_NAME, ANCESTOR_CONCEPT_ID, ANCESTOR_CONCEPT_NAME, VOCABULARY_ID,
                         CONCEPT_CLASS_ID, CONCEPT_CODE)

  return(kb2)
}

#' @name make_and_save_kb
#' @description Create and save a knowledge base that relates medical events to an ANCESTOR CONCEPT using the Athena concept table.
#' @param kb3_path path to kb-xxx3.csv file that you want to use to group medical events by
#' @param concept Athena concept table. This table is vital for all functions in this package
#' @param out_folder folder to write this file
#' @export

make_and_save_kb <- function(kb3_path, concept, out_folder)
{
  len <- stringr::str_split(kb3_path, "/") %>% unlist() %>% length()
  fname <- stringr::str_split(kb3_path, "/")[[1]][len]

  ffile <- (stringr::str_split(fname, ".csv") %>% unlist())[1]

  if(ffile %>% endsWith('3'))
  {
    ffile2 <- (stringr::str_split(ffile, '3') %>% unlist())[1]
    ffile2 %<>% paste0('2.csv')
  } else
    ffile2 <- paste0(ffile, "_2.csv")

  kb2 <- make_group_by_kb(kb3_path, concept)

  readr::write_csv(kb2, file.path(out_folder, ffile2))
  return(file.path(out_folder, ffile2))
}

kb3_path <- 'C:/Users/sumathipalaya/Desktop/kb-drug_era3.csv'

