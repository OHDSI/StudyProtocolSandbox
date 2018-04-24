# This file is in R Shiny App R Package.
# File in R Shiny App/package/OHDSI/R.

# VERIFIED FUNCTIONS
# load this file, and the ANALYZE TRENDS script will run as expected
# Generally this file is organized in reverse chronological order; newest functions at end

#' @warnings: THIS FILE IS DIRTY AND CONTAINS UNUSED FUNCTIONS
#' (e.g. find_data_quality_problems) remove such functions before submitting,
#' so that the package is clean. Also, there are commented lines of code, which is ugly


# If desired, use this function stack to build the relevant functions
# hat will allow construction of an R package with all the tools
# and functions we developed so that someone else can replicate
# our analysis. Just use roxygen2 style documentation

#****************
#GENERATE ROXYGEN DOCUMENTATION BY RUNNINING
# document() //This creates a 'man' folder in the R package with
# the .Rd R documentation files.

library(roxygen2)
# -----------------------------------------
#' @note This function filters age-stratified medical events by linear growth or decline over time
#' @param d data to filter
#' @param itemsA items that passed count_filter
#' @param alpha significance value for linear regression; default is 0.1
#' @param m minimum slope to filter by; default is 2/2000, or a change of about 2 people
#' per thousand per year
#'
#' @return
#' @return
#'
#' @export

lin_filter <- function(d, itemsA, alpha = 0.1, m = 2/2000)
{
  # Initializing
  e <-data.frame(); i=1
  temp <- data.frame()
  count2 = 0
  inc = 0
  dec = 0
  mis = 0
  inc_cids <- data.frame()
  dec_cids <- data.frame()
  nay_full <- data.frame()
  nay_cids <- data.frame()


  # Start-up
  items <- d %>% dplyr::select(stratum_1, concept_name) %>% unique()
  cidsA <- unique(itemsA$stratum_1)

  # *************** Business part  **************************
  for (cid in cidsA) # iterate by cid in itemsA
  {
    deciles <- itemsA %>% dplyr::filter(stratum_1 == cid) %>% dplyr::ungroup() %>%
      dplyr::select(decile) %>% unique()

    for(deci in deciles$decile)
    {
      e[i,'cid']=cid
      name = paste(dplyr::filter(items,stratum_1==cid)$concept_name,cid)
      tta <- d %>% dplyr::filter(stratum_1 == cid, decile == deci)

      # Use data CIDs with only 10 years of data: #REVIEW
      x <- tta$stratum_2
      y <- tta$count_value
      lm <- lm(y~x)

      if(lmp(lm) <= alpha && lm$coefficients[2] > m) # Inc if
      {
        count2 = count2 + 1
        inc = inc + 1
        inc_cids %<>% rbind(data.frame(stratum_1 = cid,
                                       concept_name = dplyr::filter(items,stratum_1==cid)$concept_name,
                                       decile = deci,
                                       slope = as.double(lm$coefficients[2]),
                                       p.value = as.double(lmp(lm))))
        itemsA[which(itemsA$stratum_1== cid & itemsA$decile==deci),]$classification <- 1

        #        inc_full %<>% rbind(tta)
      } # End Inc if

      if(lmp(lm) <= alpha && lm$coefficients[2] < -m) # Dec if
      {
        count2 = count2 + 1
        dec = dec + 1
        dec_cids %<>% rbind(data.frame(stratum_1 = cid,
                                       concept_name = dplyr::filter(items,stratum_1==cid)$concept_name,
                                       decile = deci,
                                       slope = as.double(lm$coefficients[2]),
                                       p.value = as.double(lmp(lm))))
        itemsA[itemsA$stratum_1== cid & itemsA$decile==deci,]$classification <- -1
      } # End Dec if

      #if(count == 50) break
      # else  nay_full %<>% rbind(tta)
      #
    }# end dec for
  } #end cid for
  sprintf("count2 = %i", count2)
  sprintf("increase = %i", inc)
  sprintf("decrease = %i", dec)

  # Classification labels appended to data frames inc_cids, dec_cids
  inc_cids %<>% cbind(classification = rep("Rising"))
  if(nrow(dec_cids) != 0) dec_cids %<>% cbind(classification = rep("Sinking"))
  #nay_cids <- distinct(nay_full, stratum_1)

  # ********************************************************
  #Rising first
  m2 <- median(inc_cids$slope) # Filter 2
  m3 <- mean(inc_cids$slope) + sd(inc_cids$slope) #Filter 3

  inc_cids %<>% dplyr::mutate(filter = ifelse(slope > m, 1,0),
                              classification = ifelse(slope > m, "Rising", "???")) #Filter 1

  inc_cids %<>% dplyr::mutate(filter = ifelse(slope > m2, 2, filter),
                              classification = ifelse(slope > m2, "Strongly Rising", classification)) #Filter 2
  inc_cids %<>% dplyr::mutate(filter = ifelse(slope > m3, 3, filter),
                              classification = ifelse(slope > m3, "Very Strongly Rising", classification)) #Filter 3

  m2 <- median(dec_cids$slope) # Filter 2
  m3 <- mean(dec_cids$slope) - sd(dec_cids$slope) #Filter 3

  dec_cids %<>% dplyr::mutate(filter = ifelse(slope < -m, -1,0),
                              classification = ifelse(slope < m, "Sinking", "???")) #Filter 1

  dec_cids %<>% dplyr::mutate(filter = ifelse(slope < m2, -2, filter),
                              classification = ifelse(slope < m2, "Strongly Sinking", classification)) #Filter 2

  dec_cids %<>% dplyr::mutate(filter = ifelse(slope < m3, -3, filter),
                              classification = ifelse(slope < m3, "Very Strongly Sinking", classification)) #Filter 3
  itemsA <- itemsA[-6]
  full_cids <- rbind(inc_cids, dec_cids)

  itemsA %<>% dplyr::left_join(full_cids, by = c("stratum_1" = "stratum_1",
                                                 "concept_name" = "concept_name",
                                                 "decile" = "decile"))
  itemsA %<>% dplyr::rename(score = filter)
  full_cids %<>% dplyr::rename(score = filter)
  inc_cids %<>% dplyr::rename(score = filter)
  dec_cids %<>% dplyr::rename(score = filter)
  full_cids$score2 <- abs(as.numeric(full_cids$score))
  itemsA %<>% dplyr::mutate(score = ifelse(is.na(score), 0, score),
                            classification = ifelse(is.na(classification), "Indeterminate", classification))

  return_list <- list('itemsA' = itemsA,
                      'inc_cids' = inc_cids,
                      'dec_cids' = dec_cids,
                      'full_cids'= full_cids)
  return(return_list)
} # End of method


#'
#'  @note This function filters age-stratified medical events that have a minimum occurance frequency
#' in at least one year
#' @param d data to filter
#' @param threshold minimum occurance frequency in people per thousand; 1 is default
#'
#' @return itemsA are all the age-stratified medical events that pass the threshold
#' @return itemsB are all the age-stratified medical events that fail the threshold.
#'
#' @export
count_filter <- function(d, threshold = 1)
{
  itemsA <- data.frame() #decile cids that pass filter
  itemsB <- data.frame() #decile cids that fail filter

  # items that pass filter
  itemsA <- d %>% dplyr::filter(count_value >= threshold) %>%
    dplyr::select(stratum_1, concept_name, decile, Data_Quality_Problem) %>%
    dplyr::distinct()

  # their index position
  inx <- which(d$count_value >= threshold)

  # items that fail
  itemsB <- d[-inx,] %>% dplyr::select(stratum_1, concept_name, decile, Data_Quality_Problem) %>%
    dplyr::distinct()

  #tag with filter
  itemsA %<>% cbind("flag_filter" = 1) #pass
  itemsB %<>% cbind("flag_filter" = 0) #fail

  #resolve declining "double-listed" drugs (those that start above threshold and fall below)
  itemsC <- rbind(itemsA, itemsB)
  itemsD <- itemsC %>% dplyr::group_by(stratum_1, concept_name, decile, Data_Quality_Problem) %>%
    dplyr::summarise(flag_filter = sum(flag_filter))

  itemsA <- dplyr::filter(itemsD, flag_filter == 1) #get back itemsA and itemsB
  itemsB <- dplyr::filter(itemsD, flag_filter == 0)

  pass <- nrow(itemsA)
  fail <- nrow(itemsB)
  count <- pass + fail #should equal 124880, or nrow(itemsD). If not fix error.

  print(c("Count = ", count))
  print(c("#pass = ", pass))
  print(c("#fail = ", fail))

  #prep itemsA and itemsB for next chunk
  itemsA$classification = 0
  itemsB$classification = NA
  return_list <- list("itemsA" = itemsA, "itemsB" = itemsB)
  return(return_list)
}

