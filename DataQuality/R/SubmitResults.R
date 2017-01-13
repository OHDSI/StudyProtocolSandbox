# Copyright 2016 Observational Health Data Sciences and Informatics

#' Submit the study results to the study coordinating center
#'
#' @details
#' This will upload the file \code{StudyResults.zip} to the study coordinating center using Amazon S3.
#' This requires an active internet connection.
#'
#' @param exportFolder   The path to the folder containing the \code{StudyResults.zip} file.
#' @param studyBucketName  Name of the bucket to use (provided by the study coordinator)
#' @param key            The key string as provided by the study coordinator
#' @param secret         The secret string as provided by the study coordinator
#'
#' @return
#' TRUE if the upload was successful.
#'
#' @export
submitResults <- function(exportFolder, dbName, studyBucketName, key, secret) {
  zipName <- file.path(exportFolder, paste0(dbName,"-StudyResults.zip"))
  if (!file.exists(zipName)) {
    stop(paste("Cannot find file", zipName))
  }
  writeLines(paste0("Uploading file '", zipName, "' to study coordinating center"))
  result <- OhdsiSharing::putS3File(file = zipName,
                                    bucket = studyBucketName,
                                    key = key,
                                    secret = secret)
  if (result) {
    writeLines("Upload complete")
  } else {
    writeLines("Upload failed. Please contact the study coordinator")
  }
  invisible(result)
}
