library(tidyverse)
library(data.table)
library(haven)


# State code
state_fips_master <- read_csv("data/county_fips_master.csv")


# Initialize an empty list to store data frames
df_county <- list()
df_state <- list()


# Loop over years and files, excluding specified indices
for (year in 2011:2024) {
  for (fips in unique(state_fips_master$state)[!is.na(unique(state_fips_master$state))]) {
    # Import data
    df <- read.csv(
      paste0("data/sexually-transmitted-infections/", fips, "_", year, ".csv"),
      col.names = c(
        "index",
        "county_name",
        "chlamydiacases",
        "countyvalue",
        "zscore"
      )
    )
    
    # County
    county <- df |>
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
    state <- df |>
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
    df_county <- append(df_county, list(county))
    df_state <- append(df_state, list(state))
    
  }
}

# Combine all data frames in the list into a single data frame
df_county <- rbindlist(df_county)
df_state <- rbindlist(df_state)
# Modify county names
df_county <- df_county |>
  mutate(
    county_name = str_replace(county_name, "\\^", ""),
    county_name = str_replace(county_name, "\\*\\*", ""),
    county_name = str_replace(county_name, "\\s+$", ""),
    county_name = str_to_title(county_name)
  ) |>
  relocate(year, fips_state, county_name, everything())

# Relocate and arrage state data
df_state <- df_state |>
  relocate(year, fips_state, county_name, everything()) |>
  arrange(fips_state, year)

# Valdez-Cordova Census Area, AK
# <= Chugach Census Area, AK, Copper River Census Area, AK
df_county <- df_county |>
  bind_rows(
    tibble(
      year = 2024,
      fips_state = 2,
      county_name = "Valdez-Cordova",
      chlamydiacases = sum(df_county[df_county$county_name %in% c("Chugach", "Copper River")]$chlamydiacases),
      countyvalue = sum(df_county[df_county$county_name %in% c("Chugach", "Copper River")]$countyvalue),
      zscore = NA
    )
  ) |>
  filter(!(county_name %in% c("Chugach", "Copper River"))) 
  

# Run ---------------------------------------------------------------------

# Save appended dataset
saveRDS(df_county, "data/stds_county.rds")
saveRDS(df_state, "data/stds_state.rds")
