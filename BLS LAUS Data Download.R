## The directory where the data will be stored with trailing slash
base.path <- '~/data/LAUS/'

## Create the base folder
if (!file.exists(base.path)){
  dir.create(base.path)
}

## Download all the LAUS files if they don't exist
url <- 'http://download.bls.gov/pub/time.series/la/'
files <- c('la.area', 'la.area_type', 'la.contacts', 'la.data.0.CurrentU00-04',  'la.data.0.CurrentU05-09', 'la.data.0.CurrentU10-14', 'la.data.0.CurrentU90-94', 'la.data.0.CurrentU95-99', 'la.footnote', 'la.measure', 'la.period', 'la.series', 'la.state_region_division', 'la.txt')
for(file in files){
  file.path <- paste0(base.path,"/",file)
  if(!file.exists(file.path)){
    file.url <- paste0(url,file)
    download.file(file.url, file.path)
  }
}