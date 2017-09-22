#outside function call (probably analyze_all OR super.do)
#exportFolder <- paste0(user_folder, 'export/')
#db_schema = anonymize_db_schema(1, 1)

kbFolder <- 'C:/Users/sumathipalaya/Desktop/Package/OHDSITrends/inst/'

#' @param anaonym_db_schema anonymized db_schema; use anonymize_db_schema to get
#' @param event_type In step_4, this was the text-conversion of that OMOP analysis_id. Number might be better?
#' Either can work, just makes a computer reading-in the file_name a bit harder.
#' @export




exportResults <- function(eventM2, full_cids, rollup1.0, rollup2.0, db_schema, event_type,
                          kbFolder,dest_path, Share_Data = F, concept)
{
  # Print Rollups - these are laid out easy for human, not computer to read.
  full_cids$db_schema = db_schema

  # fname <- paste("Overall_interesting", db_schema, event_type, "events", sep = '_') %>% paste0('.tsv')
  # readr::write_tsv(rollup2.0, path = paste0(dest_path, fname))
  #
  # fname <- paste("Top_trending", db_schema, event_type, "events", sep = '_') %>% paste0('.tsv')
  # readr::write_tsv(rollup1.0, path = paste0(dest_path, fname))

  #----------------------------------------------------------------------------------------------

  if(Share_Data)
  {
    fname <- paste(event_type, db_schema, 'eventM2.csv', sep = '_')
    readr::write_csv(eventM2, paste0(dest_path,fname))
  }

  fname <- paste(event_type, db_schema, "full_cids.csv", sep = '_')
  readr::write_csv(full_cids, paste0(dest_path, fname))


  # Print analysis_friendly files (same information as rollup, but comes from full_cids)
  fname <- paste(event_type, db_schema, "Overall_interesting_events.csv", sep = '_')
  out_1 <- subset_big_by_small_ids(full_cids, rollup1.0)
  readr::write_csv(out_1, path = paste0(dest_path, fname))

  fname <- paste(event_type, db_schema, "Overall_interesting_data.csv")
  out_1.d <- subset_big_by_small_ids(eventM2, rollup1.0)
  readr::write_csv(out_1.d, path = paste0(dest_path, fname))

  fname <- paste(event_type, db_schema, "Top_trending_events.csv", sep = '_')
  out_2 <- subset_big_by_small_ids(full_cids, rollup2.0)
  readr::write_csv(out_2, path = paste0(dest_path, fname))

  fname <- paste(event_type, db_schema, "Overall_interesting_data.csv")
  out_2.d <- subset_big_by_small_ids(eventM2, rollup2.0)
  readr::write_csv(out_2.d, path = paste0(dest_path, fname))

  # Print graphs using out_1, out_2, and eventM2 (use these dfs to make pdf graphs)
  graph_df_1 <- subset_big_by_small_ids(eventM2, out_1)
  graph_df_2 <- subset_big_by_small_ids(eventM2, out_2)

  print('plotting export')
  plot_pdf(graph_df_1, out.pdf = paste0(dest_path, paste(event_type, db_schema, "Overall_interesting_events.pdf", sep = '_')))
  plot_pdf(graph_df_2, out.pdf = paste0(dest_path, paste(event_type, db_schema, "Top_trending_events.pdf", sep = '_')))


  # Group By
  if(event_type %in% c(904, 604))
  {
    if(event_type == 904)
    {
      # Edit this line; should just be /inst/kb-drug_era3.csv
      kb3_path <- paste0('inst/kb-drug_era3.csv')
      kb2.csv <- make_and_save_kb(kb3_path, concept, kbFolder)
      dg <- OHDSI_shiny_dg(kb2.csv, eventM2, event_type)
      analyze_grouped_events(full_cids, eventM2, dg, kb2.csv, event_type, db_schema, dest_path)
    }
  }

}
#' @description Print graphs of all the rollup items
#' @export
print_Rollup_Graphs <- function(event_type, db_schema, full_cids, rollup1.0, rollup2.0, dest_path, eventM2)
{
  # Print analysis_friendly files (same information as rollup, but comes from full_cids)
  fname <- paste(event_type, db_schema, "Overall_interesting_events.csv", sep = '_')
  out_1 <- subset_big_by_small_ids(full_cids, rollup1.0)
  readr::write_csv(out_1, path = paste0(dest_path, fname))

  fname <- paste(event_type, db_schema, "Top_trending_events.csv", sep = '_')
  out_2 <- subset_big_by_small_ids(full_cids, rollup2.0)
  readr::write_csv(out_2, path = paste0(dest_path, fname))

  # Print graphs using out_1, out_2, and eventM2 (use these dfs to make pdf graphs)
  graph_df_1 <- subset_big_by_small_ids(eventM2, out_1)
  graph_df_2 <- subset_big_by_small_ids(eventM2, out_2)

  print('plotting')
  plot_pdf(graph_df_1, out.pdf = paste0(dest_path, paste(event_type, db_schema, "Overall_interesting_events.pdf", sep = '_')))
  plot_pdf(graph_df_2, out.pdf = paste0(dest_path, paste(event_type, db_schema, "Top_trending_events.pdf", sep = '_')))
}

#' @param site_id This has to come from Super.Do; either we give the site_id to each site, OR it is randomly generated
#' by Super.Do
#'
#' @param i int; index from for loop; indicates which db_schema this is for the site (1, 2, 3, etc.)
#' @export

anonymize_db_schema <- function(site_id, i)
{
  set.seed(site_id); anonym <- paste0(c(sample(letters, 3, replace = T),i), collapse = '')
  return(anonym)
}

#' @name split_rollup_filename
#' @export
split_rollup_filename <- function(f, i = 1) {
  f <- "Overall_interesting_dbn1_904_events.tsv"
  stringr::str_split(f, "_")[[1]][i] %>% as.integer()
}

#' @export
subset_big_by_small_ids <- function(big, small)
{
  ids <- small$stratum_1 %>% unique()
  return(big %>% dplyr::filter(stratum_1 %in% ids))
}

#' @title plot events to pdf
#' @export

 plot_pdf <- function(data, out.pdf)
{
  pdf(out.pdf)
  head <- data %>% dplyr::select(stratum_1, concept_name) %>% unique()
  for(i in 1:length(head$stratum_1))
  {
    cid = head$stratum_1[i]
    concept_name = head$concept_name[i]
    tta <- dplyr::filter(data, stratum_1 == cid)
    plot_group_by_decile_by_concept_id(name = concept_name %>% tolower() %>% capitalize(),
                                       tta,
                                       sub = paste(cid, tta$concept_code[[1]], sep = " | "),
                                       y_lab = 'Prevalence per 1000')
  }
  dev.off()
}



