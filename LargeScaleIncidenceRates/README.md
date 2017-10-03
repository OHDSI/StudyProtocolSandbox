OHDSI Large Scale Incidence Rates study
=============================================

This study aims to measure a large number of incidence rates.

Detailed information and protocol is available on ...

Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, Amazon RedShift, or Microsoft APS.
- [Java](http://java.com)

How to run
==========
1. Make sure that you have [Java](http://java.com) installed, and on Windows make sure that [RTools](http://cran.r-project.org/bin/windows/Rtools/) is installed. See the [OHDSI Wiki](http://www.ohdsi.org/web/wiki/doku.php?id=documentation:r_setup) for help on setting up your R environment

3. In `R`, use the following code to install the study package and its dependencies:
	```r
	library(devtools)
	install_github("ohdsi/SqlRender")
	install_github("ohdsi/DatabaseConnector")
	install_github("ohdsi/StudyProtocolSandbox/LargeScaleIncidenceRates")
	```
4. Once installed, you can execute the study by modifying and using the following code:

	```r
	library(LargeScaleIncidenceRates)

	connectionDetails <- createConnectionDetails(dbms = "postgresql",
	                                             user = "joe",
												 password = "secret",
						                         server = "myserver")

	# Alternatively, run this to execute the full study:
	execute(connectionDetails = connectionDetails,
		cdmDatabaseSchema = "cdm_data",
		studyCohortTable = "ohdsi_incidence_rates",
		oracleTempSchema = NULL,
		outputFolder = "c:/temp/study_results")
	```

	* For details on how to configure```createConnectionDetails``` in your environment type this for help:
	```r
	?createConnectionDetails
	```

	* ```cdmDatabaseSchema``` should specify the schema name where your data in OMOP CDM format resides. Note that for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.
	
	* ```oracleTempSchema``` should be used for Oracle users only to specify a schema where the user has write priviliges for storing temporary tables. This can be the same as the work database schema.
	
	* ```outputFolder``` a location in your local file system where results can be written. Make sure to use forward slashes (/). Do not use a folder on a network drive since this greatly impacts performance. 
	
5. Upload the file ```export/studyResult.zip``` in the output folder to the study coordinator:
    ```r
    submitResults("c:/temp/study_results/export", key = "<key>", secret = "<secret>")
    ```
    Where ```key``` and ```secret``` are the credentials provided to you personally by the study coordinator.


Getting Involved
================
* Package manual: [LargeScaleIncidenceRates.pdf](https://raw.githubusercontent.com/OHDSI/StudyProtocol/LargeScaleIncidenceRates/master/extras/LargeScaleIncidenceRates.pdf)
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="../../issues">GitHub issue tracker</a> for all bugs/issues/enhancements


License
=======
The LargeScaleIncidenceRates package is licensed under Apache License 2.0

Development
===========
LargeScaleIncidenceRates was developed in R Studio.

### Development status

Under development. Do not use.
