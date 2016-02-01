## run_analysis.R
## Create R script that does the following:
## 1.- Merges the training and the test sets to create one data set.
## 2.- Extracts only the measurements on the mean and standard deviation for each measurement.
## 3.- Uses descriptive activity names to name the activities in the data set
## 4.- Appropriately labels the data set with descriptive activity names.
## 5.- Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## Info:
## http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# Get and/or open libraries
if (!require("reshape2")) {install.packages("reshape2")}
if (!require("data.table")) {install.packages("data.table")}
if (!require("lubridate")) {install.packages("data.table")}
if (!require("dplyr")) {install.packages("data.table")}
library(reshape2)
library(data.table)
library(lubridate)
library(dplyr)

# Load activity labels and data names
activity_labels <- read.table("./UCI_HAR_Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI_HAR_Dataset/features.txt")[,2]

# Extract mean & standard devation measurements
extract_features <- grepl("(mean)|(std)", features)

# Process X_test and y_test data
X_test <- read.table("./UCI_HAR_Dataset/test/X_test.txt")
y_test <- read.table("./UCI_HAR_Dataset/test/y_test.txt")
subject_test <- read.table("./UCI_HAR_Dataset/test/subject_test.txt")
names(X_test) = features

# Extract  measurements
X_test = X_test[,extract_features]

# Load activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./UCI_HAR_Dataset/train/X_train.txt")
y_train <- read.table("./UCI_HAR_Dataset/train/y_train.txt")
subject_train <- read.table("./UCI_HAR_Dataset/train/subject_train.txt")
names(X_train) = features

# Extract mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

# Process activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "Subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)

# Labels
id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Create file (.txt)
write.table(tidy_data, file = "./data.txt")
