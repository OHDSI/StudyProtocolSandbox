get.extFiles <- function(fnames, ext)
{
  return(fnames[endsWith(fnames, ext)])
}


#' Sep Exports
#' @description get the files that match the descriptor (e.g.3rd word in export
#' file naming convention)
#' @param descriptor Description value (case sensitive)
#' @param descriptor_index word position in export file name
#' @param delim deliminator in export file name (usually '_')
#' @export

sepExportFiles <- function(files, descriptor, descriptor_index = 3, delim = '_')
{
  sss <- strsplit(files, delim) %>% data.frame()
  colnames(sss) = 1:ncol(sss)
  cols <- which(sss[descriptor_index,] == descriptor)
  sss2 <- sss[,cols]
  x <- NULL
  for(i in 1:ncol(sss2))
    x %<>% append(sss2[[i]] %>% as.character() %>% paste(collapse = delim))
  return(x)
}

extractFromFileName <- function(file, index, delim = '_')
{
  sss <- strsplit(file, delim) %>% data.frame()
  colnames(sss) = 1:ncol(sss)
  return(sss[index,1] %>% as.character())
}

#' @description read all myfiles and return 1 df that rbinds them all together
#' @param myfiles filename with extension of csv files to read
#' @param folder folder where the files are (folder must have '/' character)
#' @export

read_and_rbind_csv_files <- function(myfiles, folder)
{
  out <- NULL
  path <- paste0(folder, myfiles)
  for(p in path) out %<>% rbind(readr::read_csv(p))
  return(out)
}

#' @description Reads all the files in each analysis_id sub folder inside the export folder. Then does the central processing
#' for this one folder, and writes its outputs in the specified outFolder.
#'
#' @export

analyzeOneFileType <- function(sub_folder, fType, outFolder)
{
  fnames  <- dir(sub_folder)
  files <- fnames[endsWith(fnames, "events.csv")]
  myfiles <- sepExportFiles(files, fType)
  df <- read_and_rbind_csv_files(myfiles, sub_folder)

  # at decile level
  df_all2 <- df %>% dplyr::group_by(stratum_1, decile) %>%
    dplyr::summarise(n = n(), quant_consistency = decile_classification2(score),
                     qual_consistency = qualitative_consistency(score, n)) %>%
    dplyr::filter(n > 1)

  # at event level
  df_all1 <- df %>% dplyr::group_by(stratum_1) %>%
    dplyr::summarise(n = n(), quant_consistency = decile_classification2(score),
                     qual_consistency = qualitative_consistency(score, n)) %>%
    dplyr::filter(n > 1)

  # to write filenames, I need the analysis_id and db_schema
  fname1 <- myfiles[1]
  analysis_id <- extractFromFileName(fname1, 1) %>% as.integer()
  db_schema <- extractFromFileName(fname1, 2)
  site_name <- substr(db_schema, 1, 3)

  out_fname1 <- paste(analysis_id, site_name, fType, ';events.csv', sep = '_')
  readr::write_csv(df_all1, path = paste0(outFolder, out_fname1))

  out_fname2 <- paste(analysis_id, site_name, fType, ';events_by_decile.csv', sep = '_')
  readr::write_csv(df_all2, path = paste0(outFolder, out_fname2))
}

#' @description This function does all the Central Processing of files
#'
#' @param exportFolder unzipped exportFolder. Check that file hierarchy is what we expect; if user ran OHDSITrends
#' function from the top, we should be good to go
#'
#' @param processingFolder Destination centralized Processing Folder (will be created if it doesn't exist yet)
#'
#' @export

Central_Processing <- function(exportFolder, processingFolder)
{
  if(!dir.exists(processingFolder)) dir.create(processingFolder)

  subs <- dir(exportFolder)
  subfolders <- paste0(exportFolder, subs, '/')

  for(i in 1:length(subfolders))
  {
    sub_folder <- subfolders[i]
    outFolder <- paste0(processingFolder, subs[i], '/')

    if(!dir.exists(outFolder)) dir.create(outFolder)

    analyzeOneFileType(sub_folder, 'Overall', outFolder)
    analyzeOneFileType(sub_folder, 'Top', outFolder)
  }
}
