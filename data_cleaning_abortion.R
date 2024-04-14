library(tidyverse)
library(readxl)



# CDC ---------------------------------------------------------------------

file_path <- "data/raw/Abortion/Abortions-Distributed-by-Area-2012-2021.xlsx"
abortions_cdc <- excel_sheets(file_path) |> 
  map(
    ~ read_excel(file_path, sheet = .x, range = "B2:BH55", col_names = T)
  )

names(abortions_cdc) <- excel_sheets(file_path)


# Total by residence
abortions_cdc_residence <- abortions_cdc |> 
  map(
    ~ {
      . |> 
        filter(Area == "Total by residence") 
    }
  ) |> 
  bind_rows(.id = "year") |> 
  rename(Category = Area) |> 
  select(-"Total by location of service")

# Total by location of service
abortions_cdc_locationofservice <- abortions_cdc |>
  map( ~ {
    transposed <- t(.)
    colnames(transposed) <- as.character(transposed[1,])
    transposed <- transposed[-1, ]
    transposed <- as.data.frame(transposed) |>
      rownames_to_column("Category") |>
      filter(Category == "Total by location of service")
    transposed
  }) |>
  bind_rows(.id = "year")  |> 
  select(-"Total by residence")

abortions_cdc <- bind_rows(abortions_cdc_residence, abortions_cdc_locationofservice)

abortions_cdc <- abortions_cdc |> 
  mutate(
    "New York" = rowSums(
      mutate_all(select(abortions_cdc, contains("New York")), as.numeric), 
      na.rm = TRUE
    ), 
    `New Hampshire**` = rowSums(
      mutate_all(select(abortions_cdc, contains("Hampshire")), as.numeric), 
      na.rm = TRUE
    ), 
    `New Hampshire**` = as.character(`New Hampshire**`),
    `New Hampshire**` = if_else(
      `New Hampshire**` == "0", "--", `New Hampshire**`
    )
  ) |> 
  select(
    str_subset(names(abortions_cdc), "^(?!.*New York).*$"), "New York"
  ) |> 
  select("year", "Category", sort(tidyselect::peek_vars())) 


write_csv(abortions_cdc, file = "data/abortions_cdc.csv")



# Guttmacher Institute (Yearly, 1988-2017) --------------------------------
# Pregnancies, Births and Abortions in the United States, 1973–2017: National and State Trends by Age

file_path <- "data/raw/Abortion/NationalAndStatePregnancy_PublicUse.rds"
abortion_guttmacher_nasp <- read_rds(file_path)

states <- read.csv(file = "data/raw/states.csv")

abortion_guttmacher_nasp <- abortion_guttmacher_nasp |> 
  select(state, year, abortionstotal) |> 
  filter(state != "US") |> 
  left_join(states, by = c("state" = "Abbreviation")) |> 
  select(-state) |> 
  rename(state = State, abortion_estimate = abortionstotal) |> 
  pivot_wider(
    names_from = state,
    values_from = abortion_estimate
  ) 

write.csv(abortion_guttmacher_nasp, file = "data/abortion_guttmacher_1988_2017.csv", row.names = F)



# Guttmacher Institute (Yearly, 2020) ------------------------------
# Maddow-Zimet I and Kost K, Even before Roe was overturned, nearly one in 10 people obtaining an abortion traveled across state lines for care, New York: Guttmacher Institute, 2022, https://www.guttmacher.org/article/2022/07/even-roe-was-overturned-nearly-one-10-people-obtaining-abortion-traveled-across


file_path <- "data/raw/Abortion/no-of-abortions-by-state-of-residence.csv"

abortion_guttmacher_2020 <- read.csv(file_path)

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
  )



# Guttmacher Institute (Monthly, 2023) ------------------------------------
# The Monthly Abortion Provision Study 

file_path <- "data/raw/Abortion/MonthlyAbortionProvisionMonthly_Long.RDS"
abortion_guttmacher_maps_2023 <- read_rds(file_path)

abortion_guttmacher_maps_2023 <- abortion_guttmacher_maps_2023 |> 
  select(-c("source", "notes", "publishdate")) |> 
  filter(state != "US") |> 
  left_join(states, by = c("state" = "Abbreviation")) |> 
  select(-state) |> 
  rename(state = State, abortion_estimate = estimate)

abortion_guttmacher_maps_2023 <- abortion_guttmacher_maps_2023 |> 
  pivot_wider(
    names_from = state,
    values_from = abortion_estimate
  ) 

write.csv(abortion_guttmacher_maps_2023, file = "data/abortion_guttmacher_2023_monthly.csv", row.names = F)



# Merge -------------------------------------------------------------------

# 2023
abortion_guttmacher_2023 <- abortion_guttmacher_maps_2023 |> 
  filter(percentile == 0.5) |> 
  select(-c(month, percentile)) |> 
  summarise(
    across(everything(), .fns = ~ sum(.x, na.rm = T))
  ) |> 
  mutate(year = 2023)

abortion_guttmacher <- bind_rows(abortion_guttmacher_nasp, abortion_guttmacher_2020, abortion_guttmacher_2023) 

write.csv(abortion_guttmacher, file = "data/abortion_guttmacher.csv", row.names = F)



