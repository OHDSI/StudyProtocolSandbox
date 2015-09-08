OHDSI Drug Utilization in Children Protocol
===========================================

This study aims to measure the prevalence of drug use in children in several countries in Asia. We will compute prevalence for all drugs captured in the databases in the pediatric population. The main analysis will focus on drug classes (anatomical and therapeutic) and these prevalences will be stratified by year to evaluate temporal trends. A secondary analysis will report the five top ingredients per anatomical class per country. All analysis will be stratified by age (< 2 years, 2-11 years, and 12-18 years), and by setting (inpatient or ambulatory care).

How to run
==========

In R, use the following code to install the study package and its dependencies:

```r
install.packages("devtools")
library(devtools)
install_github("ohdsi/SqlRender")
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/OhdsiSharing")
install_github("ohdsi/StudyProtocols/DrugsInPeds")
```

Once installed, you can execute the study by modifying and using the following code:

```r
library(DrugsInPeds)

connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                             user = "joe",
                                             password = "secret",
                                             server = "myserver")

execute(connectionDetails,
        cdmDatabaseSchema = "cdm_data",
        oracleTempSchema = NULL,
        cdmVersion = "4")
        
email(from = "collaborator@@ohdsi.org",
      dataDescription = "CDM4 Simulated Data")
```

* For details on how to configure```createConnectionDetails``` in your environment type this for help:
```r
?createConnectionDetails
```

* ```cdmDatabaseSchema``` should specify the schema name where your patient-level data in OMOP CDM format resides. Note that for SQL Server, this should include both the database and schema name, for example 'cdm_data.dbo'.

* ```oracleTempSchema``` should be used in Oracle to specify a schema where the user has write priviliges for storing temporary tables.

* ```cdmVersion``` is the version of the CDM. Can be "4" or "5".

* ```from``` is your e-mail address.

* ```dataDescription``` is a short description of the source database, such as the name and version.
