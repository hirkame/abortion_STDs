library(tidyverse)


# Guttmacher Institute (Yearly, 1988-2017) --------------------------------
# Pregnancies, Births and Abortions in the United States, 1973–2017: National and State Trends by Age

file_path <- "data/raw/Abortion/NationalAndStatePregnancy_PublicUse.rds"

abortion_guttmacher_nasp <- read_rds(file_path)

states <- read.csv(file = "data/us census bureau regions and divisions.csv")

abortion_guttmacher_nasp <- abortion_guttmacher_nasp |> 
  select(state, year, abortionstotal) |> 
  filter(state != "US") |> 
  left_join(states, by = c("state" = "State.Code")) |> 
  select(-state) |> 
  rename(region = Region, division = Division, state = State, estimate = abortionstotal) |> 
  select(year, region, division, state, estimate)

write.csv(abortion_guttmacher_nasp, file = "data/abortion_guttmacher_1988_2017.csv", row.names = F)