#' This function returns the Athena event analysis id
#' affiliated with a particular particular event.
#'
#' @param event_type a string-based expression for the medical event of interest
#' do not include spaces; not case sensitive
#'
#' @return integer analysis id from Athena
#'
#' @export
get_event_id <- function(event_type)
{
  if(is.integer(event_type)) return(event_type)

  else
  {
    event_type <- tolower(event_type)
    if(event_type == 'drugingredient'| event_type == 'drugexposure')
      event_type = 704

    else if(event_type == 'condition'| event_type == 'diagnosis')
      event_type = 404
  }
  return(event_type)
}

#' This function returns the Athena event analysis name
#' affiliated with a particular Athena event id.
#'
#' @param event_type a string-based expression for the medical event of interest
#' do not include spaces; not case sensitive
#'
#' @return integer analysis id from Athena
#'
#' @export

get_omop_event_name <- function(event_type)
{
  if(is.character(event_type)) return(event_type)
  else if(event_type == 704) return('drugExposure')
  else if(event_type == 404) return('condition')
  else if(event_type == 604) return('procedure')
  else if(event_type == 904) return('drugEra')
  else
  {
    print("unknown event type")
    return('unknown_event')
  }
}

#' This function enhances the plot_facet to enable grouping by decile and database
#' For analyzing all items across all DBs (especially when grouping) this function is best
#' @param df input data.frame; all data from all dbs for ONE concept_id.
#' @note colnames of df must have stratum_1 for concept_id number, stratum_2
#' for yers, and count_value for prevalence per 1000. edit the function if you want
#' to have different column names for your variables.
#'
#'
plot_db_by_decile <- function(df = data.frame())
{
  name=paste(df$concept_name[1],
             paste("(", cid, ")", sep = ""))
  print(
    ggplot2::ggplot() + ggplot2::geom_point(data = df, aes(stratum_2, count_value,colour = factor(decile) )) +
      ggplot2::theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      ggplot2::ggtitle(str_sub(name,1,120), subtitle = "qview") +
      ggplot2::labs(x = "Years", y = "Prevalence per 1000") +
      ggplot2::scale_x_continuous(breaks = pretty_breaks(n = 10))+
      ggplot2::scale_y_continuous(breaks = pretty_breaks(n = 10)) +
      ggplot2::facet_grid(db~decile)
  )
}


#' This fuction writes a .tsv file after merging all the drugEraM2.rda files together.
#' This gives one .tsv file that contains all the data thus far gathered.
#' db names are appended to the left of the data set.


all_raw_data <- function(item = character(), data_folder = '//lhcdevfiler/cgsb-minf/yohan/OHDSITrends-pre/data',
                         dest_folder = '.tsv files')
{
  setwd(data_folder)
  if(item == 'drugEra' | item == 'drug')
  {
    item <- 'drugEra'
    load('one_drugEraM2.rda')
    load('two_drugEraM2.rda')
    load('three_drugEraM2.rda')
    drugEraM2 <- cbind('db' = 'one', drugEraM2)
    two_drugEraM2 <- cbind('db' = 'two', two_drugEraM2)
    three_drugEraM2 <- cbind('db' = 'three', three_drugEraM2)
    df <- rbind(drugEraM2, two_drugEraM2, three_drugEraM2)
  }

  file <- paste0("all_raw_", item, "M2.tsv")
  path <- paste(data_folder, dest_folder, file, sep = "/")
  write_tsv(df, path = path)
}

#Load this file to get all the functions needed to run the analysis.

#' This funciton groups an all_items file (a file that has all the classified
#' items from multiple databases) by a specified knowledge base. First, it condenses
#' all the classified deciles, so there is 1 entry per concept. The score2 valus
#' are summed together, so that each concept has 1 value for it's overall trend.
#' Max value for this parameter is 90 (3 databases * mas score2 of 3 * 10 decades)
#'
#' @param item name of the item to be classified
#' @param kb_name name of the knowledge based use
#' @param item_file full path to the all_item.csv file to group
#' @param kb_file full path to the knowledge base file to group by
#' @param dest_dir folder where the output .tsv file will go
#'
#' @note (\code{c(item, kb_name)}) are only use for naming the output file
#'
#' @return none
#'
#' @example
#' item_file <- '//lhcdevfiler/cgsb-minf/yohan/OHDSITrends-pre/data/items/all_drugEra_items.csv'
#' kb_file <- '//lhcdevfiler/cgsb-minf/yohan/OHDSITrends-pre/data/MEDI/simplified_kb_grouping_drugEra_dx.tsv.tsv'
#' dest_dir <- '//lhcdevfiler/cgsb-minf/yohan/OHDSITrends-pre/data/items/Grouped'
#' item <- 'drugEra'
#' kb_name <- 'MEDIdx'
#'
#' group_all_items(item, kb_name, item_file, kb_file, dest_dir)

#' @export
group_all_items <- function(item, kb_name, item_file, kb_file, dest_dir)
{
  require(readr)
  if(item == 'drug') iem <- 'drugEra'

  #read item data
  df <- read_csv(item_file)
  #collapse to single concept
  dfC <- df %>% group_by(stratum_1, concept_name) %>% summarize(sum_score2 = sum(score2)) %>%
    dplyr::ungroup() # Max of summarized score 2 is 3*10*3 = 90
  #read knowledge base
  sKB <- readr::read_tsv(kb_file)
  df2 <- dplyr::left_join(dfC, sKB, by = c('stratum_1' = "CONCEPT_ID", "concept_name" = "CONCEPT_NAME"))
  file <- paste0('all_', item, "_groupedBy_", kb_name, ".tsv")
  path <- paste(dest_dir, file, sep = '/')
  readr::write_tsv(df2, path = path)
}


#' This function takes the classified items (full_cids), appends a column
#' to the left, indicating which database the items are from, merges the items,
#' and then prints a single csv file for all the items
#'
#' @param dom Character vector of domains (\code{c('drug', 'proc', 'cond')})
#' @param DB  Character of the DBs (\code{c('one', 'two', 'three')})
#' @param dir file path to where the clasified items live.
#'            this directory is also where the output .csv file will go
#' @return None
#'
#' @import readr
#' @import dplyr
#'
#' @note No warning messages are thrown if the input names are bad.
#' @note csv file name is all_{domain}_items
#'
#' @example
#' dom <- c('drug', 'cond', 'proc')
#' combine_items(dom, dir = dir)
#'
#' @export
combine_items <- function(dom, DB = c('one', 'two', 'three'), dir = NULL)
{
  setwd(dir)
  require(readr); require(dplyr)
  for(domain in dom)
  {
    print("------")
    print(domain)
    print("")
    if(domain == 'drug') {domain <- 'drugEra'}
    file <- paste("all", domain, "items", sep = "_") %>% paste0(".csv")
    df <- data.frame()

    if(domain == 'drugEra') {domain <- 'drug'}
    for(db in DB)
    {
      print(paste("db", db))
      fname <- paste(db, capitalize(domain), "items", sep = "_") %>%
        paste0(".rda")
      load(fname)
      df <- cbind("db" = db, full_cids) %>% rbind(df)
      print('added')
    }
    write_csv(df, path = file)
  }
}



