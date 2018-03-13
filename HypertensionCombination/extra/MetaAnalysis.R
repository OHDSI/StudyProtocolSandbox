ResultFolder<-"C:/Users/apple/OneDrive/Study/OHDSI_HTN_combi/Results/metaanalysis"

plotMetaAnalysisForest <- function(logRr, 
                                   logLb95Ci, 
                                   logUb95Ci, 
                                   labels, 
                                   xLabel = "Relative risk", 
                                   limits = c(0.1, 10), 
                                   hakn = TRUE,
                                   fileName = NULL) {
    seLogRr <- (logUb95Ci-logLb95Ci) / (2 * qnorm(0.975))
    meta <- meta::metagen(logRr, seLogRr, studlab = labels, sm = "RR", hakn = hakn)
    s <- summary(meta)
    print(s)
    rnd <- s$random
    summaryLabel <- sprintf("Summary (I\u00B2 = %.2f)", s$I2$TE)
    d1 <- data.frame(logRr = -100,
                     logLb95Ci = -100,
                     logUb95Ci = -100,
                     name = "Source",
                     type = "header")
    d2 <- data.frame(logRr = logRr,
                     logLb95Ci = logLb95Ci,
                     logUb95Ci = logUb95Ci,
                     name = labels,
                     type = "db")
    d3 <- data.frame(logRr = rnd$TE,
                     logLb95Ci = rnd$lower,
                     logUb95Ci = rnd$upper,
                     name = summaryLabel,
                     type = "ma")
    
    d <- rbind(d1, d2, d3)
    d$name <- factor(d$name, levels = c(summaryLabel, rev(as.character(labels)), "Source"))
    
    breaks <- c(0.1, 0.25, 0.5, 1, 2, 4, 6, 8, 10)
    p <- ggplot2::ggplot(d,ggplot2::aes(x = exp(logRr), y = name, xmin = exp(logLb95Ci), xmax = exp(logUb95Ci))) +
        ggplot2::geom_vline(xintercept = breaks, colour = "#AAAAAA", lty = 1, size = 0.2) +
        ggplot2::geom_vline(xintercept = 1, size = 0.5) +
        ggplot2::geom_errorbarh(height = 0.15) +
        ggplot2::geom_point(size=3, shape = 23, ggplot2::aes(fill=type)) +
        ggplot2::scale_fill_manual(values = c("#000000", "#000000", "#FFFFFF")) +
        ggplot2::scale_x_continuous(xLabel, trans = "log10", breaks = breaks, labels = breaks) +
        ggplot2::coord_cartesian(xlim = limits) +
        ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                       panel.grid.minor = ggplot2::element_blank(),
                       panel.background = ggplot2::element_blank(),
                       legend.position = "none",
                       panel.border = ggplot2::element_blank(),
                       axis.text.y = ggplot2::element_blank(),
                       axis.title.y = ggplot2::element_blank(),
                       axis.ticks = ggplot2::element_blank(),
                       plot.margin = grid::unit(c(0,0,0.1,0), "lines"))
    
    labels <- paste0(formatC(exp(d$logRr),  digits = 2, format = "f"),
                     " (",
                     formatC(exp(d$logLb95Ci), digits = 2, format = "f"),
                     "-",
                     formatC(exp(d$logUb95Ci), digits = 2, format = "f"),
                     ")")
    
    labels <- data.frame(y = rep(d$name, 2),
                         x = rep(1:2, each = nrow(d)),
                         label = c(as.character(d$name), labels),
                         stringsAsFactors = FALSE)
    labels$label[nrow(d) + 1] <-  paste(xLabel,"(95% CI)")
    data_table <- ggplot2::ggplot(labels, ggplot2::aes(x = x, y = y, label = label)) +
        ggplot2::geom_text(size = 4, hjust=0, vjust=0.5) +
        ggplot2::geom_hline(ggplot2::aes(yintercept=nrow(d) - 0.5)) +
        ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                       panel.grid.minor = ggplot2::element_blank(),
                       legend.position = "none",
                       panel.border = ggplot2::element_blank(),
                       panel.background = ggplot2::element_blank(),
                       axis.text.x = ggplot2::element_text(colour="white"),
                       axis.text.y = ggplot2::element_blank(),
                       axis.ticks = ggplot2::element_line(colour="white"),
                       plot.margin = grid::unit(c(0,0,0.1,0), "lines")) +
        ggplot2::labs(x="",y="") +
        ggplot2::coord_cartesian(xlim=c(1,3))
    
    plot <- gridExtra::grid.arrange(data_table, p, ncol=2)
    
    if (!is.null(fileName))
        ggplot2::ggsave(fileName, plot, width = 7, height = 1 + length(logRr) * 0.3, dpi = 400)
    return(plot)
}

resultFolder<-"C:/Users/apple/OneDrive/Study/OHDSI_HTN_combi/Results"
"D:/htn_combi/17.7.10/output/output/180/export/MainResults.csv"

