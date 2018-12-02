############# Spend Prediction Analysis ##################

### removing existing environment variables
rm(list = ls())

###### Installing required packages start ##############
installPackages <- function(x){
  for(i in x){
    if(i %in% rownames(installed.packages()) == FALSE) {
      install.packages(i)
    }
  }
}

###### Installing required packages end ######

### Function to get start and end dates of dataset #######
startEndDates <- function(x){
  start <- c(year(start(x)), month(start(x)))
  end <- c(year(end(x)), month(end(x)))
  return(list(start,end))
}
### Function to get start and end dates of dataset #######

### function to convert XTS object into ts object #######
convert_XTS_TS <- function(dataset, frequency){
  # Convert the xts object to the ts class
  start <- startEndDates(dataset)
  data <- ts(as.numeric(dataset), start = start[[1]], 
             end = start[[2]], frequency = 12)
  return(data)
}
### function to convert XTS object into ts object #######

### Function to tune Hyperparameters of the algorithms #######
algoTune <- function(x, y, z, train, test, algoFlag){
  defaultacc <- 1000
  for(i in x){
    for(j in y){
      for(k in z){
        if(algoFlag == 'holt'){
          Model <- HoltWinters(train,
                               seasonal = "additive",
                               alpha = i,
                               beta = j,
                               gamma = k)
          Forecast <- forecast(Model,  h=length(test))
        } else {
          tryCatch({ Model <- 
            Arima(train, c(i, j, k),
                  seasonal = list(order = c(i, j, k), period = 12))
          Forecast <- forecast(Model,  h=length(test))
          })
        }
        
        acc <- accuracy(Forecast,test)
        avgacc <- mean(acc[,2])
        
        if(avgacc < defaultacc){
          defaultacc <- avgacc
          vec <- c(i,j,k)
          return(c(vec, defaultacc))
        }
      }
    }
  }
}
### Function to tune Hyperparameters of the algorithms #######

