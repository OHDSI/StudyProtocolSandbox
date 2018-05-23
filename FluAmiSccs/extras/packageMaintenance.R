OhdsiRTools::insertCohortDefinitionSetInPackage(
  fileName              = "CohortsToCreate.csv",
  baseUrl               = "https://epi.jnj.com:8443/WebAPI",
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


