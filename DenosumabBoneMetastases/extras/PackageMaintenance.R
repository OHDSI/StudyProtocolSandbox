# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of DenosumabBoneMetastases
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
OhdsiRTools::checkUsagePackage("DenosumabBoneMetastases")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/DenosumabBoneMetastases.pdf")
shell("R CMD Rd2pdf ./ --output=extras/DenosumabBoneMetastases.pdf")

# Insert cohort definitions from ATLAS into package -----------------------
OhdsiRTools::insertCohortDefinitionSetInPackage(fileName = "CohortsToCreate.csv",
                                                baseUrl = Sys.getenv("baseUrl"),
                                                insertTableSql = TRUE,
                                                insertCohortCreationR = TRUE,
                                                generateStats = FALSE,
                                                packageName = "DenosumabBoneMetastases")

# Hack: create new cohort definitions by dropping inclusion criteria:
source("extras/ModifyCohortDefinition.R")
insertModifiedCohortDefinitionInPackage(definitionId = 5652, 
                                        name = "DenosumabProstateCancerBroad1", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(8))
insertModifiedCohortDefinitionInPackage(definitionId = 5652, 
                                        name = "DenosumabProstateCancerBroad2", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(7, 8))
insertModifiedCohortDefinitionInPackage(definitionId = 5652, 
                                        name = "DenosumabProstateCancerBroad3", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(6, 7, 8))
insertModifiedCohortDefinitionInPackage(definitionId = 5652, 
                                        name = "DenosumabProstateCancerBroad4", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(5, 6, 7, 8))

insertModifiedCohortDefinitionInPackage(definitionId = 5665, 
                                        name = "ZoledronicAcidProstateCancerBroad1", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(8))
insertModifiedCohortDefinitionInPackage(definitionId = 5665, 
                                        name = "ZoledronicAcidProstateCancerBroad2", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(7, 8))
insertModifiedCohortDefinitionInPackage(definitionId = 5665, 
                                        name = "ZoledronicAcidProstateCancerBroad3", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(6, 7, 8))
insertModifiedCohortDefinitionInPackage(definitionId = 5665, 
                                        name = "ZoledronicAcidProstateCancerBroad4", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(5, 6, 7, 8))

insertModifiedCohortDefinitionInPackage(definitionId = 5847, 
                                        name = "DenosumabBreastCancerBroad1", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(6))
insertModifiedCohortDefinitionInPackage(definitionId = 5847, 
                                        name = "DenosumabBreastCancerBroad2", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(5, 6))

insertModifiedCohortDefinitionInPackage(definitionId = 5848, 
                                        name = "ZoledronicAcidBreastCancerBroad1", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(6))
insertModifiedCohortDefinitionInPackage(definitionId = 5848, 
                                        name = "ZoledronicAcidBreastCancerBroad2", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(5, 6))

insertModifiedCohortDefinitionInPackage(definitionId = 5866, 
                                        name = "DenosumabOtherCancerBroad1", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(6))
insertModifiedCohortDefinitionInPackage(definitionId = 5867, 
                                        name = "ZoledronicAcidOtherCancerBroad1", 
                                        baseUrl = Sys.getenv("baseUrl"), 
                                        inclusionRulesToDrop = c(6))

# Another hack: negative controls are valid for all TCs of interest. Automatically create union:
tcosOfInterest <- read.csv("inst/settings/TcosOfInterest.csv")
ncOutcomes <- read.csv("extras/NegativeControlOutcomes.csv")
ncs <- merge(tcosOfInterest[, c("targetId", "targetName", "comparatorId", "comparatorName")], ncOutcomes)
ncs$type <- "Outcome"
write.csv(ncs, "inst/settings/NegativeControls.csv", row.names = FALSE)

# Create analysis details -------------------------------------------------
source("R/CreateStudyAnalysisDetails.R")
createAnalysesDetails("inst/settings/")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("DenosumabBoneMetastases")
