library(jsonlite)
library(data.table)
library(h2o)
library(ggplot2)
library(plotly)

# Import data.
Feed <- data.table(fromJSON("C:/Users/bvis2/Desktop/OADA/nutreco/nutreco-study3-totals.csv.json"))
Slaughter <- data.table(fromJSON("C:/Users/bvis2/Desktop/OADA/nutreco/nutreco-study3-slaughterhouse.csv.json"))
BodyWeight <- data.table(fromJSON("C:/Users/bvis2/Desktop/OADA/nutreco/nutreco-study3-bw.csv.json"))

# Look at what we have.
names(Feed)
names(Slaughter)
names(BodyWeight)

# Change variable classes.
Feed[, animal := as.factor(as.integer(animal))]
Feed[, tot_visitimemin := as.numeric(tot_visitimemin)]
Feed[, tot_visit := as.integer(tot_visit)]
Feed[, tot_meal := as.integer(tot_meal)]
Feed[, tot_FI_kg := as.numeric(tot_FI_kg)]
Feed[, RFI := as.numeric(RFI)]
Feed[, day := as.numeric(day)]
Slaughter[, animal := as.factor(as.integer(volg_num))]
Slaughter[, end_gew := as.numeric(end_gew)]
Slaughter[, meatper := as.numeric(meatper)]
Slaughter[, fat := as.numeric(fat)]
BodyWeight[, animal := as.factor(as.integer(animal))]
BodyWeight[, sex := as.factor(sex)]
BodyWeight[, BW0 := as.numeric(BW0)]
BodyWeight[, BW28 := as.numeric(BW28)]
BodyWeight[, BW55 := as.numeric(BW55)]
BodyWeight[, BW97 := as.numeric(BW97)]

# Make feed info wide format.
FeedWide <- dcast(Feed, animal ~ day,
      value.var=c("tot_visitimemin", "tot_visit", "tot_meal", "tot_FI_kg", "RFI"))
FeedWide[, 1:10]

# Join all.
All <- FeedWide[Slaughter[, c("animal", "end_gew", "meatper", "fat"), with=FALSE], on="animal"]
All <- BodyWeight[, -"department", with=FALSE][All, on="animal"]

All[, 1:10]

# Do some machine learning.
h2o.init(nthreads=2)

# Load data into H2O.
swine <- as.h2o(All)

# Split data.
swineSplit <- h2o.splitFrame(swine, ratios=c(.6, .2))
swineTrain <- swineSplit[[1]]
swineValid <- swineSplit[[2]]
swineTest <- swineSplit[[3]]

# Gradient boosting machine out of the box.
gbm <- h2o.gbm(
  training_frame = swineTrain,
  validation_frame = swineValid,
  x=setdiff(names(swine), c("animal", "meatper", "fat", "end_gew")),
  y="meatper",
  ntrees=10000,
  max_depth=)

summary(gbm)
h2o.performance(gbm, newdata=swineTest)
h2o.varimp_plot(gbm, num_of_features=20)

dl <- h2o.deeplearning(
  training_frame = swineTrain,
  validation_frame = swineValid,
  x=setdiff(names(swine), c("animal", "meatper", "fat", "end_gew")),
  y="meatper")

h2o.performance(dl, newdata=swineTest)

# Verify prediction on test data.
test <- as.data.table(swineTest[c("animal", "meatper")])
test <- data.table(test, as.data.table(h2o.predict(gbm, newdata=swineTest)))
test <- data.table(test, as.data.table(h2o.predict(dl, newdata=swineTest)))

# Make predict names unique and melt.
setnames(test, make.names(names(test), unique=TRUE))
testLong <- melt(test, measure=patterns("predict"))
testLong[, variable := ifelse(variable=="predict", "gbm", "dl")]

# Plot prediction versus true affection
ggplot(testLong, aes(value, meatper, color=variable, text=paste("id:", animal))) +
  geom_point() +
  geom_abline(slope=1, linetype="dashed") +
  coord_fixed()

ggplotly() %>%
  config(displayModeBar=FALSE)
htmlwidgets::saveWidget("index.html")

# Correlations.
testLong[, cor(value, meatper, use="pairwise"), by=variable]

# Make a second dataset for plotting.
All2 <- Feed[Slaughter[, c("animal", "end_gew", "meatper", "fat"), with=FALSE], on="animal"]
All2 <- BodyWeight[, -"department", with=FALSE][All2, on="animal"]

# Make groups for high, med and low performing animals for meat percentage.
All2[!is.na(meatper), group := cut(meatper, quantile(meatper, c(0, .15, .85, 1)),
     labels=c("low", "medium", "high")), by=sex]

All2[!is.na(group), list(meatMean=mean(meatper),
                         feedMean=mean(tot_FI_kg),
                         count=.N), by=group]

# Plot total feed intake per day for high and low meatper animals.
ggplot(All2[!is.na(sex) & group!="medium"], aes(day, tot_FI_kg, color=group)) +
  geom_line(aes(group=animal), stat="smooth", method = "loess", formula = y ~ x, alpha = 1) +
  facet_wrap(~sex)

ggplotly()
