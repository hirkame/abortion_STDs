library(tidyverse)
library(sf)


# Read data
df_std_state <- read_rds("data/stds_state.rds")
df_std_county <- read_rds("data/stds_county.rds")
states <- st_read("data/map/cb_2018_us_state_500k/cb_2018_us_state_500k.shp")
county <- st_read("data/map/cb_2018_us_county_500k/cb_2018_us_county_500k.shp")


# Calculate growth rates of chlamydia cases
df_std_state <- df_std_state |> 
  mutate(
    fips_state = sprintf("%02d", fips_state)
  ) |> 
  mutate(
    growth_rate = (countyvalue - lag(countyvalue))/lag(countyvalue)*100,
    .by = "fips_state"
  ) |> 
  filter(!is.na(growth_rate))

df_std_county <- df_std_county |> 
  mutate(
    fips = sprintf("%05d", fips)
  ) |> 
  mutate(
    growth_rate = (countyvalue - lag(countyvalue))/lag(countyvalue)*100,
    .by = "fips"
  ) |> 
  filter(!is.na(growth_rate))


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
  geom_sf(data = states, aes(fill = growth_rate), lty = 0) +
  scale_fill_gradient(
    high = "red",
    mid = "white",
    low = "blue"
  ) + 
  facet_wrap(~ year) +
  labs(title = "Growth of new chlamydia cases per 100,000 people (State, %)") + 
  theme(
    text = element_text(size = 8), 
    strip.text = element_text(face="bold"),
    strip.background = element_blank(),
    plot.title = element_text(size=12)
  )

ggsave("describe/state_growth.png", width = 20, height = 12, units = "cm")


# County-level  -----------------------------------------------------------
county <- county |> 
  filter(year %in% 2021:2024)
  
ggplot() + 
  geom_sf(data = county, aes(fill = growth_rate), lty = 0) +
  scale_fill_gradient2(
    high = "red",
    mid = "white",
    low = "blue"
  ) + 
  labs(title = "Growth of new chlamydia cases per 100,000 people (County, %)") +
  facet_wrap(~ year)  + 
  theme(
    text = element_text(size = 8), 
    strip.text = element_text(face="bold"),
    strip.background = element_blank(),
    plot.title = element_text(size=12)
  )

ggsave("describe/county_growth.png", width = 20, height = 12, units = "cm")

  