#' @export
capitalize <- function (string) #from Hmisc. R package. Only this function is necessary.
{
  capped <- grep("^[A-Z]", string, invert = TRUE)
  substr(string[capped], 1, 1) <- toupper(substr(string[capped],
                                                 1, 1))
  return(string)
}

#
# makeMediumFrame <- function(obj = data.frame(), pop = data.frame(), concept = data.frame())
# {
#
#   colnames(obj) <- c("stratum_1", "concept_name",
#                      "stratum_2", "gender", "decile",
#                      "stratum_5", "pt_cont")
#
#   colnames(pop) %<>% tolower()
#
#   unique(obj$stratum_5) #returns only 0, so stratum_5 has straight zeros.... strange
#
#
#   obj <- obj[-6] #drop stratum_5, bc. it is only 0s
#
#
#
#   obj <- dplyr::left_join(obj, pop, by = c("stratum_2" = "stratum_1",
#                                     "decile" = "stratum_3",
#                                     "gender" = "stratum_2"))
#   obj
#   obj2 <- obj[,c(1:6, 10)]
#
#   #stratum_1 is ascutally the Achilles analysis id, and concept_name is really stratum_1
#   obj2 <- dplyr::rename(obj2, analysis_id = stratum_1, stratum_1 = concept_name)
#
#   #Now need to get concept_names from Athena concept.csv file
#   obj2 %<>% dplyr::left_join(concept, by = c('stratum_1' = 'concept_id'))
#   obj2 <- obj2[-1]
#
#   #Trying to re-order columns; want same order as others
#   obj2 %<>% dplyr::rename(population_count = count_value)
#   obj2 %<>% dplyr::rename(pt_count = pt_cont)
#   obj2 %<>% dplyr::select(stratum_1, concept_name, decile, stratum_2, gender, pt_count, population_count)
#
#
#   #Collapse by gender and get count_value
#   obj3 <- dplyr::group_by(obj2, stratum_1, concept_name, decile, stratum_2) %>%
#     dplyr::summarise(pt_count = sum(pt_count), population_count = sum(population_count))
#   obj3$count_value = obj3$pt_count/obj3$population_count * 1000 # Persons per thousand
#
#   #Remove concept_id = 0 and year 2015
#   obj3 %<>% dplyr::filter(stratum_1 != 0, stratum_2 != 2015)
#
#   #Make deciles strings not integers
#   decis <- obj3$decile %>% as.character() %>% as.factor()
#   if(0 %in% decis)
#   {
#     decis %<>% plyr::revalue(c("0" = "0-9", "1" = "10-19", "2" = "20-29", "3" = "30-39",
#                          "4" = "40-49", "5" = "50-59", "6" = "60-69", "7" = "70-79",
#                          "8" = "80-89", "9" = "90-99"))
#   }
#   else
#   {
#     decis %<>% plyr::revalue(c("1" = "0-9", "2" = "10-19", "3" = "20-29", "4" = "30-39",
#                         "5" = "40-49", "6" = "50-59", "7" = "60-69", "8" = "70-79",
#                         "9" = "80-89", "10" = "90-99", "11" = "100+"))
#   }
#   # decis <- ifelse(0 %in% decis, revalue(decis, c("0" = "0-9", "1" = "10-19", "2" = "20-29", "3" = "30-39",
#   #                                                 "4" = "40-49", "5" = "50-59", "6" = "60-69", "7" = "70-79",
#   #                                                 "8" = "80-89", "9" = "90-99")),
#   #                  revalue(decis, c("1" = "0-9", "2" = "10-19", "3" = "20-29", "4" = "30-39",
#   #                                   "5" = "40-49", "6" = "50-59", "7" = "60-69", "8" = "70-79",
#   #                                   "9" = "80-89", "10" = "90-99", "11" = "100+")))
#   print(decis)
#   obj3$decile = decis
#   obj3 %<>% ungroup()
#   return(obj3)
# }


insertRow <- function(existingDF, newrow, r)
{
  existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
  existingDF[r,] <- newrow
  existingDF
}


#If data values in stratum_2 for every cid in df is not continuous
# stream of integers (i.e. there is a break)
is.consecutive <- function(x, incr = 1L)
{
  is.cons = 0
  n = length(x)
  is.cons <- tail(x, -1L) == head(x, -1L) + 1
  any(diff(c(0L, which(!is.cons), length(x))) >= n)
}


#*****************Impute Zeros Function*****************************

impute_zeros <- function(df)  #apply this on tta when looping through d
{
  ymax = 0
  ymin = 0
  #Add zeros to front -- WORKS!

  if(!(2003 %in% df$stratum_2))
  {
    for(y in (df$stratum_2[1]-1):2003)
    {
      newrow <- c(df[1,1], df[1,2], df[1,3], y, 0, 0, 0)
      df <- insertRow(df, newrow, 1)
    }
  }
  # Add zeros to middle -- PROBLEMS!
  if(!is.consecutive(df$stratum_2))
  {
    x <- df$stratum_2
    is.cons <- tail(x, -1L) == (head(x, -1L) + 1)
    offset <- 0
    missing_indices <- which(!is.cons) #year missin gafter index
    #    print(missing_indices)
    for(i in seq_along(missing_indices))
    {
      ymin <- df$stratum_2[missing_indices[i] + offset] + 1
      ymax <- df$stratum_2[missing_indices[i] + 1 + offset] - 1
      offset <- ymax-ymin + 1 + offset

      for(y in ymax:ymin)
      {
        newrow <- c(df[1,1], df[1,2], df[1,3], y, 0, 0, 0)
        df <- insertRow(df, newrow, missing_indices[i]+1)
      }
    }
  }
  # Add zeros to end
  if(!(2014 %in% df$stratum_2))
  {
    for(y in (df$stratum_2[nrow(df)]+1):2014)
    {
      newrow <- list(stratum_1  = df[[1,1]],
                     concept_name = df[[1,2]],
                     decile = df[[1,3]],
                     stratum_2 = y,  count_value = 0,
                     pt_count = 0, population_count = 0)
      df <- rbind(df, newrow)
    }
  }
  df
}
#*****************************************************************************************

#Approach:

