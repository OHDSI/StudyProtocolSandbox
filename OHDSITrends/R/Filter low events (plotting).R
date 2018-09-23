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
