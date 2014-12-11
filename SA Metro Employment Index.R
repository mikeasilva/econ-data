library(dplyr)

force.download = FALSE
# Download the files

if(!file.exists('~/data')){
  dir.create(file.path('~/data'))              
}
if(!file.exists('~/data/LAUS')){
  dir.create(file.path('~/data/LAUS'))              
}

if(!file.exists('~/data/LAUS/la.series') || force.download){
  download.file('http://download.bls.gov/pub/time.series/la/la.series', '~/data/LAUS/la.series')              
}

if(!file.exists('~/data/LAUS/la.data.0.CurrentU00-04') || force.download){
  download.file('http://download.bls.gov/pub/time.series/la/la.data.0.CurrentU00-04', '~/data/LAUS/la.data.0.CurrentU00-04')              
}

if(!file.exists('~/data/LAUS/la.data.0.CurrentU05-09') || force.download){
  download.file('http://download.bls.gov/pub/time.series/la/la.data.0.CurrentU05-09', '~/data/LAUS/la.data.0.CurrentU05-09')              
}

if(!file.exists('~/data/LAUS/la.data.0.CurrentU10-14') || force.download){
  download.file('http://download.bls.gov/pub/time.series/la/la.data.0.CurrentU10-14', '~/data/LAUS/la.data.0.CurrentU10-14')              
}

# Pull the series that match these criteria:
# MSA (area_type_code = B) 
# Employment (measure_code = 5)
# Not Seasonally Adjusted (seasonal = U)
# Monthly Data (period != M13)

la.series <- read.delim('~/data/LAUS/la.series') %>%
  filter(area_type_code == "B", measure_code == 5, seasonal == "U")

la.series$msa.name <- gsub("Employment: ", "", as.character(la.series$series_title))
la.series$msa.name <- gsub("[:punct:(]U[:punct:)]", "", la.series$msa.name)
la.series$msa.name <- gsub(" Metropolitan Statistical Area ", "", la.series$msa.name)
la.series$msa.name <- gsub(" Metropolitan NECTA ", "", la.series$msa.name)

# Exclude Puerto Rico
la.series <- subset(la.series, !grepl(", PR", la.series$msa.name))

la.series <- select(la.series, msa.name, series_id) %>%
  arrange(msa.name)


data <- read.delim('~/data/LAUS/la.data.0.CurrentU00-04') %>%
  filter(series_id %in% la.series$series_id, period != "M13")
data$value <- as.numeric(as.character(data$value))

temp <- read.delim('~/data/LAUS/la.data.0.CurrentU05-09') %>%
  filter(series_id %in% la.series$series_id, period != "M13")
temp$value <- as.numeric(as.character(temp$value))

# Append rows
data <- rbind(data, temp)

temp <- read.delim('~/data/LAUS/la.data.0.CurrentU10-14') %>%
  filter(series_id %in% la.series$series_id, period != "M13")
temp$value <- as.numeric(as.character(temp$value))

# Append rows
data <- rbind(data, temp)

data <- merge(data, la.series)

# Remove Temp and la.series Data Frames
rm(temp)

str.date <- paste0(substr(data$period, 2,3), "-01-", data$year)
data$date <- as.Date(str.date,format="%m-%d-%Y")
#data$p.date <- as.POSIXlt(data$date)

rm(str.date)

# Seasonally Adjust the data
library(reshape2)
molten <- select(data, series_id, date, value) %>%
  melt(id=c('series_id','date'), na.rm=TRUE)
sa.data.wide <- dcast(molten, date ~ series_id, value.var="value") %>%
  na.omit()
rm(molten)

sa.data = as.data.frame(matrix(ncol=3, nrow=0))
names(sa.data) <- c('series_id','date','value')

for(i in 2:ncol(sa.data.wide)){
  series_id <-  names(sa.data.wide)[i]
  sa <- stl(ts(sa.data.wide[,i], start=c(2000,1), frequency = 12), "per")
  sa.data.wide[,i] <- sa$time.series[,"trend"]
  temp.df <- data.frame(c(as.character(series_id)), sa.data.wide[,1], as.numeric(sa$time.series[,"trend"]))
  names(temp.df) <- names(sa.data)
  sa.data <- rbind(sa.data, temp.df)
}
rm(temp.df, sa.data.wide, i, series_id, sa)


sa.data <- merge(sa.data, la.series)
rm(la.series)

# 2000 Employment Levels
y2k <- filter(sa.data, date == "2000-01-01") %>%
  select(series_id, value)
names(y2k) <- c('series_id', 'y2k.value')
sa.data <- merge(sa.data, y2k)
rm(y2k)
sa.data$y2k.emp.indx <- (sa.data$value / sa.data$y2k)*100


# Pre Great Recession Employment Levels
pre.gr <- filter(sa.data, date == "2007-11-01") %>%
  select(series_id, value)
names(pre.gr) <- c('series_id', 'pre.gr.value')

sa.data <- merge(sa.data, pre.gr)
rm(pre.gr)
sa.data$emp.indx <- (sa.data$value / sa.data$pre.gr)*100

# 2000 Employment Levels
#y2k <- select(data, series_id, value, period, year) %>%
#  filter(period == "M01", year == 2000) %>%
#  select(series_id, value) 
#names(y2k) <- c('series_id', 'y2k.value')
#data <- merge(data, y2k)
#rm(y2k)
#
#data$y2k.emp.indx <- (data$value / data$y2k)*100

# Pre Great Recession Employment Levels
#pre.gr <- select(data, series_id, value, period, year) %>%
#  filter(period == "M11", year == 2007) %>%
#  select(series_id, value) 
#names(pre.gr) <- c('series_id', 'pre.gr.value')
#
#data <- merge(data, pre.gr)
#rm(pre.gr)
#data$emp.indx <- (data$value / data$pre.gr)*100

#data$keep <- 1
#data[data$year < 2008,]$keep <- 0
#data[data$year == 2007 && data$period == "M12"] <- 1
#data <- data[data$keep == 1,]

library(ggplot2)
library(scales)
#ggplot(data, aes(x=date, y=y2k.emp.indx, group = series_id)) + stat_smooth( method="loess", se=F, color=alpha("#222222", .1)) + scale_x_date() + theme(axis.title.x = element_blank()) + ylab("Employment Index (Jan 2000 = 100)")
#ggplot(data, aes(x=date, y=emp.indx, group = series_id)) + stat_smooth( method="loess", se=F, color=alpha("#222222", .1)) + scale_x_date() + theme(axis.title.x = element_blank()) + ylab("Employment Index (Nov 2007 = 100)")

ggplot(sa.data, aes(x=date, y=y2k.emp.indx, group = series_id)) + geom_line(color=alpha("#222222", .1)) + scale_x_date() + theme(axis.title.x = element_blank()) + ylab("Employment Index (Jan 2000 = 100)")
ggplot(sa.data, aes(x=date, y=emp.indx, group = series_id)) + geom_line(color=alpha("#222222", .1)) + scale_x_date() + theme(axis.title.x = element_blank()) + ylab("Employment Index (Nov 2007 = 100)")

msa.names <- df[!duplicated(df$series_id),]$msa.name