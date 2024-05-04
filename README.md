# Pipeline 

1. `clean/scrape.R`: Scrape tables from [the County Health Rankings & Roadmaps](https://www.countyhealthrankings.org/health-data/health-factors/health-behaviors/sexual-activity/sexually-transmitted-infections?year=2024) and save them locally
2. `clean/append_stds.R`: Append all STD datasets across states and years
3. `clean/set_county_fips.R`: Merge STD data with county fips data

# Data source 

University of Wisconsin Population Health Institute. County Health Rankings & Roadmaps 2024. www.countyhealthrankings.org. 
