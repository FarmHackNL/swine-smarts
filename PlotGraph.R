library(jsonlite)
library(data.table)
library(ggplot2)
library(plotly)
library(animation)

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

# Make a second dataset for plotting.
All2 <- Feed[Slaughter[, c("animal", "end_gew", "meatper", "fat"), with=FALSE], on="animal"]
All2 <- BodyWeight[, -"department", with=FALSE][All2, on="animal"]

# Make groups for high, med and low performing animals for meat percentage.
All2[!is.na(meatper), group := cut(meatper, quantile(meatper, c(0, .15, .85, 1)),
                                   labels=c("Bottom 15%", "medium", "Top 15%")), by=sex]

All2[!is.na(group), list(meatMean=mean(meatper),
                         feedMean=mean(tot_FI_kg),
                         count=.N), by=group]

# Plot total feed intake per day for high and low meatper animals.
ggplot(All2[!is.na(sex) & group!="medium"], aes(day, tot_FI_kg, color=group)) +
  geom_line(aes(group=animal), stat="smooth", method = "loess", formula = y ~ x, alpha = 1) +
  facet_wrap(~sex) +
  coord_cartesian(ylim=c(0, 5), xlim=c(0, 100))

ggplotly()

# Now refresh each day.
ani.options(ani.width=800, ani.height=500)

# saveHTML(
# for (d in All2[!is.na(day), unique(day)]){
# # for (d in 1:20){
#   if (d >= 20){
#   print(ggplot(All2[sex=="M" & group!="medium" & day <= d], aes(day, tot_FI_kg, color=group)) +
#     #geom_point() +
#     geom_line(aes(group=animal), stat="smooth", method = "loess", formula = y ~ x, alpha = 0.8, size=1) +
#     coord_cartesian(ylim=c(0, 5), xlim=c(0, 100)) +
#     labs(title="Daily feed intake per animal",
#          x="Days",
#          y="Feed intake [kg]",
#          color="Feed intake group"))
# }},
# htmlfile="Feed Intake Live.html",
#    navigator=FALSE)

# Ranking for alert.
All2[, rank := frank(tot_FI_kg, ties.method="random", na.last=FALSE), by=c("group", "sex", "day")]

# Rank change per day.
setkey(All2, group, sex, day, rank)
All2[, change:=shift(rank)]
# All2[, rankChange2 := rank-shift(rank, 2), by=c("group", "sex", "day")]

summary(All2[!is.na(group) & group!="medium", list(m=mean(rankChange, na.rm=TRUE),
            sd=sd(rankChange, na.rm=TRUE)), by=c("group", "sex", "day")])

# Set warning level.
All2[, warning := rankChange >= 15]
All2[!is.na(group) & group!="medium" & warning==TRUE & day >= 20 & sex=="M"]
All2[!is.na(group) & group!="medium" & sex=="M"]

# Order for the inner join.
setkey(All2, day, warning)

saveHTML(
  for (d in All2[!is.na(day), unique(day)]){
    # for (d in 1:20){
    if (d >= 50){
      print(ggplot(All2[sex=="M" & group!="medium" & day <= d], aes(day, tot_FI_kg, color=group)) +
              #geom_point() +
              geom_line(aes(group=animal), stat="smooth", method = "loess", formula = y ~ x, alpha = 0.8, size=1, span=1) +
              geom_line(data=All2[!is.na(group) & group!="medium" & day <= d & sex=="M" & animal %in% All2[J(d, TRUE), animal]], aes(group=animal, x=day, y=tot_FI_kg), stat="smooth", method = "loess", span=1, formula = y ~ x, alpha = 0.8, size=2, color="black") +
              geom_text(data=All2[!is.na(group) & group!="medium" & day == d & sex=="M" & animal %in% All2[J(d, TRUE), animal]], aes(group=animal, x=day, y=tot_FI_kg, label=animal), alpha = 0.8, size=10, hjust=-.2, color="black") +
              coord_cartesian(ylim=c(0, 5), xlim=c(0, 100)) +
              labs(title="Daily feed intake per animal",
                   x="Days",
                   y="Feed intake [kg]",
                   color="Payout group"))
    }},
  htmlfile="Feed Intake Live.html",
  navigator=FALSE)
