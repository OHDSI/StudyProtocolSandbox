submitResults <- function(exportFolder, from_addr) {
  zipName <- file.path(exportFolder, "StudyResults.zip")
  if (!file.exists(zipName)) {
    stop(paste("Cannot find file", zipName))
  }
  writeLines(paste0("Uploading file '", zipName, "' to study coordinating center"))
  
  mime() %>%
  to("sungjae.2425@gmail.com") %>%
  from(from_addr) %>%
#  text_body("This is testing") -> text_msg
#  text_msg %>%
  subject("Study result") %>%
  text_body("This is testing") %>%
  attach_file("iris.csv") -> file_attachment
  
  result<-send_message(file_attachment)
#  result <- OhdsiSharing::putS3File(file = zipName,
#                                    bucket = "ohdsi-study-htncombi",
#                                    key = key,
#                                    secret = secret)
#  if (result) {
#    writeLines("Upload complete")
#  } else {
#    writeLines("Upload failed. Please contact the study coordinator")
#  }
#  invisible(result)
  writeLines(paste("\nCompleted to send study results to:", "sungjae.2425@gmail.com"))
}