runner <- function(d = data.frame(), items)
{
  # Setup all the temp objects needed at function level
  items2 <- as.data.frame(list("stratum_1" = 0))
  items3 <- data.frame()
  items4 <- data.frame(stratum_1 = 0)

  tta <- data.frame()
  tta2 <- data.frame()
  tta3 <- data.frame()


  ttb <- data.frame()
  ttb2 <- data.frame()
  ttb3 <- data.frame()

  ttc <- data.frame()
  stuffed <- data.frame()

  i = 0
  deciles <- unique(as.character(d$decile))

  # Currently adds zeros for a drug that has decile and year in d1.
  # If drug is totally missing (i.e. has zero years for the decile)
  # Then zeros are not imputed.

  for(j in 1:length(deciles)) #iterate through decile
  {

    print("------------")
    dec = deciles[[j]]

    d1 <- d %>% dplyr::filter(decile == dec)
    items7 <- dplyr::select(d1, stratum_1, concept_name) %>% dplyr::distinct()
    print(dec)
    ttb2 <- data.frame()


    #  dec = deciles[1]
    for (cid in items$stratum_1) #iterate through year
    {
      name=paste(dplyr::filter(items,stratum_1==cid)$concept_name,cid)
      tta <- d1 %>% dplyr::filter(stratum_1 == cid)
      if(dim(tta)[[1]] == 0)
      {
        stuffed %>% rbind(cid)
        tta <- data.frame(stratum_1 = cid,
                          items[items$stratum_1 == cid, 2], #this returns a 1x1 tibble with concept name
                          stratum_2 = 2003:2014,
                          decile = dec,
                          pt_count = 0,
                          population_count = 0,
                          count_value = 0)
        tta2 <- rbind(tta2, tta)
        items2 <- rbind(items2, tta[[1,1]])
      }


      else if(!(2014 %in% tta$stratum_2) | !(2003 %in%tta$stratum_2) | !(is.consecutive(tta$stratum_2)))
      {
        items2 <- rbind(items2, tta[[1,1]])
        tta %<>% impute_zeros() %>% dplyr::ungroup()
        tta2 <- rbind(tta2, tta)
      }

      else
      {
        items4 %<>% rbind(tta[1,1])
        ttb2 <- rbind(ttb2, as.data.frame(tta))
      }
      if(nrow(tta2) >= 1000)
      {
        tta3 <- rbind(tta3, tta2)
        tta2 <- data.frame()
      }

      if(nrow(ttb2) >= 1000)
      {
        ttb3 <- rbind(ttb3, ttb2)
        ttb2 <- data.frame()
      }

      i = i + 1
      if(i %% 1000 == 0) {print(i)}
    }
    tta3 <- rbind(tta3, tta2)
    ttb3 <- rbind(ttb3, ttb2)

    print(c("length of items 2", nrow(items2)))
    print(c("length of items 4", nrow(items4)))
    print(c("total rows", nrow(tta3) + nrow(ttb3)))

    ttb <- rbind(ttb3, ttb) #data without problems
    ttc <- rbind(tta3, ttc) #data where zeros were imputed

    tta2 <- data.frame()
    ttb2 <- data.frame()
    tta3 <- data.frame()
    ttb3 <- data.frame()
  }

  ttb <- cbind(ttb, "Data_Quality_Problem" = 0) # full items
  ttc <- cbind(ttc, "Data_Quality_Problem" = 1) # itmes missing 0s
  ttd <- rbind(ttb, ttc) %>% dplyr::ungroup() %>%
    dplyr::arrange(stratum_1, stratum_2)
  return(ttd)
}

#' internal use only
#' @description Make linear trend
#'@export

lmp <- function(modelobject)
{
  if(class(modelobject) != "lm") {stop("Not an object of class lm")}
  f <- summary(modelobject)$fstatistic
  p <- pf(f[1], f[2], f[3], lower.tail = F)
  attributes(p) <- NULL
  return(p)
}


#' @note Internal function only
#' @export
# obj <- event


makeMediumFrame <- function(obj = data.frame(), pop = data.frame(), concept = NULL, dates)
{

  colnames(concept) %<>% tolower()
  concept %<>% dplyr::select(concept_id, concept_name, concept_code)

  obj %<>% dplyr::select(STRATUM_1, STRATUM_2, gender = STRATUM_3, decile = STRATUM_4, COUNT_VALUE)
  colnames(obj) %<>% tolower()
  obj %<>% dplyr::group_by(stratum_1, stratum_2, decile) %>%
    dplyr::summarise(pt_count = sum(count_value)) %>% dplyr::ungroup()

  pop %<>% dplyr::select(stratum_2 = STRATUM_1, gender = STRATUM_2, decile = STRATUM_3,
                         population_count = COUNT_VALUE) %>%
           dplyr::group_by(stratum_2, decile) %>%
            dplyr::summarise(population_count = sum(population_count)) %>%
              dplyr::ungroup()


  # join event and pop
  obj2 <- dplyr::left_join(obj, pop)

  # join to concept for concept_name and concept_code
  obj3 <- dplyr::left_join(obj2, concept, by = c('stratum_1' = 'concept_id'))
  # change column order to make easier to read
  obj3 %<>% dplyr::select(stratum_1, concept_name, concept_code, decile, stratum_2, pt_count, population_count)
  obj3$count_value = obj3$pt_count/obj3$population_count * 1000 # Persons per thousand

  #Remove concept_id = 0 and year 2015
  obj3 %<>% dplyr::filter(stratum_1 != 0, stratum_2 %in% dates)

  #Make deciles strings not integers (REMOVED in FEB)
  # decis <- obj3$decile %>% as.character() %>% as.factor()
  # if(0 %in% decis)
  # {
  #   decis %<>% plyr::revalue(c("0" = "0-9", "1" = "10-19", "2" = "20-29", "3" = "30-39",
  #                              "4" = "40-49", "5" = "50-59", "6" = "60-69", "7" = "70-79",
  #                              "8" = "80-89", "9" = "90-99"))
  # }
  # else
  # {
  #   decis %<>% plyr::revalue(c("1" = "0-9", "2" = "10-19", "3" = "20-29", "4" = "30-39",
  #                              "5" = "40-49", "6" = "50-59", "7" = "60-69", "8" = "70-79",
  #                              "9" = "80-89", "10" = "90-99", "11" = "100+"))
  # }
  #
  # #print("Made medium Frame")
  # obj3$decile = decis


  obj3 %<>% dplyr::ungroup()
  return(obj3)
}


#' @description This function reads in pop data from the dataExtract folder
#' @export
get_pop <- function(data_folder, pop_id)
{
  pop_file = paste0('a', pop_id)
  pop_path = paste0(data_folder, paste0(pop_file, ".csv"))
  pop <- readr::read_csv(pop_path,col_types = cols())

  return(pop)
}

#' @description This function reads in event data from the dataExtract folder
#' @export

get_event <- function(data_folder, event_type)
{
  event_type <- get_event_id(event_type)

  # Update this file path with Dr. Huser's correct naming convention. E.G. WHY IS a at front?
  event_file = paste0("a", event_type, ".csv")
  event_path = paste0(data_folder, event_file)
  event <- readr::read_csv(event_path,col_types = cols())
  return(event)
}


#' Step 1 was to pre-process the data. This will read in the data files that
#' were extracted from the db
#'
#' Step 2 Preprocess the raw data extracted from the databse.
#'     This involves joining the original data with the Athena concept tables
#'     to get concept_names.
#'
#'@param data_folder where the .csv files produced by step1 live
#'@param event_type whatever naming convention Dr. Huser used to get generate
#'     names for the raw data files. For now, use 3 digit code e.g. 404 for for conditions
#' @example step_2(data_folder, event_type), where
#' data_folder = 'C:/Users/sumathipalaya/Desktop/DONOTINCLUDE-in-package/one/export'
#' event_type = 704
#'
#' @return pre-processed eventM
#'
#' @export
#'
#'

step_2 <- function(event, pop, event_type=704, OMOP = FALSE, concept_file=NULL, dates)
{

  #Replace this file path with the correct one, because the R package
  # will contain the concept.rda file when we sent it to people.
  if(is.null(concept_file))
  {
    if(OMOP)
    {
      print('STOP!!! Download concept file')
      break
    }
  }
  #set up event data to be analyzed
  else { #concept_file is not null)

    if(class(concept_file) == 'data.frame')
      concept <- concept_file
    else if(class(concept_file) == 'character' & grepl('.csv', concept_file))
    concept <- read.delim(concept_file, as.is = T, quote = "")

    colnames(concept) %<>% tolower()
    eventM <- makeMediumFrame(event, pop, concept, dates)
  }

  if(is.null(concept) | is.null(eventM))
    eventM <- makeMediumFrame(event, pop, concept = NULL, dates)

  eventM <- eventM %>%  dplyr::ungroup()
  eventM2 <- impute_zeros_trends(eventM, dates = dates)

  eventM2$analysis_id = event_type
  eventM2 %<>% dplyr::select(analysis_id, stratum_1, concept_name, concept_code, stratum_2, decile, count_value, pt_count, population_count)
  eventM2 %<>% dplyr::arrange(stratum_1)

  probs <- ifelse(is.na(eventM2$pt_count), yes = 1, no = 0)
  eventM2$Data_Quality_Problem = probs

  return(eventM2)
}

