## Create Metro Employment Rates RDS.R
## This script takes the BLS LAUS data and computes metro employment rates.  
## There are three measures: the MSA as a whole, central areas within the metro
## area and outlying areas of the metro area.

## Load the BLS LAUS data
bls.laus.employment.data <- readRDS('~/GitHub/econ-data/bls.laus.employment.data.rds')

## Aggregate data by metro area and compute the employment rate
metro.employed <- aggregate(employed ~ msa.fips + year + period + period.name, data = bls.laus.employment.data, FUN = sum)
metro.labor.force <- aggregate(labor.force ~ msa.fips + year + period + period.name, data = bls.laus.employment.data, FUN = sum)
metro <- merge(metro.employed, metro.labor.force)
metro$employment.rate <- metro$employed / metro$labor.force
rm(metro.employed, metro.labor.force)

## Compute the employment rate for central areas
central.employed <- aggregate(employed ~ msa.fips + year + period + period.name, data = bls.laus.employment.data[bls.laus.employment.data$central.outlying == 'Central',], FUN = sum)
central.labor.force <- aggregate(labor.force ~ msa.fips + year + period + period.name, data = bls.laus.employment.data[bls.laus.employment.data$central.outlying == 'Central',], FUN = sum)
central <- merge(central.employed, central.labor.force)
central$employment.rate <- central$employed / central$labor.force
rm(central.employed, central.labor.force)

## Compute the employment rate for outlying areas
outlying.employed <- aggregate(employed ~ msa.fips + year + period + period.name, data = bls.laus.employment.data[bls.laus.employment.data$central.outlying == 'Outlying',], FUN = sum)
outlying.labor.force <- aggregate(labor.force ~ msa.fips + year + period + period.name, data = bls.laus.employment.data[bls.laus.employment.data$central.outlying == 'Outlying',], FUN = sum)
outlying <- merge(outlying.employed, outlying.labor.force)
outlying$employment.rate <- outlying$employed / outlying$labor.force
rm(outlying.employed, outlying.labor.force)

## Merge the 3 data tables
names(metro)[5:7] <- c('metro.employed', 'metro.labor.force', 'metro.employment.rate')
names(central)[5:7] <- c('central.employed', 'central.labor.force', 'central.employment.rate')
names(outlying)[5:7] <- c('outlying.employed', 'outlying.labor.force', 'outlying.employment.rate')
metro.employment.rates <- merge(merge(metro, central), outlying)

## Fix the date
metro.employment.rates$date <- as.Date(paste('1',metro.employment.rates$period.name,metro.employment.rates$year), format="%d %B %Y")

## Save the data
saveRDS(metro.employment.rates, file='metro.employment.rates.rds')
rm(bls.laus.employment.data, central, metro, outlying)
