# use install.package("plyr") if you don't it installed already
library(plyr)

# set working dir to data repository location
setwd("/path/to/car-reliability")

# read in the data we've been provided with four models over all years
# for which there's data; name the columns
data <- read.csv("./four-models.csv", header = F)
names(data) <- c("year", "make", "model", "miles", "trans", "engine")

# purge any oddball miles and 2014's where there are extremely few issues so far
data <- data[data$miles > 10, ]
data <- data[data$year != 2014, ]

# read in the distribution data set, which was pulled from some sort of database (json?)
# transposing it worked alrightfor a kludgy lapply() conversion to a list -> two data frames
# eventual output is two data sets with distributions based on the entire data set (all models)
# - distribution of issues by model year
# - distribution of mileage, using 10k cuts
dists <- as.data.frame(t(read.csv("./distribution.csv", header = F)), stringsAsFactors = F)

# don't need the counts by year (column 1) since that's included in the issues set
dists <- dists[, -1]

# rename the columns and remove the first row (reduncant col names)
names(dists) <- c("miles", "issues")
dists <- dists[-1, ]

dist_list <- lapply(dists, function(col) {
  
  temp <- col
  temp <- gsub("\\{", "", temp)
  temp <- gsub("\\}", "", temp)
  temp <- temp[temp != ""]
  
  temp <- strsplit(temp, ", ")
  temp <- do.call(rbind, temp)
  temp <- apply(temp, 2, as.numeric)
  temp <- as.data.frame(temp)
  
  return(temp)
  
})

dist_miles <- dist_list$miles
names(dist_miles) <- c("miles", "count")

dist_issues <- dist_list$issues
names(dist_issues) <- c("year", "total", "trans", "engine", "ptrain")

rm(dist_list)
rm(dists)

# create a miles_cut column in data subset to match the distribution set
# uses the round_any() function from the plyr package
data$miles_cut <- round_any(data$miles, accuracy = 10000, f = ceiling)
