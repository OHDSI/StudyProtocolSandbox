Propensity Score Method Evaluation [UNDER DEVELOPMENT]
=======================================================

This study will evaluate the performance of different propensity score
methods.

```{r}
install.packages("devtools")
library(devtools)
install_github("ohdsi/OhdsiRTools")
install_github("ohdsi/SqlRender")
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/Cyclops", ref="HDPS")
install_github("ohdsi/FeatureExtraction")
install_github("ohdsi/CohortMethod", ref = "hdps_clean")
```

Obtain a CohortMethodData object. Calls functions in CohortMethod.
Currently uses single studies vignette as an example.

```{r}
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
```
Create study population and simulation profile

```{r}
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
```

We can save and load this simulation profile. If we load the simulation profile, we can re-create a studyPop using cohortMethodData = simulationProfile$partialCMD. The parameters should be the same as those that went into the studyPop that we created the simulationProfile with.

```{r}
saveSimulationProfile(simulationProfile, file = file)

simulationProfile <- loadSimulationProfile(file = file)
```

Run the simulation for given specifications

```{r}
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

```

Look at results

```{r}
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

# View propensity scores 
ps <- simulationStudy$ps

# Do things with the propensity scores to assess balance
strataLasso <- matchOnPs(psLasso)
balance <- computeCovariateBalance(strataLasso, simulationProfile$partialCMD)

# View several of these metrics together, including coverage of true value by logRr confidence interval, and proportion of std diff above a threshold before and after matching
metrics <- calculateMetrics(simulationStudy, simulationProfile$partialCMD, stdDiffThreshold = .05)
```

We can create a list of confounding schemes, true effect sizes, and outcome prevalences and run all combination of them. For example, the following code performs two confounding schemes (none and remove 25% of covariates), uses two true effect sizes, and uses two outcome prevalences. hdpsFeatures should be set to the appropriate boolean.

The resultant simulations can be accessed via a nested list, with the first index for confounding, second for effect size, third for outcome prevalence. Right now this is just done through a giant for-loop in R.

```{r}
confoundingSchemeList <- c(0,2)
confoundingProportionList <- c(NA, 0.25)
trueEffectSizeList <- c(-1, 1)
outcomePrevalenceList <- c(0.01, 0.05)
hdpsFeatures = TRUE

simulationStudies <- runSimulationStudies(simulationProfile, studyPop, n = 10, confoundingSchemeList, confoundingProportionList,
                                 trueEffectSizeList, outcomePrevalenceList, crossValidate = TRUE, hdpsFeatures = hdpsFeatures)

simulationStudy <- simulationStudies[[1]][[1]][[1]]
```