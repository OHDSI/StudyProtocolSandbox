OHDSI Patient Level Prediction Depression Models
======================================================================

This package contain the models trained on 4 different databases to predict 21 different outcomes for the target population of patients with therapeutically treated depression

How to run
==========
1. Make sure that you have Java installed. If you don't have Java already installed on your computed (on most computers it already is installed), go to java.com to get the latest version. (If you have trouble building with rJava below, be sure on Windows that your Path variable includes the path to jvm.dll (Windows Button --> type "path" --> Edit Environmental Variables --> Edit PATH variable, add to end ;C:/Program Files/Java/jre/bin/server) or wherever it is on your system.)

2. Make sure that you have Python installed. If you don't have Python already intalled on your computed, go to https://www.continuum.io/downloads to get the latest version.

3. In R, use the following code to install the study package and its dependencies:

	```r
	install.packages("drat")
	drat::addRepo("OHDSI")
  install.packages("PatientLevelPrediction")
	install.packages("ohdsi/StudyProtocolSandbox/DepressionModels")
	```

4. Once installed, you can execute the study by modifying and using the following code:

	```r
	library(DepressionModels)
  options('fftempdir' = 's:/fftemp')

  connectionDetails <- createConnectionDetails(dbms = "pdw",
                                               server = Sys.getenv('server'),
                                               port = Sys.getenv('port'),
                                               user = NULL,
                                               password = NULL)

  cdmDatabaseSchema <- Sys.getenv('mdcr')
  targetDatabaseSchema <- 'scratch.dbo'
  outputDir <- 'S:/externVal'


  # 1) first create the data in the data cdm_database
  plpData <- extractData(connectionDetails,
              cdmDatabaseSchema,
              targetDatabaseSchema,
              targetCohortTable = 'extValCohort',
              targetCohortId=1, outcomeCohortIds = 2:22)


  # 2) apply the model for the first outcome to new data
  applyModel(plpData, outcomeCohortId=2, outputDir=file.path(getwd(), 'externalValidation'))
	```

	* For details on how to configure```createConnectionDetails``` in your environment type this for help:
	```r
	?createConnectionDetails
	```

	* ```cdmDatabaseSchema``` should specify the schema name where your patient-level data in OMOP CDM format resides. Note that for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.

	* ```oracleTempSchema``` should be used in Oracle to specify a schema where the user has write priviliges for storing temporary tables.

	* ```cdmVersion``` is the version of the CDM. Can be "4" or "5".

5. Upload the file ```export/studyResult.zip``` in the output folder to the study coordinator:
    ```r
    submitResults("c:/temp/study_results/export", key = "<key>", secret = "<secret>")
    ```
    Where ```key``` and ```secret``` are the credentials provided to you personally by the study coordinator.
