library(shiny)
library(DT)

source("plots.R")

shinyServer(function(input, output, session) {
  
  previousSelection <- NULL
  previousPage <- NULL
  
  observe({
    if (input$evalType == "Comparative effect estimation") {
      choices = methods$method[methods$cer == TRUE]
    } else {
      choices = methods$method
    }
    updateCheckboxGroupInput(session, "method", choices = choices, selected = choices)
  })
  
  filterEstimates <- reactive({
    subset <- estimates[estimates$db == input$db, ]
    if (input$mdrr != "All") {
      subset <- subset[!is.na(subset$mdrrTarget) & subset$mdrrTarget < as.numeric(input$mdrr), ]
    }
    subset <- subset[subset$method %in% input$method, ]
    if (input$stratum != "All") {
      subset <- subset[subset$stratum == input$stratum, ]
    }
    if (input$calibrated == "Calibrated") {
      subset$logRr <- subset$calLogRr
      subset$seLogRr <- subset$calSeLogRr
      subset$ci95lb <- subset$calCi95lb
      subset$ci95ub <- subset$calCi95ub
      subset$p <- subset$calP
    }
    return(subset)
  })
  
  performanceMetrics <- reactive({
    subset <- filterEstimates()
    if (nrow(subset) == 0) {
      return(data.frame())
    }
    combis <- unique(subset[, c("method", "analysisId")])
    if (input$trueRr == "Overall") {
      computeMetrics <- function(i) {
        forEval <- subset[subset$method == combis$method[i] & subset$analysisId == combis$analysisId[i], ]
        roc <- pROC::roc(forEval$targetEffectSize > 1, forEval$logRr, algorithm = 3)
        auc <- round(pROC::auc(roc), 2)
        mse <- round(mean((forEval$logRr - log(forEval$targetEffectSize))^2), 2)
        coverage <- round(mean(forEval$ci95lb < forEval$targetEffectSize & forEval$ci95ub > forEval$targetEffectSize), 2)
        meanP <- round(mean(1/(forEval$seLogRr^2)), 2)
        type1 <- round(mean(forEval$p[forEval$targetEffectSize == 1] < 0.05), 2)
        type2 <- round(mean(forEval$p[forEval$targetEffectSize > 1] >= 0.05), 2)
        missing <- round(mean(forEval$seLogRr == 999), 2)
        return(c(auc = auc, coverage = coverage, meanP = meanP, mse = mse, type1 = type1, type2 = type2, missing = missing))
      }
      combis <- cbind(combis, as.data.frame(t(sapply(1:nrow(combis), computeMetrics))))
    } else {
      trueRr <- input$trueRr
      computeMetrics <- function(i) {
        forEval <- subset[subset$method == combis$method[i] & subset$analysisId == combis$analysisId[i] & subset$targetEffectSize == trueRr, ]
        mse <- round(mean((forEval$logRr - log(forEval$targetEffectSize))^2), 2)
        coverage <- round(mean(forEval$ci95lb < forEval$targetEffectSize & forEval$ci95ub > forEval$targetEffectSize), 2)
        meanP <- round(mean(1/(forEval$seLogRr^2)), 2)
        if (input$trueRr == "1") {
          auc <- NA
          type1 <- round(mean(forEval$p < 0.05), 2)  
          type2 <- NA
        } else {
          negAndPos <- subset[subset$method == combis$method[i] & subset$analysisId == combis$analysisId[i] & (subset$targetEffectSize == trueRr | subset$targetEffectSize == 1), ]
          roc <- pROC::roc(negAndPos$targetEffectSize > 1, negAndPos$logRr, algorithm = 3)
          auc <- round(pROC::auc(roc), 2)
          type1 <- NA
          type2 <- round(mean(forEval$p[forEval$targetEffectSize > 1] >= 0.05), 2)  
        }
        return(c(auc = auc, coverage = coverage, meanP = meanP, mse = mse, type1 = type1, type2 = type2))
      }
      combis <- cbind(combis, as.data.frame(t(sapply(1:nrow(combis), computeMetrics))))
    }
    colnames(combis) <- c("Method", 
                          "ID", 
                          "<span title=\"Area under the receiver operator curve\">AUC</span>", 
                          "<span title=\"Coverage of the 95% confidence interval\">Cov</span>", 
                          "<span title=\"Mean precision (1/SE^2)\">MPr</span>", 
                          "<span title=\"Mean Squared Error\">MSE</span>", 
                          "<span title=\"Type 1 Error\">T1E</span>", 
                          "<span title=\"Type 2 Error\">T2E</span>", 
                          "<span title=\"Fraction with missing estimates\">Mis</span>")
    return(combis)
  })
  
  output$performanceMetrics <- renderDataTable({
    selection = list(mode = "single", target = "row")
    options = list(pageLength = 10, 
                   searching = FALSE, 
                   lengthChange = FALSE)
    isolate(
      if (!is.null(input$performanceMetrics_rows_selected)) {
        selection$selected = input$performanceMetrics_rows_selected
        options$displayStart = floor(input$performanceMetrics_rows_selected[1] / 10) * 10 + 1
      }
    )
    data <- performanceMetrics()
    if (nrow(data) == 0) {
      return(data)
    }
    table <- DT::datatable(data, selection = selection, options = options, rownames = FALSE, escape = FALSE) 
    
    colors <- c("lightblue", "lightblue", "lightblue", "pink", "pink", "pink", "pink")
    mins <- c(0, 0, 0, 0, 0, 0, 0)
    maxs <- c(1, 1, max(data[, 5]), max(data[, 6]), 1, 1, 1)
    for (i in 1:length(colors)) {
      table <- DT::formatStyle(table = table, 
                               columns = i+2,
                               background = styleColorBar(c(mins[i], maxs[i]), colors[i]),
                               backgroundSize = '98% 88%',
                               backgroundRepeat = 'no-repeat',
                               backgroundPosition = 'center')
    }
    return(table)
  })

  output$estimates <- renderPlot({
    if (is.null(input$performanceMetrics_rows_selected)) {
      return(NULL)
    } else {
      subset <- filterEstimates()
      subset <- subset[subset$method == performanceMetrics()$Method[input$performanceMetrics_rows_selected] & subset$analysisId == performanceMetrics()$ID[input$performanceMetrics_rows_selected], ]
      if (nrow(subset) == 0) {
        return(NULL)
      }
      subset$trueRr <- subset$targetEffectSize
      return(plotScatter(subset))
    }
    
  })
  
  output$details <- renderText({
    if (is.null(input$performanceMetrics_rows_selected)) {
      return(NULL)
    } else {
      method <- as.character(performanceMetrics()$Method[input$performanceMetrics_rows_selected])
      analysisId <- performanceMetrics()$ID[input$performanceMetrics_rows_selected]
      description <- analysisRef$description[analysisRef$method == method & analysisRef$analysisId == analysisId]
      return(paste0(method , " analysis. ", analysisId, ": ", description))
    }
  })
  
  observeEvent(input$showSettings, {
    method <- as.character(performanceMetrics()$Method[input$performanceMetrics_rows_selected])
    analysisId <- performanceMetrics()$ID[input$performanceMetrics_rows_selected]
    description <- analysisRef$description[analysisRef$method == method & analysisRef$analysisId == analysisId]
    json <- analysisRef$json[analysisRef$method == method & analysisRef$analysisId == analysisId]
    showModal(modalDialog(
      title = paste0(method , " analysis. ", analysisId, ": ", description),
      pre(json),
      easyClose = TRUE,
      footer = NULL,
      size = "l"
    ))
  })
})

