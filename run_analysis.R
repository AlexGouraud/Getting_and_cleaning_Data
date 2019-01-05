require(readr)
require(plyr)
require(dplyr)

#Creation of files paths for later utilization
train_path <-  "C:/Users/Alex/Desktop/Coursera/Getting and cleaning data/UCI HAR Dataset/train/"
test_path <- "C:/Users/Alex/Desktop/Coursera/Getting and cleaning data/UCI HAR Dataset/test/"
main_path <- "C:/Users/Alex/Desktop/Coursera/Getting and cleaning data/UCI HAR Dataset/"


####################################
# LOADING OF ALL REQUIRED DATASETS #
####################################


# Load training datasets
x_train <- read.table(paste(train_path,"X_train.txt",sep=""))
y_train <- read.table(paste(train_path,"y_train.txt",sep=""))
subject_train <- read.table(paste(train_path,"subject_train.txt",sep=""))

# Load testing datasets
x_test <- read.table(paste(test_path,"X_test.txt",sep=""))
y_test <- read.table(paste(test_path,"y_test.txt",sep=""))
subject_test <- read.table(paste(test_path,"subject_test.txt",sep=""))

# Load features.txt file that contains all the variable names 
features <- read.table(paste(main_path,"features.txt",sep=""))

# Load activity_labels.txt file that contains encoded labels to link them with activity names
activity_labels <- read.table(paste(main_path,"activity_labels.txt",sep=""))


#----------------------------------------------------------------------------------------------

      
      #################################################################
      #I.Merges the training and the test sets to create one data set.#
      #################################################################
      

##############################################
# MERGING AND FIRST CLEANING OF OUR DATASETS #
##############################################

  #------------------------------------------------#
  # Dataset containing all the features: x_dataset # 
  #------------------------------------------------#

# We merge the training and test dataset to create the x_dataset
x_dataset <- rbind(x_train, x_test)  # all features without names

# We have a dataset called features containing names for x_dataset columns. Due to its dimension 561*2
# we need to transpose it, and only the second column. Remember, x_dataset is 10299*561
colnames(x_dataset) <- t(features[2])

# We remove all the parenthesis that are pretty useless IMO
names(x_dataset) <- gsub('[-()]','', names(x_dataset))


  #---------------------------------------------------------------------------#
  # Dataset containing the labels for later machine learning & co : y_dataset # 
  #---------------------------------------------------------------------------#

# We merge the training and test dataset to create the y_dataset
y_dataset <- rbind(y_train, y_test)  
# we have now y_dataset, a dataset of dimension 10299*1 containing an 'encoded' column -labels-
# These encoded labels will be replaced with appropriated strings that we find in the
# activity_labels dataset
View(activity_labels)


# Sustitute activity encoded values with their corresponding activity names
#  1 becomes WALKING
# 2 becomes WALKING_UPSTAIRS
# 3 becomes WALKING_DOWNSTAIRS
# 4 becomes SITTING
# 5 becomes STANDING
# 6 becomes LAYING

y_dataset[, 1] <- activity_labels[y_dataset[, 1], 2]

# We rename the column V1 to "activity"
colnames(y_dataset) <- "activity"


  #----------------------------------------------------------------------------#
  # Dataset containing IDs of subjects during the experiment : subject_dataset # 
  #---------------------------------------------------------------------------*#

# As usual, we merge the training and test dataset to create the subject_dataset
subject_dataset <- rbind(subject_train, subject_test) 

# We rename the column to make it easy to understand
colnames(subject_dataset) <- "ID_subject" 


  #--------------------------------------------------------------------#
  # Final dataset, containing the data of the three others: final_data # 
  #--------------------------------------------------------------------#

#Dimension of the future final dataset

#x_dataset : 561 columns 
dim(x_dataset)
#y_dataset: 1 column
dim(y_dataset)
#y_dataset: 1 column
dim(subject_dataset)
# ====> 563 columns, names at the place 56

# Merge our datasets into one dataset of dimension 10299 * 563
# First will the ID column, then name of the activity and finally the various features
final_data <- cbind(subject_dataset, y_dataset, x_dataset)
dim(final_data)
# dimension is OK


## We will just rename the t/f/Acc/Gyro/Mag with the full word found in the description online.

# Replace 't' with 'time'
colnames(final_data) <- sub("^t","Time",colnames(final_data))
# Replace 'f' with 'frequency'
colnames(final_data) <- sub("^f","Frequency",colnames(final_data))
# Replace 'Acc' with 'Accelerometer'
colnames(final_data) <- sub("Acc","Accelerometer",colnames(final_data))
# Replace 'Gyro' with 'Gyroscope'
colnames(final_data) <- sub("Gyro","Gyroscope",colnames(final_data))
# Replace 'mag' with 'Magnitude'
colnames(final_data) <- sub("Mag","Magnitude",colnames(final_data))




#----------------------------------------------------------------------------------------------


      #############################################################################################
      #II. Extracts only the measurements on the mean and standard deviation for each measurement.#
      #############################################################################################


# Get only columns which correspond to mean or sandard deviation 
# We will extract indices of columns that contain either mean or std. Then
# this vector will be used to extract the good columns. 
mean_std_columns <- grep("-(mean|std)\\(\\)", features[, 2])


# I add columns 1 and 2 on purpose to include the ID and the activity recorded for the test
mean_std_columns <- c(1,2,mean_std_columns+2) # "+2" is just used to shift all the columns of mean_std_columns by 2


########################
# FINAL DATASET WANTED #
########################
final_data_extract <- final_data[, mean_std_columns ]
dim(final_data_extract)
#----------------------------------------------------------------------------------------------


    ############################################################################################
    #III. creates a second, independent tidy data set with the average of each variable for    #
    #                           each activity and each subject.                                #
    ############################################################################################


# Use "final_data_extract" dataset to create an independet, tidy dataset
# with the average value of each activity and subject.
final_data_extract_avg <- final_data_extract %>% 
                            group_by(ID_subject,activity) %>%
                            summarise_all(funs(mean))

# Write the above created dataset in a txt file.
write.table(final_data_extract_avg, 
            file = paste(main_path, "tidy_data_avg.txt", sep=""),
            row.names=FALSE, col.names = TRUE, sep="\t")

