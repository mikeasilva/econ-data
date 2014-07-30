## Read in BEA Data
measures <- c('total.personal.income', 'population', 'per.capita.personal.income', 'nonfarm.personal.income', 'farm.personal.income', 'earnings.by.place.of.work', 'contributions.for.government.social.insurance', 'net.earnings.by.place.of.residence', 'dividends.interest.and.rent', 'personal.current.transfer.receipts', 'wages.and.salaries', 'supplements.to.wages.and.salaries', 'proprietors.Income', 'total.employment', 'wage.and.salary.employment', 'proprietors.employment', 'average.earnings.per.job', 'average.wage.per.job', 'average.compensation.per.job')

## Build data frame with all measures
for (i in 1:length(measures)){
  measure <- measures[i]
  file.name <- paste0('bea ', gsub('[.]', ' ', measure),'.csv')
  csv <- read.csv(file.name)
  csv <- csv[,2:4]
  if(exists('bea.data')){
    bea.data <- merge(x=bea.data, y=csv, by=c('msa.fips','year'), all.x=TRUE)
  }else{
    bea.data <- csv
  }
}

## Clean up
rm(csv, file.name, i, measure, measures)

## Save the output
save.image('bea.data.RData')