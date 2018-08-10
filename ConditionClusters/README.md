ConditionClusters
======================

  Introduction
============
  An R package for finding similar condition concept ids

Features
========
  - Takes a condition concept id of interest
  - Returns a specified number of simialr concepts

Technology
==========
  ConditionClusters is an R package

System Requirements
===================
  Requires R (version 3.3.0 or higher)

Example
===================
  ```r
library(ConditionClusters)
data(includedConditions)
data(similarityTop50)

includedConditions[100,]
getSimilarConcepts(includedConditions$CONDITION_CONCEPT_ID[100], n=10)

includedConditions[300,]
getSimilarConcepts(includedConditions$CONDITION_CONCEPT_ID[300], n=10)
getSimilarConcepts(73366, n=5)
```

License
=======
  ConditionClusters is licensed under Apache License 2.0

Development
===========
  ConditionClusters is being developed in R Studio.







