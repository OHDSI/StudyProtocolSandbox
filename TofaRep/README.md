# tofarep

# To run:
```r
install.packages("devtools")
library(devtools)
install_github("ohdsi/SqlRender")
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/OhdsiRTools")
install_github("ohdsi/OhdsiSharing")
install_github("ohdsi/FeatureExtraction")
install_github("ohdsi/CohortMethod")
install_github("ohdsi/EmpiricalCalibration")
install_github("ohdsi/MethodEvaluation")
install_github("ohdsi/EvidenceSynthesis")
install_github("ohdsi/StudyProtocolSandbox/TofaRep")
```

If you experience problems on Windows where rJava can't find Java, one solution may be to add `args = "--no-multiarch"` to each `install_github` call, for example:

```r
install_github("ohdsi/SqlRender", args = "--no-multiarch")
```

Once installed, you can execute the study by modifying and using the following code:

```r
library(TofaRep)

connectionDetails <- createConnectionDetails(dbms = "postgresql",
user = "joe",
password = "secret",
server = "myserver")

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = "cdm_data",
        cohortDatabaseSchema = "results",
        cohortTable = "tofarep_cohorts",
        oracleTempSchema = oracleTempSchema,
        outputFolder = "c:/temp/study_results",
        createCohorts = TRUE,
        synthesizePositiveControls = TRUE,
        runAnalyses = TRUE,
        runDiagnostics = TRUE,
        packageResults = TRUE,
        maxCores = 30)
```

* For details on how to configure```createConnectionDetails``` in your environment type this for help:
```r
?createConnectionDetails
```

* ```cdmDatabaseSchema``` should specify the schema name where your data in OMOP CDM format resides. Note that for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.

* ```workDatabaseSchema``` should specify the schema name where intermediate results can be stored. Note that for SQL Server, this should include both the database and schema name, for example 'results.dbo'.

* ```studyCohortTable``` should specify the name of the table that will be created in the work database schema where the exposure and outcomes cohorts will be stored. The default value is 'ohdsi_alendronate_raloxifene'.

* ```oracleTempSchema``` should be used for Oracle users only to specify a schema where the user has write priviliges for storing temporary tables. This can be the same as the work database schema.

* ```outputFolder``` a location in your local file system where results can be written. Make sure to use forward slashes (/). Do not use a folder on a network drive since this greatly impacts performance. 

* ```maxCores``` is the number of cores that are available for parallel processing. If more cores are made available this can speed up the analyses. Preferrably, this should be set the number of cores available in the machine.
