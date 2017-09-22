library(shiny)
library(DT)

shinyUI(
  fluidPage(style = 'width:1100px;',
    titlePanel("OHDSI Population-Level Estimation Method Evaluation"),
      fluidRow(
        column(3,
               selectInput("evalType", label = span("Evaluation type", title = "Type of task to evaluate."), choices = c("Effect estimation", "Comparative effect estimation")),
               selectInput("calibrated", label = span("Empirical calibration", title = "Should empirical calibration be applied before computing performance metrics?"), choices = c("Uncalibrated", "Calibrated")),
               selectInput("mdrr", label = span("Minimum Detectable RR", title = "Minimum detectable relative risk used to filter the controls before computing performance metrics."), choices = c("All", "4", "2", "1.5", "1.25"), selected = "1.25"),
               selectInput("db", label = span("Database", title = "The database on which the methods were executed"), choices = dbs),
               selectInput("stratum", label = span("Stratum", title = "Limiting the performance metrics to a single outcome (for exposure controls) or exposure (for outcome controls)."), choices = strata),
               selectInput("trueRr", label = span("True effect size", title = "The true effect size to be considered when computing the performance metrics."), choices = trueRrs),
               checkboxGroupInput("method", label = span("Method", title = "Methods to include in the evaluation."), choices = methods$method)
               
          ),
        column(9,
               dataTableOutput("performanceMetrics"),
               h4(textOutput("details")),
               conditionalPanel(condition = "output.details",
                  actionButton("showSettings", "Show settings"),
                  plotOutput("estimates", height = "250px")
               )
        )
      )
  )
)
        
    
