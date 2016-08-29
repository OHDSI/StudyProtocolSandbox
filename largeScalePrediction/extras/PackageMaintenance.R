# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of PopEstT2Dm
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

# Format and check code
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("SomeBySomePrediction")

# Create manual
shell("rm extras/SomeBySomePrediction.pdf")
shell("R CMD Rd2pdf ./ --output=extras/SomeBySomePrediction.pdf")


#Import the 'at risk' definition:
writeLines(paste0("Inserting at risk cohort "))
OhdsiRTools::insertCirceDefinitionInPackage(2788, "PTD",
                                            baseUrl = "http://hix.jnj.com:8080/WebAPI")


# Import outcome definitions
pathToCsv <- system.file("settings", "OutcomesOfInterest.csv", package = "SomeBySomePrediction")
outcomes <- read.csv(pathToCsv)
for (i in 1:nrow(outcomes)) {
    writeLines(paste0("Inserting HOI: ", outcomes$name[i]))
    OhdsiRTools::insertCirceDefinitionInPackage(outcomes$cohortDefinitionId[i], outcomes$name[i],
                                                baseUrl = "http://hix.jnj.com:8080/WebAPI")
}
