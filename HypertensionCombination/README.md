#HypertensionCombination

The goal of this protocols is conducting comparative effectiveness research to establish evidences for optimal anti-hypertensive combination strategies among patients without cardiovascular outcome from various databases across world.

#Participate on HypertensionCombination study

##Step 1
Install packages for CohortMethod analysis

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/OhdsiRTools")
install_github("ohdsi/OhdsiSharing")
install_github("ohdsi/SqlRender")
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/Cyclops")
install_github("ohdsi/PatientLevelPrediction")
install_github("ohdsi/FeatureExtraction")
install_github("ohdsi/CohortMethod")
```

##Step 2.
Install the package HypertensionCombination.

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/StudyProtocolSandbox/HypertensionCombination")
library(HypertensionCombination)
```

##Step 3. 
Execute the following code:

```R
library(HypertensionCombination)

cdmDatabaseSchema<-"OMOP CDM DATABASE SCHEMA"
resultsDatabaseSchema<-"RESULT DATABASE SCHEMA"

connectionDetails<-DatabaseConnector::createConnectionDetails(dbms="DBMS",
                                                              server="SERVER IP",
															  schema=resultsDatabaseSchema,
                                                              user="ID",
                                                              password="PW")

execute(connectionDetails,
	cdmDatabaseSchema = cdmDatabaseSchema,
	resultsDatabaseSchema = resultsDatabaseSchema,
	exposureTable = "exposureTable",
	outcomeTable = "outcomeTable",
	cdmVersion = 5,
	outputFolder = "output",
	createCohorts = TRUE,
	runAnalyses = TRUE,
	packageResults = TRUE,
	maxCores = 4)
```
##Step 4.
E-mail to Seng Chan You (applegna@gmail.com) with ```StudyResults.zip```

# Contacts
- Study design: Seng Chan You (applegna@gmail.com)
- R package: Sungjae Jung (sungjae.2425@gmail.com)
