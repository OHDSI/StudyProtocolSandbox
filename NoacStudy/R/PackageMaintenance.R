.formatAndCheckCode <- function() {
  OhdsiRTools::formatRFolder()
  OhdsiRTools::checkUsagePackage("NoacStudy")
}

.createManualAndVignettes <- function() {
  shell("rm extras/NoacStudy")
  shell("R CMD Rd2pdf ./ --output=extras/NoacStudy.pdf")
}

.insertCohortDefinitions <- function() {
  OhdsiRTools::insertCirceDefinitionInPackage(755, "rivaroxaban_prior_diabetes")
  OhdsiRTools::insertCirceDefinitionInPackage(757, "warfarin_prior_diabetes")
}

.createAnalysisDetails <- function() {
  createAnalysesDetails(outputFolder = "inst/settings/")
}
