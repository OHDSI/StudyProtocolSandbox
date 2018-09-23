writeReport <- function(exportFolder) {
	print(exportFolder)
    rmarkdown::render(system.file("markdown", "HTN_combi.rmd", package = "HypertensionCombination"),
                      params = list(exportFolder = exportFolder),
                      output_file = file.path(exportFolder,"report.html"),
                      rmarkdown::html_document(toc = TRUE, fig_caption = TRUE))
}