# Changelog

## ojoutils 0.3.0 (2026-05-04)

### Breaking Changes

- [`ojo_use_template()`](https://openjusticeok.github.io/ojoutils/reference/ojo_use_template.md)
  has been completely rewritten with a new API:
  - Changed from separate `base_dir` and `project_name` parameters to a
    single `path` parameter
  - Project names must now be in **kebab-case** format (lowercase
    letters, numbers, and hyphens only)
  - Automatically creates the directory if it doesn’t exist
  - Aborts with an error if the directory already exists and is
    non-empty

### New Features

- [`ojo_use_template()`](https://openjusticeok.github.io/ojoutils/reference/ojo_use_template.md)
  now supports **full interactive mode** - when called without arguments
  in an interactive R session, it prompts for:
  - Project name (with kebab-case validation)
  - Parent directory location
  - Template type (website or report)
- Added support for two distinct templates:
  - `"website"` (default) - Multi-page Quarto website from
    `okpolicy-website-template`
  - `"report"` - Single-page Quarto report from
    `okpolicy-report-template`
- New
  [`cli_yeah()`](https://openjusticeok.github.io/ojoutils/reference/cli_yeah.md)
  helper function for interactive yes/no confirmations with styled cli
  output

### Improvements

- Template validation uses
  [`rlang::arg_match()`](https://rlang.r-lib.org/reference/arg_match.html)
  for better error messages
- Friendly template names (“website”, “report”) are mapped internally to
  GitHub repository specs
- Extracted CLI helper functions to `R/cli.R` for reuse across the
  package

## ojoutils 0.2.0 (2026-04-23)

- Adds Google Cloud Storage (GCS) utilities:
  [`gcs_auth_bucket()`](https://openjusticeok.github.io/ojoutils/reference/gcs_auth_bucket.md),
  [`gcs_read_csv()`](https://openjusticeok.github.io/ojoutils/reference/gcs_read_csv.md),
  [`gcs_write_csv()`](https://openjusticeok.github.io/ojoutils/reference/gcs_write_csv.md),
  [`gcs_list_objects()`](https://openjusticeok.github.io/ojoutils/reference/gcs_list_objects.md),
  and
  [`tar_gcs_csv()`](https://openjusticeok.github.io/ojoutils/reference/tar_gcs_csv.md)
  for working with GCS via the arrow package.
- Adds
  [`count_interval()`](https://openjusticeok.github.io/ojoutils/reference/count_interval.md)
  function with Rust and Arrow backend for counting active intervals
  over time periods.
- Adds `README.Rmd` and `README.md` to repo.
- Fixes
  [`ojo_parse_county()`](https://openjusticeok.github.io/ojoutils/reference/ojo_parse_county.md)
  to eliminate dplyr 1.2.0 deprecation warning by replacing
  `case_when()` with if/else statements.

## ojoutils 0.1.3

## ojoutils 0.1.2 (2024-03-12)

- Adds `ojo_use_template` function to make it easier to add a new blank
  Quarto report to a project repository.
- Adds `dir_empty`, styled in [fs](https://fs.r-lib.org) fashion, to
  easily check whether a directory is, well, empty.

## ojoutils 0.1.1 (2023-07-08)

- Adds `ojo_parse_county` function for standardizing Oklahoma county
  names, optionally specifying the case of the result.
- Adds `ojo_counties` object which is a vector of Oklahoma county names
  in lowercase. This is also used internally by `ojo_parse_county`.

## ojoutils 0.1.0 (2023-07-07)

- Adds function `limit` which works like `head` but is helpful for when
  your brain is in SQL mode.
