library(tidyverse)




# 2023, Monthly -----------------------------------------------------------

# Load data 
file_path <- "data/raw/Abortion/MonthlyAbortionProvisionMonthly_Long.RDS"
abortion_guttmacher_maps_2023 <- read_rds(file_path)
file_path <- "data/us census bureau regions and divisions.csv"
states <- read.csv(file_path)


# Clean data
abortion_guttmacher_maps_2023 <- abortion_guttmacher_maps_2023 |> 
  select(-c("source", "notes", "publishdate")) |> 
  filter(state != "US") |> 
  left_join(states, by = c("state" = "State.Code")) |> 
  select(-state) |> 
  rename(state = State, region = Region, division = Division) |> 
  select(month, region, division, state, percentile, estimate)

write.csv(abortion_guttmacher_maps_2023, file = "data/abortion_guttmacher_2023_monthly.csv", row.names = F)




# Aggregate (2023, Yearly) --------------------------------------------------------

abortion_guttmacher_year2023 <- abortion_guttmacher_maps_2023 |> 
  filter(percentile == 0.5) |> 
  select(-c(month, percentile)) |> 
  summarise(
    estimate = sum(estimate), 
    .by = c(region, division, state)
  ) |> 
  mutate(year = 2023)

write.csv(abortion_guttmacher_year2023, file = "data/abortion_guttmacher_2023.csv", row.names = F)


