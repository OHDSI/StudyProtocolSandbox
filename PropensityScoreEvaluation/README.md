Propensity Score Method Evaluation [UNDER DEVELOPMENT]
=======================================================

This study will evaluate the performance of different propensity score
methods.
```{r}
install.packages("devtools")
library(devtools)
install_github("OHDSI/OhdsiRTools")
install_github("OHDSI/SqlRender")
install_github("OHDSI/DatabaseConnector")
install_github("OHDSI/Cyclops", ref="HDPS")
install_github("OHDSI/FeatureExtraction")
install_github("OHDSI/CohortMethod", ref = "hdps_clean")
install_github("OHDSI/StudyProtocolSandox/PropensityScoreEvaluation")
```

<<<<<<< HEAD
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
=======
Now do some stuff. Using CohortMethod single studies vignette as an
example.
```{r}
library(PropensityScoreEvaluation)
connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                             user = "joe",
                                             password = "secret",
                                             server = "myserver")

file <- "inst/sql/sql_server/coxibVsNonselVsGiBleed.sql"
exposureTable <- "coxibVsNonselVsGiBleed"
outcomeTable <- "coxibVsNonselVsGiBleed"
cdmVersion <- "4"
cdmDatabaseSchema <- "cdm4_sim"
resultsDatabaseSchema <- "my_results"
hdpsCovariates <- TRUE
>>>>>>> a459ae87702e9e83bce523cf9457692e179e14cb

cohortMethodData <- createCohortMethodData(connectionDetails = connectionDetails,
                                           file = file,
                                           exposureTable = exposureTable,
                                           outcomeTable = outcomeTable,
                                           cdmVersion = cdmVersion,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           hdpsCovariates = hdpsCovariates)
```          

<<<<<<< HEAD
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

    simulationProfile = createCMDSimulationProfile(cohortMethodData, studyPop)

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
=======
Run simulation
```{r}
simulationStudy <- runSimulationStudy(cohortMethodData, hdpsFeatures = TRUE, outcomePrevalence = 0.05)
```
>>>>>>> a459ae87702e9e83bce523cf9457692e179e14cb

Look at results
```{r}
# View coefficients used in true outcome model
trueOutcomeModel <- simulationStudy$trueOutcomeModel

<<<<<<< HEAD
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
=======
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
>>>>>>> a459ae87702e9e83bce523cf9457692e179e14cb

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
```
