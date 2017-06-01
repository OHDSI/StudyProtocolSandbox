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

#' @export
createIcd9CovariateSettings <- function(covariateDefs, windowStart = -365, windowEnd = -1) {
  covariateSettings <- list(covariateDefs = covariateDefs,
                            windowStart = windowStart,
                            windowEnd = windowEnd)
  attr(covariateSettings, "fun") <- "getDbIcd9CovariateData"
  class(covariateSettings) <- "covariateSettings"
  return(covariateSettings)
}

#' @export
getDbIcd9CovariateData <- function(connection,
                                   oracleTempSchema = NULL,
                                   cdmDatabaseSchema,
                                   cdmVersion = "5",
                                   cohortTempTable = "cohort_person",
                                   rowIdField = "subject_id",
                                   covariateSettings) {
  # Temp table names must start with a '#' in SQL Server, our source dialect:
  if (substr(cohortTempTable, 1, 1) != "#") {
    cohortTempTable <- paste("#", cohortTempTable, sep = "")
  }
  sql <- "CREATE TABLE #covar_defs (concept_id INT, covariate_id INT)"
  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)

  for (i in 1:nrow(covariateSettings$covariateDefs)) {
    sql <- SqlRender::loadRenderTranslateSql("icd9ToConcepts.sql",
                                             packageName = "EvaluatingCaseControl",
                                             dbms = attr(connection, "dbms"),
                                             oracleTempSchema = oracleTempSchema,
                                             covariate_id = covariateSettings$covariateDefs$covariateId[i],
                                             icd9 = covariateSettings$covariateDefs$icd9[i],
                                             cdm_database_schema = cdmDatabaseSchema)
    DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)
  }
  sql <- SqlRender::loadRenderTranslateSql("getIcd9Covariates.sql",
                                           packageName = "EvaluatingCaseControl",
                                           dbms = attr(connection, "dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           window_start = covariateSettings$windowStart,
                                           window_end = covariateSettings$windowEnd,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           row_id_field = rowIdField,
                                           cohort_temp_table = cohortTempTable)
  covariates <- DatabaseConnector::querySql.ffdf(connection, sql)
  colnames(covariates) <- SqlRender::snakeCaseToCamelCase(colnames(covariates))
  sql <- "TRUNCATE TABLE #covar_defs; DROP TABLE #covar_defs;"
  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)
  covariateRef <- unique(covariateSettings$covariateDefs[, c("covariateId","covariateName")])
  covariateRef$covariateId <- as.numeric(covariateRef$covariateId)
  covariateRef$covariateName <- as.factor(covariateRef$covariateName)
  covariateRef$analysisId <- 1
  covariateRef$conceptId <- 0
  covariateRef <- ff::as.ffdf(covariateRef)
  metaData <- list(call = match.call())
  result <- list(covariates = covariates,
                 covariateRef = covariateRef,
                 metaData = metaData)
  class(result) <- "covariateData"
  return(result)
}
