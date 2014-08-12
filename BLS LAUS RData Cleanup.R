## BLS LAUS RData Cleanup.R
## Some observations have the labor force and unemployed estimates
## switched.  This script corrects this problem.

## Load the RData file
load('~/GitHub/econ-data/bls.laus.data.RData')

## Change the type
bls.laus.data$labor.force <- as.numeric(as.character(bls.laus.data$labor.force))
bls.laus.data$unemployed <- as.numeric(as.character(bls.laus.data$unemployed))

## Remove the NAs
bls.laus.data <- bls.laus.data[!is.na(bls.laus.data$unemployed),]
bls.laus.data <- bls.laus.data[!is.na(bls.laus.data$labor.force),]

## Correct the data in 6 simple steps

## Step 1: Create temp data frame
data <- bls.laus.data
## Step 2: Fix the issue
data[bls.laus.data$unemployed > bls.laus.data$labor.force,8] <- bls.laus.data[bls.laus.data$unemployed > bls.laus.data$labor.force,9]
data[bls.laus.data$unemployed > bls.laus.data$labor.force,9] <- bls.laus.data[bls.laus.data$unemployed > bls.laus.data$labor.force,8]
## Step 3: Check to make sure no observations are incorrect
data[data$unemployed > data$labor.force,]
"
This step should return the following:

[1] msa.fips         state.fips       county.fips     
[4] central.outlying year             period          
[7] period.name      labor.force      unemployed      
<0 rows> (or 0-length row.names)
"
## Step 4: Replace the data frame
bls.laus.data <- data

## Step 5: Cleanup the environment
rm(data)

## Step 6: Save the Data
save.image("~/GitHub/econ-data/bls.laus.data.RData")
saveRDS(bls.laus.data, file='~/GitHub/econ-data/bls.laus.data.rds')
