Predicting randomized clinical trial results with real-world evidence: A case study in the comparative safety of tofacitinib, adalimumab and etanercept in patients with rheumatoid arthritis
======================================================================================

This study aims to compare the safety of tofacitinib with adalimumab and etanercept in patients with rheumatoid arthritis. We will replicate the design and population inclusion criteria of an ongoing phase 3b/4 randomized clinical trial (NCT02092467), with the aim of predicting the RCT results using real-world evidence. In this study, we will analyze data from observational databases across the OHDSI network using the OHDSI CohortMethod package framework to perform this comparative study.


Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, or Microsoft APS.
- R version 3.4.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 25 GB of free disk space

See [this video](https://youtu.be/K9_0s2Rchbo) for instructions on how to set up the R environment on Windows.


How to run
==========
1. In `R`, use the following code to install the study package and its dependencies:
	
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
	
	Alternatively, ensure that you have installed both 32-bit and 64-bit JDK versions, as mentioned in the [video tutorial](https://youtu.be/K9_0s2Rchbo).

2. Once installed, you can execute the study by modifying and using the following code:
	
	```r
	library(TofaRep)
	
	connectionDetails <- createConnectionDetails(dbms = "postgresql",
																						 user = "joe",
																						 password = "secret",
																						 server = "myserver")
	
	execute(connectionDetails = connectionDetails,
				cdmDatabaseSchema = "cdm_data",
				cohortDatabaseSchema = "scratch",
				cohortTable = "tofarep_cohorts",
				oracleTempSchema = NULL,
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
	
	* ```cohortDatabaseSchema``` should specify the schema name where intermediate results can be stored. Note that for SQL Server, this should include both the database and schema name, for example 'results.dbo'.
	
	* ```cohortTable``` should specify the name of the table that will be created in the work database schema where the exposure and outcomes cohorts will be stored. The default value is 'ohdsi_alendronate_raloxifene'.
	
	* ```oracleTempSchema``` should be used only by Oracle users to specify a schema where the user has write priviliges for storing temporary tables. This can be the same as the work database schema.
	
	* ```outputFolder``` a location in your local file system where results can be written. Make sure to use forward slashes (/). Do not use a folder on a network drive since this greatly impacts performance. 
	
	* ```maxCores``` is the number of cores that are available for parallel processing. If more cores are made available this can speed up the analyses. Preferrably, this should be set the number of cores available in the machine.

3. If you want, You can inspect the diagnostics in the `diagnostics` folder.

4. Upload the file ```export/studyResult.zip``` in the output folder to the study coordinator:
		```r
		submitResults("c:/temp/study_results/export", key = "<key>", secret = "<secret>")
		```
		Where ```key``` and ```secret``` are the credentials provided to you personally by the study coordinator.


Getting Involved
================
* Package manual: [TofaRep.pdf](https://raw.githubusercontent.com/OHDSI/StudyProtocolSandbox/TofaRep/master/extras/TofaRep.pdf)
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="../../issues">GitHub issue tracker</a> for all bugs/issues/enhancements


License
=======
The TofaRep package is licensed under Apache License 2.0


Development
===========
TofaRep was developed in R Studio.

### Development status

In production. We're running this study at multiple sites.