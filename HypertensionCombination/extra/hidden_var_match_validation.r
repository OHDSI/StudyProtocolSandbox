#rm(list=ls())

library(DatabaseConnector)
library(SqlRender)
library(lubridate)
#library(dplyr)

####################################################################################################################################
####################################################################################################################################
# 437038	Blood in urine
# 2212294	Measurement of creatinine in blood
# 2212597	Measurement of aspartate amino transferase (AST) (SGOT)
# 2212598	Measurement of alanine amino transferase (ALT) (SGPT)
# 3000963	Hemoglobin
# 3007070	Cholesterol in HDL [Mass/volume] in Serum or Plasma
# 3009261	Glucose [Presence] in Urine by Test strip
# 3012888	BP diastolic
# 3014051	Protein [Presence] in Urine by Test strip
# 3015736	pH of Urine
# 3016258	Waist Circumference at umbilicus by Tape measure
# 3022038	Triglyceride [Mass/volume] in Blood
# 3025315	Body weight
# 3027114	Cholesterol [Mass/volume] in Serum or Plasma
# 3028437	Cholesterol in LDL [Mass/volume] in Serum or Plasma
# 3028737	BP systolic
# 3036277	Body height
# 4289475	Gamma glutamyl transferase measurement
# 46235168	Fasting glucose [Moles/volume] in Blood
####################################################################################################################################
####################################################################################################################################

##need to be specified#############################
dataFolder<-"D:/htn_combi/17.6.15"
outputFolder<-"D:/htn_combi/17.6.15/PSMvalidation"
connectionDetails<-readRDS("D:/myconnection.rds")
###################################################

cmoutputfolder<-file.path(dataFolder,"output/cmOutput")
cdmDatabaseSchema <- "NHIS_NSC.dbo"
cdmVersion <- "5" 

measurement_concept_set<-c(3036277,3025315,3016258,3028737,3012888,46235168,2212294,
                           3000963,3022038,3027114,3028437,3007070,4289475,2212597,2212598)
measurement_concept_name_set<-c("height","weight", "waist", "SBP", "DBP", "FastingGlc","Creatinine","Hemoglobin","T.Cholesterol","Triglyceride","LDL","HDL","gGT","AST","ALT")
stratapoplist<-list.files(path=cmoutputfolder, pattern="^Strat.*180.*o0.rds")
studypoplist<-list.files(path=cmoutputfolder, pattern="^Study.*180.*o0.rds")

stratapoplist<-sort(stratapoplist)
studypoplist<-sort(studypoplist)

