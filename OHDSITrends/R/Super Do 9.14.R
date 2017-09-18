#' @description This function will analyze all analysis_ids for all schemas you ask of it.
#' Two folders will be created in a (preferably empty) user-specified folder: data and results.
#'
#' @param
#'
#' @export
OHDSITrends <- function(site_id, connectionDetails,resultsDatabaseSchema, result_event_ids,
                        pop_id, user_folder, OMOP = F, concept_file = NULL)
  #other params)
{
  # If we don't give sites an ID number, then one will be randomly chosen.
  if(is.null(site_id)) site_id <- sample(1:100, 1)
    
  dataExportFolder <- paste0(user_folder, 'Extracted Data/')
  resultsFolder <- paste0(user_folder, 'Results/')
  exportFolder <- paste0(user_folder, 'export/')
  #make dirs

  for(dr in c(user_folder, dataExportFolder, resultsFolder, exportFolder))
    if(!dir.exists(dr)) dir.create(dr)
  medical_event_ids <- c(result_event_ids, pop_id)
  getData2(connectionDetails,resultsDatabaseSchema, dataExportFolder, medical_event_ids)

  analyze_all(all_ids = result_event_ids, pop_id = pop_id, resultsDatabaseSchema, dataExportFolder,
              resultsFolder = resultsFolder, exportFolder, write_full_cids = T, OMOP = T, concept_file)
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

OHDSITrends2 <- function(pop_file_path, event_file_path, concept_file = NULL, analysis_id, db_schema,  user_folder, OMOP = F)
{
  pop <- readr::read_csv(pop_file_path)
  event <- readr::read_csv(event_file_path)

  resultsFolder <- paste0(user_folder, 'Results/')
  for(dr in c(user_folder, resultsFolder))
    if(!dir.exists(dr)) dir.create(dr)
  analyze_one(pop, event, analysis_id, db_schema, resultsFolder, write_full_cids = F, OMOP = T, concept_file)
}





