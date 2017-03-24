OHDSI Alendronate vs Raloxifen study
=============================================

This study aims to evaluate hip fracture risk in patients exposed to alendronate compared with those exposed to raloxifen.

Detailed information and protocol is available on the [OHDSI Wiki](http://www.ohdsi.org/web/wiki/doku.php?id=research:bisphosphonates_and_hip_fracture) and [Full Protocol](https://docs.google.com/document/d/1ldRAh45uUWs7pzKThBx7KhWaSpkYcD7T-QG0phbxDys/edit?usp=sharing).

Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, Amazon RedShift, or Microsoft APS.
- R version 3.2.2 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 100 GB of free disk space

Recommended
===========

- 8 CPU cores or more
- 32 GB of memory or more

How to run
==========
1. Make sure that you have [Java](http://java.com) installed, and on Windows make sure that [RTools](http://cran.r-project.org/bin/windows/Rtools/) is installed. See the [OHDSI Wiki](http://www.ohdsi.org/web/wiki/doku.php?id=documentation:r_setup) for help on setting up your R environment

3. In `R`, use the following code to install the study package and its dependencies:
	```r
	install_github("ohdsi/DatabaseConnector")
	install_github("ohdsi/AlendronateVsRaloxifen")
	```
4. Once installed, you can execute the feasibility assessment by modifying and using the following code:

	```r
	library(AlendronateVsRaloxifen)

	connectionDetails <- createConnectionDetails(dbms = "postgresql",
	                                             user = "joe",
						     password = "secret",
						     server = "myserver")

	assessFeasibility(connectionDetails,
			  cdmDatabaseSchema = "cdm_data",
			  workDatabaseSchema = "results",
			  studyCohortTable = "ohdsi_alendronate_raloxifen",
			  oracleTempSchema = NULL,
			  outputFolder = "c:/temp/study_results")
	```

	* For details on how to configure```createConnectionDetails``` in your environment type this for help:
	```r
	?createConnectionDetails
	```

	* ```cdmDatabaseSchema``` should specify the schema name where your data in OMOP CDM format resides. Note that for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.
	
	* ```workDatabaseSchema``` should specify the schema name where intermediate results can be stored. Note that for SQL Server, this should include both the database and schema name, for example 'results.dbo'.
	
	* ```studyCohortTable``` should specify the name of the table that will be created in the work database schema where the exposure and outcomes cohorts will be stored. The default value is 'ohdsi_alendronate_raloxifen'.

	* ```oracleTempSchema``` should be used for Oracle users only to specify a schema where the user has write priviliges for storing temporary tables. This can be the same as the work database schema.
	
	* ```outputFolder``` a location in your local file system where results can be written. Make sure to use forward slashes (/). Do not use a folder on a network drive since this greatly impacts performance. 

5. E-mail the `CohortCounts.csv` file to the study coordinator.

Getting Involved
================
* Package manual: [AlendronateVsRaloxifen.pdf](https://raw.githubusercontent.com/OHDSI/StudyProtocolSandbox/AlendronateVsRaloxifen/master/extras/AlendronateVsRaloxifen.pdf)
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="../../issues">GitHub issue tracker</a> for all bugs/issues/enhancements


License
=======
The AlendronateVsRaloxifen package is licensed under Apache License 2.0

Development
===========
AlendronateVsRaloxifen was developed in R Studio.

###Development status

Beta
