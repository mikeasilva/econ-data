# ============================================================================
# BEA API Functions.R
# ============================================================================
# Written by: Mike Silva
# ============================================================================
# These function serves as a wrapper for the BEA's API.  You pass in your API 
# key, a vector of KeyCodes and GeoFIPS and the function returns a matrix with
# all the data.  If you run it through the cleanData function it will scrub it
# and return a data frame.
#
# For more information please refer to the BEA API documentation at:
# http://www.bea.gov/api/_pdf/bea_web_service_api_user_guide.pdf
# ============================================================================

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
  df$GeoFips <- as.character(df$GeoFips)
  df$TimePeriod <- as.numeric(df$TimePeriod)
  df$DataValue <- as.numeric(df$DataValue)
  #Rename the columns
  names(df) <- c('msa.fips', 'year', data.value)
    
  return(df)
}