#' @description  This function imputes zeros for missing data
#' @export

impute_zeros_trends <- function(eventM, dates)
{
  #Procees: 1) make data.frame of 0s that is size of output data.frame 2) left_join this array by stratum_1 = concept_id
  # Get the unique cids and concept_names
  heads <- eventM %>% dplyr::select(stratum_1, concept_name, concept_code) %>% unique()
  cids <- heads$stratum_1
  names <- heads$concept_name
  codes <- heads$concept_code %>% as.character()

  # get deciles and dates
  decis <- dplyr::select(eventM, decile) %>% unique() %>% lapply(as.character)


  # Makes zeros data.frame that is size of destination data.frame, where count_value = 0 everywhere
  zeros <- data.frame(stratum_1 = rep(cids, each = length(dates) * length(decis[[1]])),
                      concept_name = rep(names, each = length(dates) * length(decis[[1]])),
                      concept_code = rep(codes, each = length(dates) * length(decis[[1]])),
                      stratum_2 = rep(dates, each = length(decis[[1]])))
  zeros$decile = decis[[1]]
  zeros$concept_name %<>% as.character()
  zeros$decile %<>% as.character()
  eventM$decile %<>% as.character()
  eventM$concept_name %<>% as.character()

  # Get the rows(cid, date combinations) that need to be added to eventM
  impute <- dplyr::anti_join(zeros, eventM) %>% dplyr::arrange(stratum_1, stratum_2)

  # Put 0 to count_value in impute and add analysis_id
  impute$count_value <- 0
  #impute$analysis_id = eventM$analysis_id[1]

  # bind impute to eventM
  eventM2 <- dplyr::bind_rows(eventM, impute) %>% dplyr::arrange(stratum_1, stratum_2)
  eventM2$decile %<>% as.factor()
  #if(any(is.na(eventM2$pt_count))) print("Warning, NAs introduced by imputation")
  if(any(is.na(eventM2$count_value))) print("ERROR: count_value has NAs")
  #else print("Imputation successful")

  return(eventM2)
}


#' #' @note not used
#' find_data_quality_problems <- function(eventM2)
#' {
#'   probs <- ifelse(is.na(eventM2$pt_count), yes = 1, no = 0)
#'   eventM2$Data_Quality_Problem = probs
#' }

#' Rollups
#'
#'
#'
#' @note Get df that contains all classified items for a particular event type
#' @param full_cids get from lin_list$full_cids (inernal use)
#' @param databases number of databases (user-input at top-level)
#' @param event_type type of
#'
#' @export
return_rollup_1 <- function(databases, event_type, full_cids)
{
  event_type
  #Initializing
  #  events %<>% capitalize()
  out <- data.frame()

  print(event_type)

  for(db in databases) #iterate through dbs
  {
    print(db)
    #Load data
    df <- cbind('db' = db, 'event_type' = event_type, full_cids)
    df %<>% dplyr::ungroup()

    # Shape data
    df2 <- df %>% dplyr::group_by(db, event_type, stratum_1, concept_name, score, classification) %>%
      dplyr::summarize(count = n()) %>% dplyr::ungroup()

    #get each CID, concept_name pair w/ db + event_type
    frame <- df %>% dplyr::group_by(db, event_type) %>%  dplyr::select(stratum_1, concept_name) %>%
      unique() %>% dplyr::ungroup()

    # flesh out frame
    x <- frame
    for(i in -3:3)
    {
      pi <- df2 %>% dplyr::filter(score == i)
      x <- dplyr::left_join(x, dplyr::select(pi, stratum_1, count))

      # rename count variable
      if(i == -3) x %<>% dplyr::mutate(very_strongly_sinking = count)
      if(i == -2) x %<>% dplyr::mutate(strongly_sinking = count)
      if(i == -1) x %<>% dplyr::mutate(sinking = count)
      if(i ==  1) x %<>% dplyr::mutate(rising = count)
      if(i ==  2) x %<>% dplyr::mutate(strongly_rising = count)
      if(i ==  3) x %<>% dplyr::mutate(very_strongly_rising = count)
      x %<>% dplyr::select(-count)
    }

    # fill NA with 0
    x[is.na(x)] <- 0

    out %<>% rbind(x)
  } # end db for
  return(out)
}



#' This function summarizes the classified CIDs by counting the number of age-decades
#' that are rising, strongly rising, etc. for each event type across all DBs (i.e. one row
#' per event_type account for classification of data in every database)
#'
#' @param full_cids all classified concept IDs
#' @param databases character vector containing the names of the databases
#' @param events character vector containing the type of medical event to be analyzed (e.g. drugExposure)
#' @param dest_path destination folder for the .tsv file
#'
#' @export
rollup_1.2 <- function(full_cids, databases = 'unknown', events,
                       dest_path = '')
{
  print("Rollup 1.2....... ")
  events %<>% capitalize()
  out <- data.frame()
  rollup_list <- list()
  print(databases)
  for(event in events)
  {
    #if(debug_level == 1) event = 'Drug'
    out <- return_rollup_1(databases, event, full_cids = full_cids)

    out %<>% dplyr::group_by(event_type, stratum_1, concept_name) %>%
      dplyr::summarise(very_strongly_sinking = sum(very_strongly_sinking),
                       strongly_sinking = sum(strongly_sinking),
                       sinking = sum(sinking),
                       rising = sum(rising),
                       strongly_rising = sum(strongly_rising),
                       very_strongly_rising = sum(very_strongly_rising))

    #Pring .tsv file
    fname <- paste0(event, '_full_events_rollup_1.2.tsv')
    path <- paste0(dest_path, fname)
    readr::write_tsv(out, path)
    rollup_list[[event]] <- out

    # reset data frames
    out <- data.frame()
  }
  print("Rollup 1.2....... Done")
}

#' @note This function summarizes the sorted items from the roll_up_1.2.tsv
#' @param events Characater vector for events to roll-up
#' @param rollup_folder Destination path
#' @export

skim_rollup <- function(events, rollup_folder)
{
  events %<>% OHDSITrends::capitalize()
  for(event in events) #Both rollup 1 and 1.2 are organized by event type
  {
    file = paste(event, "full_events", "rollup_1.2", sep = "_") %>% paste0(".tsv")
    print(file)
    data <- readr::read_tsv(paste0(rollup_folder, file))
    top <- data %>% dplyr::arrange(dplyr::desc(very_strongly_rising)) %>% dplyr::slice(1:50)
    bottom <- data %>% dplyr::arrange(dplyr::desc(very_strongly_sinking)) %>% dplyr::slice(1:50)
    out_file = paste("interesting", event, "events", sep = "_") %>% paste0(".tsv")
    readr::write_tsv(x = rbind(top, bottom), path = paste0(rollup_folder, out_file))

  } # end events for
}



#' @note Step 1 done => raw data is read, zeros are imputed, and result is stored in
#' ~/dest_folder/database_name (use dir.create() to make the sub-directory)
#'
#' @note Step 2: classify items by linear fit

