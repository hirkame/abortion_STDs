library(tidyverse)
library(readxl)



# CDC ---------------------------------------------------------------------

file_path <- "data/raw/Abortion/Abortions-Distributed-by-Area-2012-2021.xlsx"
abortions_cdc <- excel_sheets(file_path) |> 
  map(
    ~ read_excel(file_path, sheet = .x, range = "B2:BH55", col_names = T)
  )

names(abortions_cdc) <- excel_sheets(file_path)


# Total by residence
abortions_cdc_residence <- abortions_cdc |> 
  map(
    ~ {
      . |> 
        filter(Area == "Total by residence") 
    }
  ) |> 
  bind_rows(.id = "year") |> 
  rename(Category = Area) |> 
  select(-"Total by location of service")

# Total by location of service
abortions_cdc_locationofservice <- abortions_cdc |>
  map( ~ {
    transposed <- t(.)
    colnames(transposed) <- as.character(transposed[1,])
    transposed <- transposed[-1, ]
    transposed <- as.data.frame(transposed) |>
      rownames_to_column("Category") |>
      filter(Category == "Total by location of service")
    transposed
  }) |>
  bind_rows(.id = "year")  |> 
  select(-"Total by residence")

abortions_cdc <- bind_rows(abortions_cdc_residence, abortions_cdc_locationofservice)

abortions_cdc <- abortions_cdc |> 
  mutate(
    "New York" = rowSums(
      mutate_all(select(abortions_cdc, contains("New York")), as.numeric), 
      na.rm = TRUE
    ), 
    `New Hampshire**` = rowSums(
      mutate_all(select(abortions_cdc, contains("Hampshire")), as.numeric), 
      na.rm = TRUE
    ), 
    `New Hampshire**` = if_else(
      `New Hampshire**` == 0, NA, `New Hampshire**`
    )
  ) |> 
  select(
    str_subset(names(abortions_cdc), "^(?!.*New York).*$"), "New York"
  ) |> 
  select("year", "Category", sort(tidyselect::peek_vars())) |> 
  mutate(
    across(
      !Category, 
      as.numeric
    )
  )


write_csv(abortions_cdc, file = "data/abortions_cdc.csv")
