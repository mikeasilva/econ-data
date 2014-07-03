metrolist <- read.csv('metrolist.csv', header=F)
names(metrolist) <- c('state.fips','state.name','msa.fips','msa.name')

beaAPI <- function(api.key, key.code.vector, geo.fips.vector){
  library(RCurl) 
  library(rjson)
  
  data.matrix <- matrix(ncol=7, nrow=0)
  
  api.url <- 'http://www.bea.gov/api/data/'
  
  key.codes <- length(key.code.vector)
  geo.fipss <- length(geo.fips.vector)
  total <- key.codes * geo.fipss
  pb.i <- 0
  pb <- txtProgressBar(min = pb.i, max = total, style = 3)
  
  for(key.code in key.code.vector){
    for(geo.fips in geo.fips.vector){
      req.uri <- paste0(api.url,
                        '?&UserID=',api.key,
                        '&KeyCode=',key.code,
                        '&GeoFIPS=',geo.fips,
                        '&method=GetData&datasetname=RegionalData&ResultFormat=JSON&'
                        )
      json <- fromJSON(getURL(req.uri))
      for(new.row in json$BEAAPI$Results$Data){
        data.matrix <- rbind(data.matrix, new.row)
      }
      pb.i <- pb.i + 1
      setTxtProgressBar(pb, pb.i)
    }    
  }
  return(data.matrix)
}

cleanData <- function(df, data.value){
  # Keep only the 3 columns we are interested in
  keep <- c("GeoFips", "TimePeriod", 'DataValue')
  df <- df[keep]
  # Remove any duplicates
  df <- df[!duplicated(df),]
  # Change Variable Types
  df$TimePeriod <- as.numeric(df$TimePeriod)
  df$DataValue <- as.numeric(df$DataValue)
  #Rename the columns
  names(df) <- c('msa.fips', 'year', data.value)
  
  return(df)
}

source('~/bea.api.key.R')

key.code.vector <- c('EMP000_MI','RGDP_MP','POP_MI')
geo.fips.vector <- metrolist$msa.fips

# Download & Clean Total Employment Data
employment <- beaAPI(api.key, 'EMP000_MI', geo.fips.vector)
#employment <- cleanData(as.data.frame(employment), 'employment')


# Download & Clean Real GDP data
real.gdp <- beaAPI(api.key, 'RGDP_MP', geo.fips.vector)
#real.gdp <- cleanData(as.data.frame(real.gdp), 'real.gdp')

productivity <- merge(cleanData(as.data.frame(real.gdp), 'real.gdp'), cleanData(as.data.frame(employment), 'employment'), by=c('msa.fips', 'year'), all.y=FALSE)
productivity$worker.productivity <- (productivity$real.gdp*1000000) / productivity$employment
