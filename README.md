# Pipeline 

## Data cleaning 

1. `clean/scrape.R`: Scrape tables from [the County Health Rankings & Roadmaps](https://www.countyhealthrankings.org/health-data/health-factors/health-behaviors/sexual-activity/sexually-transmitted-infections?year=2024) and save them locally
2. `clean/append_stds.R`: Append all STD datasets across counties (states) and years
3. `clean/append_teenbirths.R`: Append all teen births datasets across counties (states) and years
4. `clean/merge_data.R`: Merge STD and teen births data with county fips data

## Data visualization

- `describe/map.R`: Plot STDs and teen births growth rate across countie (states) and years

# Data source 

University of Wisconsin Population Health Institute. County Health Rankings & Roadmaps 2024. www.countyhealthrankings.org. 
