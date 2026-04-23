# ojoutils 0.2.0 (2026-04-23)

- Adds Google Cloud Storage (GCS) utilities: `gcs_auth_bucket()`, `gcs_read_csv()`, `gcs_write_csv()`, `gcs_list_objects()`, and `tar_gcs_csv()` for working with GCS via the arrow package.
- Adds `count_interval()` function with Rust and Arrow backend for counting active intervals over time periods.
- Adds `README.Rmd` and `README.md` to repo.
- Fixes `ojo_parse_county()` to eliminate dplyr 1.2.0 deprecation warning by replacing `case_when()` with if/else statements.

# ojoutils 0.1.3

# ojoutils 0.1.2 (2024-03-12)

- Adds `ojo_use_template` function to make it easier to add a new blank Quarto report to a project repository.
- Adds `dir_empty`, styled in `{fs}` fashion, to easily check whether a directory is, well, empty.

# ojoutils 0.1.1 (2023-07-08)

- Adds `ojo_parse_county` function for standardizing Oklahoma county names, optionally specifying the case of the result.
- Adds `ojo_counties` object which is a vector of Oklahoma county names in lowercase. This is also used internally by `ojo_parse_county`.

# ojoutils 0.1.0 (2023-07-07)

- Adds function `limit` which works like `head` but is helpful for when your brain is in SQL mode.
