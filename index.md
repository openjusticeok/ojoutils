# ojoutils

[![R-CMD-check](https://github.com/openjusticeok/ojoutils/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/openjusticeok/ojoutils/actions/workflows/R-CMD-check.yaml)

A Collection of Nifty Functions and Objects for OJO Analysts

## Installation

You can install the development version of ojoutils from
[GitHub](https://github.com/) with:

``` r

remotes::install_github("openjusticeok/ojoutils")
```

## Features

### Oklahoma Data

- `ojo_counties` - Vector of Oklahoma county names
- [`ojo_parse_county()`](https://openjusticeok.github.io/ojoutils/reference/ojo_parse_county.md) -
  Standardize Oklahoma county names

### Data Analysis

- [`count_interval()`](https://openjusticeok.github.io/ojoutils/reference/count_interval.md) -
  Count active intervals over time periods using Rust/Arrow backend
- [`limit()`](https://openjusticeok.github.io/ojoutils/reference/limit.md) -
  SQL-style row limiting

### Project Management

- [`ojo_create_project()`](https://openjusticeok.github.io/ojoutils/reference/ojo_create_project.md) -
  Create standardized OJO project from template
- [`ojo_use_template()`](https://openjusticeok.github.io/ojoutils/reference/ojo_use_template.md) -
  Add Quarto report template to project

### Google Cloud Storage (GCS)

- [`gcs_auth_bucket()`](https://openjusticeok.github.io/ojoutils/reference/gcs_auth_bucket.md) -
  Authenticate with GCS and set default bucket
- [`gcs_read_csv()`](https://openjusticeok.github.io/ojoutils/reference/gcs_read_csv.md) -
  Read CSV files from GCS using Arrow
- [`gcs_write_csv()`](https://openjusticeok.github.io/ojoutils/reference/gcs_write_csv.md) -
  Write CSV files to GCS
- [`gcs_list_objects()`](https://openjusticeok.github.io/ojoutils/reference/gcs_list_objects.md) -
  List objects in a GCS bucket
- [`tar_gcs_csv()`](https://openjusticeok.github.io/ojoutils/reference/tar_gcs_csv.md) -
  Create targets pipeline targets for GCS CSVs

## Documentation

See the [package website](https://openjusticeok.github.io/ojoutils/) for
full documentation and vignettes.

## License

GPL (\>= 3)
