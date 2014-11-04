## BLS LAUS Employment RDS Cleanup.R
## Some observations have the labor force and employed estimates
## switched.  This script corrects this problem.

## Load the RDS file
bls.laus.employment.data <- readRDS('bls.laus.employment.data.rds')


## Change the type
bls.laus.employment.data$labor.force <- as.numeric(as.character(bls.laus.employment.data$labor.force))
bls.laus.employment.data$employed <- as.numeric(as.character(bls.laus.employment.data$employed))
bls.laus.employment.data$year <- as.numeric(as.character(bls.laus.employment.data$year))


## Remove the NAs
bls.laus.employment.data <- bls.laus.employment.data[!is.na(bls.laus.employment.data$employed),]
bls.laus.employment.data <- bls.laus.employment.data[!is.na(bls.laus.employment.data$labor.force),]

## Correct the data in 6 simple steps

## Step 1: Create temp data frame
data <- bls.laus.employment.data
## Step 2: Fix the issue
data[bls.laus.employment.data$employed > bls.laus.employment.data$labor.force,8] <- bls.laus.employment.data[bls.laus.employment.data$employed > bls.laus.employment.data$labor.force,9]
data[bls.laus.employment.data$employed > bls.laus.employment.data$labor.force,9] <- bls.laus.employment.data[bls.laus.employment.data$employed > bls.laus.employment.data$labor.force,8]
## Step 3: Check to make sure no observations are incorrect
data[data$employed > data$labor.force,]
"
This step should return the following:

[1] msa.fips         state.fips       county.fips     
[4] central.outlying year             period          
[7] period.name      labor.force      employed      
<0 rows> (or 0-length row.names)
"
## Step 4: Replace the data frame
bls.laus.employment.data <- data

## Step 5: Cleanup the environment
rm(data)

## Step 6: Save the Data
saveRDS(bls.laus.employment.data, file='bls.laus.employment.data.rds')
