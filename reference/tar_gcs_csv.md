# Create a targets pipeline target for writing CSVs to GCS

Creates a targets pipeline target that writes a data frame to Google
Cloud Storage as a CSV file. This is a convenience wrapper around
targets::tar_target() specifically designed for GCS CSV outputs.

## Usage

``` r
tar_gcs_csv(name, data, bucket, object, ...)
```

## Arguments

- name:

  Symbol. The name of the target (unquoted).

- data:

  Expression. The data frame to write to GCS. Can reference upstream
  targets or other R objects.

- bucket:

  Character string. The name of the GCS bucket to write to.

- object:

  Character string. The destination path for the CSV file within the
  bucket.

- ...:

  Additional arguments passed to
  [`targets::tar_target()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A targets target object suitable for use in a `_targets.R` file.

## Details

This function creates a targets target that:

1.  Authenticates with GCS using
    [`gcs_auth_bucket()`](https://openjusticeok.github.io/ojoutils/reference/gcs_auth_bucket.md)

2.  Writes the data to GCS using
    [`gcs_write_csv()`](https://openjusticeok.github.io/ojoutils/reference/gcs_write_csv.md)
    with metadata enabled

3.  Returns the metadata as the target value

The target is created with format = "qs" for efficient serialization of
the metadata list.

The `data` parameter is captured as an expression and evaluated at build
time, allowing you to reference upstream targets or other R objects.

## See also

[`targets::tar_target()`](https://docs.ropensci.org/targets/reference/tar_target.html)
for general target options,
[`gcs_write_csv()`](https://openjusticeok.github.io/ojoutils/reference/gcs_write_csv.md)
for the underlying write operation

## Examples

``` r
if (FALSE) { # \dontrun{
# In your _targets.R file:
library(targets)
library(ojoutils)

tar_plan(
  # Process some data
  tar_target(raw_data, read_csv("input.csv")),
  tar_target(clean_data, clean_my_data(raw_data)),

  # Write to GCS as a target
  tar_gcs_csv(
    gcs_output,
    clean_data,
    bucket = "my-project-data",
    object = "processed/clean_data.csv"
  )
)

# With additional tar_target options
tar_gcs_csv(
  gcs_output,
  processed_data,
  bucket = "my-project-data",
  object = "output/results.csv",
  priority = 1
)
} # }
```
