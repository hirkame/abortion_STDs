library(tidyverse)



# Guttmacher Institute (Yearly, 2020) ------------------------------
# Maddow-Zimet I and Kost K, Even before Roe was overturned, nearly one in 10 people obtaining an abortion traveled across state lines for care, New York: Guttmacher Institute, 2022, https://www.guttmacher.org/article/2022/07/even-roe-was-overturned-nearly-one-10-people-obtaining-abortion-traveled-across

file_path <- "data/raw/Abortion/no-of-abortions-by-state-of-residence.csv"
abortion_guttmacher_2020 <- read.csv(file_path)
file_path <- "data/us census bureau regions and divisions.csv"
states <- read.csv(file_path)


abortion_guttmacher_2020 <- abortion_guttmacher_2020 |> 
  select(c("state_name", "datum")) |> 
  rename(state = state_name, abortion = datum) |> 
  t() |> 
  data.frame()

colnames(abortion_guttmacher_2020) <- abortion_guttmacher_2020["state", ] 
rownames(abortion_guttmacher_2020) <- NULL

abortion_guttmacher_2020 <- abortion_guttmacher_2020[-1, ] |> 
  mutate(
    across(
      everything(), as.numeric
    ),
    year = 2020
  ) |> 
  mutate(year = 2020)

abortion_guttmacher_2020 <- abortion_guttmacher_2020 |> 
  pivot_longer(
    !year, 
    names_to = "state", 
    values_to = "estimate"
  ) |> 
  left_join(states, by = c("state" = "State")) |> 
  rename(region = Region, division = Division) |> 
  select(year, region, division, state, estimate)


write.csv(abortion_guttmacher_year2023, file = "data/abortion_guttmacher_2020.csv", row.names = F)
