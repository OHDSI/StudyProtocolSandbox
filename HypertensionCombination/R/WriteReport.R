writeReport <- function(exportFolder, outputFile) {
    rmarkdown::render(system.file("markdown", "Report.rmd", package = "HypertensionCombination"),
                      params = list(exportFolder = exportFolder),
                      output_file = outputFile,
                      rmarkdown::word_document(toc = TRUE, fig_caption = TRUE))
}