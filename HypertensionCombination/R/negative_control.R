negative_control_result <- function(connectionDetails, cdmDatabaseSchema, outputFolder) {
    exportFolder <- file.path(outputFolder, "export")
    cmOutputFolder <- file.path(outputFolder, "cmOutput")
    
    if (!file.exists(exportFolder))
        dir.create(exportFolder)
    
    if (!file.exists(cmOutputFolder))
        dir.create(cmOutputFolder)
    
    if (!file.exists(MainresultFolder))
        dir.create(MainresultFolder)
    
    result<-read.csv(file.path(exportFolder, "MainResults.csv"))
    
    neg_outcome<-result %>%
        select(comparatorId,targetId, outcomeId, analysisId, rr, ci95lb,
               ci95ub,p,treated,comparator,eventsTreated,eventsComparator) %>%
        filter(!is.na(rr)) %>%
        filter(outcomeId!=0)
    
    
    connection<-DatabaseConnector::connect(connectionDetails)
    
    ##ADDING outcome name from concept table
    unique_neg_outcome<-paste("(",paste(unique(neg_outcome$outcomeId),collapse=","),")",sep="")
    sql <- "SELECT CONCEPT_ID, CONCEPT_NAME
    FROM @cdmDatabaseSchema.CONCEPT
    WHERE CONCEPT_ID IN @unique_neg_outcome"
    sql <- renderSql(sql,
                     cdmDatabaseSchema=cdmDatabaseSchema,
                     unique_neg_outcome=unique_neg_outcome)$sql
    sql <- translateSql(sql,
                        targetDialect=connectionDetails$dbms)$sql
    neg_out_name <- querySql(connection, sql)
    colnames(neg_out_name)<-tolower(colnames(neg_out_name))
    
    neg_outcome%>%arrange(desc(eventsTreated))
    
    neg_outcome<-merge(x=neg_outcome,y=neg_out_name, by.x="outcomeId", by.y="concept_id", all.x=TRUE)
    
    #################################################
    AD_AC_neg_30<-neg_outcome %>%
        filter(analysisId==30)%>%
        filter(comparatorId ==14&targetId==13)
    
    AC_CD_neg_30<-neg_outcome %>%
        filter(analysisId==30)%>%
        filter(comparatorId ==13&targetId==34)
    
    AD_CD_neg_30<-neg_outcome %>%
        filter(analysisId==30)%>%
        filter(comparatorId ==14&targetId==34)
    
    AD_AC_neg_180<-neg_outcome %>%
        filter(analysisId==180)%>%
        filter(comparatorId ==14&targetId==13)
    
    AC_CD_neg_180<-neg_outcome %>%
        filter(analysisId==180)%>%
        filter(comparatorId ==13&targetId==34)
    
    AD_CD_neg_180<-neg_outcome %>%
        filter(analysisId==180)%>%
        filter(comparatorId ==14&targetId==34)
    
    FP_prop<-function(data=data){
        df<-data.frame(
            total_neg_control = sum(!is.na(data$p)),
            FP_neg_control = sum(data$p<0.05,na.rm=TRUE),
            FP_prop= (sum(data$p<0.05,na.rm=TRUE)/sum(!is.na(data$p)))
        )
        return(df)
    }
    
    
    sum(data$p<0.05,na.rm=TRUE)/sum(!is.na(data$p))
    
    FP_list<-function(data=data){
        return(data %>%
                   filter(p<0.05) %>%
                   arrange(p))
    }
    
    FP_prop(AD_AC_neg_30) #0.1282051
    FP_prop(AC_CD_neg_30) #0.02564103
    FP_prop(AD_CD_neg_30) #0.1538462
    
    FP_list(AD_AC_neg_30)
    FP_list(AC_CD_neg_30)
    FP_list(AD_CD_neg_30)
    
    FP_prop(AD_AC_neg_180) #0.1025641
    FP_prop(AC_CD_neg_180) #0.07692308
    FP_prop(AD_CD_neg_180) #0.1025641
    
    FP_list(AD_AC_neg_180)
    FP_list(AC_CD_neg_180) 
    FP_list(AD_CD_neg_180)
    
    FP_list<-rbind(FP_list(AD_AC_neg_180),FP_list(AC_CD_neg_180),FP_list(AD_CD_neg_180))
    FP_prop<-data.frame(rbind(FP_prop(AD_AC_neg_180),FP_prop(AC_CD_neg_180),FP_prop(AD_CD_neg_180)),row.names = c("AD_AC","AC_CD","AD_CD"))
    
    write.csv(FP_list,file.path(cmOutputFolder, "FP_list.csv"))
    write.csv(FP_prop,file.path(cmOutputFolder, "FP_prop.csv"))
}



