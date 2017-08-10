submitResults <- function(exportFolder, localName) {
  zipName <- file.path(exportFolder, "StudyResults.zip")
  if (!file.exists(zipName)) {
    stop(paste("Cannot find file", zipName))
  }
  writeLines(paste0("Uploading file '", zipName, "' to study coordinating center"))
  
## Google Drive (googledrive)
googledrive::drive_auth(new_user=T)

mirrors <- googledrive::drive_upload(media=zipName
                        ,path=googledrive::as_id("https://drive.google.com/drive/u/0/folders/0B4S3mMh259ntekVDQU9xSTlRSGs")
                        ,name=paste0("OHDSI_HTN_combi_",localName,".zip")
                        ,type=googledrive::drive_mime_type("zip")
)

## Gmail (gmailr)
#  file_attachment <- mime() %>%
#  to("sungjae.2425@gmail.com") %>%
#  from(from_addr) %>%
##  text_body("This is testing") -> text_msg
##  text_msg %>%
#  subject("Study result") %>%
#  html_body(paste0("<html><body>",msg,"</body></html>")) %>%
#  attach_file(zipName)
#  
#  result<-send_message(file_attachment)

## S3
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
