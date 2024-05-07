library(tidyverse)
library(sf)


# Read data
df_state <- read_rds("data/state_data.rds")
df_county <- read_rds("data/county_data.rds")
states <- st_read("data/map/cb_2018_us_state_500k/cb_2018_us_state_500k.shp")
county <- st_read("data/map/cb_2018_us_county_500k/cb_2018_us_county_500k.shp")


# Calculate growth rates of chlamydia cases
df_state <- df_state |> 
  mutate(
    fips_state = sprintf("%02d", fips_state)
  ) |> 
  mutate(
    growth_rate_chlamydiacases = (chlamydiacases_rate - lag(chlamydiacases_rate))/lag(chlamydiacases_rate)*100,
    growth_rate_teenbirths = (teenbirth_rate - lag(teenbirth_rate))/lag(teenbirth_rate)*100,
    .by = "fips_state"
  ) 

df_county <- df_county |> 
  mutate(
    fips = sprintf("%05d", fips)
  ) |> 
  mutate(
    growth_rate_chlamydiacases = (chlamydiacases_rate - lag(chlamydiacases_rate))/lag(chlamydiacases_rate)*100,
    growth_rate_teenbirths = (teenbirth_rate - lag(teenbirth_rate))/lag(teenbirth_rate)*100,
    .by = c("fips_state", "county_name")
  ) 


# Remove Alaska and Hawaii
states <- states |> 
  filter(!STATEFP %in% c('02', '15', '66'))
county <- county |> 
  filter(!STATEFP %in% c('02', '15', '66')) 


# Merge data
states <- states |> 
  left_join(df_state, by = join_by(STATEFP == fips_state))
county <- county |> 
  left_join(df_county, by = join_by(GEOID == fips))



# State-level -------------------------------------------------------------
states <- states |> 
  filter(year %in% 2021:2024) 

ggplot() + 
  geom_sf(data = states, aes(fill = growth_rate_chlamydiacases), lty = 0) +
  scale_fill_gradient2(
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

ggsave("describe/state_growth_chlamydia.png", width = 20, height = 12, units = "cm")

ggplot() + 
  geom_sf(data = states, aes(fill = growth_rate_teenbirths), lty = 0) +
  scale_fill_gradient2(
    high = "red",
    mid = "white",
    low = "blue"
  ) + 
  facet_wrap(~ year) +
  labs(title = "Growth of teen births per 1,000 people (State, %)") + 
  theme(
    text = element_text(size = 8), 
    strip.text = element_text(face="bold"),
    strip.background = element_blank(),
    plot.title = element_text(size=12)
  )

ggsave("describe/state_growth_teenbirths.png", width = 20, height = 12, units = "cm")



# County-level  -----------------------------------------------------------
county <- county |> 
  filter(year %in% 2021:2024)
  
ggplot() + 
  geom_sf(data = county, aes(fill = growth_rate_chlamydiacases), lty = 0) +
  scale_fill_gradient2(
    high = "red",
    mid = "white",
    low = "blue"
  ) + 
  labs(title = "Growth of new chlamydia cases per 100,000 people (County, %)") +
  facet_wrap(. ~ year)  + 
  theme(
    text = element_text(size = 8), 
    strip.text = element_text(face="bold"),
    strip.background = element_blank(),
    plot.title = element_text(size=12)
  )

ggsave("describe/county_growth_chlamydia.png", width = 20, height = 12, units = "cm")


ggplot() + 
  geom_sf(data = county, aes(fill = growth_rate_teenbirths), lty = 0) +
  scale_fill_gradient2(
    high = "red",
    mid = "white",
    low = "blue"
  ) + 
  labs(title = "Growth of teen births per 1,000 people (County, %)") +
  facet_wrap(. ~ year)  + 
  theme(
    text = element_text(size = 8), 
    strip.text = element_text(face="bold"),
    strip.background = element_blank(),
    plot.title = element_text(size=12)
  )

ggsave("describe/county_growth_teenbirths.png", width = 20, height = 12, units = "cm")

