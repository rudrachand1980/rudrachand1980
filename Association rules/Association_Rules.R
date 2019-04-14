# External data set
gros<-read.transactions(file.choose(),format = "basket",sep=",")
gras<-read.csv(file.choose(),header=F)
inspect(gros[1:10])
# If we inspect book_trans
# we should get transactions of items i.e.
# As we have 2000 rows ..so we should get 2000 transactions 
# Each row represents one transactions 
# After converting the binary format of data frame from matrix to transactions
# Perform apriori algorithm 
View(gras)
itemFrequencyPlot(gros,topN= 20) # Top 20 Items freequency plot
groc_rules<-apriori(gros,parameter = list(support=0.002,confidence=0.5))
plot(groc_rules)

# Converting data into transactions format is very important
# Once after conversion, in order to verify whether we got exact transactions format
# or not .. do inspect(transactions obtained)
# if it shows exact transactions for specific id then it is perfect, we can proceed

# In the above code format has two values either "basket" or "single"
# basket = When we have transactions represented in single row 
# Ex:      1 A,B,C
#          2 D,E,A
# We have to consider basket and sep = "," if they are separated by ","
# While cols when format = " basket" means when we have any transaction ID column 
# Then represent the column number in cols 
# cols = 1 (for movies data set we have transactions ID in 1st column )


# single = When we have transactions items represented by an transaction id like
# we have in dvd data set
# EX:          1  A
#   1  B
#   2  C
#   2  E
# Delete the heading as it will consider as one transaction
# cols=c(1,2) 1 column index-transaction ID and 2 column index- Items 

# Whenever we have binary kind of data .....load them as csv and convert them into 
# matrix format using as.matrix(data) and use this for forming 
# Association rules and change the values of support,confidence, and minlen 
# to get different rules 


# Whenever we have data containing item names, then load that data using 
# read.transactions(file="path",format="basket",sep=",")
# use this to form association rules 



# Inbuilt data set

data("Groceries")
itemFrequencyPlot(Groceries,topN=30) # Top 30 Items freequency plot
bgros<-apriori(Groceries,parameter = list(support=0.002,confidence=0.5))
library(arulesViz)
plot(bgros)
