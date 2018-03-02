#' @description This function will analyze all analysis_ids for all schemas you ask of it.
#' Two folders will be created in a (preferably empty) user-specified folder: data and results.
#'
#' @param
#'
#' @export
OHDSITrends <- function(connectionDetails,resultsDatabaseSchema, result_event_ids = c(904, 704, 1804, 604, 404),
                        user_folder='c:/temp/',
                        OMOP = TRUE, concept_file = NULL, dates, skip_plot_generation = FALSE,Share_Data = FALSE)
  #other params)
{
  pop_id = 116
  # If we don't give sites an ID number, then one will be randomly chosen.
  site_id <- sample(1:1e6, 1)

  dataExportFolder <- paste0(user_folder, 'Extracted Data/')
  resultsFolder <- paste0(user_folder, 'Results/')
  exportFolder <- paste0(user_folder, 'export/')
  kbFolder <- paste0(user_folder, 'kb/')
  #print(resultsDatabaseSchema)

   #make dirs
  for(dr in c(user_folder, dataExportFolder, resultsFolder, exportFolder, kbFolder))
    if(!dir.exists(dr)) dir.create(dr)

  # Write export and result readme files
  file.copy(from = system.file("export.txt", package = "OHDSITrends"),
            to = paste0(exportFolder, 'export.txt'))
  file.copy(from = system.file("Results.txt", package = "OHDSITrends"),
            to = paste0(resultsFolder, 'Results.txt'))

  # Business part
  medical_event_ids <- c(result_event_ids, pop_id)
  getData2(connectionDetails,resultsDatabaseSchema, dataExportFolder, medical_event_ids)

  analyze_all(site_id, all_ids = result_event_ids, pop_id = pop_id, resultsDatabaseSchema, dataExportFolder,
          resultsFolder, exportFolder, kbFolder, write_full_cids = TRUE, OMOP = TRUE, concept_file, Share_Data, dates,skip_plot_generation = skip_plot_generation)
  cat('-----------EXECUTION FINISHED----------------- \n any warning below this line can safely be ignored.\n')
}

#' @description This function will analyze all analysis_ids for all schemas you ask of it.
#' Two folders will be created in a (preferably empty) user-specified folder: data and results.
#'
#' @param pop_file_path Path to .csv file with population data; SHOULD NOT BE JOINED TO CONCEPTS!
#' @param event_file_path Path to .csv file with event data; SHOULD NOT BE JOINED TO CONCEPTS!
#' @param concept_file Path to .csv file for concepts to join to event and pop.
#' MUST have standardized columnames (see readme)
#'
#' @param db_schema name of database's schema, to keep things organized
#' @export
# Fix this one, which takes file inputs, first. This will call the new Step2 function that only
# takes file inputs.
# For now, pass in analysis_id so that step_4 works. After confirming, modidy step_4 so this is not needed
# (see comment in Analyze all trends.R)

OHDSITrends2 <- function(pop_file_path, event_file_path, concept_file = NULL, analysis_id, db_schema,
                         user_folder,  dates, write_full_cids = T, OMOP = F, Share_Data = F)
{
  # Assign  site_id randomly; used to anonymize dbs
  site_id <- sample(1:1e6, 1)

  pop <- readr::read_csv(pop_file_path)
  event <- readr::read_csv(event_file_path)

  # Initialize sub-folders in user_dir
  resultsFolder <- paste0(user_folder, 'Results/')
  exportFolder <- paste0(user_folder, 'export/')
  kbFolder <- paste0(user_folder, 'kb/')

  # Make sub directories
  for(dr in c(user_folder, resultsFolder, exportFolder, kbFolder))
    if(!dir.exists(dr)) dir.create(dr)

  # Write export and result readme files
  file.copy(from = system.file("export.txt", package = "OHDSITrends"),
            to = paste0(exportFolder, 'export.txt'))
  file.copy(from = system.file("Results.txt", package = "OHDSITrends"),
            to = paste0(resultsFolder, 'Results.txt'))

  print("Getting results")
  l <- analyze_one(pop, event, analysis_id, db_schema, resultsFolder,
              write_full_cids, OMOP, concept_file, dates)


  print("Exporting results")
  anonym_db <- anonymize_db_schema(site_id, 1)

  #reduce l$evemtM2 to not have exclude rows
  #antijoin with exclude

  l$eventM2 %<>% dplyr::filter(population_count >= 10000)

  exportResults(l$eventM2, l$full_cids, l$rollup1.0, l$rollup2.0, anonym_db, analysis_id,
                kbFolder, exportFolder, Share_Data = F, concept_file)
}




#step1 get the data
#step2 pre processing
#step 3_2 lin filter application


#analazy all file
 #analaze_one  does one event
 #trend call the above
