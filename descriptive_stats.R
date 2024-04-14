library(tidyverse)



# CDC ---------------------------------------------------------------------

# Data clean 
abortions_cdc <- read_csv("data/abortions_cdc.csv")
states <- read_csv("data/raw/us census bureau regions and divisions.csv")

abortions_cdc <- abortions_cdc |> 
  filter(
    Category == "Total by residence"
  ) |> 
  select(
    # No report states
    -str_subset(names(abortions_cdc), ".*\\*\\*"), 
    # Other countries & other categories
    -c("Category", `US Territory`, "Canada", "Mexico", "Other foreign country", 
       "Out-of-area (exact residence unknown)", "Unknown residence")
  ) |> 
  mutate_all(as.numeric) |> 
  pivot_longer(cols = -year, names_to = "State", values_to = "Value") |> 
  left_join(
    states
  )

# Plot
ggplot(abortions_cdc, aes(x = year, y = Value, color = State)) +
  facet_wrap(~ Region) + 
  geom_line() +
  labs(x = "Year", y = "Value", color = "State")
