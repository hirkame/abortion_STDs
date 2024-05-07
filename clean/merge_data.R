library(tidyverse)


# State data --------------------------------------------------------------
df_std_state <- read_rds("data/stds_state.rds")
df_teenbirths_state <- read_rds("data/teenbirths_state.rds")
# Join
df_state <- df_std_state |> 
  left_join(
    df_teenbirths_state,
    by = join_by(year, fips_state, county_name)
  ) |> 
  rename(state_name = county_name) 


# Save merged dataset
saveRDS(df_state, "data/state_data.rds")
write_dta(df_state, "data/state_data.dta")


# County data -------------------------------------------------------------
# Read data
df_std_county <- read_rds("data/stds_county.rds")
df_teenbirths_county <- read_rds("data/teenbirths_county.rds")
county_fips_master <- read.csv("data/county_fips_master.csv")


# Clean data
county_fips_master <- county_fips_master |> 
  mutate(
    county_name = str_replace_all(county_name, " City and Borough", ""),
    county_name = str_replace_all(county_name, " County", ""),
    county_name = str_replace_all(county_name, " Borough", ""),
    county_name = str_replace_all(county_name, " Parish", ""),
    county_name = str_replace_all(county_name, " Municipality", ""),
    county_name = str_replace_all(county_name, " Census Area", ""),
    county_name = str_to_title(county_name)
  )


# Join
df_county <- df_std_county |> 
  left_join(
    df_teenbirths_county, 
    by = join_by(year, fips_state, county_name)
  )
df_county <- df_county |> 
  left_join(
    county_fips_master,
    by = join_by(county_name, fips_state == state)
  )


# Save merged dataset
saveRDS(df_county, "data/county_data.rds")
write_dta(df_county, "data/county_data.dta")
