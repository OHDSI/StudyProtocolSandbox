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
# createCMDSimulationProfile and setUpSimulation by setting useCrossValidation = FALSE

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

simulationProfile <- createCMDSimulationProfile(cohortMethodData, studyPop = studyPop, outcomeId = outcomeId, useCrossValidation = TRUE)
saveSimulationProfile(simulationProfile, file = file)
simulationProfile <- loadSimulationProfile(file = file)
```

The simulation is divided into two steps: a simulation setup step and a run simulation step. The simulation setup calculates the LASSO-regularized propensity score for the specific confounding scheme and sample size desired. The run simulation setup performs the simulation over given values of the true effect size and outcome prevalence. The reason these are separated is because of the high run time of the cross validated propensity score. We save the propensity score so as to calculate it again unnecessarily. 

Confounding schemes (hiding covariates from propensity score models): 0 - no confounding ; 1 - discard demographics ; 2 - discard fraction of covariates ; 3 - discard demographics and fraction of covariates

Confounding proportion: NA - confounding schemes 0 and 1 ; otherwise (schemes 2, 3) a number between 0 and 1
  
Sample size: NA - use full cohort ; otherwise - use given size (should be smaller than size of full cohort)

```{r}
simulationSetup <- setUpSimulation(simulationProfile, cohortMethodData, useCrossValidation = TRUE, confoundingScheme = 0,
                                    confoundingProportion = NA, sampleSize = NA)

saveSimulationSetup(simulationSetup, file = file)
loadSimulationSetup(file = file)
```

We can create simulation setups en masse:

```{r}
confoundingSchemeList <- c(0,2)
confoundingProportionList <- c(NA, 0.25)
sampleSizeList <- c(NA, 5000)
outputFolder <- outputFolder

setUpSimulations(simulationProfile, cohortMethodData, confoundingSchemeList, confoundingProportionList,
                  useCrossValidation = TRUE, sampleSizeList, outputFolder)
```
For each simulation setup, we can run simulations for given true effect size and outcome prevalence.

For each simulation setup, we can also run a combination of effect sizes and outcome prevalences with runSimulationStudies. Note that in this case only one of simulationSetup or simulationSetupFolder should be given. It will either use the given setup or load from file.

``` {r}

simulationStudy <- runSimulationStudy(simulationProfile, simulationSetup = simulationSetup, cohortMethodData = cohortMethodData, simulationRuns = 10, 
                                      trueEffectSize = 1.0, outcomePrevalence = 0.05, hdpsFeatures = hdpsFeatures)
                                      
trueEffectSizeList <- c(1, 1.5, 2, 4)
outcomePrevalenceList <- c(0.001, 0.01, 0.05)
simulationSetupFolder <- simulationSetupFolder
outputFolder <- outputFolder

simulationStudies <- runSimulationStudies(simulationProfile, cohortMethodData, simulationSetup = NULL, simulationRuns = 10,
                                          trueEffectSizeList, outcomePrevalenceList, hdpsFeatures,
                                          simulationSetupFolder = simulationSetupFolder, outputFolder)

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