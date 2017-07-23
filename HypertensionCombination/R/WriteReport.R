writeReport <- function(exportFolder) {
    rmarkdown::render(system.file("markdown", "HTN_combi.rmd", package = "HypertensionCombination"),
                      params = list(exportFolder = normalizePath(exportFolder)),
                      output_file = normalizePath(file.path(exportFolder,"report.html")),
                      rmarkdown::html_document(toc = TRUE, fig_caption = TRUE))
}