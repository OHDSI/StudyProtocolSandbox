.formatAndCheckCode <- function() {
  OhdsiRTools::formatRFolder()
  OhdsiRTools::checkUsagePackage("Rivaroxaban")
}

.createManualAndVignettes <- function() {
  shell("rm extras/Rivaroxaban")
  shell("R CMD Rd2pdf ./ --output=extras/Rivaroxaban.pdf")
}

.insertCohortDefinitions <- function() {
  OhdsiRTools::insertCirceDefinitionInPackage(755, "rivaroxaban_prior_diabetes")
  OhdsiRTools::insertCirceDefinitionInPackage(757, "warfarin_prior_diabetes")
}

.createAnalysisDetails <- function() {
  createAnalysesDetails(outputFolder = "inst/settings/")
}
