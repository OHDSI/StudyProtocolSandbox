library(shiny)
library(DT)

source("plots.R")

shinyServer(function(input, output, session) {
  
  previousSelection <- NULL
  previousPage <- NULL
  
  observe({
    if (input$evalType == "Comparative effect est.") {
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
      if (input$evalType == "Comparative effect est.") {
        subset <- subset[!is.na(subset$mdrrComparator) & subset$mdrrComparator < as.numeric(input$mdrr), ]
      }
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
  
  output$controlCount <- renderText({
    subset <- filterEstimates()
    subset <- unique(subset[, c("targetId", "comparatorId", "oldOutcomeId", "targetEffectSize")])
    ncCount <- sum(subset$targetEffectSize == 1)
    pcCount <- sum(subset$targetEffectSize != 1)
    return(paste0("Metrics based on ", ncCount, " negative and ", pcCount, " positive controls"))
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
        # mse <- round(mean((forEval$logRr - log(forEval$targetEffectSize))^2), 2)
        mse <- round(mean((forEval$logRr - log(forEval$trueEffectSize))^2), 2)
        # coverage <- round(mean(forEval$ci95lb < forEval$targetEffectSize & forEval$ci95ub > forEval$targetEffectSize), 2)
        coverage <- round(mean(forEval$ci95lb < forEval$trueEffectSize & forEval$ci95ub > forEval$trueEffectSize), 2)
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
        # mse <- round(mean((forEval$logRr - log(forEval$targetEffectSize))^2), 2)
        # coverage <- round(mean(forEval$ci95lb < forEval$targetEffectSize & forEval$ci95ub > forEval$targetEffectSize), 2)
        mse <- round(mean((forEval$logRr - log(forEval$trueEffectSize))^2), 2)
        coverage <- round(mean(forEval$ci95lb < forEval$trueEffectSize & forEval$ci95ub > forEval$trueEffectSize), 2)
        meanP <- round(mean(1/(forEval$seLogRr^2)), 2)
        if (input$trueRr == "1") {
          auc <- NA
          type1 <- round(mean(forEval$p < 0.05), 2)  
          type2 <- NA
          missing <- round(mean(forEval$seLogRr == 999), 2)
        } else {
          negAndPos <- subset[subset$method == combis$method[i] & subset$analysisId == combis$analysisId[i] & (subset$targetEffectSize == trueRr | subset$targetEffectSize == 1), ]
          roc <- pROC::roc(negAndPos$targetEffectSize > 1, negAndPos$logRr, algorithm = 3)
          auc <- round(pROC::auc(roc), 2)
          type1 <- NA
          type2 <- round(mean(forEval$p[forEval$targetEffectSize > 1] >= 0.05), 2)  
          missing <- round(mean(forEval$seLogRr == 999), 2)
        }
        return(c(auc = auc, coverage = coverage, meanP = meanP, mse = mse, type1 = type1, type2 = type2, missing = missing))
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
        options$displayStart = floor(input$performanceMetrics_rows_selected[1] / 10) * 10 
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
      subset$Group <- as.factor(paste("True hazard ratio =", subset$targetEffectSize))
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
  
  output$rocCurves <- renderPlot({
    if (is.null(input$performanceMetrics_rows_selected)) {
      return(NULL)
    } else {
      subset <- filterEstimates()
      subset <- subset[subset$method == performanceMetrics()$Method[input$performanceMetrics_rows_selected] & subset$analysisId == performanceMetrics()$ID[input$performanceMetrics_rows_selected], ]
      if (nrow(subset) == 0) {
        return(NULL)
      }
      subset$trueLogRr <- log(subset$targetEffectSize)
      return(plotRocsInjectedSignals(logRr = subset$logRr, trueLogRr = subset$trueLogRr, showAucs = TRUE))
    }
    
  })
  
  output$hoverInfoEstimates <- renderUI({
    # Hover-over adapted from https://gitlab.com/snippets/16220
    if (is.null(input$performanceMetrics_rows_selected)) {
      return(NULL)
    }
    subset <- filterEstimates()
    subset <- subset[subset$method == performanceMetrics()$Method[input$performanceMetrics_rows_selected] & subset$analysisId == performanceMetrics()$ID[input$performanceMetrics_rows_selected], ]
    if (nrow(subset) == 0) {
      return(NULL)
    }
    
    subset$Group <- as.factor(paste("True hazard ratio =", subset$targetEffectSize))
    hover <- input$plotHoverInfoEstimates
    
    point <- nearPoints(subset, hover, threshold = 50, maxpoints = 1, addDist = TRUE)
    if (nrow(point) == 0) return(NULL)
    
    
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
    top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
    
    # calculate distance from left and bottom side of the picture in pixels
    left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
    top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
    
    # create style property fot tooltip
    # background color is set so tooltip is a bit transparent
    # z-index is set so we are sure are tooltip will be on top
    style <- paste0("position:absolute; z-index:100; background-color: rgba(245, 245, 245, 0.85); ",
                    "left:", left_px - 125, "px; top:", top_px - 150, "px; width:250px;")
    
    
    # actual tooltip created as wellPanel
    estimate <- paste0(formatC(exp(point$logRr), digits = 2, format = "f"),
                       " (",
                       formatC(point$ci95lb, digits = 2, format = "f"),
                       "-",
                       formatC(point$ci95ub, digits = 2, format = "f"),
                       ")")
    
    if (point$cer) {
      text <- paste0("<b> target: </b>", point$targetName, "<br/>", 
                     "<b> comparator: </b>", point$comparatorName, "<br/>")
    } else {
      text <- paste0("<b> exposure: </b>", point$targetName, "<br/>")
    }
    if (point$nesting) {
      text <- paste0(text, "<b> nesting: </b>", point$nestingName, "<br/>")
    } 
    text <- paste0(text, "<b> outcome: </b>", point$outcomeName, "<br/>",
                   "<b> estimate: </b>", estimate, "<br/>")
    div(
      style="position: relative; width: 0; height: 0",
      wellPanel(style = style, p(HTML(text)))
    )
  })
})

