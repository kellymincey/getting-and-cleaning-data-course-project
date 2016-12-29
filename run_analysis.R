library(dplyr)
library(data.table)
library(plyr)

# Download the file and put it into the data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

# Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Read in observations & combine
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
all_x<- rbind(x_train, x_test)

# Assign column names from features doc
featureNames <- read.table('./data/UCI HAR Dataset/features.txt')[[2]]
colnames(all_x) <- featureNames

# Read in activity data and combine with observations
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
all_activity<- rbind(y_test, y_train)
colnames(all_activity) <- c("activityID")
all_data <- cbind(all_activity,all_x)

# Load activity labels & use to assign labels to activities
activityLabels <- read.table('./data/UCI HAR Dataset/activity_labels.txt')
colnames(activityLabels) <- c("activityID","activityLabel")
all_data <- join(activityLabels,all_data,by="activityID")

# Read in subject IDs
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
subjects <- rbind(subject_test, subject_train)
colnames(subjects) <- c("subjectID")

# Add subject IDs to data
all_data <- cbind(subjects,all_data)

# Select the features columns that have mean or std dev in their name
relevant_data <- all_data[,grep("subjectID|activityID|activityLabel|mean|std",colnames(all_data))]

# rename variable names to more readable forms
varNames <- names(relevant_data)
varNames <- gsub(pattern="^t",replacement="time",x=varNames)
varNames <- gsub(pattern="^f",replacement="freq",x=varNames)
varNames <- gsub(pattern="-?mean[(][)]-?",replacement="Mean",x=varNames)
varNames <- gsub(pattern="-?std[()][)]-?",replacement="Std",x=varNames)
varNames <- gsub(pattern="-?meanFreq[()][)]-?",replacement="MeanFreq",x=varNames)
varNames <- gsub(pattern="BodyBody",replacement="Body",x=varNames)
names(relevant_data) <- varNames

# Create tidy data set with average for each variable by subject and activity ID
TidySet <- aggregate(. ~subjectID + activityID+activityLabel, relevant_data, mean)
TidySet <- TidySet[order(TidySet$subjectID, TidySet$activityID),]

# Create output text file of Tidy Set
write.table(TidySet, "TidySet.txt", row.name=FALSE)