#'
#' @example: see below
#' dest_folder = '/home/yohan/Desktop/'
#' db_name = 'one'
#' event_type = 904 #drugExposures
#' sep = '_'
#' extension = '.rda'
#'
#' #load one_drugEraM2 from OHDSI-PRE into memory to avoid having to run step_two
#'
#' objM2 = drugEraM2
#' rm(drugEraM2)
#' # leave event type as a number, because not all users will have OMOP data
#' # and we don't know what kind of event IDs they will be using
#'
#' Step_3(objM2, dest_folder, event_type, sep, extension)
#'
#' @export
step_3 <- function(objM2, dest_folder, event_type, sep='_', extension='.csv')
{

  # fname = paste(event_type, sep = sep) %>% paste0("M2", extension)
  # fpath = paste(dest_folder, fname, sep = "/")

  # # ***********************************************
  #       # CHANGE THIS BLOCK!!
  #   # modify this command so that it works with whatever the correct file extension is
  #   load(fpath) # because this will be a .rds file, call this object objM2
  #   objM2 <- two_procM2
  #
  # # ************************************************

  # Part 1: Threshold filter
  count_list <- count_filter(objM2)
  itemsA <- count_list$itemsA
  itemsB <- count_list$itemsB #Save this for the end

  # Part 2: Linear filter itemsA
  lin_list <- lin_filter(objM2, itemsA)
  return(lin_list) #this has itemsA, inc_cids, dec_cids, full_cids
}

#' @description  Step 4 This function summarizes the classified items from step 3
#'
#' @param full_cids from lin_filter2
#' @param events Characater vector for events to roll-up
#' @param dest_path Folder where the .tsv output summary files will go
#'
#' @export

step_4 <- function(full_cids)
{
  #if(is.character(class(event_type))) event_type %<>% capitalize()

  xxx <- full_cids %>% summarise_full_cids()
  box <- xxx %>% rollup_2.0()
  out_2.0 <- skim_rollup_2.0(xxx, box, num = 100) # overall most interesting
  out_1.0 <- skim_rollup_1.0(xxx, box, num = 50) #top rising, sinking

#  fname <- paste("Overall_interesting", db_schema, event_type, "events", sep = '_') %>% paste0('.tsv')
#  readr::write_tsv(out_2.0, path = paste0(dest_path, fname))

#  fname <- paste("Top_trending", db_schema, event_type, "events", sep = '_') %>% paste0('.tsv')
#  readr::write_tsv(out_1.0, path = paste0(dest_path, fname))
  l <- list(rollup1.0 = out_1.0, rollup2.0 = out_2.0)
  return(l)
}

# ------------------
# Added 08/09/2017 10:06

#' @description Creates plot_score = sum(abs(age-category slope * score)) / number of events in the ancestor group
#' @param clf_gb trend_classification by age-category for each medical event
#' @return unique ancestor concept_ids of the top 100 plot_scores ordered by decreasing plot_score
#' @export
filter_by_plot_score <- function(clf_gb)
{
  events_per_ancestor <- kb %>% dplyr::group_by(ancestor_concept_id, ancestor_concept_name,
                                                concept_class_id, concept_code) %>%
    dplyr::summarise(event_count = n())

  clf_gb %<>% dplyr::left_join(events_per_ancestor)
  clf_gb %<>% dplyr::filter(p.value < 0.05)

  foo <- clf_gb %>% dplyr:::group_by(ancestor_concept_id, ancestor_concept_name, concept_class_id,
                                     concept_code, event_count) %>%
    dplyr::summarise(plot_sum = sum(abs(slope)*score2))

  foo$plot_score = foo$plot_sum/foo$event_count

  plot_concepts <- foo %>% dplyr::arrange(dplyr::desc(plot_score)) %>% head(100)
  acids <- plot_concepts$ancestor_concept_id %>% unique()
  return(acids)
}
# -------------------------

#Added 08.16.17

#' @description Remove low events
#' @export
filter_low_events <- function(tdg)
{
  argo <- tdg %>% dplyr::group_by(stratum_1, concept_name, decile) %>%
    dplyr::summarise(max = max(count_value)) %>% dplyr::ungroup()
  argo_by_decile <- argo %>% dplyr::group_by(decile) %>%
    dplyr::summarise(comp = mean(max)) %>% dplyr::ungroup()

  deciles <- tdg$decile %>% unique() %>% sort() %>% as.character()
  argo$keep <- 0
  i = 0
  for(dec in deciles)
  {
    argo[which(argo$decile == dec),]$keep <-
      ifelse(argo[which(argo$decile==dec),]$max > argo_by_decile[which(argo_by_decile$decile == dec),]$comp,
             yes = 1, no = 0)
    i = i + 1
  }

  #dplyr::filter(argo, keep == 1)$stratum_1 %>% unique() %>% length()
  keepers <- dplyr::filter(argo, keep == 1)$stratum_1 %>% unique()
  tdg2 <- dplyr::filter(tdg, stratum_1 %in% keepers)
  return(tdg2)
}

#' @export
plot_group_by_decile_by_concept_id <- function(name, mydata, sub, y_lab)
{

  print(
    ggplot2::ggplot() + ggplot2::geom_line(data = mydata, ggplot2::aes(stratum_2, count_value,
                                                                       colour = factor(stratum_1))) +
      ggplot2::labs(color = '') +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1)) +
      ggplot2::ggtitle(name, subtitle = sub) +
      ggplot2::labs(x = "Years", y = y_lab) +
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 10))+
      ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
      ggplot2::facet_wrap(~decile, scales = 'free_y')
  )
}

#' @export
plot_group_by_decile <- function(name, mydata, sub, y_lab)
{
  print(
    ggplot2::ggplot() + ggplot2::geom_line(data = mydata, ggplot2::aes(stratum_2, count_value,colour = factor(concept_name %>% substr(1, 30)) )) +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, hjust = 1)) +
      ggplot2::ggtitle(name, subtitle = sub) +
      ggplot2::labs(x = "Years", y = y_lab) +
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 10))+
      ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
      ggplot2::facet_wrap(~decile, scales = 'free_y')
  )
}

#' @export
plot_png_by_atc <- function(tdg, graph_folder, TAG = NULL)
{
  aname <- tdg$ancestor_concept_name[[1]] %<>% substr(1, 60)
  acode <- tdg$concept_code[[1]]
  gname <- paste(aname, acode, sep = '_')

  if(!is.null(TAG))
  {
    pngname <- paste0('a', substr(tdg$concept_class_id[[1]], 5, 5)) %>% paste(acode, TAG, sep = '_') %>%
      paste0('.png')
  }  else
    pngname <- paste0('a', substr(tdg$concept_class_id[[1]], 5, 5)) %>% paste(acode, sep = '_') %>%
    paste0('.png')

  out.png <- paste0(graph_folder, pngname)
  png(out.png, height = 10.5, width = 10.5, units = 'in', res = 600)

  plot_group_by_decile(gname, tdg,
                       sub  = TAG,
                       y_lab = paste('Prevalence per 1000'))
  dev.off()
}

#' @export
remove_deciles <- function(mydata, ages)
{
  mydata %<>% dplyr::filter(!decile %in% ages)
  return(mydata)
}

# -------------------------------

# Added 08/09/2017 10:06

#' @description joins trend-classification by age category with the knowledge base
#' @param clf trend classification by age category for each medical event
#' @param kb knowledge base read as data.frame()
#' @return data.frame()
#' @export
join_classification_to_kb <- function(clf, kb, eventM2)
{
  if(is.character(kb)) {kb <- readr::read_csv(kb)}
  clf_gb <- dplyr::left_join(kb, clf)
  if(any(is.na(clf_gb$decile)))
  {
    print('NAs introduced.')
    xxx <- clf_gb %>% dplyr::filter(is.na(decile)) %>% dplyr::select(stratum_1) %>% unique()
    if(!any(eventM2$stratum_1 %in% xxx))
    {
      print('None of the events with NAs have data, and can be removed.')
      print('Removing these data-less events')
      clf_gb <- clf_gb[complete.cases(clf_gb),]
    }
    else cat('****************\nSome of the events with NAs have data. There is a problem with KB and Data.\nSTOP AND FIX !\n****************')
    return(clf_gb)
  }
}

# -----------------------------------
# Added 8/30/17

# R Shiny App Functions

#' @description Merges eventM2 data with group_by table
#' @note Only works for procedures and drugs so far.
#' @export

