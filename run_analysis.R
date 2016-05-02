
library(reshape2)

# Download and unzip the data set.
if(!file.exists("~/data/dataset.zip")){
  download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="~/data/dataset.zip",method="curl")
}
unzip("~/data/dateset.zip")

# Read activity and measurment files into data frame.
activities <- read.table("~/data/UCI HAR Dataset/activity_labels.txt")
features <- read.table("~/data/UCI HAR Dataset/features.txt")

# Get the activities names and and measurments' names.
activities[,2] <-as.character(activities[,2])
features[,2]<-as.character(features[,2])

# Only keep the fields that have mean or std in it, and clean up the fields names.
featuresKeep <- grep(".*mean.*|.*std.*", features[,2])
featuresKeep.names<-features[featuresKeep,2]
featuresKeep.names=gsub('-mean','Mean',featuresKeep.names)
featuresKeep.names=gsub('-std','Std',featuresKeep.names)
featuresKeep.names=gsub('[-()]','',featuresKeep.names)

# Read subject and activities information and combine them into one data frame.
training<-read.table("~/data/UCI HAR Dataset/train/X_train.txt")[featuresKeep]
trainingActivities<-read.table("~/data/UCI HAR Dataset/train/Y_train.txt")
trainingSubjects<-read.table("~/data/UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainingSubjects, trainingActivities, train)

# Read test subject and activities file and combine into one data frame.
test<-read.table("~/data/UCI HAR Dataset/test/X_test.txt")[featuresKeep]
testActivities<-read.table("~/data/UCI HAR Dataset/test/Y_test.txt")
testSubjects<-read.table("~/data/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Combine the training and test data, make subject and activities as factors.
mergeData<-rbind(training,test)
colnames(mergeData) <-c("subject","activity",featuresKeep.names)
mergeData$activity<-factor(mergeData$activity,levels=activities[,1],labels=activities[,2])
mergeData$subject<-as.factor(mergeData$subject)
mergeData.melted<-melt(mergeData,id=c("subject","activity"))
mergeData.mean<-dcast(mergeData.melted,subject+activity~variable,mean)

# write out into a txt file.
write.table(mergeData.mean,"tidy.txt",row.names=FALSE,quote=FALSE)
