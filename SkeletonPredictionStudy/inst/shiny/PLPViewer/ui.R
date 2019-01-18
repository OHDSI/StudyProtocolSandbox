# @file Ui.R
#
# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of PatientLevelPrediction
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

library(shiny)
library(plotly)
library(shinycssloaders)
library(shinydashboard)

ui <- shinydashboard::dashboardPage(skin = 'black',
  
  shinydashboard::dashboardHeader(title = "Multiple PLP Viewer", 
                                  
                                  tags$li(div(img(src = 'logo.png',
                                                title = "OHDSI PLP", height = "40px", width = "40px"),
                                            style = "padding-top:0px; padding-bottom:0px;"),
                                          class = "dropdown")
                                  
                                  
                                  ), 
    
        shinydashboard::dashboardSidebar(
          shinydashboard::sidebarMenu(
          shinydashboard::menuItem("Summary", tabName = "Summary", icon = shiny::icon("table")),
          shinydashboard::menuItem("Performance", tabName = "Performance", icon = shiny::icon("bar-chart")),
          shinydashboard::menuItem("Model", tabName = "Model", icon = shiny::icon("clipboard")),
          shinydashboard::menuItem("Log", tabName = "Log", icon = shiny::icon("list"))
        )
        ),
        
        shinydashboard::dashboardBody(
          shinydashboard::tabItems(
            # First tab content
            shinydashboard::tabItem(tabName = "Summary",
                                    
                                    shiny::fluidRow(
                                      shiny::column(2, 
                                                    shiny::h4('Filters'),
                                                    shiny::selectInput('devDatabase', 'Development Database', c('All',unique(as.character(allPerformance$devDatabase)))),
                                                    shiny::selectInput('valDatabase', 'Validation Database', c('All',unique(as.character(allPerformance$valDatabase)))),
                                                    shiny::selectInput('T', 'Target Cohort', c('All',unique(as.character(allPerformance$cohortName)))),
                                                    shiny::selectInput('O', 'Outcome Cohort', c('All',unique(as.character(allPerformance$outcomeName)))),
                                                    shiny::selectInput('riskWindowStart', 'Time-at-risk start:', c('All',unique(allPerformance$riskWindowStart))),
                                                    shiny::selectInput('riskWindowEnd', 'Time-at-risk end:', c('All',unique(as.character(allPerformance$riskWindowEnd)))),
                                                    shiny::selectInput('modelSettingName', 'Model:', c('All',unique(as.character(allPerformance$modelSettingName))))
                                      ),  
                                      shiny::column(10, style = "background-color:#F3FAFC;",
                                                    
                                                    # do this inside tabs:
                                                    shiny::tabsetPanel(
                                                      
                                                      shiny::tabPanel("Results",
                                                    shiny::div(DT::dataTableOutput('summaryTable'), 
                                                               style = "font-size:70%")),
                                                    
                                                    shiny::tabPanel("Model Settings",
                                                    shiny::h3('Model Settings: ', shiny::actionLink("modelhelp", "help")),
                                                    DT::dataTableOutput('modelTable')),
                                                    
                                                    shiny::tabPanel("Population Settings",
                                                    shiny::h3('Population Settings: ', shiny::actionLink("pophelp", "help")),
                                                    DT::dataTableOutput('populationTable')),
                                                    
                                                    shiny::tabPanel("Covariate Settings",
                                                    shiny::h3('Covariate Settings: ', shiny::actionLink("covhelp", "help")),
                                                    DT::dataTableOutput('covariateTable'))
                                                    )
                                                    
                                      )
                                      
                                    )),
            # second tab
            shinydashboard::tabItem(tabName = "Performance", 
                                    
                                    shiny::fluidRow(
                                    tabBox(
                                      title = "Performance", 
                                      # The id lets us use input$tabset1 on the server to find the current tab
                                      id = "tabset1", height = "100%", width='100%',
                                      tabPanel("Summary", 
                                               
                                               shiny::fluidRow(
                                                 shiny::column(width = 4,
                                                 shinydashboard::box(width = 12,
                                                   title = tagList(shiny::icon("question"),"Prediction Question"), status = "info", solidHeader = TRUE,
                                                   shiny::textOutput('info')
                                                 ),
                                                 shinydashboard::box(width = 12,
                                                   title = tagList(shiny::icon("gear"), "Input"), 
                                                   status = "info", solidHeader = TRUE,
                                                   shiny::sliderInput("slider1", 
                                                                      shiny::h5("Threshold value slider: "), 
                                                                      min = 1, max = 100, value = 50, ticks = F),
                                                   shiny::tags$script(shiny::HTML("
                                                                                  $(document).ready(function() {setTimeout(function() {
                                                                                  supElement = document.getElementById('slider1').parentElement;
                                                                                  $(supElement).find('span.irs-max, span.irs-min, span.irs-single, span.irs-from, span.irs-to').remove();
                                                                                  }, 50);})
                                                                                  "))
                                                   )
                                                 
                                                 ),
                                                 
                                                 
                                                 shiny::column(width = 8,
                                                               shinydashboard::box(width = 12,
                                                                                   title = "Dashboard",
                                                                                   status = "warning", solidHeader = TRUE,
                                                                                   shinydashboard::infoBoxOutput("performanceBoxThreshold"),
                                                                                   shinydashboard::infoBoxOutput("performanceBoxIncidence"),
                                                                                   shinydashboard::infoBoxOutput("performanceBoxPPV"),
                                                                                   shinydashboard::infoBoxOutput("performanceBoxSpecificity"),
                                                                                   shinydashboard::infoBoxOutput("performanceBoxSensitivity"),
                                                                                   shinydashboard::infoBoxOutput("performanceBoxNPV")
                                                                                   
                                                               ),
                                                 shinydashboard::box(width = 12,
                                                   title = "Cutoff Performance",
                                                   status = "warning", solidHeader = TRUE,
                                                   shiny::tableOutput('twobytwo')
                                                   #infoBoxOutput("performanceBox"),
                                                 )
                                                 )
                                                 )
                                               
                                               
                                               ),
                                      tabPanel("Discrimination", 
                                               
                                               shiny::fluidRow(
                                               shinydashboard::box( status = 'info',
                                                 title = "ROC Plot", solidHeader = TRUE,
                                                 shinycssloaders::withSpinner(plotly::plotlyOutput('roc'))),
                                               shinydashboard::box(status = 'info',
                                                 title = "Precision recall plot", solidHeader = TRUE,
                                                 side = "right",
                                                 shinycssloaders::withSpinner(plotly::plotlyOutput('pr')))),
                                               
                                               shiny::fluidRow(
                                                 shinydashboard::box(status = 'info',
                                                   title = "F1 Score Plot", solidHeader = TRUE,
                                                   shinycssloaders::withSpinner(plotly::plotlyOutput('f1'))),
                                                 shinydashboard::box(status = 'info',
                                                   title = "Box Plot", solidHeader = TRUE,
                                                   side = "right",
                                                   shinycssloaders::withSpinner(shiny::plotOutput('box')))),
                                               
                                               shiny::fluidRow(
                                                 shinydashboard::box(status = 'info',
                                                   title = "Prediction Score Distribution", solidHeader = TRUE,
                                                   shinycssloaders::withSpinner(shiny::plotOutput('preddist'))),
                                                 shinydashboard::box(status = 'info',
                                                   title = "Preference Score Distribution", solidHeader = TRUE,
                                                   side = "right",
                                                   shinycssloaders::withSpinner(shiny::plotOutput('prefdist'))))
                                               
                                               
                                               ),
                                    tabPanel("Calibration", 
                                             shiny::fluidRow(
                                               shinydashboard::box(status = 'info',
                                                 title = "Calibration Plot", solidHeader = TRUE,
                                                 shinycssloaders::withSpinner(shiny::plotOutput('cal'))),
                                             shinydashboard::box(status = 'info',
                                               title = "Demographic Plot", solidHeader = TRUE,
                                               side = "right",
                                               shinycssloaders::withSpinner(shiny::plotOutput('demo')))
                                    )
                                    )
                                    ))),
            
            # 3rd tab
            shinydashboard::tabItem(tabName = "Model", 
                                    shiny::fluidRow(
                                      shinydashboard::box( status = 'info',
                                                           title = "Binary", solidHeader = TRUE,
                                                           shinycssloaders::withSpinner(plotly::plotlyOutput('covariateSummaryBinary'))),
                                      shinydashboard::box(status = 'info',
                                                          title = "Measurements", solidHeader = TRUE,
                                                          side = "right",
                                                          shinycssloaders::withSpinner(plotly::plotlyOutput('covariateSummaryMeasure')))),
                                    
                                    shiny::fluidRow(width=12,
                                      shinydashboard::box(status = 'info', width = 12,
                                                           title = "Model Table", solidHeader = TRUE,
                                                           DT::dataTableOutput('modelView')))
                                    ),
            
            # 4th tab
            shinydashboard::tabItem(tabName = "Log", 
              shiny::verbatimTextOutput('log')
              )
                       
                       
       )
  )
)
