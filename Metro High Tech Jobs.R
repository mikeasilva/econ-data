# The directory where the data will be stored with trailing slash
base.path <- '~/data/OES/'

# The following list of SOC codes are the 'High Tech' occupations
high.tech.soc.codes <- c('151011', '151021', '151031', '151032', '151051', '151061', '151081', '151111', '151121', '151131', '151132', '151133', '151141', '151142', '172011', '172031', '172041', '172061', '172071', '172072', '172151', '172161', '172171', '173021', '173023', '173024', '191021', '191022', '191041', '191042', '192011', '192012', '192021', '192031', '192042', '194021', '194031', '194041', '194051', '271014', '292011', '292033', '292034', '292037')

# Create the base folder
if (!file.exists(base.path)){
  dir.create(base.path)
}

# Find out the release
file <- read.table('http://download.bls.gov/pub/time.series/oe/oe.release')

# Create the path where the data will be downloaded to
path <- paste0(base.path, file$release_date, "-", file$description)

if (!file.exists(path)){
  dir.create(path)
}

# Download all the OES files if they don't exist
url <- 'http://download.bls.gov/pub/time.series/oe/'
files <- c('oe.area', 'oe.areatype', 'oe.contacts', 'oe.data.1.AllData', 'oe.datatype', 'oe.footnote', 'oe.industry', 'oe.occugroup', 'oe.occupation', 'oe.release', 'oe.seasonal', 'oe.sector', 'oe.series', 'oe.statemsa', 'oe.txt')
for(file in files){
  file.path <- paste0(path,"/",file)
  if(!file.exists(file.path)){
    file.url <- paste0(url,file)
    download.file(file.url, file.path)
  }
}

# Get the Series ID's that we are interested in
file.path <- paste0(path,'/oe.series')
oe.series <- read.table(file.path, header = TRUE, sep = '\t', colClasses = rep('character',12))
# Only pull in industry totals
oe.series <- oe.series[oe.series$industry_code == '000000',]
# Only pull in the employment measure
oe.series <- oe.series[oe.series$datatype_code == '01',]
# Only pull in the MSA data
oe.series <- oe.series[oe.series$areatype_code == 'M',]
# Pull out the high tech and total jobs
high.tech <- oe.series[oe.series$occupation_code %in% c('000000', high.tech.soc.codes),]

file.path <- paste0(path,'/oe.data.1.AllData')
# Import the data values
oe.data <- read.table(file.path, header = TRUE, sep = '\t', colClasses = c('character', 'integer', 'character', 'character', 'character'))
# Merge in the values
high.tech <- merge(high.tech, oe.data)
# Change the type of value from character to numeric
high.tech$value <- as.numeric(high.tech$value)

# Free up some memory
rm(oe.data)
rm(oe.series)

# Pull out the total jobs figures
total <- high.tech[!high.tech$occupation_code %in% high.tech.soc.codes,]
total <- total[c('area_code', 'year','value')]
names(total) <- c('area_code', 'year','total.jobs')

# Select the high tech jobs
high.tech <- high.tech[high.tech$occupation_code %in% high.tech.soc.codes,]

library(data.table)
# Load data frame into data table
total <- data.table(total)
# Sum up the high tech jobs
high.tech.jobs <- data.table(high.tech)[, list(high.tech.occupations=sum(value)), by=list(area_code,year)]
high.tech.jobs <- merge(high.tech.jobs, total, by = c('area_code', 'year'))
high.tech.jobs$rate <- high.tech.jobs$high.tech.occupations / high.tech.jobs$total.jobs

# Export the data
write.csv(high.tech.jobs, 'high tech jobs.csv')
