# @file functions
#
# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of:
#  ----------------------------------------------
#  DiabetesTxPath
#  ----------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Stanford University Center for Biomedical Informatics - Shah Lab
# @author Rohit Vashisht
#
#' @title
#' getAgeGender
#'
#' @author
#' Rohit Vashisht
#'
#' @details
#' This function plots the results of T2D study.

getHbA1cStat <- function(results_path){
  print(paste("Getting HbA1c Stats. This might take few minutes ... "))
  resFiles <- list.files(paste(results_path,"/deleteMeBeforeSharing/",sep=""))
  #---------------------------------------------------------------------
  #For outCome 4 representing HbA1c <= 7%, represented as HbA1c7Good
  x <- grep("_o4.rds",resFiles)
  resFilesOutCome4 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome4)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome4)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome4)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome4tcOne <- resFilesOutCome4[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome4tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    conn <- DatabaseConnector::connect(connectionDetails)
    insertTable(conn,
                "ohdsiT2DstudyPop",
                studyPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
            count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    unMatchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    unMatchedHbA1cMeanSd$class <- c("unMatched")
    remove(HbA1cBefTx, HbA1cAfTx)
    # Matched Cohort
    insertTable(conn,
                "ohdsiT2DstudyPop",
                matchedPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.measurement_date >= dateadd(day,
                    -365,
                    CAST(o.COHORTSTARTDATE AS DATE)) AND m.measurement_date <= CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    matchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    matchedHbA1cMeanSd$class <- c("matched")
    remove(HbA1cBefTx, HbA1cAfTx)
    hbA1cStat <- rbind(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd)
    write.csv(hbA1cStat, file = paste(results_path,"bigToSulf_bigToDpp4_HbA1c7Good_Stat.csv",sep=""))
    remove(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd, hbA1cStat)
    remove(psScore, matchedPop, studyPop, balance)
  }else
  {
    print(paste("You don't seems to have results for the bigToSulf and bigToDpp4 comparision"))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome4tcTwo <- resFilesOutCome4[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome4tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    conn <- DatabaseConnector::connect(connectionDetails)
    insertTable(conn,
                "ohdsiT2DstudyPop",
                studyPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    unMatchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    unMatchedHbA1cMeanSd$class <- c("unMatched")
    remove(HbA1cBefTx, HbA1cAfTx)
    # Matched Cohort
    insertTable(conn,
                "ohdsiT2DstudyPop",
                matchedPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.measurement_date >= dateadd(day,
                    -365,
                    CAST(o.COHORTSTARTDATE AS DATE)) AND m.measurement_date <= CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    matchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    matchedHbA1cMeanSd$class <- c("matched")
    remove(HbA1cBefTx, HbA1cAfTx)
    hbA1cStat <- rbind(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd)
    write.csv(hbA1cStat, file = paste(results_path,"bigToSulf_bigToThia_HbA1c7Good_Stat.csv",sep=""))
    remove(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd, hbA1cStat)
    remove(psScore, matchedPop, studyPop, balance)
  }else
  {
    print(paste("You don't seems to have results for the bigToSulf and bigToThia comparision"))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome4tcThree <- resFilesOutCome4[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome4tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome4tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome4tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome4tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome4tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    conn <- DatabaseConnector::connect(connectionDetails)
    insertTable(conn,
                "ohdsiT2DstudyPop",
                studyPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    unMatchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    unMatchedHbA1cMeanSd$class <- c("unMatched")
    remove(HbA1cBefTx, HbA1cAfTx)
    # Matched Cohort
    insertTable(conn,
                "ohdsiT2DstudyPop",
                matchedPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.measurement_date >= dateadd(day,
                    -365,
                    CAST(o.COHORTSTARTDATE AS DATE)) AND m.measurement_date <= CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    matchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    matchedHbA1cMeanSd$class <- c("matched")
    remove(HbA1cBefTx, HbA1cAfTx)
    hbA1cStat <- rbind(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd)
    write.csv(hbA1cStat, file = paste(results_path,"bigToDpp4_bigToThia_HbA1c7Good_Stat.csv",sep=""))
    remove(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd, hbA1cStat)
    remove(psScore, matchedPop, studyPop, balance)
  }else
  {
    print(paste("You don't seems to have results for the bigToDpp4 and bigToThia comparision"))
  }
  #----------------------------------------------------------------------
  #---------------------------------------------------------------------
  #For outCome 5 representing HbA1c <= 8%, represented as HbA1c7Good
  x <- grep("_o5.rds",resFiles)
  resFilesOutCome5 <- resFiles[x]
  #Get files sorted for t and c comparisions
  #bigToSulf and bigToDpp4 (1,2)
  tcOne <- grep("_t1_c2",resFilesOutCome5)
  #bigToSulf and bigToThia
  tcTwo <- grep("_t1_c3",resFilesOutCome5)
  #bigToDpp4 and bigToThia
  tcThree <- grep("_t2_c3",resFilesOutCome5)
  #---- For tcOne
  if(length(tcOne)!=0){
    resFilesOutCome5tcOne <- resFilesOutCome5[tcOne]
    #load the data
    ps <- grep("Ps",resFilesOutCome5tcOne)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcOne)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcOne)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcOne)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcOne[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    conn <- DatabaseConnector::connect(connectionDetails)
    insertTable(conn,
                "ohdsiT2DstudyPop",
                studyPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    unMatchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    unMatchedHbA1cMeanSd$class <- c("unMatched")
    remove(HbA1cBefTx, HbA1cAfTx)
    # Matched Cohort
    insertTable(conn,
                "ohdsiT2DstudyPop",
                matchedPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.measurement_date >= dateadd(day,
                    -365,
                    CAST(o.COHORTSTARTDATE AS DATE)) AND m.measurement_date <= CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    matchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    matchedHbA1cMeanSd$class <- c("matched")
    remove(HbA1cBefTx, HbA1cAfTx)
    hbA1cStat <- rbind(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd)
    write.csv(hbA1cStat, file = paste(results_path,"bigToSulf_bigToDpp4_HbA1c8Moderate_Stat.csv",sep=""))
    remove(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd, hbA1cStat)
    remove(psScore, matchedPop, studyPop, balance)
  }else
  {
    print(paste("You don't seems to have results for the bigToSulf and bigToDpp4 comparision"))
  }
  #---- For tcTwo
  if(length(tcTwo)!=0){
    resFilesOutCome5tcTwo <- resFilesOutCome5[tcTwo]
    #load the data
    ps <- grep("Ps",resFilesOutCome5tcTwo)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcTwo)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcTwo)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcTwo)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcTwo[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    conn <- DatabaseConnector::connect(connectionDetails)
    insertTable(conn,
                "ohdsiT2DstudyPop",
                studyPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    unMatchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    unMatchedHbA1cMeanSd$class <- c("unMatched")
    remove(HbA1cBefTx, HbA1cAfTx)
    # Matched Cohort
    insertTable(conn,
                "ohdsiT2DstudyPop",
                matchedPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.measurement_date >= dateadd(day,
                    -365,
                    CAST(o.COHORTSTARTDATE AS DATE)) AND m.measurement_date <= CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    matchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    matchedHbA1cMeanSd$class <- c("matched")
    remove(HbA1cBefTx, HbA1cAfTx)
    hbA1cStat <- rbind(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd)
    write.csv(hbA1cStat, file = paste(results_path,"bigToSulf_bigToThia_HbA1c8Moderate_Stat.csv",sep=""))
    remove(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd, hbA1cStat)
    remove(psScore, matchedPop, studyPop, balance)
  }else
  {
    print(paste("You don't seems to have results for the bigToSulf and bigToThia comparision"))
  }
  #---- For tcThree
  if(length(tcThree)!=0){
    resFilesOutCome5tcThree <- resFilesOutCome5[tcThree]
    #load the data
    ps <- grep("Ps",resFilesOutCome5tcThree)
    psScore <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[ps],sep=""))
    matchPop <- grep("StratPop",resFilesOutCome5tcThree)
    matchedPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[matchPop],sep=""))
    studPop <- grep("StudyPop", resFilesOutCome5tcThree)
    studyPop <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[studPop],sep=""))
    bl <- grep("Bal",resFilesOutCome5tcThree)
    balance <- readRDS(paste(results_path,"deleteMeBeforeSharing/",resFilesOutCome5tcThree[bl],sep=""))
    remove(ps,matchPop,studPop,bl)
    conn <- DatabaseConnector::connect(connectionDetails)
    insertTable(conn,
                "ohdsiT2DstudyPop",
                studyPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(studyPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(studyPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    unMatchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    unMatchedHbA1cMeanSd$class <- c("unMatched")
    remove(HbA1cBefTx, HbA1cAfTx)
    # Matched Cohort
    insertTable(conn,
                "ohdsiT2DstudyPop",
                matchedPop,
                dropTableIfExists = TRUE,
                createTable = TRUE,
                tempTable = TRUE,
                oracleTempSchema = NULL)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE < CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.measurement_date >= dateadd(day,
                    -365,
                    CAST(o.COHORTSTARTDATE AS DATE)) AND m.measurement_date <= CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cBefTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    sqlOne <- paste("SELECT o.treatment,
                    count(DISTINCT m.person_id) AS patients,
                    count(*)
                    AS records,
                    AVG(m.VALUE_AS_NUMBER) AS AVG,
                    STDEV(m.VALUE_AS_NUMBER) AS STD
                    FROM @cdmDatabaseSchema.MEASUREMENT m
                    JOIN #ohdsiT2DstudyPop o
                    ON m.person_id = o.SUBJECTID
                    WHERE m.measurement_concept_id IN (3004410,
                    3007263,
                    3003309,
                    3005673,
                    40762352,
                    40758583,
                    3034639,
                    4197971)
                    AND m.MEASUREMENT_DATE > CAST(o.COHORTSTARTDATE AS DATE)
                    AND m.VALUE_AS_NUMBER < 20
                    GROUP BY o.treatment", sep = "")
    sqlOne <- SqlRender::renderSql(sqlOne, cdmDatabaseSchema = cdmDatabaseSchema)$sql
    sqlOne <- SqlRender::translateSql(sqlOne, targetDialect = connectionDetails$dbms)$sql
    HbA1cAfTx <- querySql(conn, sqlOne)
    remove(sqlOne)
    HbA1cBefTx$TcPatients <- NA
    HbA1cBefTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cBefTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cBefTx$Index <- c("Before")
    HbA1cAfTx$TcPatients <- NA
    HbA1cAfTx$TcPatients[1] <- nrow(subset(matchedPop, treatment == 0))
    HbA1cAfTx$TcPatients[2] <- nrow(subset(matchedPop, treatment == 1))
    HbA1cAfTx$Index <- c("After")
    matchedHbA1cMeanSd <- rbind(HbA1cBefTx, HbA1cAfTx)
    matchedHbA1cMeanSd$class <- c("matched")
    remove(HbA1cBefTx, HbA1cAfTx)
    hbA1cStat <- rbind(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd)
    write.csv(hbA1cStat, file = paste(results_path,"bigToDpp4_bigToThia_HbA1c8Moderate_Stat.csv",sep=""))
    remove(unMatchedHbA1cMeanSd, matchedHbA1cMeanSd, hbA1cStat)
    remove(psScore, matchedPop, studyPop, balance)
  }else
  {
    print(paste("You don't seems to have results for the bigToDpp4 and bigToThia comparision"))
  }
  #----------------------------------------------------------------------
}
