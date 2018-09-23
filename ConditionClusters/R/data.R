#' Included condition concepts
#'
#' A dataset containing the condition concept ids and names for those included
#' in this package
#'
#' @format A data frame with 30652 rows and 2 variables:
#' \describe{
#'   \item{CONDITION_CONCEPT_ID}{The concept id of the condition}
#'   \item{CONCEPT_NAME}{The corresponding name}
#' }
#'
"includedConditions"


#' The top 50 similar condition concepts for each condition concept id
#'
#' A dataset containing the condition concept ids and the top 50 similar condition
#' concept ids
#'
#' @format A data frame with 30652 rows and 2 variables:
#' \describe{
#'   \item{CONCEPT_ID_OI}{The concept id of the condition of interest}
#'   \item{CONDITION_CONCEPT_ID}{The concept id of the similar condition concept}
#'   \item{CONCEPT_NAME}{The corresponding name of the similar condition concept}
#'   \item{CONDITION_CONCEPT_ID}{The number of clusters that the concept of interest has in common with the similar concept}
#' }
#'
"similarityTop50"
