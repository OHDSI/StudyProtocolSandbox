# Format and check code ---------------------------------------------------

library(devtools)
#install_github("ohdsi/SqlRender")
#install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/OhdsiRTools")
#OhdsiRTools::formatRFolder()
#OhdsiRTools::checkUsagePackage("AlendronateVsRaloxifene")
#OhdsiRTools::updateCopyrightYearFolder()

library(OhdsiRTools)
# Create manual and vignettes ---------------------------------------------
#shell("rm extras/AlendronateVsRaloxifene.pdf")
#shell("R CMD Rd2pdf ./ --output=extras/AlendronateVsRaloxifene.pdf")


# Insert cohort definitions from ATLAS into package -----------------------
OhdsiRTools::insertCohortDefinitionSetInPackage(fileName = "CohortsToCreate.csv",
                                                baseUrl = "http://api.ohdsi.org:80/WebAPI",
                                                insertTableSql = TRUE,
                                                insertCohortCreationR = TRUE,
                                                generateStats = FALSE,
                                                packageName = "CancerTreatments")

# Create analysis details -------------------------------------------------
#connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
#                                                                server = "JRDUSAPSCTL01",user = NULL,password = NULL,port = 17001)
#cdmDatabaseSchema <- "CDM_Truven_MDCD_V521.dbo"
#createAnalysesDetails(connectionDetails, cdmDatabaseSchema, "inst/settings/")


# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("CancerTreatments")
