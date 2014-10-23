Getting And Cleaning Data *Code Book*
=================

The output data is found in "summaryActivityData.txt", which is the textual output of the summaryActivityDataTidy data frame.

*summaryActivityDataTidy*
A long-and-narrow tidy data frame containing the following columns:

*subjectNumber* - a categorical integer containing references to the study participants
*activityLabel* - a categorical character labelling the activity types
*featureName* - categorical string labelling the sensor
*mean* - the mean value of the featureName for the activity and subject
*sd* - the standard deviation of the preceding mean

*Script Description*
_Data Access_
The code initially downloads the ZIP project file, after first checking that it hasn't already downloaded it. After the download, the ZIP file is uncompressed to the local directory.

_Data Read_
The subject Training and Test files are injested and combined into one data frame called "subjects".
The activity Training and Test files are injested as are the data files called "X_...", as well as the feature files.

Activities are merged as are the data files into "activityCodes" and "activityData" files repectively. Some renaming of columns are performed to give descriptive names. After that, we merge in the activity labels and extract only the features that contain either "std" or "mean" in their names. From that point, we quickly calculate the means and standard deviations of the kept features and output the final data set.
