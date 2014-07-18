# ============================================================================
# BEA API Data Download.R
# ============================================================================
# Written by: Mike Silva
# ============================================================================
# This script pulls down metro level BEA estimates distributed by their API.
# The data are saved as csv files for further analysis.

# The following file assigns my BEA API key to the variable 'api.key'
source('~/bea.api.key.R')
# This file has the beaAPI and cleanData function
source('~/BEA API Functions.R')

# The following csv has the list of all the metros and their FIPS codes.  It 
# was downloaded from http://www.bea.gov/regional/docs/msalist.cfm by 
# selecting the MSA's by state and downloading the CSV.
metrolist <- read.csv('metrolist.csv', header=FALSE)
names(metrolist) <- c('state.fips','state.name','msa.fips','msa.name')
metrolist <- metrolist[c('msa.fips','msa.name')]
metrolist <- metrolist[!duplicated(metrolist),]
geo.fips.vector <- metrolist$msa.fips

key.codes <- c('TPI_MI', 'POP_MI', 'PCPI_MI', 'NFPI_MI', 'FPI_MI', 'EARN_MI', 'CGSI_MI', 'NE_MI', 'DIR_MI', 'PCTR_MI', 'ws_mi', 'SUPP_MI', 'PROP_MI', 'EMP000_MI', 'EMP100_MI', 'EMP200_MI', 'PJEARN_MI', 'PJWS_MI', 'PJCOMP_MI')
measures <- c('total.personal.income', 'population', 'per.capita.personal.income', 'nonfarm.personal.income', 'farm.personal.income', 'earnings.by.place.of.work', 'contributions.for.government.social.insurance', 'net.earnings.by.place.of.residence', 'dividends.interest.and.rent', 'personal.current.transfer.receipts', 'wages.and.salaries', 'supplements.to.wages.and.salaries', 'proprietors.Income', 'total.employment', 'wage.and.salary.employment', 'proprietors.employment', 'average.earnings.per.job', 'average.wage.per.job', 'average.compensation.per.job')

for (i in 1:length(key.codes)){
  # Display a message so I can see the progress
  message('Downloading ', i, ' of ', length(key.codes))
  key.code <- key.codes[i]
  measure <- measures[i]
  # Download the data
  data <- beaAPI(api.key, key.code, geo.fips.vector)
  # Clean the data
  data <- cleanData(as.data.frame(data), measure)
  data$msa.fips <- as.character(data$msa.fips)
  file.name <- paste0('bea ', gsub('[.]', ' ', measure),'.csv')
  write.csv(data, file.name)
}