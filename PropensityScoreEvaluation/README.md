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
Currently uses single studies vignette as an example. Using any existing CohortMethodData object is ok as well.

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
# defaults to cross-validation to find Lasso hyperparameter with useCrossValidation = TRUE
# set useCrossValidation = FALSE and specify a priorVariance to use a specific variance

studyPop <- createStudyPopulation(cohortMethodData = cohortMethodData,
outcomeId = outcomeId,
firstExposureOnly = FALSE,
washoutPeriod = 0,
removeDuplicateSubjects = FALSE,
removeSubjectsWithPriorOutcome = TRUE,
minDaysAtRisk = 1,
riskWindowStart = 0,
addExposureDaysToStart = FALSE,
riskWindowEnd = 30,
addExposureDaysToEnd = TRUE)

simulationProfile <- createCMDSimulationProfile(cohortMethodData, studyPop = studyPop, outcomeId = outcomeId, useCrossValidation = FALSE, priorVariance = 1)
saveSimulationProfile(simulationProfile, file = file)
simulationProfile <- loadSimulationProfile(file = file)
```

The simulation is divided into two steps: a simulation setup step and a run simulation step. The simulation setup step selects unmeasured confounding covariates and a desired sample size, if specified. It also estimates the LASSO-regularized propensity score and exposure based hdPS. The run simulation step simulates event times and estimates propensity score adjusted outcome models.

Confounding proportion: a number between 0 and 1 of fraction of covariates to discard in propensity score estimation. Set NA for no confounding
  
Sample size: NA - use full cohort ; otherwise - use given size (should be smaller than size of full cohort)

```{r}
# can turn off cross validation to specify specific variance in L1 regularized propensity score
simulationSetup <- setUpSimulation(simulationProfile, cohortMethodData, useCrossValidation = TRUE, 
                                    confoundingProportion = NA, sampleSize = NA, hdpsFeatures = hdpsFeatures)

saveSimulationSetup(simulationSetup, file = file)
loadSimulationSetup(file = file)
```

We can create simulation setups en masse:

```{r}
confoundingProportionList <- c(NA, 0.25)
sampleSizeList <- c(NA, 5000)
outputFolder <- outputFolder

setUpSimulations(simulationProfile, cohortMethodData, confoundingProportionList,
                  useCrossValidation = TRUE, sampleSizeList, outputFolder, hdpsFeatures = hdpsFeatures)
```
For each simulation setup, we can run simulations for given true effect size and outcome prevalence with `runSimulationStudy`.

For each simulation setup, we can also run a list of effect sizes and outcome prevalences with `runSimulationStudies`. This needs the folder name for a saved simulation setup.

``` {r}
# Defaults to 1-1 propensity score matching. Can use 10-fold stratification with `stratify = TRUE`
# Defaults to smoothed baseline hazard estimators. Can use discrete baseline estimators with `discrete = TRUE`
simulationStudy <- runSimulationStudy(simulationProfile = simulationProfile, simulationSetup = simulationSetup, cohortMethodData = cohortMethodData, simulationRuns = 10, 
                                      trueEffectSize = 1.0, outcomePrevalence = 0.05, hdpsFeatures = hdpsFeatures)
                                      
trueEffectSizeList <- c(log(1), log(1.5), log(2), log(4))
outcomePrevalenceList <- c(0.001, 0.01, 0.05)
simulationSetupFolder <- simulationSetupFolder
outputFolder <- outputFolder

simulationStudies <- runSimulationStudies(simulationProfile, cohortMethodData, simulationRuns = 100,
                                          trueEffectSizeList=trueEffectSizeList, outcomePrevalenceList=outcomePrevalenceList, hdpsFeatures=hdpsFeatures,
                                          simulationSetupFolder = simulationSetupFolder, outputFolder=outputFolder)

simulationStudies <- loadSimulationStudies(outputFolder)
```

Look at results. The calculateMetrics function takes a simulationStudy output and returns the bias, sd, rmse, coverage of true effect size, auc, and the number of covariates with std diff greater than a given threshold before and after matching based on PS method

```{r}
# View settings used in simulation
simulationStudy$settings

# Calculate set of metrics for simulation
metrics <- calculateMetrics(simulationStudy, simulationProfile$partialCMD, stdDiffThreshold = .05)

# Calculate set of metrics for simulation studies (nested list of different effect sizes and outcome prevalences)
metricsList <- calculateMetricsList(simulationStudies, cohortMethodData, stdDiffThreshold = .05)
metricsList[[1]][[1]]
```