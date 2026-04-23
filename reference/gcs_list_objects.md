# List objects in a Google Cloud Storage bucket

Lists all object names in a GCS bucket, optionally filtered by a prefix.
Returns a character vector of object names.

## Usage

``` r
gcs_list_objects(bucket, prefix = NULL)
```

## Arguments

- bucket:

  Character string. The name of the GCS bucket to list objects from.

- prefix:

  Character string (optional). A prefix to filter objects. Only objects
  whose names begin with this prefix will be returned.

## Value

A character vector of object names in the bucket.

## Details

This function wraps
[`googleCloudStorageR::gcs_list_objects()`](https://cloudyr.github.io/googleCloudStorageR//reference/gcs_list_objects.html)
and extracts just the object names as a character vector using
dplyr::pull().

The prefix parameter can be used to filter results to objects within a
specific "folder" or matching a specific pattern. Note that GCS uses a
flat namespace, so prefixes simulate directory structures.

## See also

[`googleCloudStorageR::gcs_list_objects()`](https://cloudyr.github.io/googleCloudStorageR//reference/gcs_list_objects.html)
for full object details

## Examples

``` r
if (FALSE) { # \dontrun{
# List all objects in a bucket
all_objects <- gcs_list_objects("my-project-data")

# List objects in a specific "folder"
csv_files <- gcs_list_objects("my-project-data", prefix = "raw/")

# List objects with a specific prefix
sales_files <- gcs_list_objects("my-project-data", prefix = "sales_2024")
} # }
```
