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

Obtain a CohortMethodData object. Calls functions in CohortMethod.
Currently uses single studies vignette as an example.

    library(PropensityScoreEvaluation)
    connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                                 user = "joe",
                                                 password = "secret",
                                                 server = "myserver")

    file = "inst/sql/sql_server/coxibVsNonselVsGiBleed.sql"
    exposureTable = "coxibVsNonselVsGiBleed"
    outcomeTable = "coxibVsNonselVsGiBleed"
    cdmVersion <- "4"
    cdmDatabaseSchema <- "my_schema"
    resultsDatabaseSchema <- "my_results"

    # use HDPS covariates or regular FeatureExtraction covariates
    hdpsCovariates = TRUE

    cohortMethodData <- createCohortMethodData(connectionDetails = connectionDetails,
                                               file = file,
                                               exposureTable = exposureTable,
                                               outcomeTable = outcomeTable,
                                               cdmVersion = cdmVersion,
                                               cdmDatabaseSchema = cdmDatabaseSchema,
                                               resultsDatabaseSchema = resultsDatabaseSchema,
                                               hdpsCovariates = hdpsCovariates)

Create study population and simulation profile

    # for testing purposes can turn off cross-validation to get things running faster in 
    # createCMDSimulationProfileand runSimulationStudy by setting crossValidate = FALSE

    studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
                                      outcomeId = 3,
                                      firstExposureOnly = FALSE,
                                      washoutPeriod = 0,
                                      removeDuplicateSubjects = FALSE,
                                      removeSubjectsWithPriorOutcome = TRUE,
                                      minDaysAtRisk = 1,
                                      riskWindowStart = 0,
                                      addExposureDaysToStart = FALSE,
                                      riskWindowEnd = 30,
                                      addExposureDaysToEnd = TRUE)

    simulationProfile <- createCMDSimulationProfile(cohortMethodData, studyPop)

Run the simulation for given specifications (TO DO create list of
speficiations and automate)

    options("fffinalizer" = "delete")

    # Default runs is n = 10; can be changed
    # Currently matching 1-1 on propensity score (strata = matchOnPs(ps))

    # Vanilla parameters: no unmeasured confounding, no replacing observed effect size, no replacing outcome prevalence
    simulationStudy <- runSimulationStudy(simulationProfile, studyPop, hdpsFeatures = hdpsCovariates)

    # Specify effect size
    simulationStudy <- runSimulationStudy(simulationProfile, studyPop, hdpsFeatures = hdpsCovariates, trueEffectSize = 1.0)

    # Specify outcome prevalence
    simulationStudy <- runSimulationStudy(simulationProfile, studyPop, hdpsFeatures = hdpsCovariates, outcomePrevalence = .05)

    # Remove demographics to simulate unmeasured confounding in propensity score
    simulationStudy <- runSimulationStudy(simulationProfile, studyPop, hdpsFeatures = hdpsCovariates, confoundingScheme = 1)

    # Remove random covariates to simulate unmeasured confounding in propensity score; here removes 25%
    simulationStudy <- runSimulationStudy(simulationProfile, studyPop, hdpsFeatures = hdpsCovariates, confoundingScheme = 2, confoundingProportion = 0.25)

    options("fffinalizer" = NULL)

Look at results

    # View true effect size used in simulation
    trueEffectSize <- simulationStudy$trueEffectSize

    # View estimates generated via different propensity scores
    logRRLasso <- simulationStudy$estimatesLasso$logRr
    logRRExposure <- simulationStudy$estimatesExpHdps$logRr
    logRRBias <- simulationStudy$estimatesBiasHdps$logRr
    mean(logRRLasso)
    sd(logRRLasso)
    mean(logRRExposure)
    sd(logRRExposure)
    mean(logRRBias)
    sd(logRRBias)

    # View auc
    aucLasso <- simulationStudy$aucLasso
    aucExpHdps <- simulationStudy$aucExpHdps
    aucBiasHdps <- simulationStudy$aucBiasHdps

    # View propensity scores for each method
    psLasso <- simulationStudy$psLasso
    psExp <- simulationStudy$psExp
    psBias <- simulationStudy$psBias

    # Do things with the propensity scores to assess balance
    strataLasso <- matchOnPs(psLasso)
    balance <- computeCovariateBalance(strataLasso, cohortMethodData)