OHDSI_shiny_dg <- function(kb.csv, eventM2, analysis_id)
{
  # Read kb
  kb <- readr::read_csv(kb.csv)
  kb$CONCEPT_CODE %<>% as.character()

  colnames(kb) %<>% tolower()
  print("Is knowledge base set up with concept_id, concept_name, ancestor_concept_id, and ancestor_concept_name?")
  print("If not, errors will result. Verify and re-run")

  colnames(kb)[1:2] <- c("stratum_1", "concept_name")

  # Filter kb to region of interest
  if(analysis_id == 904)
  {
    kb %<>% dplyr::filter(concept_class_id %in% c('ATC 3rd', 'ATC 4th'))
    #kb %<>% dplyr::filter(!concept_class_id %in% c('ATC 3rd', 'ATC 4th'))
  }
  if(analysis_id == 604)
  {
    kb %<>% dplyr::filter(vocabulary_id == 'CPT4', concept_class_id == 'CPT4 Hierarchy')
  }

  mycids <- eventM2$stratum_1 %>% unique()
  kb %<>% dplyr::filter(stratum_1 %in% mycids)

  eventKB <- dplyr::left_join(eventM2, dplyr::select(kb, stratum_1, ancestor_concept_id, ancestor_concept_name,
                                                     concept_class_id ))
  # Get rid of all unmatched events
  dg <-  eventKB %>% dplyr::filter(!is.na(ancestor_concept_id))

  old <- dg %>% dplyr::filter(decile %in% c('70-79', '80-89', '90-99'), count_value > 0) %>%
    dplyr::count(stratum_2, decile)
  rem <- ifelse(old$stratum_2 %>% unique() %>% length() < 5, yes = T, no = F)
  if(rem)
  {
    elderly <- c('70-79', '80-89', '90-99')
    #Remove deciles
    dg <- remove_deciles(dg, elderly)
  }
  return(dg)
}


#' @description Creates a plot score formedical events grouped by ancestor concept
#' @note plot score = sum of trend classification score for events in a group / number of events
#' @return Top 100 ancestor concepts
#' @export

OHDSI_shiny_plot_score <- function(clf_gb, kb)
{
  events_per_ancestor <- kb %>% dplyr::group_by(ancestor_concept_id, ancestor_concept_name,
                                                concept_class_id) %>%
    dplyr::summarise(event_count = n())

  clf_gb %<>% dplyr::left_join(events_per_ancestor)
  clf_gb %<>% dplyr::filter(p.value < 0.05)

  foo <- clf_gb %>% dplyr::group_by(ancestor_concept_id, ancestor_concept_name, concept_class_id,
                                     event_count) %>%
    dplyr::summarise(plot_sum = sum(abs(slope)*abs(score)))

  foo$plot_score = foo$plot_sum/foo$event_count

  plot_concepts <- foo %>% dplyr::arrange(dplyr::desc(plot_score)) %>% head(100)
  acids <- plot_concepts$ancestor_concept_id %>% unique()

  foo %<>% dplyr::ungroup()
  return(foo %>% dplyr::filter(ancestor_concept_id %in% acids) %>%
           dplyr::arrange(dplyr::desc(plot_score)) %>% dplyr::select(-plot_sum))
}

#' @description Plots all medical events associated with an ancestor concept
#' @export

OHDSI_shiny_plot_1 <- function(dg, acid)
{
  tdg <- dg %>% dplyr::filter(ancestor_concept_id == acid)

  if(nrow(tdg) == 0) return(NULL)

  aname <- tdg$ancestor_concept_name[[1]] %<>% substr(1, 60)
  acode <- tdg$concept_code[[1]]
  gname <- paste(acode, aname, sep = '_')

  # output plot 1
  return(plot_group_by_decile_by_concept_id(gname, tdg,
                                            sub  = '',
                                            y_lab = paste('Prevalence per 1000')))

}

#' @description Plots just the top 15 most significantly trending (rising or falling)
#'  medical events in an ancestor concept id, if the ancestor concept id is affiliated with
#'  more than 15 events.
#' @export

OHDSI_shiny_plot_2 <- function(dg, acid)
{
  tdg <- dg %>% dplyr::filter(ancestor_concept_id == acid)

  if(nrow(tdg) == 0) return(NULL)

  aname <- tdg$ancestor_concept_name[[1]] %<>% substr(1, 60)
  acode <- tdg$concept_code[[1]]
  gname <- paste(acode, aname, sep = '_')

  if(tdg$stratum_1 %>% unique() %>% length() > 15)
  {
    TAG <- 'FLTR'
    gname2 <- paste(gname, sep = '_')
    tdg2 <- filter_low_events(tdg)

    return(plot_group_by_decile_by_concept_id(gname2, tdg2,
                                              sub  = TAG,
                                              y_lab = paste('Prevalence per 1000')))

    #plot_png_by_atc(tdg2, graph_folder, TAG)
  }
  else return(NULL)
}

# -------------------------------------------------------------
# Added 9/5/17
# Updated lin_filter function and step_3. If these work with R Shiny App, then deprecate and delete
# the previous versions of these functions

#' @description This function filters age-stratified medical events by linear growth or decline over time
#' @param eventM2 cleaned data to filter
#' @param alpha significance value for linear regression; default is 0.1
#' @param m minimum slope to filter by; default is 2/2000, or a change of about 2 people
#' per thousand per year
#'
#' @export


lin_filter2 <- function(eventM2, alpha = 0.1, m = 2/2000)
{
  flt <- eventM2 %>% dplyr::group_by(stratum_1, concept_name, concept_code, decile) %>% dplyr::summarise(max = max(count_value)) %>%
    dplyr::filter(max != 0)

  x <- quantile(flt$max)[[2]] # Take top 75% of items

  flt %<>% dplyr::filter(max >= x)

  mycids <- flt$stratum_1 %>% unique()
  xxx <- eventM2 %>% dplyr::filter(stratum_1 %in% mycids) %>%
    dplyr::group_by(stratum_1, concept_name, concept_code, decile) %>% #dplyr::summarise(max(count_value)) %>%
    dplyr::summarise(slope = as.double(lm(count_value~stratum_2)$coefficients[2]),
                     p.value = as.double(lmp(lm(count_value~stratum_2))))

  # 2. Have slope and p.value for everything. Want to remove all the NaNs
  # NaNs arise bc. these were rows where there wasn't enough data for lm to be meaningful (imputed too many zeros)
  # For data quality assessment purposes, may want to return the stratum_1, decile combos that have NaNs.
  # Don't want to mix NaNs into the full_cids bit, becuase this will throw down-stream problems.

  # Bad are the event-deciles that don't have enough data for lm function to work properly. Return bad
  # for data quality assessment
  bad <- xxx[!complete.cases(xxx),]

  # remove the NAs and continue
  xxx <- xxx[complete.cases(xxx),]
  xxx %<>% dplyr::ungroup()

  # 3. Have slope and p.value for everything cleanly. Want p.vale <= alpha to have classification = 0
  xxx2 <- xxx %>% dplyr::group_by(stratum_1, concept_name, concept_code, decile, p.value, slope) %>%
    dplyr::summarise(score = ifelse(p.value >= alpha, yes = 0, no = 999),
                     classification = ifelse(p.value >= alpha, yes = 'No trend', no = 'Ambiguous trend'))

  # score = 999 is a placeholder and should be replaced.
  # Any lingering 999s will retain the Ambiguous trend label and a score of 0 (this means slope < m = 2/2000 by default)
  xxx2 %<>% dplyr::ungroup()

  # Re-score the rising events
  inc <- xxx2 %>% dplyr::filter(slope > 0)

  inc_m2 <- median(inc$slope) # Filter 2.1
  inc_m3 <- mean(inc$slope) + sd(inc$slope) #Filter 3.1

  xxx2 %<>% dplyr::mutate(score = ifelse(slope > m, 1,0),
                          classification = ifelse(slope > m, "Rising", classification)) #Filter 1

  xxx2 %<>% dplyr::mutate(score = ifelse(slope > inc_m2, 2, score),
                          classification = ifelse(slope > inc_m2, "Strongly Rising", classification)) #Filter 2
  xxx2 %<>% dplyr::mutate(score = ifelse(slope > inc_m3, 3, score),
                          classification = ifelse(slope > inc_m3, "Very Strongly Rising", classification))

  # Re-score decreasing events

  dec <- xxx2 %>% dplyr::filter(slope < 0)

  dec_m2 <- median(dec$slope)
  dec_m3 <- median(dec$slope) - sd(dec$slope)

  xxx2 %<>% dplyr::mutate(score = ifelse(slope < -m, -1,score),
                          classification = ifelse(slope < -m, "Sinking", classification)) #Filter 1

  xxx2 %<>% dplyr::mutate(score = ifelse(slope < dec_m2, -2, score),
                          classification = ifelse(slope < dec_m2, "Strongly Sinking", classification)) #Filter 2

  xxx2 %<>% dplyr::mutate(score = ifelse(slope < dec_m3, -3, score),
                          classification = ifelse(slope < dec_m3, "Very Strongly Sinking", classification)) #Filter 3



  #reduce size of xxx



  lin_list <- list('bad' = bad, 'good' = xxx2)
  return(lin_list)
}


