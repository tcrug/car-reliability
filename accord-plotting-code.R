library(ggplot2)
library(plyr)
library(reshape2)
library(scales)

setwd("./path/to/accord.csv")

accord <- read.csv("./accord.csv", header = F)
names(accord) <- c("year", "make", "model", "miles", "trans", "engine")

# purge oddball miles and 2014's
accord <- accord[accord$miles > 10 & accord$miles < 400000, ]
accord <- accord[accord$year != 2014, ]

dist_issues <- read.csv("./dist_issues.csv")
dist_miles <- read.csv("./dist_miles.csv")

# I wanted to see if there were increased issues with higher/lower
# miles per year. This uses ddply to look at Accords by each model year,
# calculate a per-model-year mileage mean, and give me
# - low cutoff (mean - 1.5sd)
# - high cutoff (mean + 1.5sd)
# - number of cars per model year
# - trans/engine issues per model year
devs <- ddply(accord, .(year), summarize, mean = mean(miles),
              low = mean(miles) - (1.5*sd(miles)),
              high = mean(miles) + (1.5*sd(miles)),
              count = length(miles))

# now we process the accord data using the deviations data above
# - subset accord data by this row's year of the devs data.frame
# - create a new column, initialized to NAs
# - assign it "low"/"high" value if it's below/above a cutoff
# - assign remaining NAs the value of "ave"
accord_proc <- lapply(1:nrow(devs), function(row) {
  
  temp <- accord[accord$year == devs[row, "year"], ]
  temp$class <- rep(NA, nrow(temp))
  temp[temp$miles <= devs[row, "low"], "class"] <- "low"
  temp[temp$miles >= devs[row, "high"], "class"] <- "hi"
  temp[is.na(temp$class), "class"] <- "ave"
  return(temp)
  
})

# join all the lists into a data.frame
accord_proc <- do.call(rbind, accord_proc)

# go through each year/class combo and calculate engine/trans issues
accord_proc <- ddply(accord_proc, .(year, class),
                     summarize, trans = sum(trans)/length(trans),
                     engine = sum(engine)/length(engine))

# melt it and give turn class into a factor
accord_proc_melt <- melt(accord_proc, id.vars = c("year", "class"))
accord_proc_melt$class <- factor(accord_proc_melt$class, levels = c("low", "hi", "ave"))

# plot low vs. high to see if there's any trend in issues
pdf("./accord_low-vs-high.pdf", width = 9, height = 6)
plot <- accord_proc_melt[accord_proc_melt$class != "ave" & accord_proc_melt$year < 2012, ]
p <- ggplot(plot, aes(x = class, y = value))
p <- p + geom_histogram(stat = "identity") + facet_grid(~year) + theme_bw()
p
dev.off()

# use plyr's round_any() function to break things into 20k groups
accord$bucket <- round_any(accord$miles, 20000, ceiling)

# find issue rates by rounded bucket
issues_bucket <- ddply(accord, .(year, bucket), summarize,
                       rate_trans = sum(trans)/length(trans),
                       rate_eng = sum(engine)/length(engine))

issues_bucket_melt <- melt(issues_bucket, id.vars = c("year", "bucket"))

# plot miles bucket vs. issue rates, facetted by year
pdf("./accord_by-year-and-miles.pdf", width = 9, height = 6)
p <- ggplot(issues_bucket_melt[issues_bucket_melt$year < 2012, ],
            aes(x = bucket, y = value, colour = variable))
p <- p + geom_point(size = 2.5) + facet_wrap(~year, nrow = 2)
p <- p + scale_x_continuous("rounded miles", labels = comma) + theme_bw()
p <- p + theme(axis.text.x = element_text(angle = 315, hjust = 0))
p
dev.off()

# the above made me wonder if the rate is affected by n
# lower n could vastly skew the average issues rates
# this is a super hacky and probably horribly wrong way to 
# get a sense of n vs. issues rates for each mileage bucket
# basically, I need the issues rate and n to be on similar scales
# so I'm just multiplying issue rates by 1000 :(
accord_ply <- ddply(accord, .(year, bucket), summarize,
                    issue_rate = 1000*(sum(engine, trans)/length(engine)),
                    total = -length(engine))

accord_ply_melt <- melt(accord_ply, id.vars = c("year", "bucket"))

pdf("./accord_issue-rate-by-year-n.pdf", width = 9, height = 6)
plot <- accord_ply_melt[accord_ply_melt$year < 2012, ]

p <- ggplot(plot, aes(x = bucket, y = value, fill = variable))
p <- p + geom_histogram(stat = "identity", position = "identity") + facet_wrap(~ year, nrow = 4)
p <- p + scale_x_continuous("Approx. mileage", labels = comma, breaks = seq(0, 400000, by = 100000))
p <- p + scale_y_continuous("", #"Rate of issues (engine + transmission)",
                            breaks = c(-250, -100, 0, 100, 250),
                            labels = c("250", "100", "0", "10%", "25%"))
p <- p + scale_fill_discrete("", breaks = c("issue_rate", "total"), labels = c("issues", "vehicles"))
p <- p + theme_bw() + theme(axis.text.x = element_text(angle = 315, hjust = 0))
p
dev.off()