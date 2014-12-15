################################################################################
#
# Coursera 'Getting and Cleaning Data' Class Project
#
# Author:   Chip Boling
#   Date:   Dec. 11, 2014
#
# See the 'CodeBook.md' file for details on running this analysis script
#
#
# 1. Merges the training and the test sets to create one data set.
#
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
# 3. Uses descriptive activity names to name the activities in the data set
#
# 4. Appropriately labels the data set with descriptive variable names.
#
# 5. From the data set in step 4, creates a second, independent tidy data set with the
#     average of each variable for each activity and each subject.


run_analysis <- local(
{
    # TODO: Trim to ones we need
    library(digest)
    library(stringr)

    getOutput <- function(arg)
    {
        print(sprintf("Example output: %s", arg))
    }
    # Args below are example. Do not need them
    function(arg="test")
    {
        readline("\nPress Enter to continue...")
        getOutput(arg)

        invisible()
    }
})
