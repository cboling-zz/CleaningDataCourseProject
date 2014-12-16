################################################################################
#
# Coursera 'Getting and Cleaning Data' Class Project
#
# Author:   Chip Boling
#   Date:   Dec. 11, 2014
#
# See the 'CodeBook.md' and 'README.md' files for details on running this analysis script.
# This script preforms the following operations.
#
#   1. Merges the training and the test sets to create one data set.
#
#   2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
#   3. Uses descriptive activity names to name the activities in the data set
#
#   4. Appropriately labels the data set with descriptive variable names.
#
#   5. From the data set in step 4, creates a second, independent tidy data set with the
#      average of each variable for each activity and each subject.

library(data.table)
library(stringr)
library(plyr)

readActivityLabels <- function(filename)
{
    ## Read in the file that associates an activity number (integer) with the text based name
    ## (label) for that activity
    ##
    ##   filename  is the path to the file containing the activity label.  This is expected
    ##             to be a space delimited file with activity number followed by the label.
    ##             No header line is expected
    ##
    ## Output is a data.table containing the 'activity' and 'name' as the column names

    # Open the file

    inputData <- fread(filename)
    setnames(inputData, c('V1','V2'), c('activity','name'))
}

readFeatures <- function(filename)
{
    ## Read in the file that associates a feature number (integer) with the text based name
    ## for that feature.
    ##
    ##   filename  is the path to the file containing the feature label.  This is expected
    ##             to be a space delimited file with featured number followed by the name.
    ##             No header line is expected
    ##
    ## Output is a data.table containing the 'feature' and 'name' as the column names

    # Open the file

    inputData    <- fread(filename)

    # Go through all the names and clean them up to be better column names.  Do this by
    # adding it as a new column so we keep the original name as well.  The name column have
    # the following special symbols:
    #
    # uppercase   -> Convert to lower case
    #     '-'     -> Convert to '_'
    #     ','     -> Convert to '_'
    #     '()'    -> Remove.  This is the () with no characters in betweedn
    #     '('     -> Convert to '_'.  This is '(' followed by a character other than ')'
    #     ')'     -> Remove

    column_name  <- gsub("()","", gsub("-|,", "_", tolower(inputData$V2)),fixed=TRUE)
    inputData$V3 <- gsub(")","", gsub("(","",column_name,fixed=TRUE))

    setnames(inputData, c('V1','V2', 'V3'), c('feature','name', 'column_name'))
}

readSubjectDataset <- function(filename)
{
    ## Read in subject number dataset and provide a more useful column name

    inputData <- fread(filename)
    setNames(inputData, c('subject'))
}

readFeaturesDataset <- function(filename, featureNames)
{
    ## Read in featursdataset and provide a more useful set of column names

    # Use read.table.  Version 1.9.4 (current as of the time this code was written) has a
    # buffer overflow error problem.  The development version 1.9.5 does have a partial fix
    # but I want to only use fully released libraries in this converter.

    inputDataTable <- read.table(filename)

    # Now create a data.table so we will always work with data.tables

    inputData <- as.data.table(inputDataTable)

    # The number of columns in our input data should be the same as the number of rows in the
    # feature names (featureNames$column_name are the cleaned column names).  If they do not
    # match, throw an error, else use it to set the names of out inputData columns.

    if (ncol(inputData) != nrow(featureNames))
    {
        errFmt <- paste("readFeaturesDataset: The number of columns (%d) in the input file ",
                        "does not match the number of rows (%d) in the feature names for ",
                        "those columns")
        stop(sprintf(errFmt, ncol(inputData), nrow(featureNames)))
    }
    setNames(inputData, featureNames[['column_name']])
}

