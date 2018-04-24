ExistingStrokeRiskExternalValidation
======================

  Introduction
============
  A package for running the OHDSI network study to externally validate 5 existing stroke risk prediction models using the PatientLevelPrediction framework


Features
========
  - Creates target cohort of females newly diagnosed with atrial fibrilation between ages 35-65
  - Creates outcome cohort of stroke with hospitilisation
  - Implements 5 existing stroke risk prediciton models and validates on data in OMOP CDM
  - Sends summary results 

Technology
==========
  ExistingStrokeRiskExternalValidation is an R package.

System Requirements
===================
  Requires R (version 3.3.0 or higher).

Dependencies
============
  * PatientLevelPrediction
  * PredictionComparison

Getting Started
===============
  1. In R, use the following commands to download and install:

  ```r
install.packages("drat")
drat::addRepo("OHDSI")
install.packages("ExistingStrokeRiskExternalValidation")
```

License
=======
  ExistingStrokeRiskExternalValidation is licensed under Apache License 2.0

Development
===========
  ExistingStrokeRiskExternalValidation is being developed in R Studio.

