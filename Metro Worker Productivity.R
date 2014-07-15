# ============================================================================
# Metro Worker Productivity.R
# ============================================================================
# Written by: Mike Silva
# ============================================================================
# This script constructs a Metro Worker Productivity data set using the BEA's 
# regional estimates as distributed by their API.
# ============================================================================

# The following file assigns my BEA API key to the variable 'api.key'
source('~/bea.api.key.R')
# This file has the beaAPI and cleanData function
source('~/BEA API Functions.R')

# The following csv has the list of all the metros and their FIPS codes.  It 
# was downloaded from http://www.bea.gov/regional/docs/msalist.cfm by 
# selecting the MSA's by state and downloading the CSV.
metrolist <- read.csv('metrolist.csv', header=FALSE)
names(metrolist) <- c('state.fips','state.name','msa.fips','msa.name')
geo.fips.vector <- metrolist$msa.fips

# Download & Clean Total Employment Data
employment <- beaAPI(api.key, 'EMP000_MI', geo.fips.vector)
employment <- cleanData(as.data.frame(employment), 'employment')

# Download & Clean Real GDP data
real.gdp <- beaAPI(api.key, 'RGDP_MP', geo.fips.vector)
real.gdp <- cleanData(as.data.frame(real.gdp), 'real.gdp')

# Create the productivity data frame
productivity <- merge(real.gdp, employment, by=c('msa.fips', 'year'), all.y=FALSE)
productivity$worker.productivity <- (productivity$real.gdp*1000000) / productivity$employment

# Save the data
write.csv(productivity, 'Metro Worker Productivity.csv')
write.csv(employment, 'Metro Total Employment.csv')
write.csv(real.gdp, 'Metro Real GDP.csv')
