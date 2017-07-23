writeReport <- function(exportFolder, outputFile) {
    rmarkdown::render(system.file("markdown", "HTN_combi.rmd", package = "HypertensionCombination"),
                      params = list(exportFolder = exportFolder),
                      output_file = outputFile,
                      rmarkdown::word_document(toc = TRUE, fig_caption = TRUE))
}