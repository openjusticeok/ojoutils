library(ojodb)
library(tidyverse)

crim_charges <- ojo_crim_cases(districts = "all",
                               case_types = c("CM", "CF"),
                               file_years = 2000:2023
                               ) |>
  distinct(count_as_filed, .keep_all = TRUE) |>
  ojo_collect()

write_csv(crim_charges, "./data/uccs-datasets/all-cm-cf-counts-filed-2000-2023.csv")

crim_charges |>
  select(count_as_filed) |>
  write_csv("./data/uccs-datasets/all-cm-cf-counts-filed-2000-2023-only-counts.csv")
