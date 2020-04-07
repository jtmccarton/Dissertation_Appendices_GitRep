## match ups linear regression analysis
## disso

matchups <- read.csv("YOUR DIRECTORY TO ALL_Sat_InSitu_Matchups.txt FILE HERE")
matchups$log.ArgoChl<-log10(matchups$ArgoChl)

hr2subset <- subset(matchups, timediff>-2 & timediff<2)
hr12subset <- subset(matchups, timediff>-12 & timediff<12)
hr24subset <- subset(matchups, timediff>-24 & timediff<24)

library(ggplot2)
library(dplyr)
library(gapminder)
# select lmodel2 package

###########################################################
# R^2 = % of variance in dependent variable that independent variable explains
# R^2 = variance explained by the model / total variance
# i.e. ARGO chl measures explain 63.7% of variation in OC4me match ups +/- 24 hrs

## EXACT NN MATCH UPS 24 HRS:
# SIGNIFICANT & R^2 = 
par(mfrow=c(1,1))
plot(hr24subset$NNChl ~ hr24subset$log.ArgoChl)

data(matchups)
ArgoAndNN24.mod2 <- lmodel2(hr24subset$NNChl ~ hr24subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndNN24.mod2.res = resid(ArgoAndNN24.mod2)
plot(hr24subset$log.ArgoChl, ArgoAndNN24.mod2.res, ylab="Residuals", xlab="ArgoChl")

plot.new()
ArgoAndNN24.mod2
modelplotNN = plot(ArgoAndNN24.mod2, 'MA', main = '', ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ", pch = 16, 
                 ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 1.3)
# add different circle sizes for each time limit
par(new=T)
plot(hr24subset$log.ArgoChl, hr24subset$NNChl, pch = 16, col = "black", ylab = '', xlab = '', axes=F,
     ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 1.3)
par(new=T)
plot(hr12subset$log.ArgoChl, hr12subset$NNChl, pch = 16, col = "azure4", ylab = '', xlab = '', axes=F,
     ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 2)
par(new=T)
plot(hr2subset$log.ArgoChl, hr2subset$NNChl, pch = 16, col = "azure3", ylab = '', xlab = '',
     axes=F, ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 4)
par(new=F)
lines(ArgoAndNN24.mod2, ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ", pch = 16, 
      ylim = c(-2.0, -0.48), xlim = c(-1.5, 1))
#par(new=F)


# n = 13 (number of objects)
    # r-square = 0.558857 (coefficient of determination of the OLS regression)
    # MA Intercept = -1.281599
    # MA Slope = -0.2002119 (COEFFICIENT - algorithm value decreases by .2 every time In Situ value changes by 1)
    # MA Angle (deg) = -11.32161
    # MA P-perm (1-tailed) = 0.008 (whether or not relationship is statistically significant)


## EXACT OC4 MATCH UPS 24 HRS:
# SIGNIFICANT & R^2 = 0.637
par(mfrow=c(1,1))
plot(hr24subset$OC4Chl ~ hr24subset$log.ArgoChl)

data(matchups)
ArgoAndOC424.mod2 <- lmodel2(hr24subset$OC4Chl ~ hr24subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndOC424.mod2.res = resid(ArgoAndOC424.mod2)
plot(hr24subset$log.ArgoChl, ArgoAndOC424.mod2.res, ylab="Residuals", xlab="ArgoChl")


plot.new()
ArgoAndOC424.mod2
modelplotOC = plot(ArgoAndOC424.mod2, "MA", main = '', ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ", pch = 16, 
                   ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 1.3)
# add different circle sizes for each time limit
par(new=T)
plot(hr24subset$log.ArgoChl, hr24subset$OC4Chl, pch = 16, col = "black", ylab = '', xlab = '', axes=F,
     ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 1.3)
par(new=T)
plot(hr12subset$log.ArgoChl, hr12subset$OC4Chl, pch = 16, col = "azure4", ylab = '', xlab = '', axes=F,
     ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 2)
par(new=T)
plot(hr2subset$log.ArgoChl, hr2subset$OC4Chl, pch = 15, col = "azure3", ylab = '', xlab = '',
     axes=F, ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 4)
par(new=F)


# n = 12
# r-square = 0.6365427 
# MA Intercept = -1.076917
# MA Slope = -0.1498989 
# MA Angle = -8.525103 
# MA P-perm (1-tailed) = 0.003

###########################################################



## EXACT NN MATCH UPS 12 HRS:
# NOT SIGNIFICANT
par(mfrow=c(1,1))
plot(hr12subset$NNChl ~ hr12subset$log.ArgoChl)

data(matchups)
ArgoAndNN12.mod2 <- lmodel2(hr12subset$NNChl ~ hr12subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndNN12.mod2
plot(ArgoAndNN12.mod2, "MA", ylab="log NN Chl (μg/l)", xlab="log Argo Chl (μg/l)")
    # n = 7
    # r-square = 0.5219773 
    # MA Intercept = -1.251082
    # MA Slope = -0.1990107 
    # MA Angle = -11.25542
    # MA P-perm (1-tailed) = 0.069




## EXACT OC4 MATCH UPS 12 HRS:
# NOT SIGNIFICANT
par(mfrow=c(1,1))
plot(hr12subset$OC4Chl ~ hr12subset$log.ArgoChl)

data(matchups)
ArgoAndOC412.mod2 <- lmodel2(hr12subset$OC4Chl ~ hr12subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndOC412.mod2
plot(ArgoAndOC412.mod2, "MA", ylab="Argo Chl (μg/l) ", xlab="OC4me Chl (μg/l)")
    # n = 6
    # r-square = 0.5595189
    # MA Intercept = -1.135987
    # MA Slope = -0.1252629
    # MA Angle = -7.139847 
    # MA P-perm (1-tailed) = 0.072



###########################################################

# EXACT NN MATCH UPS 2 HRS
par(mfrow=c(1,1))
plot(hr2subset$NNChl ~ hr2subset$log.ArgoChl, pch = 16, col = "azure3", ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ",
    ylim = c(-1.2, -0.4), xlim = c(-1.2, -0.4), cex = 4)
#(-0.438, -0.488) (-1.147, -1.118)
text(-1.12,-1.1, "(-0.438, -0.488)", cex=1, pos=4, col="black") 
text(-0.65,-0.5, "(-1.147, -1.118)", cex=1, pos=4, col="black") 


# 3x3 BIN OC4 MATCH UPS 2 HRS
par(mfrow=c(1,1))
plot(hr2subset$OC4Chl ~ hr2subset$log.ArgoChl, pch = 16, col = "azure3", ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ",
     ylim = c(-1.2, -0.4), xlim = c(-1.2, -0.4), cex = 4)
     #ylim = c(-1.02, -0.7), xlim = c(-1.2, -0.4), cex = 4)
#(-0.438, -0.74) (-1.147, -0.992)
text(-1.12,-0.983, "(-0.438, -0.74)", cex=1, pos=4, col="black") 
text(-0.65,-0.747, "(-1.147, -0.992)", cex=1, pos=4, col="black") 
#text(-1.1,-0.983, "(-0.438, -0.74)", cex=1, pos=4, col="black") 
#text(-0.6,-0.747, "(-1.147, -0.992)", cex=1, pos=4, col="black") 



############## COMBINED PLOT
par(mfrow=c(1,1))
plot(hr2subset$NNChl ~ hr2subset$log.ArgoChl, pch = 16, col = "azure3", ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ",
     ylim = c(-1.2, -0.4), xlim = c(-1.2, -0.4), cex = 4)
#(-0.438, -0.488) (-1.147, -1.118)
text(-1.12,-1.1, "(-0.438, -0.488)", cex=1, pos=4, col="black") 
text(-0.65,-0.5, "(-1.147, -1.118)", cex=1, pos=4, col="black") 
par(new=T)
plot(hr2subset$OC4Chl ~ hr2subset$log.ArgoChl, pch = 15, col = "darkgrey", ylab="", xlab="", axes=F,
     ylim = c(-1.2, -0.4), xlim = c(-1.2, -0.4), cex = 4)
text(-1.12,-0.983, "(-0.438, -0.74)", cex=1, pos=4, col="black") 
text(-0.65,-0.747, "(-1.147, -0.992)", cex=1, pos=4, col="black") 




###########################################################
# algorithm chl averaged for 3x3 bin around match-up pixel
# some are significant, but all have <0.05 R^2 value...



## 3x3 BIN NN MATCH UPS 24 HRS:
par(mfrow=c(1,1))
plot(hr24subset$NNChlAvg ~ hr24subset$log.ArgoChl)

data(matchups)
ArgoAndNN24Avg.mod2 <- lmodel2(hr24subset$NNChlAvg ~ hr24subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndNN24Avg.mod2.res = resid(ArgoAndNN24Avg.mod2)
plot(hr24subset$log.ArgoChl, ArgoAndNN24Avg.mod2.res, ylab="Residuals", xlab="ArgoChl")

plot.new()
ArgoAndNN24Avg.mod2
plot(ArgoAndNN24Avg.mod2, "MA", main = '', ylab="NN Chl 3x3 Pixel Average (μg/l)", xlab="Argo Chl (μg/l) ", pch = 16, 
     ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 1.3)
# add different circle sizes for each time limit
par(new=T)
plot(hr24subset$log.ArgoChl, hr24subset$NNChlAvg, pch = 16, col = "black", ylab = '', xlab = '', axes=F,
     ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 1.3)
par(new=T)
plot(hr12subset$log.ArgoChl, hr12subset$NNChlAvg, pch = 16, col = "azure4", ylab = '', xlab = '', axes=F,
     ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 2)
par(new=T)
plot(hr2subset$log.ArgoChl, hr2subset$NNChlAvg, pch = 16, col = "azure3", ylab = '', xlab = '',
     axes=F, ylim = c(-2.0, -0.48), xlim = c(-1.5, 1), cex = 4)
par(new=F)
#lines(ArgoAndNN24Avg.mod2, ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ", pch = 16, 
     # ylim = c(-2.0, -0.48), xlim = c(-1.5, 1))
#par(new=F)
    # n = 17
    # r-square = 0.3863968
    # slope (coefficient) = -0.1727788
    # MA P-perm (1-tailed) = 0.01



## 3x3 BIN OC4 MATCH UPS 24 HRS:
par(mfrow=c(1,1))
plot(hr24subset$OC4ChlAvg ~ hr24subset$log.ArgoChl)

data(matchups)
ArgoAndOC424Avg.mod2 <- lmodel2(hr24subset$OC4ChlAvg ~ hr24subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndOC424Avg.mod2

plot.new()
plot(ArgoAndOC424Avg.mod2, "MA", main = '', ylab="OC4Me Chl 3x3 Pixel Average (μg/l)", xlab="Argo Chl (μg/l) ", pch = 16, 
     ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 1.3)
# add different circle sizes for each time limit
par(new=T)
plot(hr24subset$log.ArgoChl, hr24subset$OC4ChlAvg, pch = 16, col = "black", ylab = '', xlab = '', axes=F,
     ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 1.3)
par(new=T)
plot(hr12subset$log.ArgoChl, hr12subset$OC4ChlAvg, pch = 16, col = "azure4", ylab = '', xlab = '', axes=F,
     ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 2)
par(new=T)
plot(hr2subset$log.ArgoChl, hr2subset$OC4ChlAvg, pch = 15, col = "azure3", ylab = '', xlab = '',
     axes=F, ylim = c(-1.7, -0.48), xlim = c(-1.5, 1), cex = 4)
par(new=F)
# n = 16
# r-square = 0.2391528
# slope (coefficient) = -0.1047601
# MA P-perm (1-tailed) = 0.031


###########################################################



## 3x3 BIN NN MATCH UPS 12 HRS:
par(mfrow=c(1,1))
plot(hr12subset$NNChlAvg ~ hr12subset$log.ArgoChl)

data(matchups)
ArgoAndNN12Avg.mod2 <- lmodel2(hr12subset$NNChlAvg ~ hr12subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndNN12Avg.mod2
plot(ArgoAndNN12Avg.mod2, "MA")
    # n = 9
    # r-square = 0.3244771
    # slope (coefficient) = -0.1665822 
    # MA P-perm (1-tailed) = 0.066



## 3x3 BIN OC4 MATCH UPS 12 HRS:
par(mfrow=c(1,1))
plot(hr12subset$OC4ChlAvg ~ hr12subset$log.ArgoChl)

data(matchups)
ArgoAndOC412Avg.mod2 <- lmodel2(hr12subset$OC4ChlAvg ~ hr12subset$log.ArgoChl, data = matchups, nperm=999)
ArgoAndOC412Avg.mod2
plot(ArgoAndOC412Avg.mod2, "MA")
    # n = 8
    # r-square = 0.1025558 
    # slope (coefficient) = -0.06359992 
    # MA P-perm (1-tailed) = 0.23




###########################################################


# 3x3 BIN NN MATCH UPS 2 HRS
par(mfrow=c(1,1))
plot(hr2subset$NNChlAvg ~ hr2subset$log.ArgoChl)
#(-0.438, -0.488) (-1.147, -1.134)
text(-1.15,-1.1, "(-0.438, -0.488)", cex=1, pos=4, col="black") 
text(-0.61,-0.5, "(-1.147, -1.134)", cex=1, pos=4, col="black") 


# 3x3 BIN OC4 MATCH UPS 2 HRS
par(mfrow=c(1,1))
plot(hr2subset$OC4ChlAvg ~ hr2subset$log.ArgoChl)
#(-0.438, -0.74) (-1.147, -0.992)
text(-1.15,-0.983, "(-0.438, -0.74)", cex=1, pos=4, col="black") 
text(-0.61,-0.747, "(-1.147, -0.992)", cex=1, pos=4, col="black") 


############## COMBINED PLOT
par(mfrow=c(1,1))
plot(hr2subset$NNChlAvg ~ hr2subset$log.ArgoChl, pch = 16, col = "azure3", ylab="NN Chl (μg/l)", xlab="Argo Chl (μg/l) ",
     ylim = c(-1.2, -0.4), xlim = c(-1.2, -0.4), cex = 4)
#(-0.438, -0.488) (-1.147, -1.118)
text(-1.12,-1.12, "(-0.438, -0.488)", cex=1, pos=4, col="black") 
text(-0.65,-0.48, "(-1.147, -1.118)", cex=1, pos=4, col="black") 
par(new=T)
plot(hr2subset$OC4ChlAvg ~ hr2subset$log.ArgoChl, pch = 15, col = "darkgrey", ylab="", xlab="", axes=F,
     ylim = c(-1.2, -0.4), xlim = c(-1.2, -0.4), cex = 4)
text(-1.12,-0.975, "(-0.438, -0.74)", cex=1, pos=4, col="black") 
text(-0.65,-0.73, "(-1.147, -0.992)", cex=1, pos=4, col="black") 



