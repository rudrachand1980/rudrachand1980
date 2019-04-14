
#install.packages("arules")
library("arules") 
phonedata <- read.csv("G:/DATA SCIENCE/HYD(19-02-17)/R Codes/Association Rules/PhoneData.csv")
View(phonedata)
attach(phonedata)
# What is apriori
?apriori
# Rules Generated from apriori algorithm
library("arulesViz")
#inspect(rules,by="lift")
?inspect

# converting phonedata into matrix format using as.matrix
rules<-apriori(as.matrix(phonedata),parameter = list(support = 0.01,confidence=0.5,target="rules",minlen=3))
inspect(rules) # to view rules we use inspect 

# Different types of visualization of rules
plot(rules,method = "grouped")
plot(rules,method = "graph")

