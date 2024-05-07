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
      paste0("data/teen-births/", fips, "_", year, ".csv")
    )
    
    # County
    county <- df |>
      slice(2:n()) |>
      select(-1) |>
      mutate(# Generate year and fips
        year = year,
        fips_state = fips
      ) 
    
    # State
    state <- df |>
      slice_head() |>
      select(-1) |>
      mutate(# Generate year and fips
        year = year,
        fips_state = fips
      ) 
    
    # Append data frame to the list
    df_county <- append(df_county, list(county))
    df_state <- append(df_state, list(state))
    
  }
}


# Combine all data frames in the list into a single data frame
df_county <- rbindlist(df_county, fill=TRUE)
df_state <- rbindlist(df_state, fill=TRUE)


# Clean data
clean_teenbirths <- function (df, state = F) {
  df <- df |>
    mutate(
      county_name = if_else(!is.na(County), County,
                            if_else(
                              !is.na(Borough), Borough,
                              if_else(!is.na(Parish), Parish, NA),
                            )),
      teenbirths = Teen.Births,
      teenpopulation = Teen.Population,
      teenbirth_rate = coalesce(as.character(`County.Value`), 
                             as.character(`Borough.Value`), 
                             as.character(`Parish.Value`),
                             as.character(`County.Value.`), 
                             as.character(`Borough.Value.`), 
                             as.character(`Parish.Value.`),
                             as.character(`County.Value..`), 
                             as.character(`Borough.Value..`), 
                             as.character(`Parish.Value..`)),
      errormargin = Error.Margin
    ) 
  
  if(state == T) {
    df <- df |> 
      mutate(
        errormargin = if_else(year %in% 2012:2017, 
                              teenbirth_rate, 
                              errormargin),
        teenbirth_rate = if_else(year %in% 2012:2017, teenpopulation, teenbirth_rate)
      )
  }
  
  df <- select(df, year, fips_state, county_name, teenbirths, teenbirth_rate, errormargin)
  
  # Adjust types
  df <- df |>
    mutate(across(
      .fns = ~ {
        as.character(.x) |>
          str_replace(",", "") |>
          as.numeric()
      },
      .cols = c(teenbirths, teenbirth_rate)
    ))
  
  
  # Modify county names
  df <- df |>
    mutate(
      county_name = str_replace(county_name, "\\^", ""),
      county_name = str_replace(county_name, "\\*\\*", ""),
      county_name = str_replace(county_name, "\\s+$", ""),
      county_name = str_to_title(county_name)
    ) |>
    relocate(year, fips_state, county_name, everything())
  
  # Relocate and arrage state data
  df <- df |>
    relocate(year, fips_state, county_name, everything()) |>
    arrange(fips_state, year)
  
  # Valdez-Cordova Census Area, AK
  # <= Chugach Census Area, AK, Copper River Census Area, AK
  if(state == F) { 
    df <- df |>
      bind_rows(
        tibble(
          year = 2024,
          fips_state = 2,
          county_name = "Valdez-Cordova",
          teenbirths = sum(df[df$county_name %in% c("Chugach", "Copper River")]$teenbirths),
          teenbirth_rate = sum(df[df$teenbirth_rate %in% c("Chugach", "Copper River")]$teenbirth_rate) / 2
        )
      ) |>
      filter(!(county_name %in% c("Chugach", "Copper River"))) 
  }
  
  return(df)
} 

df_county <- clean_teenbirths(df_county)
df_state <- clean_teenbirths(df_state, state = TRUE)


# Run ---------------------------------------------------------------------

# Save appended dataset
saveRDS(df_county, "data/teenbirths_county.rds")
saveRDS(df_state, "data/teenbirths_state.rds")
