# Authenticate with Google Cloud Storage

Authenticates with Google Cloud Storage (GCS) using the gargle package
for OAuth2 token fetching, then sets the specified bucket as the global
bucket for subsequent GCS operations.

## Usage

``` r
gcs_auth_bucket(bucket)
```

## Arguments

- bucket:

  Character string. The name of the GCS bucket to set as the global
  bucket for subsequent operations.

## Value

The bucket name (invisibly).

## Details

This function uses
[`gargle::token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.html)
to obtain an OAuth2 token with cloud-platform scope, then authenticates
with `googleCloudStorageR`. It sets the global bucket so that subsequent
GCS operations don't need to specify the bucket parameter repeatedly.

The function returns the bucket name invisibly, making it suitable for
use in pipelines where you want to authenticate and continue processing.

## See also

[`googleCloudStorageR::gcs_auth()`](https://cloudyr.github.io/googleCloudStorageR//reference/gcs_auth.html)
for more authentication options

## Examples

``` r
if (FALSE) { # \dontrun{
# Authenticate and set a specific bucket as global
gcs_auth_bucket("my-project-data")

# Can be used in a pipeline
"my-project-data" |> gcs_auth_bucket()
} # }
```