for (i in seq(length(studypoplist))){
      stratapop<-readRDS(file.path(cmoutputfolder,stratapoplist[i]))
      studypop<-readRDS(file.path(cmoutputfolder,studypoplist[i]))
      
      targetstudypop<-subset(studypop, treatment ==1, select = c(subjectId,cohortStartDate))
      compstudypop<-subset(studypop, treatment ==0, select = c(subjectId,cohortStartDate))
      
      targetstratapop<-subset(stratapop, treatment ==1, select = c(subjectId,cohortStartDate))
      compstratapop<-subset(stratapop, treatment ==0, select = c(subjectId,cohortStartDate))
      
      ##############################################################################################################################################
      ####Target Study Population ##################################################################################################################
      ##draw measurement
      targetstudysubjectid<-paste0("(",paste(targetstudypop$subjectId, collapse=","),")")
      connection<-connect(connectionDetails)
      sql <- "SELECT * FROM @cdmDatabaseSchema.measurement
      where person_id in @targetstudysubjectid"
      sql <- renderSql(sql,
                       cdmDatabaseSchema=cdmDatabaseSchema,
                       targetstudysubjectid=targetstudysubjectid)$sql
      sql <- translateSql(sql,
                          targetDialect=connectionDetails$dbms)$sql
      targetstudymeas <- querySql(connection, sql)
      
      colnames(targetstudymeas)<-tolower(colnames(targetstudymeas))
      targetstudymeas<-dplyr::select(targetstudymeas,person_id, measurement_concept_id, measurement_date, value_as_number, value_as_concept_id, unit_concept_id)
      #length(unique(targetstudypop$subjectId)) #3935
      #length(unique(targetstudymeas$person_id)) #3140
      #nrow(targetstudymeas) #187404
      
      temptargetstudypopmeas<-merge(targetstudypop, targetstudymeas, by.x="subjectId", by.y="person_id", all.x=FALSE,all.y=TRUE)
      rm(targetstudymeas)
      #nrow(targetstudypopmeas) #187404
      #identify population who underwent general examation during the previous year of cohort_start
      #sum(( year(targetstudypopmeas$cohortStartDate)-year(targetstudypopmeas$measurement_date) )==1 ) #17269
      targetstudypopmeas<-subset(temptargetstudypopmeas,( (year(temptargetstudypopmeas$cohortStartDate)-year(temptargetstudypopmeas$measurement_date) )==1) )
      #############################################################################################################################################
      
      
      #############################################################################################################################################
      ####Comparator Study Population ##################################################################################################################
      compstudysubjectid<-paste0("(",paste(compstudypop$subjectId, collapse=","),")")
      
      connection<-connect(connectionDetails)
      sql <- "SELECT * FROM @cdmDatabaseSchema.measurement
      where person_id in @compstudysubjectid"
      sql <- renderSql(sql,
                       cdmDatabaseSchema=cdmDatabaseSchema,
                       compstudysubjectid=compstudysubjectid)$sql
      sql <- translateSql(sql,
                          targetDialect=connectionDetails$dbms)$sql
      compstudymeas <- querySql(connection, sql)
      
      colnames(compstudymeas)<-tolower(colnames(compstudymeas))
      compstudymeas<-dplyr::select(compstudymeas,person_id, measurement_concept_id, measurement_date, value_as_number, value_as_concept_id, unit_concept_id)
      
      #length(unique(compstudypop$subjectId)) #7634
      #length(unique(compstudymeas$person_id)) #6450
      #nrow(compstudymeas) #394335
      
      tempcompstudypopmeas<-merge(compstudypop, compstudymeas, by.x="subjectId", by.y="person_id", all.x=FALSE,all.y=TRUE)
      rm(compstudymeas)
      #nrow(compstudypopmeas) #394335
      
      #identify population who underwent general examation during the previous year of cohort_start
      #sum(( year(compstudypopmeas$cohortStartDate)-year(compstudypopmeas$measurement_date) )==1 ) #34488
      compstudypopmeas<-subset(tempcompstudypopmeas,( (year(tempcompstudypopmeas$cohortStartDate)-year(tempcompstudypopmeas$measurement_date) )==1) )
      ##############################################################################################################
      
      
      ##############################################################################################################
      ##MAKING STRATAPOPMEAS########################################################################################
      targetstratapopmeas<-subset(targetstudypopmeas,subjectId %in% targetstratapop$subjectId)
      compstratapopmeas<-subset(compstudypopmeas,subjectId %in% compstratapop$subjectId)
      
      #nrow(targetStudyPopMeas)
      #nrow(targetStrataPopMeas)
      
      #nrow(compStudyPopMeas)
      #nrow(compStrataPopMeas)
      ##############################################################################################################
      ##############################################################################################################

      ##############################################################################################################
      ##comparsion of sbp in two cohorts ###########################################################################
      df<-data.frame()

      for (j in seq(length(measurement_concept_set))){
        measurement_id<-measurement_concept_set[j]
        value.targetStudy<-subset(targetstudypopmeas,measurement_concept_id ==measurement_id)$value_as_number
        value.compStudy<-subset(compstudypopmeas,measurement_concept_id ==measurement_id)$value_as_number
        
        value.targetStrata<-subset(targetstratapopmeas,measurement_concept_id ==measurement_id)$value_as_number
        value.compStrata<-subset(compstratapopmeas,measurement_concept_id ==measurement_id)$value_as_number
        
        #hist(value.targetStudy)
        #hist(value.compStudy)
        studyF.test<-var.test(value.targetStudy,value.compStudy)
        
        studyF.test$p.value
        
        studyT.test<-t.test(value.targetStudy,value.compStudy,paired=FALSE,var.equal=TRUE,conf.level=0.95)
        studyT.test$p.value
        studyT.test$estimate
        
        strataF.test<-var.test(value.targetStrata,value.compStrata)
        strataF.test$p.value
        
        strataT.test<-t.test(value.targetStrata,value.compStrata,paired=FALSE,var.equal=TRUE,conf.level=0.95)
        strataT.test$p.value
        strataT.test$estimate
        
        data.frame(before.target.n = length(value.targetStudy),
                   before.comparator.n = length(value.compStudy),
                   before.target.mean = studyT.test$estimate[1],
                   before.comparator.mean = studyT.test$estimate[2],
                   before.diff = abs(studyT.test$estimate[2]-studyT.test$estimate[1]),
                   before.p=studyT.test$p.value,
                   after.target.n = length(value.targetStrata),
                   after.comparator.n = length(value.compStrata),
                   after.target.mean = strataT.test$estimate[1],
                   after.comparator.mean = strataT.test$estimate[2],
                   after.diff = abs(strataT.test$estimate[2]-strataT.test$estimate[1]),
                   after.p=strataT.test$p.value
        )
        
        df<-rbind(df,data.frame(before.target.n = length(value.targetStudy),
                                before.comparator.n = length(value.compStudy),
                                before.target.mean = studyT.test$estimate[1],
                                before.comparator.mean = studyT.test$estimate[2],
                                before.diff = abs(studyT.test$estimate[2]-studyT.test$estimate[1]),
                                before.p=studyT.test$p.value,
                                after.target.n = length(value.targetStrata),
                                after.comparator.n = length(value.compStrata),
                                after.target.mean = strataT.test$estimate[1],
                                after.comparator.mean = strataT.test$estimate[2],
                                after.diff = abs(strataT.test$estimate[2]-strataT.test$estimate[1]),
                                after.p=strataT.test$p.value
        ))
        
        ##draw histograms before and after PSM
        
        #remove outlier 
        
        value.all<-c(value.targetStudy,value.compStudy,value.targetStrata,value.compStrata)
        outlier.border<-quantile(value.all,probs = c(0.025,0.975))
        
        value.targetStudy<-value.targetStudy[(value.targetStudy>=outlier.border[1]) & (value.targetStudy<=outlier.border[2])]
        value.compStudy<-value.compStudy[(value.compStudy>=outlier.border[1]) & (value.compStudy<=outlier.border[2])]
        value.targetStrata<-value.targetStrata[(value.targetStrata>=outlier.border[1]) & (value.targetStrata<=outlier.border[2])]
        value.compStrata<-value.compStrata[(value.compStrata>=outlier.border[1]) & (value.compStrata<=outlier.border[2])]
        
        png(file.path(outputFolder,paste0("cohortNo",i,"_",measurement_concept_name_set[j],".png")))
        par(mfrow=c(1,2))
        hist(value.targetStudy, col=rgb(1,0,0,0.5),xlim=outlier.border,#ylim=c(0,0.1), 
             breaks=20,
             #breaks=round(seq(from=quantile(value.all,probs = c(0.05,0.95))[1],quantile(value.all,probs = c(0.05,0.95))[2],length.out=20)),
             prob=T,xlab=measurement_concept_name_set[j],
             main="Before PSM")
        hist(value.compStudy, col=rgb(0,0,1,0.5),xlim=outlier.border,#ylim=c(0,0.1), 
             breaks=20,prob=T,xlab=measurement_concept_name_set[j],
             add=T)
        hist(value.targetStrata, col=rgb(1,0,0,0.5),xlim=outlier.border,#ylim=c(0,0.1), 
             breaks=20,prob=T,xlab=measurement_concept_name_set[j],
             main="After PSM")
        hist(value.compStrata, col=rgb(0,0,1,0.5),xlim=outlier.border,#ylim=c(0,0.1), 
             breaks=20,prob=T,xlab=measurement_concept_name_set[j],
             add=T)
        dev.off()
        
      }
      
      rownames(df)<-measurement_concept_name_set
      print(df)
      write.csv(df,file.path(outputFolder,paste0("matching_meas_value","cohortNo",i,"_",".csv")))
}