### Function for time series forecasting #######
spend_func <- function(dataset_name, pFlag, pPrice, percent){
  if((pFlag == TRUE) | (pPrice == TRUE)){
    colnames(dataset_name)  <- c("x1","x2")
    
    ### Creating XTS object
    dataset_name.xts <- xts(x=dataset_name$x1,order.by = dataset_name$x2)
    dataset_name.monthly  <- apply.monthly(dataset_name.xts, mean)
    
    # select first 80% data for train and 20% to test data
    trainrows   <- floor(percent*length(dataset_name.monthly))
    train       <- dataset_name.monthly[1:trainrows,]
    test        <- dataset_name.monthly[(trainrows+1):length(dataset_name.monthly),]
    
    ## Converting XTS object to TS object
    dataset_name.full  <- convert_XTS_TS(dataset_name.monthly, 12) 
    dataset_name.train <- convert_XTS_TS(train, 12)
    dataset_name.test  <- convert_XTS_TS(test, 12)
    
    alpha <- c(0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
    beta  <- c(0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
    gamma <- c(0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
    
    p <- c(0,1)
    d <- c(0,1)
    q <- c(0,1)

    holts  <- algoTune(alpha, beta, gamma, dataset_name.train, dataset_name.test,'holt')
    arimas <- algoTune(p, d, q, dataset_name.train, dataset_name.test,'arima')
    
    if(holts[4] < arimas[4]){
      final.model <- HoltWinters(dataset_name.full, 
                                 seasonal = "additive",
                                 alpha = holts[1],
                                 beta = holts[2],
                                 gamma = holts[3])
    } else{
      tryCatch(
        { final.model <- 
          arima(dataset_name.full, 
                c(arimas[1], arimas[3], arimas[3]),
                seasonal = list(order = c(arimas[1], 
                                          arimas[2], 
                                          arimas[3] ), period = 12))
      })
    }
    
    forecast.final <- forecast(final.model, h = 6)
    forecast.final <- as.data.frame(forecast.final)
    forecast.final <- forecast.final %>% select(-one_of(c("Lo 80","Hi 80","Lo 95","Hi 95")))
    forecast.final <- setDT(forecast.final, keep.rownames = TRUE)[]
    
    colnames(forecast.final) <- c("x2","x1")
    forecast.final$x2        <- lubridate::mdy(forecast.final$x2)  
    forecast.final           <- forecast.final[,c("x1", "x2")]
    colnames(forecast.final) <- predcols
    return(forecast.final)
  }
}
### Function for time series forecasting #######

################################ Program Start ######################################

installPackages(c('lubridate','forecast','TTR','dplyr',
                  'xts', 'xlsx','data.table','caret'))

library(lubridate) # date and time
library(forecast) # time series analysis
library(TTR)
library(dplyr)
library(xts)
library(tseries)
library(xlsx)
library(data.table)
library(caret)

file <- "New Sample data for spend calculation.xlsx"
sheets <- length(excel_sheets(file)) - 1 ## Get no of sheets

### Read the input excel file
for(sheet in 1:sheets){
  data1 <- read.xlsx(file, sheetIndex = sheet)
  
  
  ### Drop rows if all the rows are null values
  data1 <- data1[rowSums(is.na(data1)) != ncol(data1), ]
  data1$Transaction.Date <- lubridate::ymd(data1$Transaction.Date)
  orgCol <- colnames(data1)
  dataorg <- data1
  pslFlag <- unique(data1$PSL)
  predictPrice <- FALSE
  predictFlag <- FALSE
  priceFlag <- length(unique(dataorg$Unit.Price))
  quantityFlag <- length(unique(dataorg$Quantity))
  spendFlag <- length(unique(dataorg$Spend))
  noof_forecast <- 6
  
  ### If pslFlag = 'No' or price and quantity not available then predict Spend
  if((pslFlag == 'No') | ( priceFlag == 1 & quantityFlag == 1 & spendFlag > 1)) {
    data1 <- data1[,c("Spend","Transaction.Date")]
    predcols <- colnames(data1)
    predictFlag <- TRUE
    forecastResult <- spend_func(data1, predictFlag, predictPrice, 0.8)
    ### If pslFlag = 'Yes' predict unit price or quantity based on conditions
  } else {
    if(class(dataorg$Contract.end.date) == "factor"){
      dataorg$Contract.end.date <- lubridate::dmy(data1$Contract.end.date)
    } else {
      dataorg$Contract.end.date <- lubridate::ymd(data1$Contract.end.date)
    }
    lastrow <- dataorg[nrow(dataorg),]
    prevprice <- lastrow$Unit.Price
    YoYFlag <- ifelse(is.na(lastrow$YoY.price.change) == FALSE, TRUE, FALSE)
    data1 <- data1[c("Unit.Price","Quantity","Transaction.Date")]
    
    if(YoYFlag){
      newprice <- prevprice + lastrow$YoY.price.change
    } else { ### If "YoY price change" feature is blank, then predict price
      data2 <- data1[c("Unit.Price","Transaction.Date")]
      predcols <- colnames(data2)
      predictPrice <- TRUE
      priceForecast <- spend_func(data2, predictFlag, predictPrice, 0.8)
    }
    
    ### If "Quantity" feature is varying, then predict Quantity
    if(length(unique(data1$Quantity)) > 1) {
      data3 <- data1[c("Quantity","Transaction.Date")]
      predcols <- colnames(data3)
      predictFlag <- TRUE
      quantityForecast <- spend_func(data3,predictFlag, predictPrice, 0.8)
    }
    
    ### Combine the price and Quantity forecast results
    if(predictPrice == TRUE & predictFlag == TRUE){
      finalForecast <- cbind(priceForecast, quantityForecast)
    } else if(predictPrice == TRUE & predictFlag == FALSE){
      finalForecast <- priceForecast
    } else if(predictPrice == FALSE & predictFlag == TRUE){
      finalForecast <- quantityForecast
    }
    
    if(predictPrice == TRUE | predictFlag == TRUE){
      finalForecast <- as.data.frame(finalForecast)
      cols <- !duplicated(colnames(finalForecast), fromLast = TRUE)
      finalForecast <- finalForecast[, cols]
    }
    
  }
  
  if((pslFlag == 'No') | ( priceFlag == 1 & quantityFlag == 1 & spendFlag > 1)) {
    temp.data       <- forecastResult[,c(2,1)]
    temp.data       <- cbind(dataorg[1:noof_forecast,1:18],  temp.data)
    final_dataset   <- rbind(dataorg,temp.data)
    final_dataset$Spend <- round(final_dataset$Spend,2)
  } else{
    # No prediction required, reduce price by YOY percentage
    if(predictFlag == FALSE & predictPrice == FALSE){
      temp.data <- dataorg[1:noof_forecast,c(1:20)]
      lastdate <- max(dataorg$Transaction.Date)
      dates <- seq(lastdate+1, by = "month", length.out = noof_forecast)
      temp.data$Transaction.Date <- dates
      # predict price and quantity 
    } else if(predictPrice == TRUE & predictFlag == TRUE){
      temp.data <- cbind(dataorg[1:noof_forecast,c(1:16)], 
                         finalForecast, dataorg[1:noof_forecast,c(20)])
      colnames(temp.data) <- orgCol
      # Predict Quantity
    } else if(predictPrice == FALSE & predictFlag == TRUE){
      temp.data <- cbind(dataorg[1:noof_forecast,c(1:17)], finalForecast, 
                         dataorg[1:noof_forecast,c(20)])
      colnames(temp.data) <- orgCol
    }
    
    if(YoYFlag){
      temp.data$Unit.Price <- newprice
    }
    
    final_dataset   <- rbind(dataorg,temp.data)
    final_dataset$Spend <- final_dataset$Unit.Price * final_dataset$Quantity
    
    if(max(final_dataset$Transaction.Date) > max(final_dataset$Contract.end.date)){
      filter <- final_dataset$Transaction.Date > final_dataset$Contract.end.date
      ### Reducing price by 3% for competative bid
      final_dataset[filter,]$Unit.Price <- final_dataset[filter,]$Unit.Price - 
        (0.03 * final_dataset[filter,]$Unit.Price)
      ### Calculating spend
      final_dataset[filter,]$Spend <- 
        final_dataset[filter,]$Unit.Price * final_dataset[filter,]$Quantity
    }
    
    final_dataset$Unit.Price <- round(final_dataset$Unit.Price,2)
    final_dataset$Quantity <- round(final_dataset$Quantity,0)
    final_dataset$Spend <- round(final_dataset$Spend,2)
  }
  
  print(sheet)
  #  Writing forecast result into csv file
  write.xlsx(final_dataset,'Forecast_result.xlsx', 
             sheetName=paste("Case",sheet), append = TRUE,
             row.names = FALSE)
}

################################ Program End ######################################