library(tidyverse)
library(sf)


# Read data
df_std_state <- read_rds("data/stds_state.rds")
df_std_county <- read_rds("data/stds_county.rds")
states <- st_read("data/map/cb_2018_us_state_500k/cb_2018_us_state_500k.shp")
county <- st_read("data/map/cb_2018_us_county_500k/cb_2018_us_county_500k.shp")


# Adjust data
df_std_state <- df_std_state |> 
  mutate(
    fips_state = sprintf("%02d", fips_state)
  )  
df_std_county <- df_std_county |> 
  mutate(
    fips = sprintf("%05d", fips)
  )  


# Remove Alaska and Hawaii
states <- states |> 
  filter(!STATEFP %in% c('02', '15', '66'))
county <- county |> 
  filter(!STATEFP %in% c('02', '15', '66')) 

# Merge data
states <- states |> 
  left_join(df_std_state, by = join_by(STATEFP == fips_state))
county <- county |> 
  left_join(df_std_county, by = join_by(GEOID == fips))



# State-level -------------------------------------------------------------
states <- states |> 
  filter(year %in% 2021:2024) 

ggplot() + 
  geom_sf(data = states, aes(fill = countyvalue), lty = 0) +
  scale_fill_distiller(palette = "RdPu", direction = 1) + 
  facet_wrap(~ year)


# County-level  -----------------------------------------------------------
county <- county |> 
  filter(year %in% 2021:2024) 
  
ggplot() + 
  geom_sf(data = county, aes(fill = countyvalue), lty = 0) +
  scale_fill_distiller(palette = "RdPu", direction = 1) + 
  facet_wrap(~ year)

  

