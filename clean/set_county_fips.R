library(tidyverse)


# Read data
df_std <- read_rds("data/stds_county.rds")
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
df_std <- left_join(
  df_std, county_fips_master, 
  by = join_by(county_name, fips_state == state)
)


# Save merged dataset
saveRDS(df_std, "data/stds_county.rds")
write_dta(df_std, "data/stds_county.dta")
