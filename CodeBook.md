# Code Book, Course Project for 'Getting and Cleaning Data' 
I wrote this markdown file with Dillinger. If you don't know it, it allows you to write .md file really easily especially for Github
If you want to try... https://dillinger.io/
Sorry for the multiple typos, I prefer drink wine and eat baguettes rather than do this :]

# Introduction
The objective here is to provide a guide to understand how our datasets where transformed into the textfile provided in the GitHub repository.
The course mentionned **five objectives** required to pass the test, that we will describe here (you also might want to read the program run_Analysis.R):
   - Merges the training and the test sets to create one data set.
   - Extracts only the measurements on the mean and standard deviation for each measurement.
   - Uses descriptive activity names to name the activities in the data set
   - Appropriately labels the data set with descriptive variable names.
   - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We won't do each step exactly in this order but we should end up with a proper tidy dataset that we will call **tidy_data_avg.txt**

# Data source

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

# For each record it is provided:
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

# The dataset includes the following files:
- 'README.txt'
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.
 
# Notes: 
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

For more information about this dataset contact: activityrecognition@smartlab.ws
# License:
Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

You can download all these datasets with the following link: http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip
# Required version and packages
The program was written with the following R version
```{r} 
> version
    platform       x86_64-w64-mingw32          
    arch           x86_64                      
    os             mingw32                     
    system         x86_64, mingw32             
    status                                     
    major          3                           
    minor          5.1                         
    year           2018                        
    month          07                          
    day            02                          
    svn rev        74947                       
    language       R                           
    version.string R version 3.5.1 (2018-07-02)
    nickname       Feather Spray     
```
We used readr, plyr and dplyr as well as the vanilla packages included in R.
```{r} 
> require(readr)
> require(plyr)
> require(dplyr)
```
# Creating the final dataset from train and test sets
Creating path in our environment
```{r}
> train_path <-  "C:/Users/Alex/Desktop/Coursera/Getting and cleaning data/UCI HAR Dataset/train/"
> test_path <- "C:/Users/Alex/Desktop/Coursera/Getting and cleaning data/UCI HAR Dataset/test/"
> main_path <- "C:/Users/Alex/Desktop/Coursera/Getting and cleaning data/UCI HAR Dataset/"
```
Load training datasets
```{r}
> x_train <- read.table(paste(train_path,"X_train.txt",sep=""))
> y_train <- read.table(paste(train_path,"y_train.txt",sep=""))
> subject_train <- read.table(paste(train_path,"subject_train.txt",sep=""))
```
Load testing datasets
```{r}
> x_test <- read.table(paste(test_path,"X_test.txt",sep=""))
> y_test <- read.table(paste(test_path,"y_test.txt",sep=""))
> subject_test <- read.table(paste(test_path,"subject_test.txt",sep=""))
```
Load features.txt file that contains all the variable names 
```{r}
> features <- read.table(paste(main_path,"features.txt",sep=""))
```
Load activity_labels.txt file that contains encoded labels to link them with activity names
```{r}
> activity_labels <- read.table(paste(main_path,"activity_labels.txt",sep=""))
```
## Dataset containing all the features: x_dataset
We merge the training and test dataset to create the x_dataset
```{r}
> x_dataset <- rbind(x_train, x_test)  # all features without names
```
We now have a dataset called features containing names for x_dataset columns. Due to its dimension (561,2), 
we need to transpose it and only the second column to have a dimension (1,561).
Remember, x_dataset is (10299,561)

We transpose features[,2] and use it as a vectore of names for x_dataset
```{r}
> colnames(x_dataset) <- t(features[2])
```
We remove all the parenthesis that are pretty useless IMO
```{r}
> names(x_dataset) <- gsub('[-()]','', names(x_dataset))
```
## Dataset containing all the labels for later machine learning & co : y_dataset 
We merge the training and test dataset to create the y_dataset
```{r}
> y_dataset <- rbind(y_train, y_test)  
```
We now have the y_dataset, a dataset of dimension (10299,1) containing an 'encoded' column -labels-
These encoded labels will be replaced with appropriated strings that we find in the activity_labels dataset
```{r}
> view(activity_labels) # I won't use Rmarkdown for now... But it could show the ouput :)
```
We will sustitute activity encoded values with their corresponding activity names
  - 1 becomes WALKING
  - 2 becomes WALKING_UPSTAIRS
  - 3 becomes WALKING_DOWNSTAIRS
  - 4 becomes SITTING
  - 5 becomes STANDING
  - 6 becomes LAYING
