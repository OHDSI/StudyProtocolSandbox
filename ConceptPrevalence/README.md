ConceptPrevalence
================

Introduction
==========
A package to calculate the counts of the standard and source concepts in an OMOP CDM and extract the current version of the mappings used

Technology
==========
ConceptPrevalence is an R package.

Dependencies
============
* SqlRender
* DatabaseConnector

Getting started
============
In R, use the following commands to download and install:

install.packages("devtools")
devtools::install_github("OHDSI/StudyProtocolSandbox/ConceptPrevalence")

library('ConceptPrevalence')

## Add inputs for the site:

dbms <- 'your_dbms'
user <- 'user'
password <- 'password'
server <- Sys.getenv('server')
port <- Sys.getenv('port')
cdmName <- 'your_cdm_name'
cdmDatabaseSchema <- 'your_cdm_schema
vocabDatabaseSchema <- 'your_vocab_schema'
resultDatabaseSchema <-"your_results_schema"


connectionDetails <- DatabaseConnector::createConnectionDetails(
															  dbms = dbms,
                                                              server = server,
                                                              user = user,
                                                              password = password,
                                                              port = port
							      							)
                                                              
## Then run the following:
ConceptPrevalence::calculate (
 				 connectionDetails,
  				 cdmName,
				 cdmDatabaseSchema,
 				 vocabDatabaseSchema,
				 resultDatabaseSchema
				 )


## Upload the results
### Email
ao2671 at cumc.columbia.edu

### Cyberduck
select "S3 (Amazon Simple Storage Service)" in the drop down
nickname: <whatever you want to use>
server:    s3.amazonaws.com
access key:   AKIAYF7DPYA7X6ZQZWFS
click on "more options"
path:  /ohdsi-study-cp

### R script
install.packages("base64enc") 
install.packages("aws.signature") 
install.packages("aws.s3", repos = "http://cloudyr.github.io/drat")
library(“aws.s3”)
Setwd(‘~/working_directory’)
aws.s3::put_object(file = "file_name.csv",
                             object = "s3://ohdsi-study-cp/file_name.csv",
                             key = 'AKIAYF7DPYA7X6ZQZWFS',
                             secret = 'Jk76kbC/y0g5kvSmvyilSy/jL6f96//gSSytplOF',
                             check_region = FALSE)

                                                         
License
=======
  ConceptPrevalence is licensed under Apache License 2.0

Development
===========
  ConceptPrevalence is being developed in R Studio.
