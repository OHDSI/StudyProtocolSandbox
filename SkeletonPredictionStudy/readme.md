A Package Skeleton for Patientl-Level Prediction Studies
========================================================

A skeleton package, to be used as a starting point when implementing patient-level prediction studies.

Vignette: [Using the package skeleton for patient-level prediction studies](https://raw.githubusercontent.com/OHDSI/StudyProtocolSandbox/master/SkeletonPredictionStudy/inst/doc/UsingSkeletonPackage.pdf)

Instructions 
===================

- Step 1: Create the prediction study design in atlas
- Step 2: Copy and Rename the SkeletonPredictionStudy package (e.g., in this example I will rename it ExamplePredictionStudy)
- Step 3: Save the json object copied from altas into package location: './inst/settings/predictionAnalysisList.json' found in the ExamplePredictionStudy directory
- Step 4: Populated the package with cohort details by opening the ExamplePredictionStudy.Rproj in the ExamplePredictionStudy directory and running:
  ```r
  library('ExamplePredictionStudy')
  createStudyFiles(baseUrl=http://api.ohdsi.org:80/WebAPI")
```
This extracts the cohorts designed in atlas into the package 
- Step 5: Now build the package by clicking the 'Install and Restart' button
- Step 6: Share the package and get people to execute the study by running:
  ```r
  library('ExamplePredictionStudy')
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = 'my dbms e.g., sql server',
                                                                server = 'my server',
                                                                user = 'my username',
                                                                password = 'not telling',
                                                                port = 'port number')
execute(connectionDetails = connectionDetails,
                    cdmDatabaseSchema = 'your cdm schema',
                    cohortDatabaseSchema = 'your cohort schema',
                    cohortTable = "cohort",
                    outcomeDatabaseSchema = 'your cohort schema',
                    outcomeTable = "cohort",
                    oracleTempSchema = cohortDatabaseSchema,
                    outputFolder = 'my study results',
                    createCohorts = TRUE,
                    packageResults = TRUE,
                    minCellCount= 5,
                    packageName="SkeletonPredictionStudy")
```
- Step 7: You can then easily transport these results into a network study package by copying this package https://github.com/OHDSI/StudyProtocolSandbox/tree/master/PredictionNetworkStudySkeleton and running:
  ```r
  code to come soon
```


# Development status

Under development. Do not use