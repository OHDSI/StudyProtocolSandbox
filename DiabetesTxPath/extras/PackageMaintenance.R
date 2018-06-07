# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of DiabetesTxPath
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
OhdsiRTools::checkUsagePackage("DiabetesTxPath")
OhdsiRTools::updateCopyrightYearFolder()


# Create manual and vignettes ---------------------------------------------
shell("rm extras/DiabetesTxPath.pdf")
shell("R CMD Rd2pdf ./ --output=extras/DiabetesTxPath.pdf")


# Insert cohort definitions from ATLAS into package -----------------------
pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "DiabetesTxPath")
cohortsToCreate <- read.csv(pathToCsv)
for (i in 1:nrow(cohortsToCreate)) {
  writeLines(paste("Inserting cohort:", as.character(cohortsToCreate$name[i]), sep = ""))
  OhdsiRTools::insertCohortDefinitionInPackage(cohortsToCreate$atlasId[i],
                                               cohortsToCreate$name[i],
                                               "http://api.ohdsi.org/WebAPI")
}


