2 + 2 # control + enter  or control + R
# works as calculator

1:50 # print numbers 1 to 50 to the console

50:1 # print numbers 50 to 1 in reverse order to console

print ("Hello World!")

# ctrl + L is going to clear the console

x <- 1:5 # assigning numbers 1 to 5 to the object x
x

y <- c(3, 5, 8, 1, 2) # alt + '-' is the shortcut for assignment operator
y

a <- x + y
a

z <- 4:9
z

x + z

x * 2

ls()  # list objects

install.packages("XML")

library(XML)

version

mba <- read.csv("Desktop/Datasets_BA/mba.csv") # load csv file into R



?read.csv

View(mba) # show the dataset uploaded to R

getwd() # shows the current working directory

setwd("E:/R Codes/Basics") # set a working directory of your choice

str(mba) # quick overview of the variables & dataset

update.packages()

install.packages("foreign")

library(foreign)

spss <- read.spss("cancer.sav")

spss

View(spss)
spss1 <- read.spss("cancer.sav", to.data.frame = T, use.value.labels = T)

View(spss1)

??AirPassengers

?read.spss

install.packages("sas7bdat")  # or install Hmisc
library(sas7bdat)
data(sas7bdat.sources)

View(sas7bdat.sources)

str(sas7bdat.sources)

write.csv(sas7bdat.sources, file = "aaa.csv") 

install.packages("RODBC")
library(RODBC)
odbcDataSources()
getwd()

myconn <-  odbcConnectAccess("(Microsoft Access Driver(*.mdb, *.accdb)); Dbq=Sample.mdb")

Test <- sqlFetch(myconn, "Location")
Test

install.packages("base")
library(base)
web_page_data <- readLines("https://www.qstatix.com")

install.packages("RCurl")
library(RCurl)
data2 <- getURL("https://www.qstatix.com")

browseURL("http://ftp.iitm.ac.in/cran/")


library()
install.packages("xlsx")
library(xlsx)
require(xlsx)

library(help = "xlsx")

vignette(package="xlsx")

browseVignettes(package="xlsx")

vignette()

browseVignettes()


rm(list=ls())
#=======================================================
  
  # vector
  
temp <- c(38, 32, 34, 38, 40)  

mean(1,2,3,4,5)

x <- c(1, 2, 3, 4, 5)

mean(x)

# List

rain <- list('Y', 'N', 'N', 'Y', 'Y')
temp <- list(38, 32, 34, 38, 40)

raintemp <- list(rain, temp)
raintemp

# matrix

temp <- c(38, 32, 34, 38, 40)
percp <- c(110, 102, 103, 117, 90)

matrix(c(temp, percp), nrow=2, byrow=F)

temperptrain <- data.frame(temp = c(38, 32, 34, 38, 40), 
                           percp=c(110, 102, 103, 117, 90), 
                           rain=c('Y', 'N', 'N', 'Y', 'Y'))

temperptrain

#user defined function
cube <- function(x){x*x*x}
cube(2)
cube(1:4) 

#in-built functions
a <- seq(1, 0, -0.1)
a

ordered <- order(fraudData$creditLine) # arrange dataset in ascending order based on a var
fraudData[ordered, ]

fraudData[rev(order(fraudData$creditLine)), ] # arrange dataset in descending order based on a var

cc <- cbind(Plasma, Diabetes) # used to combine 2 datasets with unequal columns

cr <- rbind(hour_transaction, transaction_data) # used to combine 2 datasets with unequal rows

ctwod <- merge(all_transactions, creditdata)

ctwod <- merge(all_transactions, creditdata, all = TRUE)

sum(ctwod$fakeID_Cardholder)

sum(ctwod$fakeID_Cardholder, na.rm=TRUE)

b <- array(1:30, c(5, 3, 4))
a
b
b[ ,2:3, ] # rows, columns, tables

data()
data("EuStockMarkets")
View(EuStockMarkets)
?EuStockMarkets
