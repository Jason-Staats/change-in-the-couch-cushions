# Load libraries
library(dplyr)
library(tidyr)

# Read data
df <- read.csv("C:/Portfolio Projects/Exercise Dataset/activity_healthcare_agg.csv")

# Model 1
model1 <- lm(avg_spending ~ avg_muscle, data = df)
cat("Model 1: Muscle-strengthening activities vs Healthcare Spending\n")
summary(model1)


# Model 2
model2 <- lm(avg_spending ~ avg_no_leisure, data = df)
cat("Model 2: No leisure-time activity vs Healthcare Spending\n")
summary(model2)

# Pearson correlation 
cor.test(df$avg_muscle, df$avg_no_leisure)
