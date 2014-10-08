# Analysis for Coursera Getting and Cleaning Data Programming Assignment
#
require(data.table)
require(tidyr)

# check to see if the zip file exists
zipFile = "./data/getdata-projectfiles-UCI HAR Dataset.zip"
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!file.exists(zipFile)){
  download.file(url, zipFile, method="curl")
}

# check to see if the file has been unzipped
dataDir ="./data/UCI HAR Dataset"
if(!file.exists(dataDir)){
  unzip(zipFile, exdir="./data")
}

# at this point, we can be reasonably assured that the raw data is around, so read it in

