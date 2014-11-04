## Using my blsAPI package
## https://github.com/mikeasilva/blsAPI
library('blsAPI')

csv <- read.csv('List1.csv', stringsAsFactors=FALSE, colClasses=rep('character',14))

## Only get the Metros
csv <- csv[csv$Metropolitan.Micropolitan.Statistical.Area == "Metropolitan Statistical Area",]

## Build the BLS Series ids for the employed and labor force estimates
series.ids <- paste0('LAUCN', csv$FIPS.State.Code, csv$FIPS.County.Code,'000000000')

## Build the matrix to hold the data
employed <- matrix(ncol=8, nrow=0)
labor.force <- matrix(ncol=8, nrow=0)

## This function adds processes the JSON data and adds it to the matrix
processData <- function (m, msa.fips, state.fips, county.fips, central.outlying, data){
  for(d in data){
    data.year <- d$year
    data.period <- d$period
    data.period.name <- d$periodName
    data.value <- d$value
    new.row <- c(msa.fips, state.fips, county.fips, central.outlying, data.year, data.period, data.period.name, data.value)
    m <- rbind(m, new.row)
  }
  return(m)
}

## Build the progressbar
pb <- txtProgressBar(min = 0, max = length(series.ids), style = 3)

## Loop through the series
for (i in 1:length(series.ids)){
  #message('Getting series ',i,' of ',length(series.ids))
  msa.fips <- csv[i,'CBSA.Code']
  state.fips <- csv[i, 'FIPS.State.Code']
  county.fips <- csv[i, 'FIPS.County.Code']
  central.outlying <- csv[i, 'Central.Outlying.County']
  series.id <- series.ids[i]
  ## The BLS API has a 10 year maximum.  This allows us to pull the full range
  start.years <- c('1990','2001','2011')
  end.years <- c('2000','2010','2014')
  for(j in 1:length(start.years)){
    start.year <- start.years[j]
    end.year <- end.years[j]
    payload <- list(
      'seriesid' = c(
        paste0(series.id,'5'), 
        paste0(series.id,'6')), 
      'startyear' = start.year, 
      'endyear' = end.year
    )
    ## Make the API request
    response <- blsAPI(payload)
    ## Parse the response
    json <- fromJSON(response)
    ## Get the data
    u <- json$Results$series[[1]]$data
    lf <- json$Results$series[[2]]$data
    ## Add it to the matrix
    employed <- processData(employed, msa.fips, state.fips, county.fips, central.outlying, u)  
    labor.force <- processData(labor.force, msa.fips, state.fips, county.fips, central.outlying, lf)
  }
  ## Update the progress bar
  setTxtProgressBar(pb, i)
}
## Turn the matrix into a data frame
employed <- as.data.frame(employed)
labor.force <- as.data.frame(labor.force)
## Rename the columns
names(employed) <- c('msa.fips','state.fips','county.fips','central.outlying','year','period','period.name','value')
names(labor.force) <- names(employed)

# Post Processing
names(employed)[8] <- 'employed'
names(labor.force)[8] <- 'labor.force'
bls.laus.employment.data <- merge(employed, labor.force)
rm(labor.force, employed, central.outlying, county.fips, end.year, end.years, i,j,json,lf,msa.fips, payload,pb,response,series.id,series.ids,start.year,start.years,state.fips,u, csv, processData)
saveRDS(bls.laus.employment.data, 'bls.laus.employment.data.rds')