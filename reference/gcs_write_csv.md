# Write a CSV file to Google Cloud Storage

Writes a data frame to a CSV file in Google Cloud Storage using the
arrow package. Optionally returns metadata about the uploaded object.

## Usage

``` r
gcs_write_csv(data, bucket, object, meta = FALSE)
```

## Arguments

- data:

  A data frame to write to GCS.

- bucket:

  Character string. The name of the GCS bucket to write to.

- object:

  Character string. The destination path for the CSV file within the
  bucket (e.g., "folder/subfolder/filename.csv").

- meta:

  Logical. If `TRUE`, returns a list with object metadata. If `FALSE`
  (default), returns the GCS path invisibly.

## Value

If `meta = TRUE`, a list containing:

- `path`: The full GCS path to the object

- `md5_hash`: The MD5 hash of the uploaded object

- `generation`: The object's generation number

- `size`: The object size in bytes

- `updated`: The last update timestamp

If `meta = FALSE`, the GCS path (invisibly).

## Details

This function uses arrow's CSV writer for efficient writing of data
frames to GCS. The file is written directly to the specified GCS path
without requiring temporary local storage.

When `meta = TRUE`, the function retrieves and returns metadata about
the uploaded object including:

- The GCS path

- MD5 hash for integrity verification

- Generation number for versioning

- File size

- Last updated timestamp

## See also

[`arrow::write_csv_arrow()`](https://arrow.apache.org/docs/r/reference/write_csv_arrow.html)
for write options,
[`googleCloudStorageR::gcs_get_object()`](https://cloudyr.github.io/googleCloudStorageR//reference/gcs_get_object.html)
for metadata retrieval

## Examples

``` r
if (FALSE) { # \dontrun{
# Write a data frame to GCS
gcs_write_csv(mtcars, "my-project-data", "output/mtcars.csv")

# Write and get metadata back
meta <- gcs_write_csv(mtcars, "my-project-data", "output/mtcars.csv", meta = TRUE)
print(meta$md5_hash)

# Use with authentication
gcs_auth_bucket("my-project-data")
gcs_write_csv(my_data, "my-project-data", "processed/results.csv")
} # }
```
