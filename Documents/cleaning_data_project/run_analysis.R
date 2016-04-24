
#setwd("./R/Project module 3/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/")

#uploading the required tables in R
xtrain<-read.table("./train/X_train.txt")
ytrain<-read.table("./train/Y_train.txt")
subjecttrain<-read.table("./train/subject_train.txt")

xtest<-read.table("./test/X_test.txt")
ytest<-read.table("./test/Y_test.txt")
subjecttest<-read.table("./test/subject_test.txt")

activ_labels<-read.table("./activity_labels.txt")
names(activ_labels)[1]="activ_number"
names(activ_labels)[2]="activ_label"

features<-read.table("./features.txt")

# Combining the train and test databases
xall<-rbind(xtrain, xtest)
yall<-rbind(ytrain, ytest)
names(yall)[1]="activ_number"
subjectall<-rbind(subjecttrain, subjecttest)

# Identifying the mean and standard deviation columns
features$mean<-grepl("mean", features[,2])
features$standard_dev<-grepl("std", features[,2])
features$mean_stddev<-as.logical(features$mean+features$standard_dev)

#adding the information about activity in the main database
extract<-xall[,features$mean_stddev==TRUE]
yall$order<-as.numeric(row.names(yall))
merge(yall, activ_labels, by="activ_number")->yall2
yall2$order<-as.numeric(yall2$order)
yall2[order(yall2$order),]->yall2
extract<-cbind(yall2$activ_label, extract)
names(extract)[1]="activity"

#creating explicit variable names
features_extract<-features[features$mean_stddev==TRUE,]
old <-names(extract[,2:80])

new<-as.character(features_extract[,2])
new<-gsub("\\(|\\)","",new)
setnames(extract, old, new)

#adding information about the subject
extract<-cbind( subjectall,extract)
names(extract)[1]="subject"

#creating a new database according to the criteria set by Coursera
library(dplyr)

newDB<-extract %>%  group_by(subject, activity) %>% summarise_each(funs(mean))
write.table(newDB,"./newDB.txt", row.name=FALSE)