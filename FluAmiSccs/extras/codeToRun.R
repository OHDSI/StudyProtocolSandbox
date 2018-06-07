# install.packages("S:/Git/Bitbucket/nejm_flu_ami/", repos = NULL, type ="source", dependencies = FALSE)
options(fftempdir = "S:/FFTemp")

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms     = Sys.getenv("dbms"),
  server   = Sys.getenv("server"),
  port     = as.numeric(Sys.getenv("port")),
  user     = NULL,
  password = NULL
)

# PRIMARY DX OUTCOMES, FLU VISIT IP/OP STRATIFIED
outputFolder <- "S:/StudyResults/nejmfluami_primary_dx"

nejmfluami::execute(
  connectionDetails      = connectionDetails,
  cdmDatabaseSchema      = "cdm_truven_ccae_v697.dbo",
  cohortDatabaseSchema   = "Scratch.dbo",
  cohortTable            = "nejm_flu_ami_cohorts_primary_dx_ccae_v697",
  outputFolder           = outputFolder,
  createCohorts          = FALSE,
  runSccs                = FALSE,
  analyzeResults         = FALSE,
  runCm                  = FALSE,
  analyzeCmResults       = FALSE
)

nejmfluami::execute(
  connectionDetails      = connectionDetails,
  cdmDatabaseSchema      = "cdm_truven_mdcr_v698.dbo",
  cohortDatabaseSchema   = "Scratch.dbo",
  cohortTable            = "nejm_flu_ami_cohorts_primary_dx_mdcr_v698",
  outputFolder           = outputFolder,
  createCohorts          = FALSE,
  runSccs                = FALSE,
  analyzeResults         = FALSE,
  runCm                  = FALSE,
  analyzeCmResults       = FALSE
)