validateDataTables <- function(subjectTable, dataSetTable, dataLabelTable, suffix)
{
    # Validate some assumptions or basic requirements of our tables

    if (ncol(subjectTable) != 1)
    {
        stop("validateTables: subect table should have only one column")
    }
    if (nrow(subjectTable) != nrow(dataSetTable) | nrow(subjectTable) != nrow(dataLabelTable))
    {
        errFmt <- paste("validateDataTables [%s]: The number of rows in our tables do not ",
                        "match. They are subject(%d), dataset(%d), and label(%d)")
        errMsg <- sprintf(errFmt, suffix, nrow(subjectTable),  nrow(dataSetTable),
                          nrow(dataLabelTable))
        stop(errMsg)
    }
    invisible()
}

readDataSet <- function(baseDir, suffix, featureNames)
{
    ## Read in and clean a data set
    ##
    ##   basedir       The base input directory.  From this directory, a set of input files with
    ##                 predefined prefixes (and base directories) will be read and clean
    ##
    ##    suffix       The suffix to apply to select filenames to for the full path. This suffix
    ##                 will typically be either 'test' or 'train'.
    ##
    ##   featureNames  The feature number to feature name data.table to use to provide a better
    ##                 set of column names for the feature data set
    ##
    ## Outputs a single cleaned and tidy data.table

    baseDir <- file.path(baseDir, suffix)

    # Create the filenames we are interested in

    subjectFileName   <- file.path(baseDir, paste(paste("subject_", suffix, sep=""), ".txt",
                                                  sep=""))
    dataSetFileName   <- file.path(baseDir, paste(paste("X_", suffix, sep=""), ".txt", sep=""))
    dataLabelFileName <- file.path(baseDir, paste(paste("y_", suffix, sep=""), ".txt", sep=""))

    # Read the following raw data
    #   subject   - A single column with the test subject number
    #   dataSet   - Features dataset. Features are normalized and bounded within [-1,1].
    #   dataLabel - Activity labels

    subjectTable   <- readSubjectDataset(subjectFileName)
    dataSetTable   <- readFeaturesDataset(dataSetFileName, featureNames)
    dataLabelTable <- fread(dataLabelFileName)

    # Validate the tables

    validateDataTables(subjectTable, dataSetTable, dataLabelTable, suffix)

    # Merge the data into a single data.table and return it to caller

    cbind(cbind(subjectTable, dataLabelTable), dataSetTable)
}

run_analysis <- function(inputDir="./data/UCI HAR Dataset", outputDir="./output")
{
    ## Main script input function.  This function is ran when you enter the 'run_analysis'
    ## command on the R command line (or RStudio Console)
    ##
    ##   'inputDir' is the base input subdirectory where the original (unzipped) data can
    ##              be found.
    ##
    ##  'outputDir' is the output directory where all tidy data is written.

    # Make sure output directory exists

    if (!file.exists(outputDir)) { dir.create(outputDir) }

    # Read in the Activity Label data.  To retrieve a label for activity == 3, use:
    #     activityLabel[activityLabel$activity == 3,]$name

    activityLabel <- readActivityLabels(file.path(inputDir, "activity_labels.txt"))

    # Read in the Feature Name data.  This is a data.table similar to what we did for the
    # activity labels.

    featureNames  <- readFeatures(file.path(inputDir, "features.txt"))

    # Now read in the test and training data sets (this will satisfy '3 & 4' requirement above)

    trainingData <- readDataSet(inputDir, "train", featureNames)
    testData     <- readDataSet(inputDir, "test", featureNames)

    # 1.  Now merge the training and test data

    allData <- rbind(trainingData, testData)

    # 2. Extract only the measurements on the mean and standard deviation for each measurement

    #meanAndDevData <- extractData
    # TODO

    #   5. From the combined data set, creates a second, independent tidy data set with the

    # TODO

    print("Done")
}


#   1. Merges the training and the test sets to create one data set.
#
#   2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
#   3. Uses descriptive activity names to name the activities in the data set
#
#   4. Appropriately labels the data set with descriptive variable names.
#
#   5. From the data set in step 4, creates a second, independent tidy data set with the
#      average of each variable for each activity and each subject.
