OHDSI Cancer Treatment
=============================================

This study aims to look at cancer patients. It is inspired by a question from National Cancer Institute (NCI).

Wiki link to the study is [OHDSI Wiki](http://www.ohdsi.org/web/wiki/doku.php?id=research:bisphosphonates_and_hip_fracture) 

Protocol is available here [Protocol](https://1drv.ms/w/s!AkvVyFP8dhtKjVt-45bwg29Sf7wg)


Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, Amazon RedShift, or Microsoft APS.
- R version 3.2.2 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)


How to run
==========
1. Make sure that you have [Java](http://java.com) installed, and on Windows make sure that [RTools](http://cran.r-project.org/bin/windows/Rtools/) is installed. See the [OHDSI Wiki](http://www.ohdsi.org/web/wiki/doku.php?id=documentation:r_setup) for help on setting up your R environment

3. In `R`, use the following code to install the study package and its dependencies:
	```r
	library(devtools)
	install_github("ohdsi/SqlRender")
	install_github("ohdsi/DatabaseConnector")
	install_github("ohdsi/OhdsiRTools")
	install_github("ohdsi/OhdsiSharing")
	install_github("ohdsi/FeatureExtraction")
	install_github("ohdsi/CohortMethod")
	install_github("ohdsi/EmpiricalCalibration")
	install_github("ohdsi/StudyProtocolSandbox/CancerTx")
	```
4. Once installed, you can execute the study by modifying and using the following code:

	```r
	library(xxx)

	connectionDetails <- createConnectionDetails(dbms = "postgresql",
	                                             user = "joe",
						     password = "secret",
						     server = "myserver")
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
	
5. Execute

    ```r
    
    cdmDatabaseSchema='mycdm'
    workDatabaseSchema='usersandbox'
    studyCohortTable='cancercohort'
    workFolder='c:/b/cath'
    execute(connectionDetails = connectionDetails,cdmDatabaseSchema = cdmDatabaseSchema,
        workDatabaseSchema = workDatabaseSchema,studyCohortTable = studyCohortTable,outputFolder = workFolder)

    ```
6. Upload the file ```export/studyResult.zip``` in the output folder to the study coordinator. The output consist of several files. One file is called CohortCounts.csv. The third column in this file (called count) will have count of patients found for each Atlas phenotype listed in file [CohortsToCreate.csv](https://github.com/OHDSI/StudyProtocolSandbox/blob/master/CancerTreatments/inst/settings/CohortsToCreate.csv)

    ```r
    submitResults("c:/temp/study_results/export", key = "<key>", secret = "<secret>")
    ```
    Where ```key``` and ```secret``` are the credentials provided to you personally by the study coordinator.
	



Getting Involved
================

* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="../../issues">GitHub issue tracker</a> for all bugs/issues/enhancements


License
=======
The study package is licensed under Apache License 2.0

Development
===========
Study was developed in R Studio.

### Development status

In development.
