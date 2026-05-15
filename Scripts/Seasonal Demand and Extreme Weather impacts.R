library(tidyverse)
library(lubridate)
library(ggplot2)
library(dplyr)

#########################################Problem 1###############################
df <- read.csv("Eskom demand Data.csv")

head(df[[1]])

df <- df %>%
  mutate(
    datetime = parse_date_time(Date.Time.Hour.Beginning,
                               orders = c("dmy HMS p", "ymd HMS p",
                                          "dmy HM p",  "ymd HM p"))
  )                                                                 ##Why? so we can group the dates into weekdays and weekends, compare trends time patterns.

##Extracting the usable features
df <- df %>%
  mutate(
    hour = hour(datetime),
    date = as.Date(datetime),
    weekday = wday(datetime, label = TRUE),
    is_weekend = weekday %in% c("Sat", "Sun") # True is weekend
  )

# 2. Aggregate to get average demand per hour for weekdays and weekends
hourly_curve <- df %>%
  group_by(hour, is_weekend) %>%
  summarise(avg_demand = mean(Residual.Demand, na.rm = TRUE)) %>%
  mutate(day_type = ifelse(is_weekend, "Weekend", "Weekday"))


# 3. Plot the average daily curve
ggplot(hourly_curve, aes(x = hour, y = avg_demand, color = day_type)) +
  geom_line(size = 1.2) +
  labs(
    title = "Hourly Electricity Demand: Weekday vs Weekend",
    x = "Hour of Day",
    y = "Average Demand (MW)",
    color = "Day Type"
  ) +
  theme_minimal()

# 4. Season column
df<- df %>%
  mutate(
    month = month(date),
    season = case_when(
      month %in% c(12, 1, 2) ~ "Summer",
      month %in% c(3, 4, 5)  ~ "Autumn",
      month %in% c(6, 7, 8)  ~ "Winter",
      month %in% c(9, 10, 11) ~ "Spring"
    )
  )

# 5. Aggregate hourly demand by season
seasonal_curve <- df %>%
  group_by(hour, season) %>%
  summarise(avg_demand = mean(Residual.Demand, na.rm = TRUE))

ggplot(seasonal_curve, aes(x = hour, y = avg_demand, color = season)) +
  geom_line(size = 1.2) +
  labs(
    title = "Hourly Electricity Demand by Season",
    x = "Hour of Day",
    y = "Average Demand (MW)"
  ) +
  theme_minimal()

######################################Problem 2###########################################
library(dplyr)
#1. transfer data
temp1 <- read.csv("Durban Weather 2021-2025.csv")
temp2 <- read.csv("Cape Town Weather 2021-2025.csv")
temp3 <- read.csv("Johannesburg Weather 2021-2025.csv")

#2. Convert data to numeric
temp1 <- temp1 %>%
  mutate(
    datetime = ymd_hm(time),
    temperature_2m = as.numeric(temperature_2m),
    rain._mm = as.numeric(rain._mm)
  )

temp2 <- temp2 %>%
  mutate(
    datetime = ymd_hm(time),
    temperature_2m = as.numeric(temperature_2m),
    rain_mm = as.numeric(rain_mm)
  )

temp3 <- temp3 %>%
  mutate(
    datetime = ymd_hm(time),
    temperature_2m = as.numeric(temperature_2m),
    rain_mm = as.numeric(rain_mm)
  )

#3. variable time has to be separated into a date column
temp1 <- temp1 %>%
  mutate(date = as.Date(datetime))

temp2 <- temp2 %>%
  mutate(date = as.Date(datetime))

temp3 <- temp3 %>%
  mutate(date = as.Date(datetime))

#4. combining both cities
temp_all <- bind_rows(temp1, temp2, temp3)

#5. daily average temp
daily_temp <- temp_all %>%
  group_by(date) %>%
  summarise(
    avg_temp = mean(temperature_2m, na.rm = TRUE)
  )
head(daily_temp)
summary(daily_temp$avg_temp)

# Top 5% = hot days, Bottom 5% = cold days
hot_threshold <- quantile(daily_temp$avg_temp, 0.95, na.rm = TRUE) #95th percentile
cold_threshold <- quantile(daily_temp$avg_temp, 0.05, na.rm = TRUE) #5th percentile

#classifying extreme temp days
daily_temp <- daily_temp %>%
  mutate(
    extreme = case_when(
      avg_temp >= hot_threshold ~ "Very Hot",
      avg_temp <= cold_threshold ~ "Very Cold",
      TRUE ~ "Normal"
    )
  )

df_peak <- df %>%
  left_join(daily_temp, by = "date")

#Step 3: Filter peak hours (17:00–20:00)
df_peak_hours <- df_peak %>%
  filter(hour >= 17 & hour <= 20, !is.na(extreme))

#manually calculating normal temperature mean
normal_mean <- df_peak_hours %>%
  filter(extreme == "Normal") %>%
  summarise(mean_demand = mean(Residual.Demand, na.rm = TRUE)) %>%
  pull(mean_demand)

#Calculate mean demand by temperature category
peak_summary <- df_peak_hours %>%
  group_by(extreme) %>%
  summarise(
    mean_demand_MW = mean(Residual.Demand, na.rm = TRUE)
  ) %>%
  mutate(
    perc_diff_vs_normal = 100 * (mean_demand_MW - normal_mean) / normal_mean
  )

peak_summary

#Problem 2 Plot
ggplot(peak_summary, aes(x = extreme, y = mean_demand_MW, fill = extreme)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = paste0(round(perc_diff_vs_normal, 1), "%")), 
            vjust = -0.5, size = 4) +
  labs(
    title = "Average Peak Hour Electricity Demand by Temperature Category",
    x = "Temperature Category",
    y = "Mean Demand (MW)"
  ) +
  scale_fill_manual(values = c("Very Hot" = "red", "Very Cold" = "blue", "Normal" = "grey")) +
  theme_minimal()

######################################Problem 3###########################################


# Rename categories for clearer interpretation
daily_temp <- daily_temp %>%
  mutate(
    period_type = case_when(
      extreme == "Very Hot"  ~ "heatwave",
      extreme == "Very Cold" ~ "cold_snap",
      TRUE                   ~ "normal"
    )
  )

# Merge weather classification into demand data
df2 <- df %>%
  left_join(
    daily_temp %>% select(date, period_type),
    by = "date"
  )

# Calculate daily variability measures
daily_variability <- df2 %>%
  group_by(date, period_type) %>%
  summarise(
    daily_mean = mean(Residual.Demand, na.rm = TRUE),
    daily_sd   = sd(Residual.Demand, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    daily_cv = daily_sd / daily_mean
  )

# Summarise variability across weather conditions
final_variability <- daily_variability %>%
  group_by(period_type) %>%
  summarise(
    avg_sd = mean(daily_sd, na.rm = TRUE),
    avg_cv = mean(daily_cv, na.rm = TRUE),
    .groups = "drop"
  )

print(final_variability)

# Plot coefficient of variation
ggplot(daily_variability,
       aes(x = period_type,
           y = daily_cv,
           fill = period_type)) +
  geom_boxplot() +
  labs(
    title = "Demand Variability Across Weather Conditions",
    x = "Weather Condition",
    y = "Coefficient of Variation"
  ) +
  scale_fill_manual(values = c(
    "heatwave" = "red",
    "cold_snap" = "blue",
    "normal" = "grey"
  )) +
  theme_minimal()