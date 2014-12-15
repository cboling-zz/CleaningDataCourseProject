#
# Utility to get and extract data for course project.  This should be ran from your base project
# directory and should only need to be ran once.  It creates an 'origData' sub directory with
# the original ZIP file and extracts the data to a data subdirectory.  Don't forget to set your
# working directory 'setwd()' before running it in case you are running from R-Studio
#
#   Usage:  downloadData()
#
downloadData <- function()
{
    url     <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    dataDir <- "./data"
    zipDir  <- "./origData"
    zipFile <- "./origData/Dataset.zip"

    # Create subdirs

    if (!file.exists(zipDir))  { dir.create(zipDir) }
    if (!file.exists(dataDir)) { dir.create(dataDir) }

    # Always download since we need the timestamp of when it was retrieved

    #download.file(url, zipFile, "wget", quiet=TRUE, cacheOK=FALSE)
    print(sprintf("Downloaded %s at %s %s", url, Sys.time(), Sys.Date()))

    # Unzip the data

    unzip(zipFile, exdir=dataDir, overwrite=TRUE)
}
