setwd("D:\\ML\\R\\Support Vector Machine")
letters<-read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/letter-recognition/letter-recognition.data",header = F)
View(letters)
colnames(letters)<-c("lettr","x-box","y-box","width","high","onpix","x-bar","y-bar","x2bar","y2bar","xybar","x2ybar","xy2bar","x-ege","xegvy","y-ege","yegvx")
View(letters)
write.csv(letters,file="letters.csv",col.names = F,row.names = F)
# For SVM all the features must be in numeric 
# All the feature values should be in same range 
# If not we should normalize 
# SVM model will perform Rescalling automatically 

# data is randomly arranged 
letters<-read.csv(file.choose())
letters_train<-letters[1:16000,]
letters_test<-letters[16001:20000,]
View(letters)
# to train model
# e1071 package from LIBSVM library written in c++ 
# SVMlight algorithm klar package 

# Begineers SVM functions kernlab package 

# kvsm() function uses gaussian RBF kernel 

# Building model 

library(kernlab)
library(caret)
model1<-ksvm(lettr ~.,data = letters_train,kernel = "vanilladot")
model1

help(kvsm)
??kvsm
# Evaluating model performances 

letter_predictions<-predict(model1,letters_test)

head(letter_predictions)

table(letter_predictions,letters_test$lettr)

mean(letter_predictions==letters_test$lettr)

agreement <- letter_predictions==letters_test$lettr

table(agreement)
prop.table(table(agreement))

# Improving the model performance
# earlier ksvm used simple linear kernel function

# popular gaussian RBF function

model2<-ksvm(lettr ~.,data = letters_train,kernel = "rbfdot")
letter_predict<-predict(model2,letters_test)

head(letter_predict)

table(letter_predict,letters_test$lettr)

agree1<-letter_predict==letters_test$lettr
table(agree1)

prop.table(table(agree1))

