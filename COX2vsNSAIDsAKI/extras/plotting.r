resultFolder<-""
stratPop<-readRDS(file.path(resultFolder,"StratPop_l1_s1_p1_t917_c979_s2_o978.rds"))

CohortMethod::plotKaplanMeier(population = stratPop, confidenceIntervals = TRUE)
CohortMethod::drawAttritionDiagram(stratPop)
CohortMethod::getFollowUpDistribution(population = stratPop)
CohortMethod::plotFollowUpDistribution(population = stratPop, targetLabel ="Cox2 inhibitor", comparatorLabel = "NSAIDs")
CohortMethod::plotKaplanMeier(population = stratPop, targetLabel ="Cox2 inhibitor", comparatorLabel = "NSAIDs", confidenceIntervals = TRUE)