#' @description This funciton creates a "sever data quality problem" folder and write .csv with
# stratum_1, concept_name, deciles for the events in bad. At end, zip this file.
#' @param db will come from higher-level wrapper. The function that calls step_3 will ask for resultsDatabaseSchema;
# each element of resultsDatabaseSchema will be pased to step_3 as db.
#' @export
step_3.2 <- function(eventM2, dataExportFolder, db, output_problematic_events=FALSE)
{
  lin_list <- lin_filter2(eventM2, alpha = 0.1, m = 2/2000)

  if(output_problematic_events){
        # write bad to .csv file in a sub-folder of the user-input dir
        bad <- lin_list$bad

        badDir <- paste0(dataExportFolder, '/', 'Data Problem/')
        if(!dir.exists(badDir)) dir.create(badDir)

        fpath <- paste0(badDir, db, '_bad_event_age_combinations.csv')
        readr::write_csv(bad, fpath)
  }

  good <- lin_list$good
  return(good)
}

#--------------------------------------------------
# Updated September 10, 2017

#' @description Get the deciles affiliated with each classification score and counts how many deciles
#' per medical event gave a particular trend score.
#' @export
summarise_full_cids <- function(full_cids)
{
  xxx <- full_cids %>% dplyr::group_by(stratum_1, concept_name, score, classification) %>%
    dplyr::summarize(count = n(), dec = paste(decile, collapse = ", ")) %>% dplyr::ungroup()
  return(xxx)
}

#' @description Transposes summarise_full_cids output, so that you can see the rising and sinking events as columns.
#' @note No trend column encompases both events where the lin_filter function could not compute a trend and trends
#' that were deemed statistically insignificant by lin_filter; that is, had a p.vale < alpha
#' @export
rollup_2.0 <- function(xxx)
{
  # Get deciles for each score value
  box <- xxx %>% dplyr::select(stratum_1, concept_name) %>% unique()
  #REVIEW
  #for each classification type compute
  for(i in -3:3)
  {
    xxx2 <- xxx %>% dplyr::filter(score == i)
    box %<>% dplyr::left_join(xxx2 %>% dplyr::select(stratum_1, concept_name, dec))
    names(box)[length(box)] = i
  }

  names(box)[-(1:2)] <- c("very strongly sinking", "strongly sinking", "sinking", "no trend",
                          "rising", "strongly rising", "very_strongly_rising")
  return(box)
}

#' @description Return top n medical events with interesting trends overall (both rising and sinking)
#' @param xxx Summarized full_cids
#' @param n Number of events to return
#' @export

skim_rollup_2.0 <- function(xxx, rollup, num = 100)
{
  # Now, I need to know how many deciles are in each score. This part is easy, becuase that information is in xxx$count
  rank <- xxx %>% dplyr::group_by(stratum_1, concept_name) %>% dplyr::summarize(rank = sum(count * abs(score))) %>%
    dplyr::arrange(desc(rank)) %>% head(num)

  out <- dplyr::left_join(rank %>% dplyr::select(stratum_1, concept_name), rollup)
  return(out)
}

#' @description Return top n medical events with most very strongly risking age categories and top n medical events
#' with most very strongly sinking age categories
#' @param xxx Summarized full_cids
#' @param rollup Result of rollup_2.0
#' @param n Number of events to return
#' @export

skim_rollup_1.0 <- function(xxx, rollup, num = 50)
{
  rank <- xxx %>% dplyr::group_by(stratum_1, concept_name) %>% dplyr::summarize(rank = sum(count * (score))) %>%
    dplyr::arrange(desc(rank))

  rising <- rank %>% head(num) %>% dplyr::select(stratum_1, concept_name) %>% dplyr::left_join(rollup)
  sinking <- rank %>% tail(num) %>% dplyr::select(stratum_1, concept_name) %>% dplyr::left_join(rollup)

  out <- rbind(rising, sinking) #%>% dplyr::select(stratum_1, concept_name) %>% unique()
  return(out)

  #out <- dplyr::left_join(events, rollup)
}

#' @name Plot_group_pdf Plots pdf file of group_by events (top 100)
#' @param plot_table1 Top 100 events to plot
#' @param dg Processed data joined to group_by knowledge base
#' @export
#' @param plot_table1
#' @param dg
plot_group_pdf <- function(plot_table1, dg, pdf.name)
{
  acids <- (plot_table1 %>% dplyr::arrange(desc(plot_score)) %>% dplyr::select(ancestor_concept_id) %>%
              unique() %>% unlist() %>% as.integer())
  pdf(pdf.name)
  for(acid in acids)
  {
    OHDSI_shiny_plot_1(dg, acid)
    OHDSI_shiny_plot_2(dg, acid)
    tbl <- gridExtra::tableGrob(dg %>% dplyr::filter(ancestor_concept_id == acid) %>%
                                  dplyr::select(ID = stratum_1, Name = concept_name) %>% unique())
    gridExtra::grid.arrange(tbl)
  }
  dev.off()
}

#' @param dg
#' @param kb2.csv
#' @param analysis_id
#' @param db_schema Both ananonymized and normal should work
#' @param folder Where to put the outputs
#' @export

analyze_grouped_events <- function(full_cids, eventM2, dg, kb2.csv, analysis_id,
                                   db_schema, folder)
{
  kb <- dg %>% dplyr::select(stratum_1, concept_name, ancestor_concept_id, ancestor_concept_name,
                             concept_class_id, concept_code) %>% unique()

  print("joining classification ----------")
  clf_gb <- join_classification_to_kb(full_cids, kb, eventM2) # replace kb with input$kb.csv
  print("done 1")

  print("plot score -------------")
  # print(head(kb))
  # print(head(clf_gb))
  plot_table1 <- OHDSI_shiny_plot_score(clf_gb, kb)

  csv.name <- paste(analysis_id, db_schema, 'grouped_by_concept_ancestor.csv', sep = '_')
  csv.path <- paste0(folder, csv.name)
  readr::write_csv(plot_table1, csv.path)

  print("done 2")

  # print("plotting group_by graphs")
  # pdf.name <- paste(analysis_id, db_schema, 'grouped_by_concept_ancestor.pdf', sep = '_')
  # pdf.path <- paste0(folder, pdf.name)
  #
  # plot_group_pdf(plot_table1, dg, pdf.path)
}