nhis<-read.csv(file.path("D:/htn_combi/17.7.10/output/output/180/export/MainResults.csv"))
medicare<-read.csv(file.path(resultFolder,"Janssen Medicare Files (1)/180/MainResults.csv"))
medicaid<-read.csv(file.path(resultFolder,"Janssen Medicaid Files/180/MainResults.csv"))

nhisFolder<-"D:/htn_combi/17.8.7/output/export"
medicareFolder<-"C:/Users/apple/OneDrive/Study/OHDSI_HTN_combi/Results/Janssen Medicare Files (1)"
medicaidFolder<-"C:/Users/apple/OneDrive/Study/OHDSI_HTN_combi/Results/Janssen Medicaid Files"

targetid<-13180
comparatorid<-14180

targetid<-34180
comparatorid<-13180

targetid<-34180
comparatorid<-14180

outcomeid<-0



outcomeidset<-c(0, 2, 3,4, 4320)

for (outcomeid in outcomeidset){
    nhis_outcome<-nhis[nhis$outcomeId == outcomeid,]
    medicare_outcome<-medicare[medicare$outcomeId == outcomeid,]
    medicaid_outcome<-medicaid[medicaid$outcomeId == outcomeid, ]
    for (j in 1:3){
        switch(j,
               {targetid<-13180
               comparatorid<-14180
               },
               {
                targetid<-34180
                comparatorid<-13180       
               },
               {targetid<-34180
               comparatorid<-14180})
            
        pdf(file.path(ResultFolder,paste0("t",targetid,"c",comparatorid,"o",outcomeid,".pdf")))
        plotMetaAnalysisForest(logRr = c(nhis_outcome[ (nhis_outcome$comparatorId==comparatorid & nhis_outcome$targetId == targetid), ]$logRr ,
                                         medicare_outcome[ (medicare_outcome$comparatorId==comparatorid & medicare_outcome$targetId == targetid), ]$logRr,
                                         medicaid_outcome[ (medicaid_outcome$comparatorId==comparatorid & medicaid_outcome$targetId == targetid), ]$logRr),
                               logLb95Ci = log(
                                   c(nhis_outcome[ (nhis_outcome$comparatorId==comparatorid & nhis_outcome$targetId == targetid), ]$ci95lb ,
                                     medicare_outcome[ (medicare_outcome$comparatorId==comparatorid & medicare_outcome$targetId == targetid), ]$ci95lb,
                                     medicaid_outcome[ (medicaid_outcome$comparatorId==comparatorid & medicaid_outcome$targetId == targetid), ]$ci95lb)
                               ),
                               logUb95Ci = log(
                                   c(nhis_outcome[ (nhis_outcome$comparatorId==comparatorid & nhis_outcome$targetId == targetid), ]$ci95ub ,
                                     medicare_outcome[ (medicare_outcome$comparatorId==comparatorid & medicare_outcome$targetId == targetid), ]$ci95ub,
                                     medicaid_outcome[ (medicaid_outcome$comparatorId==comparatorid & medicaid_outcome$targetId == targetid), ]$ci95ub)
                               ),
                               labels = c("NHIS", "Medicare", "Medicaid"),
                               limits = c(0.2, 5)
        )
        dev.off()
        png(file.path(ResultFolder,paste0("t",targetid,"c",comparatorid,"o",outcomeid,".png")))
        plotMetaAnalysisForest(logRr = c(nhis_outcome[ (nhis_outcome$comparatorId==comparatorid & nhis_outcome$targetId == targetid), ]$logRr ,
                                         medicare_outcome[ (medicare_outcome$comparatorId==comparatorid & medicare_outcome$targetId == targetid), ]$logRr,
                                         medicaid_outcome[ (medicaid_outcome$comparatorId==comparatorid & medicaid_outcome$targetId == targetid), ]$logRr),
                               logLb95Ci = log(
                                   c(nhis_outcome[ (nhis_outcome$comparatorId==comparatorid & nhis_outcome$targetId == targetid), ]$ci95lb ,
                                     medicare_outcome[ (medicare_outcome$comparatorId==comparatorid & medicare_outcome$targetId == targetid), ]$ci95lb,
                                     medicaid_outcome[ (medicaid_outcome$comparatorId==comparatorid & medicaid_outcome$targetId == targetid), ]$ci95lb)
                               ),
                               logUb95Ci = log(
                                   c(nhis_outcome[ (nhis_outcome$comparatorId==comparatorid & nhis_outcome$targetId == targetid), ]$ci95ub ,
                                     medicare_outcome[ (medicare_outcome$comparatorId==comparatorid & medicare_outcome$targetId == targetid), ]$ci95ub,
                                     medicaid_outcome[ (medicaid_outcome$comparatorId==comparatorid & medicaid_outcome$targetId == targetid), ]$ci95ub)
                               ),
                               labels = c("NHIS", "Medicare", "Medicaid"),
                               limits = c(0.2, 5)
        )
        dev.off()
        
    }
}