```{r}
y_dataset[, 1] <- activity_labels[y_dataset[, 1], 2]
```
We rename the column V1 to "activity"
```{r}
> colnames(y_dataset) <- "activity"
```
## Dataset containing IDs of subjects for the experiment : subject_dataset #
As usual, we merge the training and test dataset to create the subject_dataset
```{r}
> subject_dataset <- rbind(subject_train, subject_test) 
```
We rename the column to make it easy to understand
```{r}
> colnames(subject_dataset) <- "ID_subject" 
```
## Final dataset, containing the data of the three others: final_data 
Dimension of the future final dataset
I always found interesting to compute dimensions of datasets before any try of merge & co. Here it's pretty easy but for some datasets, very 
exhausting for the hardware, it's usefull to predict a little bit what will happen...
The output of "dim()" cannot be shown but usually I use Rmarkdown... :(

x_dataset : 10299 lines, 561 columns 
```{r}
> dim(x_dataset)
[1] 10299   561
```
y_dataset: 1 column
```{r}
> dim(y_dataset)
[1] 10299     1
```
y_dataset: 1 column
```{r}
> dim(subject_dataset)
[1] 10299     1
```
Great! After merging we should have 563 columns and 10299 lines

Merge our datasets into one dataset of dimension 10299 * 563
**First will have the ID column, then name of the activity and finally the various features**
```{r}
> final_data <- cbind(subject_dataset, y_dataset, x_dataset)
```
```{r}
> dim(final_data)
[1] 10299   563    #  <- damn that's a good prediction I did :)
```
**Our dataset is almost ready we will do one more modification to make labels of columns slightly more understandable**
We will just rename the t/f/Acc/Gyro/Mag with the full word found in the description online.
'Acc' becomes 'Accelerometer'
```{r}
> colnames(final_data) <- sub("Acc","Accelerometer",colnames(final_data))
```
'Gyro' becomes 'Gyroscope'
```{r}
> colnames(final_data) <- sub("Gyro","Gyroscope",colnames(final_data))
```
't' becomes 'time'
```{r}
> colnames(final_data) <- sub("^t","Time",colnames(final_data))
```
'f' becomes 'frequency'
```{r}
> colnames(final_data) <- sub("^f","Frequency",colnames(final_data))
```
'mag' becomes 'Magnitude'
```{r}
> colnames(final_data) <- sub("Mag","Magnitude",colnames(final_data))
```
**We now have a dataset containing the ID of the person in the first columns, then the activity not encoded anymore, and finally 561
variables that don't have parenthesis anymore as well as a name "slightly" more easy to read.**

# Extracting all columns that include std (standard deviation) and mean measures

Get only columns which correspond to mean or sandard deviation
We will extract indices of columns that contain either mean or std. Then this vector will be used to extract the good columns. 
```{r}
> mean_std_columns <- grep("-(mean|std)\\(\\)", features[, 2])
```
I added columns 1 and 2 on purpose to include the ID and the activity recorded for the test
```{r}
> mean_std_columns <- c(1,2,mean_std_columns+2) # "+2" is just used to shift all the columns of mean_std_columns by 2
```

# Final dataset 
```{r}
> final_data_extract <- final_data[, mean_std_columns ]
> dim(final_data_extract)
[1] 10299    68
```
We have now "only" 68 columns...
```{r}
> names(final_data_extract)
 [1] "ID_subject"                                      "activity"                                        "TimeBodyAccelerometermeanX"                     
 [4] "TimeBodyAccelerometermeanY"                      "TimeBodyAccelerometermeanZ"                      "TimeBodyAccelerometerstdX"                      
 [7] "TimeBodyAccelerometerstdY"                       "TimeBodyAccelerometerstdZ"                       "TimeGravityAccelerometermeanX"                  
[10] "TimeGravityAccelerometermeanY"                   "TimeGravityAccelerometermeanZ"                   "TimeGravityAccelerometerstdX"                   
[13] "TimeGravityAccelerometerstdY"                    "TimeGravityAccelerometerstdZ"                    "TimeBodyAccelerometerJerkmeanX"                 
[16] "TimeBodyAccelerometerJerkmeanY"                  "TimeBodyAccelerometerJerkmeanZ"                  "TimeBodyAccelerometerJerkstdX"                  
[19] "TimeBodyAccelerometerJerkstdY"                   "TimeBodyAccelerometerJerkstdZ"                   "TimeBodyGyroscopemeanX"                         
[22] "TimeBodyGyroscopemeanY"                          "TimeBodyGyroscopemeanZ"                          "TimeBodyGyroscopestdX"                          
[25] "TimeBodyGyroscopestdY"                           "TimeBodyGyroscopestdZ"                           "TimeBodyGyroscopeJerkmeanX"                     
[28] "TimeBodyGyroscopeJerkmeanY"                      "TimeBodyGyroscopeJerkmeanZ"                      "TimeBodyGyroscopeJerkstdX"                      
[31] "TimeBodyGyroscopeJerkstdY"                       "TimeBodyGyroscopeJerkstdZ"                       "TimeBodyAccelerometerMagnitudemean"             
[34] "TimeBodyAccelerometerMagnitudestd"               "TimeGravityAccelerometerMagnitudemean"           "TimeGravityAccelerometerMagnitudestd"           
[37] "TimeBodyAccelerometerJerkMagnitudemean"          "TimeBodyAccelerometerJerkMagnitudestd"           "TimeBodyGyroscopeMagnitudemean"                 
[40] "TimeBodyGyroscopeMagnitudestd"                   "TimeBodyGyroscopeJerkMagnitudemean"              "TimeBodyGyroscopeJerkMagnitudestd"              
[43] "FrequencyBodyAccelerometermeanX"                 "FrequencyBodyAccelerometermeanY"                 "FrequencyBodyAccelerometermeanZ"                
[46] "FrequencyBodyAccelerometerstdX"                  "FrequencyBodyAccelerometerstdY"                  "FrequencyBodyAccelerometerstdZ"                 
[49] "FrequencyBodyAccelerometerJerkmeanX"             "FrequencyBodyAccelerometerJerkmeanY"             "FrequencyBodyAccelerometerJerkmeanZ"            
[52] "FrequencyBodyAccelerometerJerkstdX"              "FrequencyBodyAccelerometerJerkstdY"              "FrequencyBodyAccelerometerJerkstdZ"             
[55] "FrequencyBodyGyroscopemeanX"                     "FrequencyBodyGyroscopemeanY"                     "FrequencyBodyGyroscopemeanZ"                    
[58] "FrequencyBodyGyroscopestdX"                      "FrequencyBodyGyroscopestdY"                      "FrequencyBodyGyroscopestdZ"                     
[61] "FrequencyBodyAccelerometerMagnitudemean"         "FrequencyBodyAccelerometerMagnitudestd"          "FrequencyBodyBodyAccelerometerJerkMagnitudemean"
[64] "FrequencyBodyBodyAccelerometerJerkMagnitudestd"  "FrequencyBodyBodyGyroscopeMagnitudemean"         "FrequencyBodyBodyGyroscopeMagnitudestd"         
[67] "FrequencyBodyBodyGyroscopeJerkMagnitudemean"     "FrequencyBodyBodyGyroscopeJerkMagnitudestd"     
```
Looks OK.

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.     
We obviously use the "final_data_extract" dataset to create an independent and tidy dataset
The objective is to have a table with the average value of each activity and subject for the 66 columns selected above.
```{r}
final_data_extract_avg <- final_data_extract %>% 
                            group_by(ID_subject,activity) %>%
                            summarise_all(funs(mean))
```
Done. Thank you Dplyr.

We now write the above created dataset in a txt file with a tab separator (my favorite).
```{r}
write.table(final_data_extract_avg, 
            file = paste(main_path, "tidy_data_avg.txt", sep=""),
            row.names=FALSE, col.names = TRUE, sep="\t")
```







