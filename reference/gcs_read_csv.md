# Read a CSV file from Google Cloud Storage

Reads a CSV file from Google Cloud Storage into a data frame using the
arrow package for efficient reading. Optionally cleans column names
using janitor::clean_names().

## Usage

``` r
gcs_read_csv(bucket, object, clean_names = TRUE)
```

## Arguments

- bucket:

  Character string. The name of the GCS bucket containing the file.

- object:

  Character string. The path to the CSV file within the bucket.

- clean_names:

  Logical. If `TRUE` (default), column names are cleaned using
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html).
  If `FALSE`, original column names are preserved.

## Value

A data frame (tibble) containing the CSV data.

## Details

This function uses arrow's CSV reader which is optimized for performance
and can handle large files efficiently. The GCS path is constructed
using glue for safe string interpolation.

By default, column names are cleaned using janitor::clean_names() to
convert them to snake_case and remove special characters. Set
`clean_names = FALSE` to preserve original column names.

## See also

[`arrow::read_csv_arrow()`](https://arrow.apache.org/docs/r/reference/read_delim_arrow.html)
for reading options,
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
for name cleaning details

## Examples

``` r
if (FALSE) { # \dontrun{
# Read a CSV and clean column names
data <- gcs_read_csv("my-project-data", "raw/customers.csv")

# Read a CSV preserving original column names
data <- gcs_read_csv("my-project-data", "raw/customers.csv", clean_names = FALSE)

# Use with gcs_auth_bucket for authenticated reading
gcs_auth_bucket("my-project-data")
data <- gcs_read_csv("my-project-data", "processed/sales_2024.csv")
} # }
```
