# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of PneumoniaRiskOfPPI.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("PneumoniaRiskOfPPI")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/PneumoniaRiskOfPPI.pdf")
shell("R CMD Rd2pdf ./ --output=extras/PneumoniaRiskOfPPI.pdf")

# Create vignette ---------------------------------------------------------
rmarkdown::render("vignettes/UsingSkeletonPackage.Rmd",
                  output_file = "../inst/doc/UsingPneumoniaRiskOfPPI..pdf",
                  rmarkdown::pdf_document(latex_engine = "pdflatex",
                                          toc = TRUE,
                                          number_sections = TRUE))

# Insert cohort definitions from ATLAS into package -----------------------
OhdsiRTools::insertCohortDefinitionSetInPackage(fileName = "CohortsToCreate.csv",
                                                baseUrl = Sys.getenv("baseUrl"),
                                                insertTableSql = TRUE,
                                                insertCohortCreationR = TRUE,
                                                generateStats = FALSE,
                                                packageName = "PneumoniaRiskOfPPI")

# Create analysis details -------------------------------------------------
source("extras/CreateStudyAnalysisDetails.R")
createAnalysesDetails("inst/settings/")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("PneumoniaRiskOfPPI")
