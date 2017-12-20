#' @name analyze_all
#' @description This function analyzes all items you pass into it.
#'
#' @export
analyze_all <- function(site_id, all_ids, pop_id, resultsDatabaseSchema, dataExportFolder, resultsFolder, exportFolder,
                        kbFolder, write_full_cids = T, OMOP, concept_file = NULL, Share_Data = F, dates)
{
  print(resultsDatabaseSchema)


  for(analysis_id in all_ids)
  {
    output_folder <- paste0(resultsFolder, paste(analysis_id, 'Results')) %>% paste0('/')
    if(!dir.exists(output_folder)) dir.create(output_folder)

    export_folder <- paste0(exportFolder, paste(analysis_id, 'Results')) %>% paste0('/')
    if(!dir.exists(export_folder)) dir.create(export_folder)

    for(i in 1:length(resultsDatabaseSchema))
    {
      db <- resultsDatabaseSchema[i]
      print(db)
      cat('doing:', analysis_id, db, '\n')
      data_folder <- paste0(dataExportFolder, db, '/')

      # Get data
      pop <- get_pop(data_folder, pop_id)
      event <- get_event(data_folder, analysis_id)

      l <- analyze_one(pop, event, analysis_id, db, output_folder, write_full_cids, OMOP, concept_file, dates = dates)
      anonym_db <- anonymize_db_schema(site_id, i)
      exportResults(l$eventM2, l$full_cids, l$rollup1.0, l$rollup2.0, anonym_db, analysis_id,
                    kbFolder, export_folder, Share_Data, concept_file)
    }
  }
}

# Put note below in OHDSITrends2 documenatation as well.
#' @description  This function will do full analysis for one medical event. It takes in pop and event as dataframes and
#' other parameters for house-keeping purposes.
#'
#' @note RENAME the "File Results" or at least the output files in that folder before running this commnad again.
#' as they will be overridden the next time this function is called.
#' @export
analyze_one <- function(pop, event, analysis_id, db_schema, resultsFolder,
                        write_full_cids = T, OMOP, concept_file, dates)
{
  # Load the OHDSIVocab concept table if that's the correct one but it hasn't been passed in.
  # Step2 will check other conditions and throw error.
  if(OMOP & is.null(concept_file))
  {
      print('STOP!!! LOAD CONCEPT FILE')
      break
  }

  #output_folder <- paste0(resultsFolder, 'File Results/')
  #if(!dir.exists(output_folder)) dir.create(output_folder)

  output_folder <- resultsFolder

  # Main Code Body.

  # 2 (event, pop, event_type=704, OMOP = FALSE, concept_file=NULL)
  eventM2 <- step_2(event, pop, analysis_id, OMOP, concept_file, dates = dates) # pt and pop count have NAs... remove
  eventM2 %<>% dplyr::mutate(pt_count = ifelse(is.na(pt_count), 0, pt_count),
                             population_count = ifelse(is.na(population_count), 0, population_count))

  fname <- paste(analysis_id, db_schema, 'processed_data.csv', sep = '_')
  readr::write_csv(eventM2, paste0(resultsFolder, fname))

  print("Step 2 done")

  # 3
  print("Applying lin filter")
  full_cids <- step_3.2(eventM2, output_folder, db_schema) %>% dplyr::ungroup()
    print("Step 3 done")

  if(write_full_cids)
  {
    print('writing full_cids')
    fname <- paste(analysis_id, db_schema, 'full_cids.csv', sep = '_')
    path <- paste0(output_folder, fname)
    full_cids$db_schema = db_schema
    readr::write_csv(full_cids, path)
    print('wrote full_cids file')
    full_cids$db_schema  <- NULL
  }

  # 4
  if(OMOP) event_type <- get_omop_event_name(analysis_id)
  else event_type <- 'unknown'
  l <- step_4(full_cids, dest_path = output_folder , event_type, db_schema)
  print(paste0("step 4 ------ done. new files in: ", output_folder))

  print_Rollup_Graphs(analysis_id, db_schema, full_cids, l$rollup1.0, l$rollup2.0, dest_path = output_folder, eventM2)
  l$eventM2 <- eventM2
  l$full_cids <- full_cids
  return(l)
}
