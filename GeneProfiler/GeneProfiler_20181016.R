
library(shiny)
library(xlsx)
library(shinydashboard)
library(SqlRender)
library(DatabaseConnector)
library(dplyr)
library(GenVisR)

############################################

shinyApp(
  
  # UI Definition
  
  ui <- dashboardPage(
    
    #1
    dashboardHeader(title='G-CDM'),
    
    #2
    dashboardSidebar(sidebarMenu(menuItem('DB connection', tabName='db'),
                                 menuItem('Overall Profile', tabName='WaterFall'),
                                 menuItem('Mutation Type', tabName='MutationType'),
                                 menuItem('Pathogeny', tabName='PathogenyPlot'),
                                 menuItem('Gene', tabName='GenePlot'),
                                 menuItem('Variant', tabName='VariantTable')
                                 )),
    
    #3
    dashboardBody(
      
      tabItems(
        
        #3-1 DB Connection
        tabItem(tabName='db',
                fluidRow(
                  titlePanel('Database Connection'),
                  
                  sidebarPanel(
                    #input text to db information
                    textInput("ip","IP")
                    ,textInput("user","USER")
                    ,passwordInput("pw","PASSWORD")
                    ,textInput("schema","GCDM Database")
                    ,textInput("Cohort_table","Cohort Table")
                    ,actionButton("db_load","Load DB")
                    ,width=10),
                  
                  mainPanel(
                    verbatimTextOutput("txt"),
                    tableOutput("view")))),
        
        
        # 3-2 WaterFall
        tabItem(tabName = "WaterFall",
                fluidRow(
                  titlePanel("Overall Mutation Profile"),
                  
                  sidebarPanel(
                    actionButton(inputId = 'Show_WF', label = 'Go!'), width=2),
  
                  mainPanel(
                    plotOutput(outputId = "WF_Plot"), width=12)
                  )),
        
        
        # 3-3 Mutation Type
        tabItem(tabName = "MutationType",
                fluidRow(
                  titlePanel("Mutation Type"),
                  
                  sidebarPanel(
                    actionButton(inputId = 'Show_MutationType', label = 'Go!'), width=2),
                  
                  mainPanel(
                    plotOutput(outputId = "MutationType_Plot"), width=12)
                )),
        
        
        # 3-4 Pathogeny Plot
        tabItem(tabName = "PathogenyPlot",
                fluidRow(
                  titlePanel("Pathogeny Plot"),
                  
                  sidebarPanel(
                    actionButton(inputId = 'Show_Pathogeny', label = 'Go!'), width=2),
                  
                  mainPanel(
                    plotOutput(outputId = "Pathogeny_Plot"), width=12)
                )),
        
        
        
        # 3-5 Pathogeny & Drug Response Genes
        tabItem(tabName = "GenePlot",
                fluidRow(
                  titlePanel("Gene Plot"),
                  
                  sidebarPanel(
                    actionButton(inputId = 'Show_GenePlot', label = 'Go!'), width=2),
                  
                  mainPanel(
                    plotOutput(outputId = "GenePlot"), width=12)
                )), 
        
        
        # 3-6 Variant
        tabItem(tabName = "VariantTable",
                fluidRow(
                  titlePanel("Variant Table"),
                  
                  sidebarPanel(
                    actionButton(inputId = 'Show_VariantTable', label = 'Go!'), width=2),
                  
                  mainPanel(
                    tableOutput(outputId = "VariantTable"), width=12)
                ))
        
      ))), # End of dashboardPage
                
  
  
############################################################
 


  server <- function(input, output, session) {
    

    ##### 3-1 DB Connection
    cohort_personID <- eventReactive(input$db_load, {
      connectionDetails <<- DatabaseConnector::createConnectionDetails(dbms="sql server", 
                                                                      server=input$ip,
                                                                      user=input$user,
                                                                      password=input$pw,
                                                                      schema=input$schema)
      
      connection <<- DatabaseConnector::connect(connectionDetails)

      sql <- "SELECT distinct subject_id FROM @schema.dbo.@Cohort_table order by subject_id"
      sql <- SqlRender::renderSql(sql, schema=input$schema, Cohort_table=input$Cohort_table)$sql
      sql <- SqlRender::translateSql(sql, targetDialect=connectionDetails$dbms)$sql
      cohort_personID <<- DatabaseConnector::querySql(connection, sql)})
    
    #cohort_personID <- cohort_personID()
    
    
    
    
    ##### 3-2 WaterFall Plot
    draw.WF <- eventReactive(input$Show_WF, {
      
      connectionDetails <<- DatabaseConnector::createConnectionDetails(dbms="sql server", 
                                                                       server=input$ip,
                                                                       user=input$user,
                                                                       password=input$pw,
                                                                       schema=input$schema)
      
      connection <<- DatabaseConnector::connect(connectionDetails)
      
      sql <- "SELECT A.person_id, B.target_gene_source_value, A.hgvs_p, A.sequence_alteration, A.variant_feature
              FROM (SELECT * FROM @schema.dbo.variant_occurrence 
              WHERE person_id IN (SELECT distinct subject_id FROM @schema.dbo.@Cohort_table)) A
              LEFT OUTER JOIN @schema.dbo.[target_gene] B ON A.target_gene_id = B.target_gene_concept_id"
      sql <- SqlRender::renderSql(sql, schema=input$schema, Cohort_table=input$Cohort_table)$sql
      sql <- SqlRender::translateSql(sql, targetDialect=connectionDetails$dbms)$sql
      cohort_variant <- DatabaseConnector::querySql(connection, sql)
      # View(cohort_variant)
      
      cohort_variant$VARIANT_FEATURE[cohort_variant$SEQUENCE_ALTERATION == 'Amplification'] <- 'Amplification'
      
      cohort_variant$VARIANT_FEATURE[cohort_variant$SEQUENCE_ALTERATION == 'Deletion'] <- 'Deletion'
      
      cohort_variant <- cohort_variant[complete.cases(cohort_variant[ , c("VARIANT_FEATURE")]), ]

      cohort_variant <- cohort_variant[cohort_variant$VARIANT_FEATURE!='Intron', ]

      cohort_variant <- cohort_variant[cohort_variant$VARIANT_FEATURE!='Synonymous', ]

      cohort_variant <- cohort_variant[cohort_variant$VARIANT_FEATURE!='Other', ]

      cohort_variant <- cohort_variant[complete.cases(cohort_variant[ , c("TARGET_GENE_SOURCE_VALUE")]), ]


      # Create a data frame of random elements to plot
      inputData <- data.frame("sample" = cohort_variant$PERSON_ID,
                              "gene" = cohort_variant$TARGET_GENE_SOURCE_VALUE,
                              "variant_class" = cohort_variant$VARIANT_FEATURE)
      colnames(inputData) <- c('sample', 'gene', 'variant_class')

      table <- as.data.frame(table(inputData$variant_class))
      table <- table[order(-table$Freq), ]
      
      # choose the most deleterious to plot with y being defined as the most deleterious
      most_deleterious <- as.character(table$Var1)
      
      waterfall(inputData, fileType="Custom", variant_class_order = most_deleterious, plotMutBurden = FALSE, 
                mainXlabel = TRUE, maxGenes=50, mainGrid = TRUE, mainLabelSize = 1,
                plot_proportions = TRUE, section_heights = c(0, 400, 60))
      
    }) # End of draw.WF
    
      output$WF_Plot <- renderPlot({draw.WF()}, execOnResize = TRUE) 
      
      
      
      
      
      ##### 3-3 Mutation Type
      
      draw.MutationType <- eventReactive(input$Show_MutationType, {
        
        connectionDetails <<- DatabaseConnector::createConnectionDetails(dbms="sql server", 
                                                                         server=input$ip,
                                                                         user=input$user,
                                                                         password=input$pw,
                                                                         schema=input$schema)
        
        connection <<- DatabaseConnector::connect(connectionDetails)
        
        sql <- "SELECT A.person_id, B.target_gene_source_value, A.hgvs_p, A.sequence_alteration, A.variant_feature
              FROM (SELECT * FROM @schema.dbo.variant_occurrence 
        WHERE person_id IN (SELECT distinct subject_id FROM @schema.dbo.@Cohort_table)) A
        LEFT OUTER JOIN @schema.dbo.[target_gene] B ON A.target_gene_id = B.target_gene_concept_id"
        sql <- SqlRender::renderSql(sql, schema=input$schema, Cohort_table=input$Cohort_table)$sql
        sql <- SqlRender::translateSql(sql, targetDialect=connectionDetails$dbms)$sql
        cohort_forMT <- DatabaseConnector::querySql(connection, sql)
   
        par(mfrow=c(1,2))

        Tbl4BarPlot <- as.data.frame(table(cohort_forMT$SEQUENCE_ALTERATION))
        for (i in 1:dim(Tbl4BarPlot)[1]){
          Tbl4BarPlot$Proportion[i] <- Tbl4BarPlot$Freq[i]/sum(Tbl4BarPlot$Freq)
        }
        Tbl4BarPlot <- Tbl4BarPlot[order(-Tbl4BarPlot$Proportion),]
        barplot(Tbl4BarPlot$Proportion, names.arg = Tbl4BarPlot$Var1,
                xlab="Sequence Alteration", ylab = 'Fraction of Mutation Type', ylim=c(0:1))
        
        Tbl4BarPlot <- as.data.frame(table(cohort_forMT$VARIANT_FEATURE))
        for (i in 1:dim(Tbl4BarPlot)[1]){
          Tbl4BarPlot$Proportion[i] <- Tbl4BarPlot$Freq[i]/sum(Tbl4BarPlot$Freq)
        }
        Tbl4BarPlot <- Tbl4BarPlot[order(-Tbl4BarPlot$Proportion),]
        barplot(Tbl4BarPlot$Proportion, names.arg = Tbl4BarPlot$Var1,
                xlab="Sequence Alteration", ylab = 'Fraction of Mutation Type', ylim=c(0:1))
        
      }) # End of draw.MutationType
      
      output$MutationType_Plot <- renderPlot({draw.MutationType()}, execOnResize = TRUE) 
      
      
      
      
      
      ##### 3-4 Pathogeny Plot
      
      draw.PathogenyPlot <- eventReactive(input$Show_Pathogeny, {
        
        connectionDetails <<- DatabaseConnector::createConnectionDetails(dbms="sql server", 
                                                                         server=input$ip,
                                                                         user=input$user,
                                                                         password=input$pw,
                                                                         schema=input$schema)
        
        connection <<- DatabaseConnector::connect(connectionDetails)
        
        sql <- "SELECT A.person_id, B.target_gene_source_value, A.variant_exon_number, 
                       A.hgvs_p, A.sequence_alteration, A.variant_feature,
                       C.variant_origin, C.variant_pathogeny
                FROM (SELECT * FROM @schema.dbo.variant_occurrence 
                      WHERE person_id IN (SELECT subject_id FROM @schema.dbo.@Cohort_table)) A
                LEFT OUTER JOIN @schema.dbo.[target_gene] B ON A.target_gene_id = B.target_gene_concept_id
                LEFT OUTER JOIN @schema.dbo.[variant_annotation] C ON A.variant_occurrence_id = C.variant_occurrence_id"
        sql <- SqlRender::renderSql(sql, schema=input$schema, Cohort_table=input$Cohort_table)$sql
        sql <- SqlRender::translateSql(sql, targetDialect=connectionDetails$dbms)$sql
        cohort_forPathogeny <<- DatabaseConnector::querySql(connection, sql)
  
        
        par(mfrow=c(1,2))
        
        Tbl4PiePlot <- as.data.frame(table(cohort_forPathogeny$VARIANT_ORIGIN))
        slices <- Tbl4PiePlot$Freq
        lbls <- as.character(Tbl4PiePlot$Var1)
        pct <- round(slices/sum(slices)*100)
        lbls <- paste(lbls, pct) # add percents to labels 
        lbls <- paste(lbls,"%",sep="") # ad % to labels 
        pie(slices, labels = lbls, main="Proportion of Variant Origin", clockwise = TRUE)
        
        Tbl4PiePlot <- as.data.frame(table(cohort_forPathogeny$VARIANT_PATHOGENY))
        slices <- Tbl4PiePlot$Freq
        lbls <- as.character(Tbl4PiePlot$Var1)
        pct <- round(slices/sum(slices)*100)
        lbls <- paste(lbls, pct) # add percents to labels 
        lbls <- paste(lbls,"%",sep="") # ad % to labels 
        pie(slices, labels = lbls, main="Proportion of Variant Pathogeny", clockwise = TRUE )
        
      }) # End of draw.PathogenyPlot
      
      output$Pathogeny_Plot <- renderPlot({draw.PathogenyPlot()}, execOnResize = TRUE) 
      
      
      
      
      ##### 3-5 Pathogeny & Drug Response Genes
      
      draw.GenePlot <- eventReactive(input$Show_GenePlot, {
        
        connectionDetails <<- DatabaseConnector::createConnectionDetails(dbms="sql server", 
                                                                         server=input$ip,
                                                                         user=input$user,
                                                                         password=input$pw,
                                                                         schema=input$schema)
        
        connection <<- DatabaseConnector::connect(connectionDetails)
        
        sql <- "SELECT A.person_id, B.target_gene_source_value, A.variant_exon_number, 
        A.hgvs_p, A.sequence_alteration, A.variant_feature,
        C.variant_origin, C.variant_pathogeny
        FROM (SELECT * FROM @schema.dbo.variant_occurrence 
        WHERE person_id IN (SELECT subject_id FROM @schema.dbo.@Cohort_table)) A
        LEFT OUTER JOIN @schema.dbo.[target_gene] B ON A.target_gene_id = B.target_gene_concept_id
        LEFT OUTER JOIN @schema.dbo.[variant_annotation] C ON A.variant_occurrence_id = C.variant_occurrence_id"
        sql <- SqlRender::renderSql(sql, schema=input$schema, Cohort_table=input$Cohort_table)$sql
        sql <- SqlRender::translateSql(sql, targetDialect=connectionDetails$dbms)$sql
        cohort_forPathogeny <<- DatabaseConnector::querySql(connection, sql)
        # View(cohort_forPathogeny)
        
        cohort_forGenes <<- cohort_forPathogeny[cohort_forPathogeny$VARIANT_PATHOGENY %in% 
                                                 c('Pathogenic/Likely pathogenic', 'Drug response') &
                                                 cohort_forPathogeny$VARIANT_ORIGIN %in% 'somatic', ]
        Tbl4Gene <- as.data.frame(table(cohort_forGenes$TARGET_GENE_SOURCE_VALUE))
        Tbl4Gene <- Tbl4Gene[order(-Tbl4Gene$Freq),]
        par(mfrow=c(1,1))
        slices <- Tbl4Gene$Freq
        lbls <- as.character(Tbl4Gene$Var1)
        pct <- round(slices/sum(slices)*100)
        lbls <- paste(lbls, pct) # add percents to labels
        lbls <- paste(lbls,"%",sep="") # ad % to labels
        pie(slices, labels = lbls, main="Proportion of Pathogeny & Drug Response Genes", clockwise = TRUE )
      }) # End of draw.GenePlot
      
      output$GenePlot <- renderPlot({draw.GenePlot()}, execOnResize = TRUE) 
      
      
      
      
      ##### 3-6 Variant
      
      draw.VariantTable <- eventReactive(input$Show_VariantTable, {
        
        connectionDetails <<- DatabaseConnector::createConnectionDetails(dbms="sql server", 
                                                                         server=input$ip,
                                                                         user=input$user,
                                                                         password=input$pw,
                                                                         schema=input$schema)
        
        connection <<- DatabaseConnector::connect(connectionDetails)
        
        sql <- "SELECT A.person_id, B.target_gene_source_value, A.variant_exon_number, 
        A.hgvs_p, A.sequence_alteration, A.variant_feature,
        C.variant_origin, C.variant_pathogeny
        FROM (SELECT * FROM @schema.dbo.variant_occurrence 
        WHERE person_id IN (SELECT subject_id FROM @schema.dbo.@Cohort_table)) A
        LEFT OUTER JOIN @schema.dbo.[target_gene] B ON A.target_gene_id = B.target_gene_concept_id
        LEFT OUTER JOIN @schema.dbo.[variant_annotation] C ON A.variant_occurrence_id = C.variant_occurrence_id"
        sql <- SqlRender::renderSql(sql, schema=input$schema, Cohort_table=input$Cohort_table)$sql
        sql <- SqlRender::translateSql(sql, targetDialect=connectionDetails$dbms)$sql
        cohort_forPathogeny <<- DatabaseConnector::querySql(connection, sql)
        
        cohort_forGenes <<- cohort_forPathogeny[cohort_forPathogeny$VARIANT_PATHOGENY %in% 
                                                  c('Pathogenic/Likely pathogenic', 'Drug response') &
                                                  cohort_forPathogeny$VARIANT_ORIGIN %in% 'somatic', ]
        
        
        colnames(cohort_forGenes) <- c('Person', 'Gene', 'Exon', 'HGVSp', 
                                       'Sequence Alteration', 'Variant Feature', 'Origin', 'Pathogeny')
        cohort_forGenes <- cohort_forGenes[order(cohort_forGenes$Gene),]
        cohort_forGenes
        
      }) # End of draw.VariantTable
      
      output$VariantTable <- renderTable({draw.VariantTable()}, execOnResize = TRUE) 
      
      
    
  } # End of server
)
