setwd("D:/ML/R/KNN")
library(readr)
wbcd<-read_csv("D:/ML/R/KNN/wbcd.csv")
View(wbcd)
str
##retrieve the dimension
dim(wbcd)

# Id column can be removed 
wbcd<-wbcd[-1]
dim(wbcd)
# count of types of cancer 
table(wbcd$diagnosis)
# Converting the diagnosis into factor and assigning M as Malignant and B as Benign
wbcd$diagnosis<-factor(wbcd$diagnosis,levels = c("B","M"),labels = c("Benign","Malignant"))
# count of B and M
table(wbcd$diagnosis)
# Proportions of B and M
round(prop.table(table(wbcd$diagnosis))*100,digits=1)
# rest of the data contains 3 different measures of 10 characteristics
summary(wbcd[c("radius_mean","area_mean","smoothness_mean")])
# From the above data it seems that area will show more influence than smoothness. So we will normalize the data
normalize_data<-function(x){
  return((x-min(x))/(max(x)-min(x)))
}
# Rather than applying each element individually we will use "lapply()" function in R which 
# it considers the list and applies the function to each list element
# Lapply function considers each column as list and it will apply function to each element under columns
wbcd_n<-as.data.frame(lapply(wbcd[2:31],normalize_data))
summary(wbcd_n$area_mean)

# for predicting the accuracy of the model we will first split the data into training and testing 
# training - 469 and test data contains -100 data
# [ row column ] <- syntax
wbcd_train<-wbcd_n[1:469,]
dim(wbcd_train)
wbcd_test<-wbcd_n[470:569,]
dim(wbcd_test)

# we will exclude the target variables from training and test data sets. For training we need to store
# these into factor vectors

wbcd_train_labels<-wbcd[1:469,1]
wbcd_train_labels<-as.factor(wbcd_train_labels[[1]])
class(wbcd_train_labels)
wbcd_test_labels<-wbcd[470:569,1]
wbcd_test_labels<-as.factor(wbcd_test_labels[[1]])
class(wbcd_test_labels)
# class package for classification which is a k-nn implementation and we will use knn() to to implement
# knn algorithm. knn() takes 4 parameters - train,test,class,k
library(class)
wbcd_test_pred<-knn(wbcd_train,wbcd_test,cl=wbcd_train_labels,k=21) # sqrt(469) generalized k-value odd number 
class(wbcd_test_pred)
# choosing an odd number elimates the chance of getting tie

# evaluating the model performance
# wbcd_test_pred vector should match with wbcd_test_labels
# By crosstable function from gmodels package
library(gmodels)
# cross table
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred,
           prop.chisq=FALSE)

