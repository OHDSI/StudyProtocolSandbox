# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of PopEstMethodEvaluation
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

#' @export
createNestingCohorts <- function(connectionDetails,
                                 cdmDatabaseSchema,
                                 oracleTempSchema = NULL,
                                 nestingCohortDatabaseSchema = cdmDatabaseSchema,
                                 nestingCohortTable = "condition_era",
                                 workFolder,
                                 cdmVersion = "5",
                                 createBaselineCohorts = TRUE) {
    connection <- DatabaseConnector::connect(connectionDetails)
    sql <- SqlRender::loadRenderTranslateSql("CreateCohortTable.sql",
                                             packageName = "PopEstMethodEvaluation",
                                             dbms = connectionDetails$dbms,
                                             cohort_database_schema = nestingCohortDatabaseSchema,
                                             cohort_table = nestingCohortTable,
                                             cdm_version = cdmVersion)
    DatabaseConnector::executeSql(connection, sql)

    sql <- SqlRender::loadRenderTranslateSql("Osteoarthritis.sql",
                                             packageName = "PopEstMethodEvaluation",
                                             dbms = connectionDetails$dbms,
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             target_database_schema = nestingCohortDatabaseSchema,
                                             target_cohort_table = nestingCohortTable,
                                             target_cohort_id = 80180)
    if (cdmVersion == "4"){
        sql <- gsub("cohort_definition_id", "cohort_concept_id", sql)
        sql <- gsub("visit_concept_id", "place_of_service_concept_id", sql)
    }

    DatabaseConnector::executeSql(connection, sql)
    RJDBC::dbDisconnect(connection)
    invisible(TRUE)
}
