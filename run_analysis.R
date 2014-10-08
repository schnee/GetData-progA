# Analysis for Coursera Getting and Cleaning Data Programming Assignment

# I'm not super familiar with data.table, so I'm going to try it. Hopefully this
# won't end in tears
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

#meh fread is not happy with the X_train.txt files, so use read.table
dataTrain = data.table(read.table(file.path(dataDir, "train", "X_train.txt")))
dataTest = data.table(read.table(file.path(dataDir, "test", "X_test.txt")))

# and read in the features
features = fread(file.path(dataDir, "features.txt"))
setnames(features, names(features), c("featureNumber", "featureName"))

## merge the data tables together
activityCodes = rbind(activityTrain, activityTest)
activityData = rbind(dataTrain, dataTest)

# little clean up
#rm(subjectTrain, subjectTest, activityTrain, activityTest, dataTrain, dataTest)

# add some nice labels
setnames(subjects,"V1", "subjectNumber")
setnames(activityCodes, "V1", "activityNumber")

# and one more binding
activityData = cbind(subjects, activityCodes, activityData)

# pull in the activity names, too
activityLabels = fread(file.path(dataDir, "activity_labels.txt"))
setnames(activityLabels, names(activityLabels), c("activityNumber", "activityLabel"))

# now we'll want to extract the measures of interest. These are identified by
# feature names containing "mean" and "std" (for standard deviation)


features = features %>% filter(grepl(".*-std.*|.*-mean.*", featureName))

features$featureCode = features[, paste0("V", featureNumber)]

keeps = c("subjectNumber", "activityNumber", features$featureCode)


# not sure why I have to do this, but the subset won't work otherwise...
# (something with data.table that I'm not familiar with)
setkey(activityData, subjectNumber, activityNumber)

activityData = activityData[,keeps, with=FALSE]

setnames(activityData, names(activityData), 
         c("subjectNumber", "activityNumber", features$featureName))

activityData = merge(activityData, activityLabels, by="activityNumber")

# when I merged, my last column is now the Activity Label I want to only 
# calculate stats on the features, so I need to index into 'gather' nicely
lastDataColumn = ncol(activityData)-1

activityDataTidy = gather(activityData, featureName, featureMeasure, 3:lastDataColumn)

# create the tidy summary data set. Note, long and narrow
summaryActivityDataTidy = activityDataTidy %>% 
  group_by(subjectNumber, activityLabel, featureName) %>% 
  summarize(mean=mean(featureMeasure), sd=sd(featureMeasure))

write.table(summaryActivityDataTidy, "summaryActivityData.txt", row.names=F)
