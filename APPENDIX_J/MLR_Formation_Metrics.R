# MULTIPLE LINEAR REGRESSION of Eddy data, then Filament data, then combined data


# read combined dataset
combiData <- read.csv('YOUR DIRECTORY TO CombinedDataforR.csv FILE HERE')
# convert month from int to factor
combiData$Month <- as.factor (combiData$Month)
# subset eddy eata
eddyData <- combiData[c(1:101), c(1:21)]
# subset filament data
filData <- combiData[c(102:155),c(1:21)]

# create multiple linear regression model for eddy data
# where Y = gradient (continuous)
# where Y = level (Low/Med/High) (categorical)
#  Y = FWHM (continuous)
#eModel <- lm(eddyData$Gradient ~ eddyData$Month + eddyData$IslandDist_km + eddyData$IslandDiam_km + eddyData$r1angle + eddyData$r1vel, data = eddyData)
#summary(eModel)
# Months not presenting significance
# Use seasons instead
#

###################################
# EDDY ONLY, Y = gradient (continuous)

eModel <- lm(eddyData$Gradient ~ eddyData$IslandDist_km + eddyData$IslandDiam_km + eddyData$r1angle + eddyData$r1vel, data = eddyData)
summary(eModel)
anova(eModel)
#Residual standard error: 0.3156 on 96 degrees of freedom
#Multiple R-squared:  0.3392,	Adjusted R-squared:  0.3117 
#F-statistic: 12.32 on 4 and 96 DF,  p-value: 3.986e-08
# only current velocity is significant


# compute pearson's correlation between x variables
cor(eddyData$r1vel, eddyData$r1angle, method = 'pearson')
# 0.293 (29% correlation)

# visually assess assumptions
plot(eModel)
# no pattern in cloud of residuals, but most concentrated at lower end of plot
# red line fairly flat
# acceptable residuals


# JUST VEL, Y = gradient (continuous)
eModel3 <- lm(eddyData$Gradient ~ eddyData$r1vel, data = eddyData)
summary(eModel3)

plot(eddyData$Gradient ~ eddyData$r1vel, ylab = "Eddy Log[10] Gradient (μg /l /km)", xlab = "Current Velocity (m /s)",
     pch = 16, col = rgb(0.6, 0, 0, 1), cex = 1.2)
abline(eModel3)
# velocity highly significant
# Residual standard error: 0.2916 on 99 degrees of freedom
# Multiple R-squared:  0.1636,	Adjusted R-squared:  0.1551 
# F-statistic: 19.36 on 1 and 99 DF,  p-value: 2.729e-05

# JUST ANGLE, Y = gradient (continuous)
eModel4 <- lm(eddyData$Gradient ~ eddyData$r1angle, data = eddyData)
summary(eModel4)

plot(eddyData$Gradient ~ eddyData$r1angle, ylab = "Eddy Log[10] Gradient (μg /l /km)", xlab = "Current Angle (° from N)",
     pch = 16, col = rgb(0.6, 0, 0, 1), cex = 1.2)
abline(eModel4)


###################################
# EDDY ONLY, Y = FWHM (continuous)
eModelFWHM <- lm(eddyData$FWHM_km ~ eddyData$IslandDist_km + eddyData$IslandDiam_km + eddyData$r1angle + eddyData$r1vel, data = eddyData)
summary(eModelFWHM)

# DIAMETER ONLY
eModelFWHM2 <- lm(eddyData$FWHM_km ~ eddyData$IslandDiam_km, data = eddyData)
summary(eModelFWHM2)

plot(eddyData$FWHM_km ~ eddyData$IslandDiam_km, ylab = "Eddy Full Width Half Max (km)", xlab = "Island Diameter (km)",
     pch = 16, col = rgb(0.6, 0, 0, 1), cex = 1.2)
abline(eModelFWHM2)

# DISTANCE ONLY
eModelFWHM3 <- lm(eddyData$FWHM_km ~ eddyData$IslandDist_km, data = eddyData)
summary(eModelFWHM3)

plot(eddyData$FWHM_km ~ eddyData$IslandDist_km, ylab = "Eddy Full Width Half Max (km)", xlab = "Distance From Island (km)",
     pch = 16, col = rgb(0.6, 0, 0, 1), cex = 1.2)
abline(eModelFWHM3)


# VEL ONLY
eModelFWHM4 <- lm(eddyData$FWHM_km ~ eddyData$r1vel, data = eddyData)
summary(eModelFWHM4)

plot(eddyData$FWHM_km ~ eddyData$r1vel, ylab = "Eddy Full Width Half Max (km)", xlab = "Current Velocity (m/s)",
     pch = 16, col = rgb(0.6, 0, 0, 1), cex = 1.2)
abline(eModelFWHM4)
###################################
###################################
###################################
# FILAMENT ONLY, Y = gradient (cont)

fModel <- lm(filData$Gradient ~ filData$IslandDist_km + filData$IslandDiam_km + filData$r1angle + filData$r1vel, data = filData)
summary(fModel)
#Residual standard error: 0.2956 on 46 degrees of freedom
#Multiple R-squared:  0.4217,	Adjusted R-squared:  0.3337 
#F-statistic: 4.792 on 7 and 46 DF,  p-value: 0.0004139
# island dist and current vel are significant

