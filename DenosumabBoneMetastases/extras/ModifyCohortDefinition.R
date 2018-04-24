insertModifiedCohortDefinitionInPackage <- function(definitionId,
                                                    name = NULL,
                                                    baseUrl,
                                                    inclusionRulesToDrop) {
  ### Fetch JSON object ###
  url <- paste(baseUrl, "cohortdefinition", definitionId, sep = "/")
  json <- httr::GET(url)
  json <- httr::content(json)
  if (is.null(name)) {
    name <- json$name
  }
  parsedExpression <- RJSONIO::fromJSON(json$expression)
  
  # Drop selected inclusion rules
  writeLines(sprintf("Modifying cohort '%s'", json$name ))
  inclusionRulesToDrop <- inclusionRulesToDrop[order(-inclusionRulesToDrop)]
  for (i in inclusionRulesToDrop) {
    rule <- parsedExpression$InclusionRules[[i]]
    writeLines(sprintf("- Dropping rule '%s'", rule$name))
    parsedExpression$InclusionRules[[i]] <- NULL
  }
  json <- RJSONIO::toJSON(parsedExpression)
  
  # Write JSON to file
  if (!file.exists("inst/cohorts")) {
    dir.create("inst/cohorts", recursive = TRUE)
  }
  fileConn <- file(file.path("inst/cohorts", paste(name, "json", sep = ".")))
  writeLines(json, fileConn)
  close(fileConn)
  
  ### Fetch SQL by posting JSON object ###
  jsonBody <- RJSONIO::toJSON(list(expression = parsedExpression), digits = 23)
  httpheader <- c(Accept = "application/json; charset=UTF-8", `Content-Type` = "application/json")
  url <- paste(baseUrl, "cohortdefinition", "sql", sep = "/")
  cohortSqlJson <- httr::POST(url, body = jsonBody, config = httr::add_headers(httpheader))
  cohortSqlJson <- httr::content(cohortSqlJson)
  sql <- cohortSqlJson$templateSql
  if (!file.exists("inst/sql/sql_server")) {
    dir.create("inst/sql/sql_server", recursive = TRUE)
  }
  
  # Write SQL to file
  fileConn <- file(file.path("inst/sql/sql_server", paste(name, "sql", sep = ".")))
  writeLines(sql, fileConn)
  close(fileConn)
}