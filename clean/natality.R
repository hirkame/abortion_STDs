library(tidyverse)
library (foreign)



# States ------------------------------------------------------------------

# States: 2016-2022 
file_path <- "data/raw/Natality/natality_2016-2022_state.txt"
natality_2016_2022_state <- read.table(file_path, header = TRUE, sep = "\t", nrows = 4284)
natality_2016_2022_state <- natality_2016_2022_state[, 2:ncol(natality_2016_2022_state)]


# State: 2023-
file_path <- "data/raw/Natality/natality_2023_state.txt"
natality_2023_state <- read.table(file_path, header = TRUE, sep = "\t", nrows = 714)
natality_2023_state <- natality_2023_state[, 2:ncol(natality_2023_state)]


# Merge
natality_state <- bind_rows(natality_2023_state, natality_2016_2022_state) |> 
  arrange(State.of.Residence, Year, Month.Code) 


# Rename
old_names <- colnames(natality_state)
new_names <- gsub("\\.", "_", old_names)
colnames(natality_state) <- new_names


# Save
write.dta(natality_state, "data/natality_state.dta")
saveRDS(natality_state, "data/natality_state.rds")


# County ------------------------------------------------------------------

# County: 2016-2022 
file_path <- "data/raw/Natality/natality_2016-2022_county.txt"
natality_2016_2022_county <- read.table(file_path, header = TRUE, sep = "\t", nrows = 7512)
natality_2016_2022_county <- natality_2016_2022_county[, 2:ncol(natality_2016_2022_county)]


# # County: 2023- 
# file_path <- "data/raw/county_2023_state.txt"
# county_2023_state <- read.table(file_path, header = TRUE, sep = "\t", nrows = 612)
# county_2023_state <- county_2023_state[, 2:ncol(county_2023_state)]
# 
# 
# # Merge
# natality_state <- bind_rows(county_2023_state, natality_2016_2022_county) |> 
#   arrange("County.of.Residence", "Year", "Month")