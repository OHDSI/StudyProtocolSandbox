submitResults <- function(exportFolder, key, secret) {
  zipName <- file.path(exportFolder, "StudyResults.zip")
  if (!file.exists(zipName)) {
    stop(paste("Cannot find file", zipName))
  }
  writeLines(paste0("Uploading file '", zipName, "' to study coordinating center"))
  result <- OhdsiSharing::putS3File(file = zipName,
                                    bucket = "ohdsi-study-htncombi",
                                    key = key,
                                    secret = secret)
  if (result) {
    writeLines("Upload complete")
  } else {
    writeLines("Upload failed. Please contact the study coordinator")
  }
  invisible(result)
}