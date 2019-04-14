##### Classification using Decision Trees and Rules -------------------

#### Part 1: Decision Trees -------------------
## Understanding Decision Trees ----
# calculate entropy of a two-class segment
-0.60 * log2(0.60) - 0.40 * log2(0.40)

# Entropy curve 
curve(-x * log2(x) - (1 - x) * log2(1 - x),col="red", xlab = "x", ylab = "Entropy", lwd=4)

## Example: Identifying Risky Bank Loans ----
## Step 2: Exploring and preparing the data ----
credit <- read.csv("")
View(credit)
str(credit)

# look at two characteristics of the applicant
table(credit$checking_balance)
table(credit$savings_balance)

# look at two characteristics of the loan
summary(credit$months_loan_duration)
summary(credit$amount)

# look at the class variable
table(credit$default)

# create a random sample for training and test data
# use set.seed to use the same random number sequence as the
set.seed(12345)
credit_rand <- credit[order(runif(1000)), ]

# compare the credit and credit_rand data frames
summary(credit$amount)
summary(credit_rand$amount)
head(credit$amount)
head(credit_rand$amount)

# Preparing Decision tree for the entire data set

library(C50) # this package is used for applying 
# c50 algorithm for building a decision tree

credit_model1<- C5.0(credit[-17],credit$default) # c5.0(all inputs,output)

plot(credit_model1)
# display simple facts about the tree
credit_model1


# For detailed information about tree
summary(credit_model1)
# From the summary we can say that checking_balance is used as root node 
# for decision tree building

# Evakuating accuracy of decision tree
credit_pred1 <- predict(credit_model1, credit) # Predicted values

# cross tabulation of predicted versus actual classes
library(gmodels)
CrossTable(credit$default, credit_pred1,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

# Accuracy of the model 
Accuracy1<-(668+200)/(1000)
Accuracy1 # 86.8%

# Improving the accuracy of Decision tree model by boosting technique
# Boosting decision tree by 5 trails
credit_boost5 <- C5.0(credit[-17], credit$default,
                      trials = 5)

# display simple facts about the tree
credit_boost5


# For detailed information about tree
summary(credit_boost5)
# From the summary we can say that checking_balance is used as root node 
# for decision tree building

# Evakuating accuracy of decision tree
credit_pred5 <- predict(credit_boost5, credit) # Predicted values

# cross tabulation of predicted versus actual classes
library(gmodels)
CrossTable(credit$default, credit_pred5,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

# Accuracy of the model 
Accuracy5<-(668+250)/(1000)
Accuracy5 # 91.8%

# Boosting decision tree by 10 trails
credit_boost10 <- C5.0(credit[-17], credit$default,
                       trials = 5)

# display simple facts about the tree
credit_boost10


# For detailed information about tree
summary(credit_boost10)
# From the summary we can say that checking_balance is used as root node 
# for decision tree building

# Evakuating accuracy of decision tree
credit_pred10 <- predict(credit_boost10, credit) # Predicted values

# cross tabulation of predicted versus actual classes
library(gmodels)
CrossTable(credit$default, credit_pred10,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

# Accuracy of the model 
Accuracy10<-(682+250)/(1000)
Accuracy10 # 93.2%

