Propensity Score Method Evaluation [UNDER DEVELOPMENT]
=======================================================

This study will evaluate the performance of different propensity score
methods.

    install.packages("devtools")
    library(devtools)
    install_github("ohdsi/OhdsiRTools")
    install_github("ohdsi/SqlRender")
    install_github("ohdsi/DatabaseConnector")
    install_github("ohdsi/Cyclops", ref="HDPS")
    install_github("ohdsi/FeatureExtraction")
    install_github("ohdsi/CohortMethod", ref = "hdps_clean")

Now do some stuff. Using CohortMethod single studies vignette as an
example.

    library(PropensityScoreEvaluation)
    connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                                 user = "joe",
                                                 password = "secret",
                                                 server = "myserver")

    file = "inst/sql/sql_server/coxibVsNonselVsGiBleed.sql"
    exposureTable = "coxibVsNonselVsGiBleed"
    outcomeTable = "coxibVsNonselVsGiBleed"
    cdmVersion <- "4"
    cdmDatabaseSchema <- "cdm4_sim"
    resultsDatabaseSchema <- "my_results"
    hdpsCovariates = TRUE

    cohortMethodData <- createCohortMethodData(connectionDetails = connectionDetails,
                                               file = file,
                                               exposureTable = exposureTable,
                                               outcomeTable = outcomeTable,
                                               cdmVersion = cdmVersion,
                                               cdmDatabaseSchema = cdmDatabaseSchema,
                                               resultsDatabaseSchema = resultsDatabaseSchema,
                                               hdpsCovariates = hdpsCovariates)

Run simulation

    options("fffinalizer" = "delete")
    simulationStudy <- runSimulationStudy(cohortMethodData, hdpsFeatures = TRUE, outcomePrevalence = 0.05)
    options("fffinalizer" = NULL)

Look at results

    # View coefficients used in true outcome model
    trueOutcomeModel = simulationStudy$trueOutcomeModel

    # View true effect size used in simulation
    trueEffectSize = simulationStudy$trueEffectSize

    # View estimates generated via different propensity scores
    logRRLasso = simulationStudy$estimatesLasso$logRr
    logRRExposure = simulationStudy$estimatesExpHdps$logRr
    logRRBias = simulationStudy$estimatesBiasHdps$logRr
    mean(logRRLasso)
    sd(logRRLasso)
    mean(logRRExposure)
    sd(logRRExposure)
    mean(logRRBias)
    sd(logRRBias)

    # View auc
    aucLasso = simulationStudy$aucLasso
    aucExpHdps = simulationStudy$aucExpHdps
    aucBiasHdps = simulationStudy$aucBiasHdps

    # View propensity scores for each method
    psLasso = simulationStudy$psLasso
    psExp = simulationStudy$psExp
    psBias = simulationStudy$psBias

    # Do things with the propensity scores to assess balance
    strataLasso = matchOnPs(psLasso)
    balance = computeCovariateBalance(strataLasso, cohortMethodData)
