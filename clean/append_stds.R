library(tidyverse)
library(data.table)
library(haven)


# Initialize an empty list to store data frames
df_std <- list()


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
      ),
      skip = 1
    )
    
    # Type
    df <- df |>
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
    df_std <- append(df_std, list(df))
  }
}


# Combine all data frames in the list into a single data frame
df_std <- rbindlist(df_std)


# Modify county names
df_std <- df_std |> 
  mutate(
    county_name = str_replace(county_name, "\\^", ""), 
    county_name = str_replace(county_name, "\\*\\*", ""), 
    county_name = str_replace(county_name, "\\s+$", ""),
    county_name = str_to_title(county_name)
  ) |> 
  relocate(year, fips_state, county_name, everything())


# Valdez-Cordova Census Area, AK
# <= Chugach Census Area, AK, Copper River Census Area, AK
df_std <- df_std |> 
  bind_rows(
    tibble(
      year = 2024,
      fips_state = 2,
      county_name = "Valdez-Cordova",
      chlamydiacases = sum(df_std[df_std$county_name %in% c("Chugach", "Copper River")]$chlamydiacases), 
      countyvalue = sum(df_std[df_std$county_name %in% c("Chugach", "Copper River")]$countyvalue),
      zscore = NA
    )
  ) |> 
  filter(!(county_name %in% c("Chugach", "Copper River"))) 


# Save appended dataset
saveRDS(df_std, "data/stds.rds")
