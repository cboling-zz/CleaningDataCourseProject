Getting and Cleaning Data Course Project
========================================

This project provides the required 'R' script to perform cleaning operations on a set of data
obtained from a Human Activity Recognition test performed uses a Samsung Galaxy S smartphone.

The *run_analysis.R* script will read in the training and test data sets

Running the script
------------------

To run the script, start **R**, source the *run_analysis.R* script, and then run the 
*run_analysis()*.  For example, from the directory containing the R Script enter:

'''
prompt> R --quiet
> source("run_analysis.R")
> run_analysis()
'''

This will read and tidy the data and create any output files in the *output* subdirectory by
default.  Upon successfull completion, the script will output **Done** and return you to the
*R* prompt.


Downloading the original data
-----------------------------

The oroginal data is available is included in this *Github* project in the *origData* (zip file)
and *data* (expanded files) subdirectory.  The link to the original data is provided below
and you can use the supplied *getData.R* script to automatically download it for you.  Simply 
use the **getData()** function after sourcing the *getData.R* script.

[original data set](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 

Version Information
-------------------

The following version of **R** and *R Libraries* were used to clean the data.

* R version 3.1.2 (2014-10-31) -- "Pumpkin Helmet"
* data.table -- 1.9.5
* plyr -- 1.8.1
* stringr -- 0.6.2

The operating system was Ubuntu 14.04 on a 64-bit x86 platform

