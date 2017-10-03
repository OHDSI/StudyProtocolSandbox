# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of LargeScaleIncidenceRates
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

#' Submit the study results to the study coordinating center
#'
#' @details
#' This will upload the file \code{StudyResults.zip} to the study coordinating center using Amazon S3.
#' This requires an active internet connection.
#'
#' @param outputFolder   The path to the folder containing the \code{Results.csv} file.
#' @param key            The key string as provided by the study coordinator
#' @param secret         The secret string as provided by the study coordinator
#'
#' @return
#' TRUE if the upload was successful.
#'
#' @export
submitResults <- function(outputFolder, key, secret) {
  fileName <- file.path(outputFolder, "Results.csv")
  if (!file.exists(fileName)) {
    stop(paste("Cannot find file", fileName))
  }
  writeLines(paste0("Uploading file '", fileName, "' to study coordinating center"))
  result <- OhdsiSharing::putS3File(file = fileName,
                                    bucket = "todo",
                                    key = key,
                                    secret = secret)
  if (result) {
    writeLines("Upload complete")
  } else {
    writeLines("Upload failed. Please contact the study coordinator")
  }
  invisible(result)
}
