# SA-Energy-Demand-Analysis 2021-2026

**Project Overview:** An investigation into South Africa's electricity demand patterns, focusing on seasonal variability and grid stress during extreme weather events.



**Problem 1: Hourly Electricity Demand Patterns**

* Hourly demand was aggregated by weekday vs weekend and by season.
* Weekdays show sharper evening peaks (\~17:00–20:00) than weekends.
* Seasonal variation: peaks are higher in winter and slightly flatter in summer.
* Takeaway: Demand patterns vary by both day type and season, reflecting human activity and heating/cooling needs.



**Problem 2:Peak Hour Demand on Extreme-Temperature Days**

* Daily average temperature was calculated across Durban, Cape Town, and Johannesburg.
* Days were classified as Very Hot (top 5%), Very Cold (bottom 5%), or Normal.
* Mean demand during 17:00–20:00: Very Hot = 24,799 MW (−6.3%), Very Cold = 29,219 MW (+10.3%), Normal = 26,469 MW.
* Takeaway: Peak demand rises on very cold days and slightly drops on very hot days.



**Problem 3: Demand Variability During Weather-Stressed Periods**

* Daily average temperature was calculated across Durban, Cape Town, and Johannesburg.
* Days were classified as Heatwave (top 5%), Cold Snap (bottom 5%), or Normal.
* Demand variability was measured using standard deviation (SD) and coefficient of variation (CV).
* Cold Snap = SD of 3,172 MW and CV of 0.128, Heatwave = SD of 1,532 MW and CV of 0.067, Normal = SD of 2,273 MW and CV of 0.097.
* Takeaway: Electricity demand becomes most volatile during cold snaps, while heatwaves show comparatively more stable demand patterns.



**Tech Stack**

***Language***: R

***Libraries***: tidyverse, ggplot2, lubridate, dplyr

