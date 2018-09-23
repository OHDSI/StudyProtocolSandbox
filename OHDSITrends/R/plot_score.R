filter_by_plot_score4 <- function(clf_gb)
{
  events_per_ancestor <- kb %>% dplyr::group_by(ancestor_concept_id, ancestor_concept_name,
                                                concept_class_id, concept_code) %>%
    dplyr::summarise(event_count = n())

  clf_gb %<>% dplyr::left_join(events_per_ancestor)
  clf_gb %<>% dplyr::filter(p.value < 0.05)

  foo <- clf_gb %>% dplyr:::group_by(ancestor_concept_id, ancestor_concept_name, concept_class_id,
                                     concept_code, event_count) %>%
    dplyr::summarise(score_sum = sum(score2), plot_sum = sum(abs(slope)*score2))

  foo$pre_plot_score = foo$plot_sum/foo$event_count
  foo$score_score = foo$score_sum/foo$event_count

  #some events have a crazy high slope; they're boring events, so we want to remove
  # Remove these 6 sigma events that have only 2 drugs
  sigma <- sd(foo$pre_plot_score)
  foobar <- mean(foo$pre_plot_score)
  foo %<>% dplyr::filter(pre_plot_score < foobar + 5*sigma)

  foo$plot_score = foo$pre_plot_score + foo$score_score
  foo %<>% dplyr::filter(event_count > 1)

  plot_concepts <- foo %>% dplyr::arrange(dplyr::desc(plot_score)) %>% head(100)
  acids <- plot_concepts$ancestor_concept_id %>% unique()
  return(acids)
}


filter_by_plot_score3 <- function(clf_gb)
{
  events_per_ancestor <- kb %>% dplyr::group_by(ancestor_concept_id, ancestor_concept_name,
                                                concept_class_id, concept_code) %>%
    dplyr::summarise(event_count = n())

  clf_gb %<>% dplyr::left_join(events_per_ancestor)
  clf_gb %<>% dplyr::filter(p.value < 0.05)

  foo <- clf_gb %>% dplyr:::group_by(ancestor_concept_id, ancestor_concept_name, concept_class_id,
                                     concept_code, event_count) %>%
    dplyr::summarise(plot_sum = sum(score2))

  foo$plot_score = foo$plot_sum
  foo %<>% dplyr::filter(event_count > 1)

  plot_concepts <- foo %>% dplyr::arrange(dplyr::desc(plot_score)) %>% head(100)
  acids <- plot_concepts$ancestor_concept_id %>% unique()
  return(acids)
}

filter_by_plot_score2 <- function(clf_gb)
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
  foo %<>% dplyr::filter(event_count > 1)

  plot_concepts <- foo %>% dplyr::arrange(dplyr::desc(plot_score)) %>% head(100)
  acids <- plot_concepts$ancestor_concept_id %>% unique()
  return(acids)
}



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

# sub functions
# join_classification_to_kb <- function(clf, kb)
# {
#   clf_gb <- dplyr::left_join(kb, clf)
#   if(any(is.na(clf_gb$decile)))
#   {
#     print('NAs introduced.')
#     xxx <- clf_gb %>% dplyr::filter(is.na(decile)) %>% dplyr::select(stratum_1) %>% unique()
#     if(!any(eventM2$stratum_1 %in% xxx))
#     {
#       print('None of the events with NAs have data, and can be removed.')
#       print('Removing these data-less events')
#       clf_gb <- clf_gb[complete.cases(clf_gb),]
#     }
#     else cat('****************\nSome of the events with NAs have data. There is a problem with KB and Data.\nSTOP AND FIX !\n****************')
#     return(clf_gb)
#   }
# }

