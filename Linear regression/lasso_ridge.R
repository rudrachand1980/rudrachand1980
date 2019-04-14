library(glmnet)
library(psych)
library(mlbench)
library(caret)

data("BostonHousing")
data <- BostonHousing
str(data)
pairs.panels(data[c(-4,-14)])
#Data Partition
set.seed(222)
ind <- sample(2,nrow(data),replace = T,prob = c(0.7,0.3))
train_data <- data[ind == 1,]
test_data  <- data[ind == 2,]
#Custom control parameters
custom <- trainControl(method = "repeatedcv",number = 10,repeats = 5,verboseIter = T)
#linear Model
set.seed(1234)
lm <- train(medv ~.,train_data,method = 'lm',trControl = custom)
lm$results
summary(lm)
plot(lm$finalModel)
#Ridge regression
set.seed(1234)
ridge <- train(medv ~.,train_data,method = 'glmnet',trControl = custom , tuneGrid = ())
print(ridge)
