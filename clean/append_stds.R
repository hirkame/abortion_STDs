library(tidyverse)
library(data.table)
library(haven)


# State code
state_fips_master <- read_csv("data/county_fips_master.csv")


# Initialize an empty list to store data frames
df_std_county <- list()
df_std_state <- list()


# Loop over years and files, excluding specified indices
for (year in 2011:2024) {
  for (fips in unique(state_fips_master$state)[!is.na(unique(state_fips_master$state))]) {
    # Import data
    df <- read.csv(
      paste0("data/STDs/", fips, "_", year, ".csv"),
      col.names = c(
        "index",
        "county_name",
        "chlamydiacases",
        "countyvalue",
        "zscore"
      )
    )
    
    # County
    df_county <- df |> 
      slice(2:n()) |> 
      select(!index) |>
      mutate(# Generate year and fips
        year = year,
        fips_state = fips) |>
      mutate(across(
        .fns = ~ {
          as.character(.x) |>
            str_replace(",", "") |>
            as.numeric()
        },
        .cols = c(chlamydiacases, countyvalue)
      ))
    
    # State
    df_state <- df |> 
      slice_head() |> 
      select(!index) |>
      mutate(# Generate year and fips
        year = year,
        fips_state = fips) |>
      mutate(across(
        .fns = ~ {
          as.character(.x) |>
            str_replace(",", "") |>
            as.numeric()
        },
        .cols = c(chlamydiacases, countyvalue)
      ))
    
    # Append data frame to the list
    df_std_county <- append(df_std_county, list(df_county))
    df_std_state <- append(df_std_state, list(df_state))
  }
}


# Combine all data frames in the list into a single data frame
df_std_county <- rbindlist(df_std_county)
df_std_state <- rbindlist(df_std_state)


# Modify county names
df_std_county <- df_std_county |> 
  mutate(
    county_name = str_replace(county_name, "\\^", ""), 
    county_name = str_replace(county_name, "\\*\\*", ""), 
    county_name = str_replace(county_name, "\\s+$", ""),
    county_name = str_to_title(county_name)
  ) |> 
  relocate(year, fips_state, county_name, everything())
df_std_state <- df_std_state |> 
  relocate(year, fips_state, county_name, everything()) |> 
  arrange(fips_state, year)



# Valdez-Cordova Census Area, AK
# <= Chugach Census Area, AK, Copper River Census Area, AK
df_std_county <- df_std_county |> 
  bind_rows(
    tibble(
      year = 2024,
      fips_state = 2,
      county_name = "Valdez-Cordova",
      chlamydiacases = sum(df_std_county[df_std_county$county_name %in% c("Chugach", "Copper River")]$chlamydiacases), 
      countyvalue = sum(df_std_county[df_std_county$county_name %in% c("Chugach", "Copper River")]$countyvalue),
      zscore = NA
    )
  ) |> 
  filter(!(county_name %in% c("Chugach", "Copper River"))) 


# Save appended dataset
saveRDS(df_std_county, "data/stds_county.rds")
saveRDS(df_std_state, "data/stds_state.rds")
