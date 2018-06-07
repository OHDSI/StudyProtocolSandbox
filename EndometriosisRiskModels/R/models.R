#' Details of the 16 models
#'
#' A dataset containing the information (target cohort, outcome cohort, development database and model name)
#' for the 16 models
#'
#' @format A data frame with 16 rows and 5 variables:
#' \describe{
#'   \item{modelLocation}{The location of the model in the packake}
#'   \item{targetCohort}{The target cohort used to develop the model}
#'   \item{outcomeCohort}{The outcome cohort used to develop the model}
#'   \item{database}{The database used to develop the model}
#'   \item{internalAUC}{The AUC on the test set}
#' }
"models"
