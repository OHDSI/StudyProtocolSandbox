OhdsiRTools::insertCohortDefinitionSetInPackage(
  fileName              = "CohortsToCreate.csv",
  baseUrl               = Sys.getenv("baseUrl"),
  insertTableSql        = TRUE,
  insertCohortCreationR = TRUE,
  generateStats         = FALSE,
  packageName           = "nejmfluami"
)
# rebuild to load settings

nejmfluami::createSettings("inst/settings")
# rebuild to load settings

nejmfluami::createCmSettings("inst/settings")
# rebuild to load settings


