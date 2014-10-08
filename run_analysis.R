# Analysis for Coursera Getting and Cleaning Data Programming Assignment
#
require(data.table)
require(dplyr)
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

#subject files
subjectTrain = fread(file.path(dataDir, "train", "subject_train.txt"))
subjectTest  = fread(file.path(dataDir, "test" , "subject_test.txt" ))
## merge them
subjects = rbind(subjectTrain, subjectTest)

#activity files
activityTrain = fread(file.path(dataDir, "train", "Y_train.txt"))
activityTest  = fread(file.path(dataDir, "test" , "Y_test.txt" ))
## merge them
activityCodes = rbind(activityTrain, activityTest)

#meh fread is not happy with the X_train.txt files, so use read.table
dataTrain = data.table(read.table(file.path(dataDir, "train", "X_train.txt")))
dataTest = data.table(read.table(file.path(dataDir, "test", "X_test.txt")))

## merge them
activityData = rbind(dataTrain, dataTest)

# little clean up
#rm(subjectTrain, subjectTest, activityTrain, activityTest, dataTrain, dataTest)

# add some nice labels
setnames(subjects,"V1", "subjectNumber")
setnames(activityCodes, "V1", "activityNumber")

# and one more binding
activityData = cbind(subjects, activityCodes, activityData)

# now we'll want to extract the measures of interest. These are identified by
# feature names containing "mean" and "std" (for standard deviation)

features = fread(file.path(dataDir, "features.txt"))
setnames(features, names(features), c("featureNumber", "featureName"))

features = features %>% filter(grepl(".*-std.*|.*-mean.*", featureName))

features$featureCode = features[, paste0("V", featureNumber)]

keeps = c("subjectNumber", "activityNumber", features$featureCode)

# not sure why I have to do this, but the subset won't work otherwise...
# (something with data.table that I'm not familiar with)
setkey(activityData, subjectNumber, activityNumber)

activityData = activityData[,keeps, with=FALSE]

setnames(activityData, names(activityData), c("subjectNumber", "activityNumber", features$featureName))

