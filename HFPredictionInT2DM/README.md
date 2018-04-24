OHDSI Patient Level Prediction of Heart Failure in patients with T2DM
======================================================================

This study aims to generate prediction models for heart failure within
a cohort of people with Type 2 Diabetes.

How to run
==========
1. Make sure that you have Java installed. If you don't have Java already installed on your computed (on most computers it already is installed), go to java.com to get the latest version. (If you have trouble building with rJava below, be sure on Windows that your Path variable includes the path to jvm.dll (Windows Button --> type "path" --> Edit Environmental Variables --> Edit PATH variable, add to end ;C:/Program Files/Java/jre/bin/server) or wherever it is on your system.)

2. Make sure that you have Python installed. If you don't have Python 2.7 already intalled on your computed, go to https://www.continuum.io/downloads to get the latest version. 

3. In R, use the following code to install the study package and its dependencies:

	```r
	install.packages("drat")
        drat::addRepo("OHDSI")
        install.packages("PatientLevelPrediction")
	install_packages("OhdsiSharing")
	install.packages("devtools")
	library(devtools)
	install_github("ohdsi/StudyProtocolSandbox/HFPredictionInT2DM")
	```

4. Once installed, you can execute the study by modifying and using the following code:

	```r
	library(LargeScalePrediction)
    options('fftempdir' = 's:/fftemp')

	connectionDetails <- createConnectionDetails(dbms = "postgresql",user = "joe",
						     password = "secret",
						     server = "myserver")
    workFolder <- "s:/temp/LargeScalePrediction"

    fetchAllDataFromServer(connectionDetails = connectionDetails,
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           oracleTempSchema = oracleTempSchema,
                           workDatabaseSchema = workDatabaseSchema,
                           studyCohortTable = studyCohortTable,
                           workFolder = workFolder)

    generateAllPopulations(workFolder)

    fitAllPredictionModels(workFolder)
    
    createSummary(workFolder)
    
    * The results can be zipped using the following command:
    
    packageResults(workFolder = workFolder,
                   dbName="<name>")
	```
	* ```dbName``` is added to name of the zipfile.
	
	* For details on how to configure```createConnectionDetails``` in your environment type this for help:
	```r
	?createConnectionDetails
	```

	* ```cdmDatabaseSchema``` should specify the schema name where your patient-level data in OMOP CDM format resides. Note that for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.

	* ```oracleTempSchema``` should be used in Oracle to specify a schema where the user has write priviliges for storing temporary tables.

	* ```cdmVersion``` is the version of the CDM. Can be "4" or "5".

5. Upload the file ```export/<dbName>-studyResult.zip``` in the export folder to the study coordinator:
    ```r
    submitResults(workFolder, dbName = "<name>", key = "<key>", secret = "<secret>")
    ```
    Where ```dbName``` is the name of your database, ```key``` and ```secret``` are the credentials provided to you personally by the study coordinator.
