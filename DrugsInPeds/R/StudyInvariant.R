# Copyright 2015 Observational Health Data Sciences and Informatics
#
# This file is part of DrugsInPeds
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' @title Email results
#'
#' @details
#' This function emails the result CSV files to the study coordinator.
#'
#' @return
#' A list of files that were emailed.
#'
#' @param from     Return email address
#' @param to			(Optional) Delivery email address (must be a gmail.com acccount)
#' @param subject  (Optional) Subject line of email
#' @param dataDescription A short description of the database
#' @param file	(Optional) Name of local file with results; makee sure to use forward slashes (/)
#'
#' @export
email <- function(from,
                  to,
                  subject,
                  dataDescription,
                  file) {

    if (missing(from)) stop("Must provide return address")
    if (missing(dataDescription)) stop("Must provide a data description")

    if (missing(to)) to <- getDestinationAddress()
    if (missing(subject)) subject <- getDefaultStudyEmailSubject()
    if (missing(file)) file <- getDefaultStudyFileName()

    if(!file.exists(file)) stop(paste(c("No results file named '",file,"' exists"),sep = ""))

    tryCatch({
        result <- mailR::send.mail(from = from,
                                   to = to,
                                   subject = subject,
                                   body = paste("\n", dataDescription, "\n",
                                                sep = ""),
                                   smtp = list(host.name = "aspmx.l.google.com",
                                               port = 25),
                                   attach.files = file,
                                   authenticate = FALSE,
                                   send = TRUE)
        if (result$isSendPartial()) {
            stop("Unknown error in sending email")
        } else {
            writeLines(c(
                "Sucessfully emailed the following file:",
                paste("\t", file, sep = ""),
                paste("to:", to)
            ))
        }
    }, error = function(e) {
        writeLines(c(
            "Error in automatically emailing results, most likely due to security settings.",
            "Please manually email the following file:",
            paste("\t", file, sep = ""),
            paste("to:", to)
        ))
    })
}
