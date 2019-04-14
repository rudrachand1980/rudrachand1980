library(MASS)
library(neuralnet)
#H2O is fast and scalable opensource machine learning platform.
#several algorith is available.
#install.packages("h2o")
library(h2o)
set.seed(123)
DF <- Boston
str(DF)
help("Boston")
dim(DF)
colnames(DF)
head(DF,3)
apply(DF,2,range)
##function to normalize the data
norm <- function(x){
  (x - min(x)) / (max(x) - min(x))
}
norm_df <- as.data.frame(lapply(DF,FUN = norm))
#st_df <- as.data.frame(lapply(DF,FUN = scale))
#View(st_df)
#head(st_df)
hist(norm_df$medv)
#View(st_df)
#h2o initialisation
h2o.init(ip="localhost",port = 54321,max_mem_size = "1000m")
##defining dataset x and y
y <- "medv"
x <- setdiff(colnames(DF),y)

##splitting dataset train and test
library(caTools)
training <- sample.split(norm_df$medv,SplitRatio = 0.8)
df_train <- subset(norm_df,training==TRUE)
df_test <- subset(norm_df,training==FALSE)

##fit the model
#?h2o.deeplearning
##x is the predictors, y is the response variable names

##activation = Tanh,Tanhwithdropout,rectifiers

##input dropout ratio = take any random sampling
##n folds= number of fold for cross validation
##distribution=gaussian,poission,bournouli
model_deep <- h2o.deeplearning(x=x,
                               y=y,
                               seed = 1234,
                               training_frame = as.h2o(df_train),
                               nfolds = 3,
                               stopping_rounds = 7,
                               epochs = 400,
                               overwrite_with_best_model = TRUE,
                               activation = "Tanh",
                               input_dropout_ratio = 0.1,
                               hidden = c(10,10),
                               l1=6e-4,
                               loss = "Automatic",
                               distribution = "AUTO",
                               stopping_metric = "MSE")
#plot(model_deep)
model_deep
#h2o.shutdown(promt=FALSE)
