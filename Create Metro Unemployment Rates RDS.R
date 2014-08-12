## Create Metro Unemploymenr Rates RDS.R
## This script takes the BLS LAUS data and computes metro unemployment rates.  
## There are three measures: the MSA as a whole, central areas within the metro
## area and outlying areas of the metro area.

## Load the BLS LAUS data
bls.laus.data <- readRDS('~/GitHub/econ-data/bls.laus.data.rds')

## Aggregate data by metro area and compute the unemployment rate
metro.unemployed <- aggregate(unemployed ~ msa.fips + year + period + period.name, data = bls.laus.data, FUN = sum)
metro.labor.force <- aggregate(labor.force ~ msa.fips + year + period + period.name, data = bls.laus.data, FUN = sum)
metro <- merge(metro.unemployed, metro.labor.force)
metro$unemployment.rate <- metro$unemployed / metro$labor.force
rm(metro.unemployed, metro.labor.force)

## Compute the unemployment rate for central areas
central.unemployed <- aggregate(unemployed ~ msa.fips + year + period + period.name, data = bls.laus.data[bls.laus.data$central.outlying == 'Central',], FUN = sum)
central.labor.force <- aggregate(labor.force ~ msa.fips + year + period + period.name, data = bls.laus.data[bls.laus.data$central.outlying == 'Central',], FUN = sum)
central <- merge(central.unemployed, central.labor.force)
central$unemployment.rate <- central$unemployed / central$labor.force
rm(central.unemployed, central.labor.force)

## Compute the unemployment rate for outlying areas
outlying.unemployed <- aggregate(unemployed ~ msa.fips + year + period + period.name, data = bls.laus.data[bls.laus.data$central.outlying == 'Outlying',], FUN = sum)
outlying.labor.force <- aggregate(labor.force ~ msa.fips + year + period + period.name, data = bls.laus.data[bls.laus.data$central.outlying == 'Outlying',], FUN = sum)
outlying <- merge(outlying.unemployed, outlying.labor.force)
outlying$unemployment.rate <- outlying$unemployed / outlying$labor.force
rm(outlying.unemployed, outlying.labor.force)

## Merge the 3 data tables
keep <- c(names(metro)[1:4], names(metro)[7])
metro <- metro[,keep]
central <- central[,keep]
outlying <- outlying[,keep]
names(central)[5] <- 'central.unemployment.rate'
names(outlying)[5] <- 'outlying.unemployment.rate'
metro.unemployment.rates <- merge(merge(metro, central), outlying)

## Save the data
saveRDS(metro.unemployment.rates, file='metro.unemployment.rates.rds')
rm(bls.laus.data, central, metro, outlying, keep)
