install.packages("googlesheets4")
install.packages("dplyr")
install.packages("RMySQL")
install.packages("DBI")
install.packages("cronR")
library(googlesheets4)
library(dplyr)
library(RMySQL)
library(DBI)
library(cronR)
library(readr)

url <- "https://raw.githubusercontent.com/Rainieeeeeee/Rainieeeeeee/main/stat_update.csv"
stats <- read_csv(url)
#head(stats)
studies_data <- stats %>%
  mutate(
    id = id,
    policy_id = policies_id,
    study_name = type_of_policy,
    refined_stat = refined_stat,
    effect_type = effect_type,
    links = link_to_source,
    coder = coder,
    time = year_of_Study,
    population = population,
    units = units,
    # Add other necessary columns and transformations as needed
  ) %>%
  select(policy_id, study_name, refined_stat, population, units, time, effect_type, links, coder)
studies_data
con = DBI::dbConnect(
  MySQL(),
  user = "greentechsetup",
  password = "fanciest of feasts",
  dbname = "greentechdb",
  host = "128.253.5.67",
  port = 3306)

dbWriteTable(con, "Studies", studies_data, append = TRUE, row.names = FALSE)


dbExecute(con, 
          "INSERT INTO RefinedStats (policy_id, refined_stat_avg,se)
           SELECT policy_id, AVG(CAST(refined_stat AS DECIMAL(10, 6))) AS avg_stat,
           STD(CAST(refined_stat AS DECIMAL(10, 6))) AS se
           FROM Studies
           GROUP BY policy_id")



dbExecute(con, "
    INSERT INTO Policies (policy_id, cmaq_category, type, affects, se, activity_amount, ef_amount)
    SELECT 
        r.policy_id, 
        s.study_name AS cmaq_category, 
        s.effect_type AS type, 
        CASE WHEN s.effect_type = 'Activity' THEN 'vmt' 
             WHEN s.effect_type = 'Emissions Factor' THEN 'emissionFactor' 
             ELSE NULL END AS affects,
        r.se,
        CASE WHEN s.effect_type = 'Activity' THEN r.refined_stat_avg ELSE NULL END AS activity_amount,
        CASE WHEN s.effect_type = 'Emissions Factor' THEN r.refined_stat_avg ELSE NULL END AS ef_amount
    FROM 
        RefinedStats r
    LEFT JOIN 
        Studies s ON r.policy_id = s.policy_id
    ON DUPLICATE KEY UPDATE
        cmaq_category = VALUES(cmaq_category),
        type = VALUES(type),
        affects = VALUES(affects),
        se = VALUES(se),
        activity_amount = VALUES(activity_amount),
        ef_amount = VALUES(ef_amount)
")
