# Policy transfer script
- Ruirui

I transfer the data from the form of stats to the policies.

1, We got the row data, and the information of population/area from the paper.\

2, **Row data**\
   The unit of the type activity is km/year.\
   The unit of the type emission factor is g/km.\
   
3, **refine data**\
   The type of activity refine = row data / population, and the unit is km/person.\
   The type of emission factor refine = row data, and the unit is g/km.\
   
4, Using R to calculate the avg and sd of the refine_stat.\

5, Using R to transfer stats to policies.

***policies***
  
![image](https://github.com/Rainieeeeeee/Rainieeeeeee/assets/97750142/8b0fcac8-ea56-4580-859e-9263654472ed)




***R code**
```{R}
greentechdb_stats = read.csv("~/desktop/green tech project/stats.csv")

if (!is.numeric(greentechdb_stats$refined_stat)) {
  greentechdb_stats$refined_stat <- as.numeric(greentechdb_stats$refined_stat)
}

rideshare_sum = 0
rideshare_count = 0
rideshare_values = c()
Alternative_Fuels_and_Vehicles_sum = 0
Alternative_Fuels_and_Vehicles_count = 0
Alternative_Fuels_and_Vehicles_values = c()
Congestion_Reduction_and_Traffic_Flow_Improvements_sum = 0
Congestion_Reduction_and_Traffic_Flow_Improvements_count = 0
Congestion_Reduction_and_Traffic_Flow_Improvements_values = c()
for (i in 1:nrow(greentechdb_stats)) {
  if (greentechdb_stats$cmaq_category[i] == "Ride Sharing") {
    rideshare_sum = rideshare_sum + greentechdb_stats$refined_stat[i]
    rideshare_count = rideshare_count + 1
    rideshare_values = c(rideshare_values, greentechdb_stats$refined_stat[i])
  }
  
  if (greentechdb_stats$cmaq_category[i] == "Alternative Fuels and Vehicles") {
    Alternative_Fuels_and_Vehicles_sum = Alternative_Fuels_and_Vehicles_sum + greentechdb_stats$refined_stat[i]
    Alternative_Fuels_and_Vehicles_count = Alternative_Fuels_and_Vehicles_count + 1
    Alternative_Fuels_and_Vehicles_values = c(Alternative_Fuels_and_Vehicles_values,greentechdb_stats$refined_stat[i])
  }
  
  if (greentechdb_stats$cmaq_category[i] == "Congestion Reduction and Traffic Flow Improvements") {
    Congestion_Reduction_and_Traffic_Flow_Improvements_sum = Congestion_Reduction_and_Traffic_Flow_Improvements_sum + greentechdb_stats$refined_stat[i]
    Congestion_Reduction_and_Traffic_Flow_Improvements_count = Congestion_Reduction_and_Traffic_Flow_Improvements_count + 1
    Congestion_Reduction_and_Traffic_Flow_Improvements_values = c(Congestion_Reduction_and_Traffic_Flow_Improvements_values, greentechdb_stats$refined_stat[i])
  }
  
}


rideshare_avg = rideshare_sum / rideshare_count
rideshare_sd = sd(rideshare_values)
Alternative_Fuels_and_Vehicles_avg = Alternative_Fuels_and_Vehicles_sum/Alternative_Fuels_and_Vehicles_count
Alternative_Fuels_and_Vehicles_sd = sd(Alternative_Fuels_and_Vehicles_values)
Congestion_Reduction_and_Traffic_Flow_Improvements_avg = Congestion_Reduction_and_Traffic_Flow_Improvements_sum/Congestion_Reduction_and_Traffic_Flow_Improvements_count
Congestion_Reduction_and_Traffic_Flow_Improvements_sd = sd(Congestion_Reduction_and_Traffic_Flow_Improvements_values)
policies <- data.frame(
  "Select Policy(ies)" = character(),
  "Policy ID" = numeric(),
  "CMAQ category (n = 7)" = character(),
  "EffectType" = character(),
  "Avg. Cost of Policy when applied 1 time/1 unit" = numeric(),
  "MetricAffected" = character(),
  "Amount Activity Control" = numeric(),
  "Percent Activity Control (%)" = numeric(),
  "Amount EF Control" = numeric(),
  "Percent EF Control (%)" = numeric(),
  "Standard Error" = numeric()
)

policy_data_list <- list()
for (i in 1:nrow(greentechdb_stats)) {
  cmaq_category <- greentechdb_stats$cmaq_category[i]
  if (greentechdb_stats$cmaq_category[i] == "Ride Sharing") {
    policy_data <- data.frame(
      "Select Policy(ies)" = NA,
      "Policy ID" = 1,
      "CMAQ category (n = 7)" = "Ride Sharing",
      "EffectType" = "Activity",
      "Avg. Cost of Policy when applied 1 time/1 unit" = 0,
      "MetricAffected" = "vmt",
      "Amount Activity Control" = rideshare_avg,
      "Percent Activity Control (%)" = NA,
      "Amount EF Control" = NA,
      "Percent EF Control (%)" = NA,
      "Standard Error" = rideshare_sd
    )
    policy_data_list[[i]] <- policy_data
  }
  if (greentechdb_stats$cmaq_category[i] == "Alternative Fuels and Vehicles") {
    policy_data <- data.frame(
      "Select Policy(ies)" = NA,
      "Policy ID" = 2,
      "CMAQ category (n = 7)" = "Alternative Fuels and Vehicles",
      "EffectType" = "Emission_Factor",
      "Avg. Cost of Policy when applied 1 time/1 unit" = 0,
      "MetricAffected" = "emissionfFactor",
      "Amount Activity Control" = NA,
      "Percent Activity Control (%)" = NA,
      "Amount EF Control" = Alternative_Fuels_and_Vehicles_avg,
      "Percent EF Control (%)" = NA,
      "Standard Error" = Alternative_Fuels_and_Vehicles_sd
    )
    policy_data_list[[i]] <- policy_data
  }
  if (greentechdb_stats$cmaq_category[i] == "Congestion Reduction and Traffic Flow Improvements") {
    policy_data <- data.frame(
      "Select Policy(ies)" = NA,
      "Policy ID" = 3,
      "CMAQ category (n = 7)" = "Congestion Reduction and Traffic Flow Improvements",
      "EffectType" = "Emission_Factor",
      "Avg. Cost of Policy when applied 1 time/1 unit" = 0,
      "MetricAffected" = "emissionfFactor",
      "Amount Activity Control" = NA,
      "Percent Activity Control (%)" = NA,
      "Amount EF Control" = Congestion_Reduction_and_Traffic_Flow_Improvements_avg,
      "Percent EF Control (%)" = NA,
      "Standard Error" = Congestion_Reduction_and_Traffic_Flow_Improvements_sd
    )
    policy_data_list[[i]] <- policy_data
  }
  
  policies <- do.call(rbind, policy_data_list)
}
duplicate_rows <- duplicated(policies)
unique_policies <- subset(policies, !duplicate_rows)

write.csv(unique_policies, file = "~/desktop/green tech project/policies.csv", row.names = FALSE)

```
