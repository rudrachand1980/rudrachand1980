library(rvest)
library(magrittr)
library(XML)
a<-10
king<-NULL
url1<-"http://www.imdb.com/title/tt0944947/reviews?start="
for(i in 0:55){
  url<-read_html(as.character(paste(url1,i*a,sep="")))
  ping<-url %>%
    html_nodes("#tn15content p") %>%         
    html_text() 
  king<-c(king,ping)
}
king
write.table(king,"gameofthrones.txt")


### (#tn15content p) for this you have download an google extension
# SelectorGadget
# One you have installed
# Go to reviews page and click on the SelectorGadget, by clicking it will enable
# Its functioning and now navigate your cursor to the content which you 
# Want to extract once you click that content it will highlight all the 
# common content which is under the same path 
# Scroll down if it is highlighting any extra things other than the content 
# you want to extract and click that content. It will make that content red.
# Once you have done selecting the appropriate content, copy the path which is 
# Displayed in the Selectorgadget bar in the R code

# This code is used only for extracting reviews which are publicly available
