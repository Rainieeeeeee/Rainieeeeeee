```R
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

policies <- data.frame(
  policy_id = integer(0),
  cmaq_category = character(0),
  type = character(0),
  cost_per_unit = numeric(0),
  affects = character(0),
  activity_amount = numeric(0),
  activity_percent = numeric(0),
  ef_amount = numeric(0),
  ef_percent = numeric(0),
  se = numeric(0),
  policy_name = character(0),
  stringsAsFactors = FALSE # 避免将字符列转换为因子
)
policies <- data.frame(
  "policy_id" = numeric(),
  "cmaq_category" = character(),
  "type" = character(),
  "cost_per_unit" = numeric(),
  "affects" = character(),
  "activity_amount" = numeric(),
  "activity_percent" = numeric(),
  "ef_amount" = numeric(),
  "ef_percent" = numeric(),
  "se" = numeric(),
  "policy_name" = character(),
)

policy_data_list <- list()
for (i in 1:nrow(greentechdb_stats)) {
  cmaq_category <- greentechdb_stats$cmaq_category[i]
  if (greentechdb_stats$cmaq_category[i] == "Ride Sharing") {
    policy_data <- data.frame(
      "select_policy" = NA,
      "policy_id" = 1,
      "cmaq_category" = "Ride Sharing",
      "type" = "Activity",
      "cost_per_unit" = 0,
      "affects" = "vmt",
      "activity_amount" = rideshare_avg,
      "activity_percent" = NA,
      "ef_amount" = NA,
      "ef_percent" = NA,
      "se" = NA,
      "se" = rideshare_sd,
      "policy_name" = NA
    )
    policy_data_list[[i]] <- policy_data
  }
  if (greentechdb_stats$cmaq_category[i] == "Alternative Fuels and Vehicles") {
    policy_data <- data.frame(
      "select_policy" = NA,
      "policy_id" = 2,
      "cmaq_category" = "Alternative Fuels and Vehicles",
      "type" = "Emission_Factor",
      "cost_per_unit" = 0,
      "affects" = "emissionFactor",
      "activity_amount" = NA,
      "activity_percent" = NA,
      "ef_amount" = Alternative_Fuels_and_Vehicles_avg,
      "ef_percent" = NA,
      "se" = Alternative_Fuels_and_Vehicles_sd,
      "policy_name" = NA
    )
    policy_data_list[[i]] <- policy_data
  }
  if (greentechdb_stats$cmaq_category[i] == "Congestion Reduction and Traffic Flow Improvements") {
    policy_data <- data.frame(
      "select_policy" = NA,
      "policy_id" = 3,
      "cmaq_category" = "Congestion Reduction and Traffic Flow Improvements",
      "type" = "Emission_Factor",
      "affects" = 0,
      "activity_amount" = "emissionFactor",
      "Amount Activity Control" = NA,
      "activity_percent" = NA,
      "ef_amount" = Congestion_Reduction_and_Traffic_Flow_Improvements_avg,
      "ef_percent" = NA,
      "se" = Congestion_Reduction_and_Traffic_Flow_Improvements_sd,
      "policy_name" = NA
    )
    policy_data_list[[i]] <- policy_data
  }
  
  policies <- do.call(rbind, policy_data_list)
}
duplicate_rows <- duplicated(policies)
unique_policies <- subset(policies, !duplicate_rows)

write.csv(unique_policies, file = "~/desktop/green tech project/policies.csv", row.names = FALSE)

```