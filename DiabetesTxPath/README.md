---
title: "Type-2 Diabetes Treatment Pathways"
author: "Rohit Vashisht"
date: "3/23/2017"
output: html_document
---
# Learning Effective Clinical Treatment Pathways for Type-2 Diabetes from Observational Data.

## Objective: 
Treatment guidelines for the management of type-2 diabetes mellitus (T2DM) are controversial because existing evidence from randomized clinical trials do not address many important clinical questions. An earlier investigation led by Observational Health Data Science (OHDSI) group reveled heterogeneity in the practice of both first and second line treatment choices in T2D with respect to established clinical guidelines. The choice of an optimal second-line drug among available options (Sulfonylureas, DPP4-Inhibitors, Thiazolidinediones) remains ambiguous. In this study, we seek to compare Sulfonylurea, DPP4-Inhibitors, and Thiazolidinediones when prescribed after Metformin for outcomes related to reduction in HbA1c < 7%, events related to Myocardial Infarction, Kidney and Eye related disorders within OHDSI network.

## Rationale: 
Type-2 diabetes (T2DM) affects an estimated 29.1 million people in the United States. Its global prevalence is projected to reach 440 million adults by the end of 2030. Current treatment guidelines, which are derived from a few randomized controlled trials, recommend the use of metformin as first-line monotherapy. However, when metformin exhibits adverse effects or fails to control diabetes, the second line therapy must be chosen, and there is little consensus on how to choose a second line therapy; with the American Diabetes Association recommending sulfonylureas, meglitinide, pioglitazone or dipeptidyl peptidase 4 inhibitor (DPP4) as second-line agent, and the American Association of Clinical Endocrinologists recommending alpha-glucose inhibitors, DPP4 inhibitors and GLP-1 agonist. Given the availability of myriad treatment options for second-line therapy, the problem of selecting an optimal second-line agent requires urgent attention.

## Project Lead(s): 
Rohit Vashisht, Ken Jung, Alejandro Schuler, Juan Banda, James Weaver, Martijin Schuemie, Patrick Ryan and Nigam Shah

## Coordinating Institution(s): 
Stanford University

# Study Protocol
A detailed study protocol is provided in this repository with file name T2D_Study_Protocol.docx

# R-Package
This is an R package that can be used to execute T2D study. An in-depth discussion on the study design can be found at (link to protocol). Very briefly, the R-Package enables one to decipher effective treatment pathways of T2D in terms of controlling a) HbA1c b) less adverse events in terms of Myocardial Infraction c) less adverse events in terms of Kidney related disorders and d) less adverse events related to Eyes disorder. A step-by-step guide to execute this study is provided below: 

## Step-1
The package can be installed as follows:
```r
library("devtools")
install_github("rohit43/DiabetesTxPath")
```

## Step-2
Make sure you have installed all the latest versions of the following packages. The study might throw an error in case old packages are loaded. 
Load the required libraries as follows:

```r
library("OhdsiRTools")
library("OhdsiSharing")
library("SqlRender")
library("DatabaseConnector")
library("FeatureExtraction")
library("CohortMethod")
library("EmpiricalCalibration")
library("DiabetesTxPath")
```
## Step-3
Setup your JBC driver environment and connection details as follows:
```r
jdbcDrivers <- new.env()
connectionDetails <- createConnectionDetails(dbms = "yourDatabase", 
                                             server = "yourServer",
                                             user = "yourUserName", 
                                             password = "yourPassword",
                                             port = "yourPort")
```

## Step-4
Provide database schema name and other details as follows.

```r
cdmDatabaseSchema <- "nameOfYourCdmSchema"
resultsDatabaseSchema <- "nameOfResultsSchema"
targetDatabaseSchema <- "nameOfResultsSchema"
#----**********------
#Make sure to add / at the end of results_path in case you don't have that otherwise no folder 
#will be created and the study might crash.
results_path <- "path to results folder" #where you want the results to be saved.
#For example results_path <- "/Users/rvashisht/Desktop/StudyResults/" will save the
#study results in StudyResults folder in Desktop.
#----*********-------
cdmVersion <- "5" #do not change this. Please note, this study can only be executed on CDMV5 
maxCores <- 40 #change this depending on your compute power.
```

## Step-5
The complete study can be executed with a single function as shown below. Please note, this function will run the study for all the 4 different outcomes a)HbA1c b)Myocardial Infraction c)Kidney Disease and d)Eyes related disorders considered in this analysis.The script to run the complete study is below:

```r
runCompleteStudy(connectionDetails = connectionDetails,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 resultsDatabaseSchema = resultsDatabaseSchema,
                 cdmVersion = cdmVersion,
                 results_path = results_path,
                 maxCores = maxCores)
```
## Important
The runCompleteStudy function will create a folder *deleteMeBeforeSharing*.
Please do not share this folder. Make sure to delete this folder from your 
results folder before sharing rest of the results.


Package the results as follows:
```r
packageResults(connectionDetails = connectionDetails, 
               cdmDatabaseSchema = cdmDatabaseSchema, 
               workFolder = results_path, 
               dbName = cdmDatabaseSchema)
```

Time of execution can vary from few hours to day or two, depending on the size of the dataset you have. 

