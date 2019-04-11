# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of ConceptPrevalence package
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

#' Calculates the counts of standard and source concepts
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmName The name of the CDM
#' @param cdmDatabaseSchema  The schema holding the CDM data
#' @param vocabDatabaseSchema The schema holding the OMOP Vocabularies
#' @param resultDatabaseSchema The schema with the writing access
#' @param target_database_schema The schema with the writing access
#' @export


calculate <- function(
  connectionDetails,
  cdmName,
  cdmDatabaseSchema,
  vocabDatabaseSchema,
  resultDatabaseSchema)
 {
  connection <- DatabaseConnector::connect(connectionDetails)
 sql <- SqlRender::loadRenderTranslateSql("ConceptPrevalence.sql",
                                         "ConceptPrevalence",
                                         dbms = connectionDetails$dbms,
                                         cdm_database_schema = cdmDatabaseSchema,
                                         vocabulary_database_schema = vocabDatabaseSchema,
                                         target_database_schema = resultDatabaseSchema,
                                         cdm_name = cdmName
                                                           )

  DatabaseConnector::executeSql(connection, sql)

  sql <- SqlRender::render("SELECT * FROM @target_database_schema.count_standard;", target_database_schema = resultDatabaseSchema)
  standard <- DatabaseConnector::querySql(connection, sql)

  sql <- SqlRender::render("SELECT * FROM @target_database_schema.count_source;", target_database_schema = resultDatabaseSchema)
  source <- DatabaseConnector::querySql(connection, sql)

  sql <- SqlRender::render("SELECT * FROM @target_database_schema.mappings;", target_database_schema = resultDatabaseSchema)
  mappings <- DatabaseConnector::querySql(connection, sql)

  sql <- SqlRender::render("SELECT * FROM @target_database_schema.cdm_vocab_version;", target_database_schema = resultDatabaseSchema)
  vocab_version <- DatabaseConnector::querySql(connection, sql)

  sql <- SqlRender::render("SELECT * FROM @target_database_schema.cdm;", target_database_schema = resultDatabaseSchema)
  cdm_info <- DatabaseConnector::querySql(connection, sql)

  write.table(standard, file = file.path(getwd(), "count_standard.csv"), row.names = FALSE, sep = ",")
  write.table(source, file = file.path(getwd(), "count_source.csv"), row.names = FALSE, sep = ",")
  write.table(mappings, file = file.path(getwd(), "mappings.csv"), row.names = FALSE, sep = ",")
  write.table(vocab_version, file = file.path(getwd(), "vocab_version.csv"), row.names = FALSE, sep = ",")
  write.table(cdm_info, file = file.path(getwd(), "cdm_info.csv"), row.names = FALSE, sep = ",")
  DatabaseConnector::disconnect(connection)
}
