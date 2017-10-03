# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of EvaluatingCaseControl
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

# Format and check code ----
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("EvaluatingCaseControl")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual and vignette ----
shell("EvaluatingCaseControl.pdf")
shell("R CMD Rd2pdf ./ --output=extras/EvaluatingCaseControl.pdf")

# Insert cohort definitions into package ----
OhdsiRTools::insertCohortDefinitionSetInPackage("CohortsToCreate.csv",
                                                generateStats = FALSE,
                                                packageName = "EvaluatingCaseControl")

# Create analysis details ----
createCaseControlAnalysesDetails("inst/settings/")
createCohortMethodAnalysesDetails("inst/settings/")
createCaseTimeControlAnalysesDetails("inst/settings/")

# Store environment in which the study was executed ----
OhdsiRTools::insertEnvironmentSnapshotInPackage("EvaluatingCaseControl")



