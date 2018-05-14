# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of TofaRep
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
OhdsiRTools::checkUsagePackage("TofaRep")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/TofaRep.pdf")
shell("R CMD Rd2pdf ./ --output=extras/TofaRep.pdf")

# Create vignette ---------------------------------------------------------
rmarkdown::render("vignettes/TofaRep.Rmd",
                  output_file = "../inst/doc/using_TofaRep.pdf",
                  rmarkdown::pdf_document(latex_engine = "pdflatex",
                                          toc = TRUE,
                                          number_sections = TRUE))

# Insert cohort definitions from ATLAS into package -----------------------
OhdsiRTools::insertCohortDefinitionSetInPackage(fileName = "CohortsToCreate.csv",
                                                baseUrl = Sys.getenv("baseUrl"),
                                                insertTableSql = TRUE,
                                                insertCohortCreationR = TRUE,
                                                generateStats = FALSE,
                                                packageName = "TofaRep")

# Hack: We want to use the same negative controls for each target-comparator combination. Automatically generate file
ncs <- read.csv("extras/NegativeControls.csv")
tcos <- read.csv("inst/settings/tcosOfInterest.csv")
tcs <- unique(tcos[, c("targetId", "targetName", "comparatorId", "comparatorName")])
ncs <- merge(tcs, ncs)
write.csv(ncs, "inst/settings/NegativeControls.csv", row.names = FALSE)
  
# Create analysis details -------------------------------------------------
source("extras/CreateStudyAnalysisDetails.R")
createAnalysesDetails("inst/settings/")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("TofaRep")

# Build source package ----------------------------------------------------
name <- list.files(path = "extras", pattern = ".*.tar.gz", full.names = TRUE)
unlink(name)
shell("R CMD build ../TofaRep")
name <- list.files(pattern = ".*.tar.gz")
file.rename(name, file.path("extras", name))
