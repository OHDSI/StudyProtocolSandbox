#' GetSimilarConditions
#'
#' This returns a ranked list of similar conditions for a user input condition concept_id
#'
#' @description
#' This returns a ranked list of similar conditions for a user input condition concept_id
#' @details
#' Users input a condition concept id and get a ranked list lf similar conditions returned
#'
#' @param conditionConceptId               The concept id for the condition you want similar conditions to
#' @param n                The number of similar conditions return (default is 50 - needs to be less than 50)
#' @return
#' A dataframe with the similar condition names, concept ids and similarity measure
#'
#'
#' @export
getSimilarConcepts <- function(conditionConceptId, n=50) {
  if(n>50){
    n <- 50
  }
  ind <- which(conditionConceptId==includedConditions$CONDITION_CONCEPT_ID)
  if(length(ind)==0){
    stop('Input condition concept id not in similarity matrix')
  }
  writeLines(paste0('Finding similar condition concepts for: ',
                    includedConditions$CONCEPT_NAME[includedConditions$CONDITION_CONCEPT_ID==conditionConceptId]))
  result <- data.frame(similarityTop50[similarityTop50$CONCEPT_ID_OI==conditionConceptId,])

  return(result[1:n,])
}



#' getClusterResults
#'
#' This performs the ensemble clustering on your data
#'
#' @description
#' This returns a list containing the individual cluster results, the similarity matrix and the condition concept ids included
#' @details
#' Users input a cdmDatabaseSchema and connectionDetails then the data are extracted from the CDM and clustering performed
#'
#' @param connectionDetails         The connect details to connect to the database
#' @param cdmDatabaseSchema         Thew schema to perform the clustering on
#' @return
#' A list containing the individual cluster results, the similarity matrix and the condition concept ids included
#'
#'
#' @export
getClusterResults <- function(connectionDetails, cdmDatabaseSchema){

conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)
targetDialect <- connectionDetails$dbms

sql <- "select a.condition_concept_id, b.ancestor_concept_id,
count(distinct a.person_id)*1.0/max(a.rn) tot from
(select person_id, condition_concept_id,
min(condition_start_date) condition_start_date,
row_number() over (partition by condition_concept_id order by person_id) rn
from @cdm_database_schema.condition_occurrence
group by person_id, condition_concept_id) a inner join
@cdm_database_schema.drug_exposure c

on a.person_id=c.person_id and
datediff(day, c.drug_exposure_start_date, a.condition_start_date) > -7
and datediff(day, c.drug_exposure_start_date, a.condition_start_date) <=0

inner join @cdm_database_schema.concept_ancestor b
on b.descendant_concept_id = c.drug_concept_id

inner join @cdm_database_schema.concept e
on b.ancestor_concept_id=e.concept_id
and e.CONCEPT_CLASS_ID in ('ATC 1st', 'ATC 2nd',  'ATC 3rd')

group by a.condition_concept_id, b.ancestor_concept_id"

sql <- SqlRender::renderSql(sql, cdm_database_schema=cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql = dql, targetDialect = targetDialect)$sql

test <- DatabaseConnector::querySql(connection = conn, sql)

conditions_ids <- data.frame(CONDITION_CONCEPT_ID = unique(test$CONDITION_CONCEPT_ID),
                             x = 1:length(unique(test$CONDITION_CONCEPT_ID)))
test2 <- merge(test, conditions_ids)
drug_ids <- data.frame(ANCESTOR_CONCEPT_ID = unique(test$ANCESTOR_CONCEPT_ID),
                       y = 1:length(unique(test$ANCESTOR_CONCEPT_ID)))
test2 <- merge(test2, drug_ids)
matrixSparse <- Matrix::sparseMatrix(i = test2$x,
                                     j = test2$y,
                                     x = test2$TOT)
mat2 <- as.matrix(matrixSparse)

sql <- "select concept_id, concept_name from @cdm_database_schema.concept"
sql <- SqlRender::renderSql(sql, cdm_database_schema=cdmDatabaseSchema)$sql
sql <- SqlRender::translateSql(sql = dql, targetDialect = targetDialect)$sql

names <- DatabaseConnector::querySql(connection = conn, sql)

includedConditions <- merge(conditions_ids, names,
                            by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
# Dissimilarity matrix
d <- stats::dist(mat2, method = "euclidean")

# Hierarchical clustering using Complete Linkage
hc1 <- stats::hclust(d, method = "complete" )
clusters <- stats::cutree(hc1, k = 500)
clust_hc_p5k <- merge(cbind(conditions_ids, hc_p5k=clusters), names,
                      by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
clusters <- stats::cutree(hc1, k = 3000)
clust_hc_3k <- merge(cbind(conditions_ids, hc_3k=clusters), names,
                     by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
clusters <- stats::cutree(hc1, k = 1000)
clust_hc_1k <- merge(cbind(conditions_ids, hc_1k=clusters), names,
                     by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')

all_clusters <- merge(clust_hc_p5k[,c(1,4,3)],clust_hc_3k[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')
all_clusters <- merge(all_clusters,clust_hc_1k[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')

clusters <- stats::kmeans(mat2, centers =100, iter.max = 1000)
kmeans100v1 <- merge(cbind(conditions_ids,kmeans100v1=clusters$cluster), names,
                     by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
clusters <- stats::kmeans(mat2, centers =100, iter.max = 1000)
kmeans100v2 <- merge(cbind(conditions_ids,kmeans100v2=clusters$cluster), names,
                     by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
clusters <- stats::kmeans(mat2, centers =100, iter.max = 1000)
kmeans100v3 <- merge(cbind(conditions_ids,kmeans100v3=clusters$cluster), names,
                     by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
clusters <- stats::kmeans(mat2, centers =1000, iter.max = 1000)
kmeans1000 <- merge(cbind(conditions_ids,kmeans1000=clusters$cluster), names,
                    by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
clusters <- stats::kmeans(mat2, centers =3000, iter.max = 1000)
kmeans3000 <- merge(cbind(conditions_ids,kmeans3000=clusters$cluster), names,
                    by.x='CONDITION_CONCEPT_ID', by.y='CONCEPT_ID')
all_clusters <- merge(all_clusters,kmeans100v1[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')
all_clusters <- merge(all_clusters,kmeans100v2[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')
all_clusters <- merge(all_clusters,kmeans100v3[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')
all_clusters <- merge(all_clusters,kmeans1000[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')
all_clusters <- merge(all_clusters,kmeans3000[,c(1,3)],
                      by='CONDITION_CONCEPT_ID')

sim <- sapply(1:nrow(all_clusters),
              function(i) sum(all_clusters[5,3:10]==all_clusters[i,3:10]))

return(list(individualClusters = all_clusters,
            similarityMatrix = sim,
            includedConditions = includedConditions))

}
