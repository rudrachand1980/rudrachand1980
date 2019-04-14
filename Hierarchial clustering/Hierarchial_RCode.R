  # load package 'readxl' to load data from xlsx file
library(readxl)
input <- read_excel("D:/Hierarchical Clustering/University_Clustering.xlsx") 
View(input)
mydata<-input[1:25,c(1,3:8)]
View(mydata)
normalized_data<-scale(mydata[,2:7]) # Excluding the university name column before normalizing the data
d<-dist(normalized_data,method="euclidean") # Distance matrix
fit<-hclust(d,method="complete")
?hclust
plot(fit) # Display Dendrogram
plot(fit,hang=-1)
groups<-cutree(fit,k=5)

?cutree
rect.hclust(fit,k=5,border="red")
?rect.hclust

membership<-as.matrix(groups)

final<-data.frame(mydata,membership)
final1<-final[,c(ncol(final),1:(ncol(final)-1))]
View(final1)

# Load the package for writing the data into xlsx file format
library(xlsx)
write.xlsx(final1,file="final1.xlsx")

# Explore setcolor for repositioning the columns in R 
# Also install the package data.table
install.packages("data.table")
library(data.table)