# visually assess assumptions
plot(fModel)
# seems to be less normal dist & less homogenaety of variance

# model DIST only
fModel2 <- lm(filData$Gradient ~ filData$IslandDist_km, data = filData)
#rgb(0, 0, 0.6, 1)
summary(fModel2)
# not significant when modeled alone
plot(filData$Gradient ~ filData$IslandDist_km, ylab = "Filament Log[10] Gradient (μg /l /km)", xlab = "Island Distance (km)",
     pch = 17, col = rgb(0, 0, 0.6, 1), cex = 1.2)
abline(fModel2)

# model VEL only
fModel3 <- lm(filData$Gradient ~ filData$r1vel, data = filData)
summary(fModel3)
# significant
plot(filData$Gradient ~ filData$r1vel, ylab = "Filament Log[10] Gradient (μg /l /km)", xlab = "Current Velocity (m/s)",
     pch = 17, col = rgb(0, 0, 0.6, 1), cex = 1.2)
abline(fModel3)

###################################
# FILAMENT ONLY, Y = FWHM (cont)
fModelFWHM <- lm(filData$FWHM_km ~ filData$IslandDist_km + filData$IslandDiam_km + filData$r1angle + filData$r1vel, data = filData)
summary(fModelFWHM)
# r1angle and island diameter are significant


# island diameter only
fModelFWHM2 <- lm(filData$FWHM_km ~ filData$IslandDiam_km, data = filData)
summary(fModelFWHM2)
# significant
#Residual standard error: 1.353 on 52 degrees of freedom
#Multiple R-squared:  0.2338,	Adjusted R-squared:  0.2191 
#F-statistic: 15.87 on 1 and 52 DF,  p-value: 0.0002121
plot(filData$FWHM_km ~ filData$IslandDiam_km, ylab = "Filament Full Width Half Max (km)", xlab = "Island Diameter (km)",
     pch = 17, col = rgb(0, 0, 0.6, 1), cex = 1.2)
abline(fModelFWHM2)

# current angle only
fModelFWHM3 <- lm(filData$FWHM_km ~ filData$r1angle, data = filData)
summary(fModelFWHM3)
# significant
#Residual standard error: 1.413 on 52 degrees of freedom
#Multiple R-squared:  0.1645,	Adjusted R-squared:  0.1485 
#F-statistic: 10.24 on 1 and 52 DF,  p-value: 0.002341
plot(filData$FWHM_km ~ filData$r1angle, ylab = "Filament Full Width Half Max (km)", xlab = "Current Angle (° from N)",
     pch = 17, col = rgb(0, 0, 0.6, 1), cex = 1.2)
abline(fModelFWHM3)
# HOWEVER, the plot has an outlier

# island diameter only
fModelFWHM4 <- lm(filData$FWHM_km ~ filData$IslandDiam_km, data = filData)
summary(fModelFWHM4)


###################################
###################################
###################################
###################################
# COMBINED DATA

#cModel <- lm(combiData$Gradient ~ combiData$Season + combiData$IslandDist_km + combiData$IslandDiam_km + combiData$r1angle + combiData$r1vel, data = combiData)
#summary(cModel)
#Residual standard error: 0.2865 on 147 degrees of freedom
#Multiple R-squared:  0.2912,	Adjusted R-squared:  0.2575 
#F-statistic: 8.629 on 7 and 147 DF,  p-value: 7.555e-09

#encorporate interaction between angle and vel
cModel <- lm(combiData$Gradient ~ combiData$IslandDist_km + combiData$IslandDiam_km + combiData$r1angle + combiData$r1vel, data = combiData)
summary(cModel)
# interaction not statistically significant
#Residual standard error: 0.2853 on 148 degrees of freedom
#Multiple R-squared:  0.2921,	Adjusted R-squared:  0.2634 
#F-statistic: 10.18 on 6 and 148 DF,  p-value: 2.06e-09
# no indiv variables significant

# compute pearson's correlation between x variables
cor(combiData$r1vel, combiData$r1angle, method = 'pearson')
# 0.313 (31% correlation)

# visually assess assumptions
plot(cModel)
# seems to be less normal dist & less homogenaety of variance



###################################
# COMBINED DATA with y=FWHM

#cModel <- lm(combiData$Gradient ~ combiData$Season + combiData$IslandDist_km + combiData$IslandDiam_km + combiData$r1angle + combiData$r1vel, data = combiData)
#summary(cModel)
#encorporate interaction between angle and vel
cModel3 <- lm(combiData$FWHM_km ~ combiData$Season + combiData$IslandDist_km + combiData$IslandDiam_km + combiData$r1angle + combiData$r1vel, data = combiData)
summary(cModel3)
#Residual standard error: 1.887 on 148 degrees of freedom
#Multiple R-squared:  0.1814,	Adjusted R-squared:  0.1482 
#F-statistic: 5.465 on 6 and 148 DF,  p-value: 3.914e-05
# no indiv variables significant

# visually assess assumptions
plot(cModel3)
# seems to meet requirements

